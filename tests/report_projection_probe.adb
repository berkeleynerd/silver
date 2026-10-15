with Ada.Command_Line;
with Ada.Sequential_IO;
with Ada.Text_IO;
with Silver_Report_Projection;

procedure Report_Projection_Probe is
   package Bytes is new Ada.Sequential_IO (Character);
   use Silver_Report_Projection;
   Input, Output : Bytes.File_Type;
   Current : State := Initial_State;
   Item : Character;
begin
   Bytes.Open (Input, Bytes.In_File, Ada.Command_Line.Argument (1));
   Bytes.Create (Output, Bytes.Out_File, Ada.Command_Line.Argument (2));
   while not Bytes.End_Of_File (Input) loop
      Bytes.Read (Input, Item);
      declare
         Next : constant Transition := Advance (Current, Item);
      begin
         Current := Next.Following;
         for I in 1 .. Next.Length loop
            Bytes.Write (Output, Next.Bytes (I));
         end loop;
      end;
      exit when Current.Failed;
   end loop;
   Bytes.Close (Input);
   Bytes.Close (Output);
   if Complete (Current) then
      Ada.Text_IO.Put_Line ("accepted");
   else
      Ada.Text_IO.Put_Line ("rejected");
      Ada.Command_Line.Set_Exit_Status (1);
   end if;
end Report_Projection_Probe;
