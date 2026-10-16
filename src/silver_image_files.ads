with Ada.Text_IO;
with SPARK.Containers.Functional.Infinite_Sequences;
with Silver_Image_Model;
with Silver_Platform;

package Silver_Image_Files with SPARK_Mode => On is
   package Model renames Silver_Image_Model;
   use type Model.Plan;
   use type Model.Plan_Kind;
   use type Model.Byte_Count;
   package Bytes is new SPARK.Containers.Functional.Infinite_Sequences
     (Element_Type => Character, Use_Logical_Equality => True);
   use type Bytes.Sequence;

   --  Observations of successful libc byte operations. These do not add a
   --  finite input-buffer limit or execute in the adapter binary.
   Read_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;
   Copied_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;
   Written_Bytes : Bytes.Sequence := Bytes.Empty_Sequence with Ghost => Static;
   Read_Ended, Files_Closed : Boolean := False with Ghost => Static;
   Rechecked : Model.Plan := (others => <>) with Ghost => Static;

   procedure Snapshot
     (Input_Name, Snapshot_Name : String;
      Plan : out Model.Plan; Success : out Boolean)
     with Global => (In_Out => Ada.Text_IO.File_System,
       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,
                  Files_Closed, Rechecked)),
       Pre => Silver_Platform.Valid_Path (Input_Name)
         and then Silver_Platform.Valid_Path (Snapshot_Name)
         and then Input_Name /= Snapshot_Name,
       Post => (Static => (if Success then Read_Ended and then Files_Closed
         and then Read_Bytes = Copied_Bytes and then Read_Bytes = Written_Bytes
         and then Plan = Rechecked));

   procedure Refine
     (Snapshot_Name, Refined_Name : String;
      Plan : Model.Plan; Success : out Boolean)
     with Global => (In_Out => Ada.Text_IO.File_System,
       Output => (Read_Bytes, Copied_Bytes, Written_Bytes, Read_Ended,
                  Files_Closed, Rechecked)),
       Pre => Silver_Platform.Valid_Path (Snapshot_Name)
         and then Silver_Platform.Valid_Path (Refined_Name)
         and then Snapshot_Name /= Refined_Name
         and then Plan.Kind = Model.Refine
         and then Plan.Declarations_Offset < Plan.Includes_Offset
         and then Plan.Includes_Offset < Plan.Bytes,
       Post => (Static => (if Success then Read_Ended and then Files_Closed
         and then Read_Bytes = Copied_Bytes and then Rechecked = Plan));
end Silver_Image_Files;
