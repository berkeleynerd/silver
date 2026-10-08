with Silver_Libc;
with Interfaces.C;
with System;

package body Silver_Platform
  with SPARK_Mode => On
is
   use type Interfaces.C.int;
   use type Interfaces.C.char;
   use type Interfaces.C.size_t;
   use type System.Address;

   use Silver_Libc;

   procedure Observed_Get (File : System.Address; Item : out Interfaces.C.int)
     with Pre => Read_Count <= Max_File_Length,
          Post => Read_Ended = (Item = -1)
            and then Read_Bytes (1 .. Read_Count'Old) =
              Read_Bytes'Old (1 .. Read_Count'Old)
            and then (if Item in 0 .. 255 then
              Read_Count = Read_Count'Old + 1
              and then Read_Bytes (Read_Count) = Character'Val (Item)
            else Read_Count = Read_Count'Old)
   is
   begin
      Item := C_Get (File);
      Read_Ended := Item = -1;
      if Item in 0 .. 255 then
         Read_Count := Read_Count + 1;
         Read_Bytes (Read_Count) := Character'Val (Item);
      end if;
   end Observed_Get;

   procedure Observed_Put
     (File : System.Address; Item : Interfaces.C.int; Status : out Interfaces.C.int)
     with Pre => Item in 0 .. 255 and then Written_Count < Max_File_Length,
          Post => Written_Bytes (1 .. Written_Count'Old) =
              Written_Bytes'Old (1 .. Written_Count'Old)
            and then (if Status = Item then
              Written_Count = Written_Count'Old + 1
              and then Written_Bytes (Written_Count) = Character'Val (Item)
            else Written_Count = Written_Count'Old)
   is
   begin
      Status := C_Put (Item, File);
      if Status = Item then
         Written_Count := Written_Count + 1;
         Written_Bytes (Written_Count) := Character'Val (Item);
      end if;
   end Observed_Put;

   procedure Read_File
     (Name : String; Buffer : out String; Last : out Natural;
      Too_Long : out Boolean; Success : out Boolean)
   is
      File : System.Address;
      Item, Status : Interfaces.C.int;
      Reached_End : Boolean := False;
   begin
      Buffer := (others => Character'Val (0));
      Last := 0;
      Too_Long := False;
      Success := False;
      Read_Bytes := (others => Character'Val (0));
      Read_Count := 0;
      Read_Ended := False;
      Read_Closed := False;
      File := C_Open (Interfaces.C.To_C (Name), Interfaces.C.To_C ("rb"));
      if File = System.Null_Address then
         return;
      end if;

      Success := True;
      for Index in Buffer'Range loop
         pragma Loop_Invariant (Last = Index - 1 and then Read_Count = Last);
         pragma Loop_Invariant (Buffer (1 .. Last) = Read_Bytes (1 .. Read_Count));
         Observed_Get (File, Item);
         if Item = -1 then
            Status := C_Error (File);
            Success := Status = 0;
            Reached_End := True;
            exit;
         elsif Item not in 0 .. 255 then
            Success := False;
            exit;
         end if;
         Buffer (Index) := Character'Val (Item);
         Last := Index;
      end loop;

      if Success and then not Reached_End then
         Observed_Get (File, Item);
         if Item = -1 then
            Status := C_Error (File);
            Success := Status = 0;
         elsif Item in 0 .. 255 then
            Too_Long := True;
         else
            Success := False;
         end if;
      end if;
      Status := C_Close (File);
      Read_Closed := Status = 0;
      Success := Success and then Status = 0;
   end Read_File;

   procedure Write_File (Name : String; Contents : String; Success : out Boolean)
   is
      File : System.Address;
      Status : Interfaces.C.int;
   begin
      Success := False;
      Written_Bytes := (others => Character'Val (0));
      Written_Count := 0;
      Write_Closed := False;
      File := C_Open (Interfaces.C.To_C (Name), Interfaces.C.To_C ("wb"));
      if File = System.Null_Address then
         return;
      end if;
      Success := True;
      for Index in Contents'Range loop
         pragma Loop_Invariant (Written_Count = Index - Contents'First);
         pragma Loop_Invariant
           (for all Offset in 1 .. Written_Count =>
             Written_Bytes (Offset) = Contents (Contents'First + (Offset - 1)));
         Observed_Put
           (File, Interfaces.C.int (Character'Pos (Contents (Index))), Status);
         if Status /= Interfaces.C.int (Character'Pos (Contents (Index))) then
            Success := False;
            exit;
         end if;
      end loop;
      Status := C_Close (File);
      Write_Closed := Status = 0;
      Success := Success and then Status = 0;
   end Write_File;

   procedure Run (Command : String; Success : out Boolean) is
      Status : Interfaces.C.int;
   begin
      Status := C_System (Interfaces.C.To_C (Command));
      Command_Text := (others => Character'Val (0));
      Command_Length := Command'Length;
      Command_Text (1 .. Command_Length) := Command;
      Command_Status := Status;
      Success := Status = 0;
   end Run;

   procedure Create_Workspace (Name : out Workspace_Path; Success : out Boolean) is
      Prefix : constant String := Workspace_Prefix;
      Template : Interfaces.C.char_array := Interfaces.C.To_C (Prefix & "XXXXXX");
      Result : System.Address;
      Status : Interfaces.C.int;
   begin
      Name := (others => ' ');
      Success := False;
      Status := C_Mkdir (Interfaces.C.To_C (".silver"), 8#700#);
      --  An existing parent is normal. mkdtemp will report failure if the
      --  parent is inaccessible or is not a directory.
      if Status /= 0 and then Status /= -1 then
         return;
      end if;
      Status := C_Mkdir (Interfaces.C.To_C (Silver_Build.Root_Directory), 8#700#);
      if Status /= 0 and then Status /= -1 then
         return;
      end if;
      Result := C_Mkdtemp (Template);
      if Result = System.Null_Address
        or else Template (Template'Last) /= Interfaces.C.nul
      then
         return;
      end if;
      for Index in Name'Range loop
         Name (Index) := Interfaces.C.To_Ada (Template (Interfaces.C.size_t (Index - 1)));
      end loop;
      --  Check the returned path before it can be used in any command.
      Success := Name (1 .. Prefix'Last) = Prefix
        and then (for all Item of Name =>
          Item in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '.' | '/' | '-' | '_')
        and then (for all Index in Prefix'Last + 1 .. Name'Last =>
          Name (Index) in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9');
   end Create_Workspace;
end Silver_Platform;
