with Ada.Text_IO;
with Interfaces.C;
with Silver_Build;

package Silver_Platform
  with SPARK_Mode => On
is
   Max_Path_Length : constant Positive := 4_096;
   Max_File_Length : constant Positive := 2_097_152;

   --  Observations of the actual libc calls, checked statically and erased
   --  from executable code even when runtime assertions are enabled.
   --  A read may observe one extra byte to detect an oversized input.
   Read_Bytes : String (1 .. Max_File_Length + 1) := (others => Character'Val (0))
     with Ghost => Static;
   Read_Count : Natural range 0 .. Max_File_Length + 1 := 0 with Ghost => Static;
   Read_Ended, Read_Closed : Boolean := False with Ghost => Static;
   Written_Bytes : String (1 .. Max_File_Length) := (others => Character'Val (0))
     with Ghost => Static;
   Written_Count : Natural range 0 .. Max_File_Length := 0 with Ghost => Static;
   Write_Closed : Boolean := False with Ghost => Static;
   Command_Text : String (1 .. 16_384) := (others => Character'Val (0)) with Ghost => Static;
   Command_Length : Natural range 0 .. 16_384 := 0 with Ghost => Static;
   Command_Status : Interfaces.C.int := 0 with Ghost => Static;

   function Valid_Path (Name : String) return Boolean is
     (Name'Length in 1 .. Max_Path_Length
      and then (for all Item of Name => Item /= Character'Val (0)));

   procedure Read_File
     (Name : String; Buffer : out String; Last : out Natural;
      Too_Long : out Boolean; Success : out Boolean)
     with Global => (In_Out => Ada.Text_IO.File_System,
                     Output => (Read_Bytes, Read_Count, Read_Ended, Read_Closed)),
          Pre => Valid_Path (Name) and then Buffer'First = 1
            and then Buffer'Length in 1 .. Max_File_Length,
          Post => (Runtime => Last <= Buffer'Length,
                   Static => Last <= Buffer'Length
            and then (if Success and then not Too_Long then
              Read_Ended and then Read_Closed and then Last = Read_Count
              and then Buffer (1 .. Last) = Read_Bytes (1 .. Read_Count)));

   procedure Write_File (Name : String; Contents : String; Success : out Boolean)
     with Global => (In_Out => Ada.Text_IO.File_System,
                     Output => (Written_Bytes, Written_Count, Write_Closed)),
          Pre => Valid_Path (Name)
            and then Contents'Length <= Max_File_Length,
          Post => (Static => (if Success then Write_Closed
            and then Written_Count = Contents'Length
            and then Written_Bytes (1 .. Written_Count) = Contents));

   procedure Run (Command : String; Success : out Boolean)
     with Global => (In_Out => Ada.Text_IO.File_System,
                     Output => (Command_Text, Command_Length, Command_Status)),
          Pre => Command'Length in 1 .. 16_384
            and then (for all Item of Command => Item /= Character'Val (0)),
          Post => (Static => Command_Length = Command'Length
            and then Command_Text (1 .. Command_Length) = Command
            and then Success = (Interfaces.C."=" (Command_Status, 0)));

   Workspace_Prefix : constant String := Silver_Build.Root_Directory & "/program-";
   subtype Workspace_Path is String (1 .. Workspace_Prefix'Length + 6);
   procedure Create_Workspace (Name : out Workspace_Path; Success : out Boolean)
     with Global => (In_Out => Ada.Text_IO.File_System),
          Post => (if Success then Valid_Path (Name)
                   and then Name (1 .. Workspace_Prefix'Length) = Workspace_Prefix
                   and then (for all Index in Workspace_Prefix'Last + 1 .. Name'Last =>
                     Name (Index) in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9'));
end Silver_Platform;
