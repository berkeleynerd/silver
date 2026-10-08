with Ada.Text_IO;
with Silver_Platform;
with Silver_Library_Reports;

package Silver_Libraries with SPARK_Mode => On is
   Max_Source_Length : constant Positive := 16_384;
   type Unit_Kind is (IO_Specification, IO_Implementation, Imported_Interface);
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

   --  These observations come from actual returned read/write results.
   Captured, Checked : Source_Set :=
     (Bytes => (others => (others => Character'Val (0))), Lengths => (others => 0))
     with Ghost => Static;
   type Evidence_Array is array (Silver_Library_Reports.Report_Kind) of Boolean;
   Accepted_Reports : Evidence_Array := (others => False) with Ghost => Static;
   All_Written, Proof_Complete : Boolean := False with Ghost => Static;


   procedure Check_Proof_Evidence (Directory : String; Success : out Boolean)
     with Global => (In_Out => Ada.Text_IO.File_System,
                     Output => (Silver_Platform.Read_Bytes, Silver_Platform.Read_Count,
                                Silver_Platform.Read_Ended, Silver_Platform.Read_Closed,
                                Proof_Complete, Accepted_Reports)),
          Pre => Valid_Directory (Directory)
            and then Directory'Length <= Silver_Platform.Max_Path_Length - 45,
          Post => (Static => Success = Proof_Complete
            and then (if Success then (for all Kind in Silver_Library_Reports.Report_Kind => Accepted_Reports (Kind))));

   procedure Same_Sources
     (Directory : String; Expected : Source_Set; Success : out Boolean)
     with Global => (In_Out => Ada.Text_IO.File_System,
                     Output => (Silver_Platform.Read_Bytes, Silver_Platform.Read_Count,
                                Silver_Platform.Read_Ended, Silver_Platform.Read_Closed,
                                Checked)),
          Pre => Valid_Directory (Directory) and then Complete (Expected),
          Post => (Static => (if Success then Same_Bytes (Checked, Expected)));

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
                     and then All_Written));
end Silver_Libraries;
