with Ada.Text_IO;
with Silver_Platform;
with Silver_Library_Reports;
with Silver_Report_Reader;

package Silver_Libraries with SPARK_Mode => On is
   Max_Source_Length : constant Positive := 16_384;
   type Unit_Kind is
     (IO_Specification, IO_Implementation, Imported_Interface,
      Arguments_Specification, Arguments_Implementation, Runtime_Interface);
   subtype Source_Buffer is String (1 .. Max_Source_Length);
   subtype Source_Length is Natural range 0 .. Max_Source_Length;
   type Buffer_Array is array (Unit_Kind) of Source_Buffer;
   type Length_Array is array (Unit_Kind) of Source_Length;
   type Source_Set is record
      Bytes : Buffer_Array;
      Lengths : Length_Array;
   end record;

   function Complete (Sources : Source_Set) return Boolean is
     (for all Kind in Unit_Kind => Sources.Lengths (Kind) > 0);
   function Same_Bytes (Left, Right : Source_Set) return Boolean is
     (Left.Lengths = Right.Lengths
      and then (for all Kind in Unit_Kind =>
        Left.Bytes (Kind) (1 .. Left.Lengths (Kind)) = Right.Bytes (Kind) (1 .. Right.Lengths (Kind))));
   function Valid_Directory (Directory : String) return Boolean is
     (Directory'First = 1 and then Silver_Platform.Valid_Path (Directory)
      and then Directory'Length <= Silver_Platform.Max_Path_Length - 23);
   function File_Name (Kind : Unit_Kind) return String
     with Global => null,
          Post => File_Name'Result'First = 1
            and then File_Name'Result'Length in 13 .. 22
            and then (for all Item of File_Name'Result => Item /= Character'Val (0));
   function Expected_Source (Kind : Unit_Kind) return String
     with Global => null,
          Post => Expected_Source'Result'First = 1
            and then Expected_Source'Result'Length in 1 .. Max_Source_Length;
   function Bound_To_Compiler (Sources : Source_Set) return Boolean is
     (for all Kind in Unit_Kind =>
        Sources.Bytes (Kind) (1 .. Sources.Lengths (Kind)) = Expected_Source (Kind));

   --  These observations come from actual returned read/write results.
   Captured, Checked : Source_Set :=
     (Bytes => (others => (others => Character'Val (0))), Lengths => (others => 0))
     with Ghost => Static;
   type Evidence_Array is array (Silver_Library_Reports.Report_Kind) of Boolean;
   Accepted_Reports : Evidence_Array := (others => False) with Ghost => Static;
   type Raw_Report_Array is array (Silver_Library_Reports.Report_Kind)
     of Silver_Report_Reader.Model.Byte_Sequences.Sequence with Ghost => Static;
   Raw_Reports : Raw_Report_Array :=
     (others => Silver_Report_Reader.Model.Byte_Sequences.Empty_Sequence) with Ghost => Static;
   function Audited_Raw_Reports return Boolean is
     (for all Kind in Silver_Library_Reports.Report_Kind =>
       Silver_Library_Reports.Unbounded_Runtime_Report_Policy (Raw_Reports (Kind), Kind))
     with Ghost => Static;
   All_Written, Proof_Complete : Boolean := False with Ghost => Static;


   procedure Check_Proof_Evidence (Directory : String; Success : out Boolean)
     with Global => (In_Out => Ada.Text_IO.File_System,
                     Output => (Silver_Report_Reader.Raw_Bytes,
                                Silver_Report_Reader.Projected_Bytes,
                                Silver_Report_Reader.Report_Bytes,
                                Silver_Report_Reader.Report_Length,
                                Silver_Report_Reader.Report_State,
                                Silver_Report_Reader.Report_Ended,
                                Silver_Report_Reader.Report_Closed,
                                Proof_Complete, Accepted_Reports, Raw_Reports)),
          Pre => Valid_Directory (Directory)
            and then Directory'Length <= Silver_Platform.Max_Path_Length - 45,
          Post => (Static => Success = Proof_Complete
            and then (if Success then Audited_Raw_Reports
              and then (for all Kind in Silver_Library_Reports.Report_Kind => Accepted_Reports (Kind))));

   procedure Same_Sources
     (Directory : String; Expected : Source_Set; Success : out Boolean)
     with Global => (In_Out => Ada.Text_IO.File_System,
                     Output => (Silver_Platform.Read_Bytes, Silver_Platform.Read_Count,
                                Silver_Platform.Read_Ended, Silver_Platform.Read_Closed,
                                Checked)),
          Pre => Valid_Directory (Directory) and then Complete (Expected),
          Post => (Static => (if Success then Same_Bytes (Checked, Expected)
            and then Bound_To_Compiler (Checked) = Bound_To_Compiler (Expected)));

   procedure Capture_And_Snapshot
     (Directory : String; Sources : out Source_Set; Success : out Boolean)
     with Global => (In_Out => (Ada.Text_IO.File_System,
                                Silver_Platform.Read_Bytes, Silver_Platform.Read_Count,
                                Silver_Platform.Read_Ended, Silver_Platform.Read_Closed,
                                Silver_Platform.Written_Bytes, Silver_Platform.Written_Count,
                                Silver_Platform.Write_Closed),
                     Output => (Captured, Checked, All_Written)),
          Pre => Valid_Directory (Directory),
          Post => (Runtime => Complete (Sources) = Success,
                   Static => (if Success then
                     Same_Bytes (Captured, Sources) and then Same_Bytes (Checked, Sources)
                     and then Bound_To_Compiler (Sources) and then All_Written));
end Silver_Libraries;
