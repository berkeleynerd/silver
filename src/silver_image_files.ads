with Ada.Text_IO;
with SPARK.Big_Integers;
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
   use SPARK.Big_Integers;
   package Counts is new Signed_Conversions (Model.Byte_Count);

   --  Exact byte-level splice, stated independently of the streaming loop.
   --  Count is the number of original bytes already copied. A fragment is
   --  present once the byte at its zero-based insertion offset was copied.
   function Spliced_Prefix
     (Original, Refined : Bytes.Sequence; Plan : Model.Plan;
      Count : Model.Byte_Count) return Boolean is
     (Bytes.Length (Original) = Counts.To_Big_Integer (Count)
      and then Bytes.Length (Refined) = Counts.To_Big_Integer (Count)
        + (if Count > Plan.Declarations_Offset then
             To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)
        + (if Count > Plan.Includes_Offset then
             To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0)
      and then (for all I in Model.Byte_Count range 1 .. Count =>
        Bytes.Get (Refined, Counts.To_Big_Integer (I)
          + (if I > Plan.Declarations_Offset then
               To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion)) else 0)
          + (if I > Plan.Includes_Offset then
               To_Big_Integer (Model.Insertion_Length (Model.Includes_Insertion)) else 0))
        = Bytes.Get (Original, Counts.To_Big_Integer (I)))
      and then (if Count > Plan.Declarations_Offset then
        (for all I in 1 .. Model.Insertion_Length (Model.Declarations_Insertion) =>
          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Declarations_Offset)
            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Declarations_Insertion, I)))
      and then (if Count > Plan.Includes_Offset then
        (for all I in 1 .. Model.Insertion_Length (Model.Includes_Insertion) =>
          Bytes.Get (Refined, Counts.To_Big_Integer (Plan.Includes_Offset)
            + To_Big_Integer (Model.Insertion_Length (Model.Declarations_Insertion))
            + To_Big_Integer (I)) = Model.Insertion_Byte (Model.Includes_Insertion, I))))
     with Ghost => Static,
       Pre => Plan.Declarations_Offset < Plan.Includes_Offset;

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
       Post => (Runtime => (if Plan.Kind = Model.Refine then
         Plan.Declarations_Offset < Plan.Includes_Offset
         and then Plan.Includes_Offset < Plan.Bytes),
         Static => (if Success then Read_Ended and then Files_Closed
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
         and then Read_Bytes = Copied_Bytes and then Rechecked = Plan
         and then Spliced_Prefix (Read_Bytes, Written_Bytes, Plan, Plan.Bytes)));
end Silver_Image_Files;
