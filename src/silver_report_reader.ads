with Ada.Text_IO;
with Silver_Platform;
with Silver_Report_Projection;
with Silver_Report_Projection_Model;

package Silver_Report_Reader with SPARK_Mode => On is
   package Model renames Silver_Report_Projection_Model;
   Raw_Bytes : Model.Byte_Sequences.Sequence := Model.Byte_Sequences.Empty_Sequence
     with Ghost => Static;
   Projected_Bytes : Model.Byte_Sequences.Sequence := Model.Byte_Sequences.Empty_Sequence
     with Ghost => Static;
   --  These observations describe the bounded projection, not a truncated
   --  prefix of the original report. The original stream is consumed to EOF.
   Report_Bytes : String (1 .. Silver_Platform.Max_File_Length) :=
     (others => Character'Val (0)) with Ghost => Static;
   Report_Length : Natural range 0 .. Silver_Platform.Max_File_Length := 0
     with Ghost => Static;
   Report_State : Silver_Report_Projection.State :=
     Silver_Report_Projection.Initial_State with Ghost => Static;
   Report_Ended, Report_Closed : Boolean := False with Ghost => Static;

   procedure Read_Report
     (Name : String; Buffer : out String; Last : out Natural;
      Too_Long : out Boolean; Success : out Boolean)
     with Global => (In_Out => Ada.Text_IO.File_System,
       Output => (Raw_Bytes, Projected_Bytes, Report_Bytes, Report_Length,
                  Report_State, Report_Ended, Report_Closed)),
       Pre => Silver_Platform.Valid_Path (Name) and then Buffer'First = 1
         and then Buffer'Length in 1 .. Silver_Platform.Max_File_Length,
       Post => (Runtime => Last <= Buffer'Length,
         Static => Last <= Buffer'Length
           and then (if Success then not Too_Long
             and then Report_Ended and then Report_Closed
             and then Silver_Report_Projection.Complete (Report_State)
             and then Model.Refines (Raw_Bytes, Projected_Bytes, Report_State)
             and then Model.Matches (Projected_Bytes, Buffer, Last)
             and then Last = Report_Length
             and then Buffer (1 .. Last) = Report_Bytes (1 .. Report_Length)));
end Silver_Report_Reader;
