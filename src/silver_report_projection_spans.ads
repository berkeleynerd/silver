with SPARK.Big_Integers;
with Silver_Report_Projection_Model;

--  Exact byte-interval consequences of the independently defined emissions.
package Silver_Report_Projection_Spans
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   package Model renames Silver_Report_Projection_Model;
   package Bytes renames Model.Byte_Sequences;
   use type Bytes.Sequence;

   function Silent (Raw : Bytes.Sequence; First, Last : Big_Natural) return Boolean is
     (for all I in Raw =>
        (if First <= I and then I <= Last then
          Model.Advance_Spec
            (Model.Scan_State (Raw, I - 1), Bytes.Get (Raw, I)).Length = 0))
     with Pre => First >= 1 and then First <= Last + 1 and then Last <= Bytes.Length (Raw);

   function Retained (Raw : Bytes.Sequence; First, Last : Big_Natural) return Boolean is
     (for all I in Raw =>
        (if First <= I and then I <= Last then
          Model.Advance_Spec
            (Model.Scan_State (Raw, I - 1), Bytes.Get (Raw, I)).Length = 1
          and then Model.Advance_Spec
            (Model.Scan_State (Raw, I - 1), Bytes.Get (Raw, I)).Bytes (1) = Bytes.Get (Raw, I)))
     with Pre => First >= 1 and then First <= Last + 1 and then Last <= Bytes.Length (Raw);

   function Exact_Range (Raw : Bytes.Sequence; First, Last : Big_Natural) return Boolean is
     (Bytes.Length (Model.Scan_Bytes (Raw, Last)) =
        Bytes.Length (Model.Scan_Bytes (Raw, First - 1)) + Last + 1 - First
      and then (for all I in Raw =>
        (if First <= I and then I <= Last then
          Bytes.Get (Model.Scan_Bytes (Raw, Last),
            Bytes.Length (Model.Scan_Bytes (Raw, First - 1)) + I + 1 - First)
          = Bytes.Get (Raw, I))))
     with Pre => First >= 1 and then First <= Last + 1 and then Last <= Bytes.Length (Raw);

   procedure Silent_Range (Raw : Bytes.Sequence; First, Last : Big_Natural)
     with Global => null,
       Pre => First >= 1 and then First <= Last + 1
         and then Last <= Bytes.Length (Raw) and then Silent (Raw, First, Last),
       Post => Model.Scan_Bytes (Raw, Last) = Model.Scan_Bytes (Raw, First - 1),
       Subprogram_Variant => (Decreases => Last + 1 - First);

   procedure Retained_Range (Raw : Bytes.Sequence; First, Last : Big_Natural)
     with Global => null,
       Pre => First >= 1 and then First <= Last + 1
         and then Last <= Bytes.Length (Raw) and then Retained (Raw, First, Last),
       Post => Exact_Range (Raw, First, Last),
       Subprogram_Variant => (Decreases => Last + 1 - First);

   procedure Output_Prefix (Raw : Bytes.Sequence; First, Last : Big_Natural)
     with Global => null,
       Pre => First <= Last and then Last <= Bytes.Length (Raw),
       Post => Model.Scan_Bytes (Raw, First) <= Model.Scan_Bytes (Raw, Last),
       Subprogram_Variant => (Decreases => Last - First);
end Silver_Report_Projection_Spans;
