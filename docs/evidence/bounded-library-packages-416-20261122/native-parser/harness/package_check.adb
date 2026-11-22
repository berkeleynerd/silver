with Ada.Command_Line;
with Ada.Streams;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;
with Silver_Application_Units;
with Silver_Output_Profile;
procedure Package_Check is
   package IO renames Ada.Streams.Stream_IO;
   use type Ada.Streams.Stream_Element_Offset;
   function Read (Path : String) return String is
      File : IO.File_Type;
   begin
      IO.Open (File, IO.In_File, Path);
      declare
         Size : constant Ada.Streams.Stream_Element_Offset := Ada.Streams.Stream_Element_Offset (IO.Size (File));
         Data : Ada.Streams.Stream_Element_Array (1 .. Size);
         Last : Ada.Streams.Stream_Element_Offset;
         Text : String (1 .. Natural (Size));
      begin
         IO.Read (File, Data, Last);
         IO.Close (File);
         for I in Text'Range loop Text (I) := Character'Val (Data (Ada.Streams.Stream_Element_Offset (I))); end loop;
         return Text;
      end;
   end Read;
begin
   declare
      Spec : constant String := Read (Ada.Command_Line.Argument (1));
      Body_Source : constant String := Read (Ada.Command_Line.Argument (2));
      Main : constant String := Read (Ada.Command_Line.Argument (3));
   begin
      if not Silver_Application_Units.Fits (Spec, Body_Source, Main) then
         Ada.Command_Line.Set_Exit_Status (2);
         return;
      end if;
      declare Result : constant Silver_Output_Profile.Analysis_Result :=
        Silver_Output_Profile.Analyze (Silver_Application_Units.Pack (Spec, Body_Source, Main));
      begin
         if not Result.Accepted then
            Ada.Text_IO.Put_Line ("REJECTED");
            Ada.Command_Line.Set_Exit_Status (2);
         else
            Ada.Text_IO.Put_Line ("ACCEPTED" & Result.Package_Info.Routine_Count'Image);
            for I in 1 .. Result.Package_Info.Routine_Count loop
               Ada.Text_IO.Put ("Routine" & I'Image & " reads");
               for S in 1 .. Result.Package_Info.State_Count loop
                  if Result.Package_Info.Routines (I).May_Read (S) then Ada.Text_IO.Put (S'Image); end if;
               end loop;
               Ada.Text_IO.Put (" writes");
               for S in 1 .. Result.Package_Info.State_Count loop
                  if Result.Package_Info.Routines (I).May_Write (S) then Ada.Text_IO.Put (S'Image); end if;
               end loop;
               Ada.Text_IO.New_Line;
            end loop;
         end if;
      end;
   end;
end Package_Check;
