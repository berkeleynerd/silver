with Interfaces.C;
with System;
with Silver_Libc;
with Silver_Image_Libc;

package body Silver_Image_Install with SPARK_Mode => On is
   use type Interfaces.C.int;
   use type Interfaces.C.char;
   use type Interfaces.C.size_t;
   use type System.Address;
   use Silver_Platform;
   use Silver_Libc;

   procedure Ensure_Theory (Directory : String; Success : out Boolean) is
      Root : constant String (1 .. Directory'Length) := Directory;
      Theories : constant String := Root & "/_theories";
      Destination : constant String := Theories & "/silver_image.mlw";
      Prefix : constant String := Theories & "/image-";
      Template : Interfaces.C.char_array := Interfaces.C.To_C (Prefix & "XXXXXX");
      Private_Directory : String (1 .. Prefix'Length + 6);
      Result : System.Address;
      Status : Interfaces.C.int;
      Observed : String (1 .. Silver_Image_Theory.Theory_Text'Length);
      Last : Natural;
      Too_Long, Read_OK : Boolean;
   begin
      Success := False;
      Written_Bytes := (others => Character'Val (0));
      Written_Count := 0;
      Write_Closed := False;
      Read_File (Destination, Observed, Last, Too_Long, Read_OK);
      if Read_OK then
         Success := not Too_Long and then Last = Observed'Length
           and then Observed = Silver_Image_Theory.Theory_Text;
         return;
      end if;
      Status := C_Mkdir (Interfaces.C.To_C (Directory), 8#700#);
      if Status /= 0 and then Status /= -1 then return; end if;
      Status := C_Mkdir (Interfaces.C.To_C (Root & "/sessions"), 8#700#);
      if Status /= 0 and then Status /= -1 then return; end if;
      Status := C_Mkdir (Interfaces.C.To_C (Theories), 8#700#);
      if Status /= 0 and then Status /= -1 then return; end if;
      Result := C_Mkdtemp (Template);
      if Result = System.Null_Address
        or else Template (Template'Last) /= Interfaces.C.nul
      then
         return;
      end if;
      for Index in Private_Directory'Range loop
         pragma Loop_Invariant (Template'First = 0
           and then Template'Last = Interfaces.C.size_t (Private_Directory'Last));
         Private_Directory (Index) :=
           Interfaces.C.To_Ada (Template (Interfaces.C.size_t (Index - 1)));
      end loop;
      if not Valid_Path (Private_Directory)
        or else Private_Directory (1 .. Prefix'Length) /= Prefix
        or else not (for all Index in Prefix'Length + 1 .. Private_Directory'Last =>
          Private_Directory (Index) in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9')
      then
         return;
      end if;
      declare
         Staged : constant String := Private_Directory & "/silver_image.mlw";
      begin
         if not Valid_Path (Staged) then return; end if;
         Write_File (Staged, Silver_Image_Theory.Theory_Text, Success);
         if not Success then return; end if;
         Status := Silver_Image_Libc.C_Link
           (Interfaces.C.To_C (Staged), Interfaces.C.To_C (Destination));
         Success := False;
         if Status /= 0 and then Status /= -1 then return; end if;
      end;
      --  A concurrent publisher may already have installed the same theorem.
      --  link never replaces a conflicting file. Validate the complete selected
      --  file regardless of which invocation published it.
      if not Valid_Path (Destination) then return; end if;
      Read_File (Destination, Observed, Last, Too_Long, Read_OK);
      Success := Read_OK and then not Too_Long and then Last = Observed'Length
        and then Observed = Silver_Image_Theory.Theory_Text;
   end Ensure_Theory;
end Silver_Image_Install;
