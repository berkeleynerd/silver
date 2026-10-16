with Ada.Command_Line;
with Ada.Streams.Stream_IO;
with Ada.Text_IO;
with Silver_Image_Model;

procedure Image_Model_Probe is
   package Model renames Silver_Image_Model;
   package IO renames Ada.Streams.Stream_IO;
   Input : IO.File_Type;
   Data : Ada.Streams.Stream_Element_Array (1 .. 1);
   Last : Ada.Streams.Stream_Element_Offset;
   Current : Model.State := Model.Initial_State;
   Plan : Model.Plan;
begin
   IO.Open (Input, IO.In_File, Ada.Command_Line.Argument (1));
   while not IO.End_Of_File (Input) loop
      IO.Read (Input, Data, Last);
      Model.Consume (Current, Character'Val (Data (1)));
   end loop;
   IO.Close (Input);
   Plan := Model.Finish (Current);
   Ada.Text_IO.Put_Line (Model.Plan_Kind'Image (Plan.Kind));
   Ada.Text_IO.Put_Line (Model.Byte_Count'Image (Plan.Bytes));
   Ada.Text_IO.Put_Line (Model.Original_Node_Id'Image (Plan.Greatest_Id));
   for Kind in Model.Insertion_Kind loop
      for Position in 1 .. Model.Insertion_Length (Kind) loop
         Ada.Text_IO.Put (Model.Insertion_Byte (Kind, Position));
      end loop;
      Ada.Text_IO.New_Line;
   end loop;
end Image_Model_Probe;
