with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Values;
with Silver_Report_Observation_Windows;
with Silver_Report_Observations;

--  An accepted original value can be copied into an enclosing scanner with
--  at least the original depth headroom and an arbitrary following suffix.
package Silver_Report_Projection_Continuations
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;
   package Values renames Silver_Report_Projection_Values;
   package Windows renames Silver_Report_Observation_Windows;
   package Observations renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;

   procedure Retained_Value_Skip
     (Raw, Target : Bytes.Sequence; First, Last, Outer_Start : Big_Natural;
      Shift : Big_Integer; Openers : Observations.Nesting;
      Level : Observations.Nesting_Level)
     with Global => null,
       Pre => Values.Ready (Raw, First)
         and then Observations.Value_Spec (Raw, First) = Last
         and then Windows.Same_Window (Raw, Target, First, Last, Shift)
         and then Outer_Start >= 1 and then Outer_Start <= First + Shift
         and then Level > 0
         and then Level <= Model.Scan_State (Raw, First - 1).Depth,
       Post => Observations.Value_From
         (Target, Outer_Start, First + Shift, Openers, Level, False, False, True) =
           Observations.Value_From
         (Target, Outer_Start, Last + Shift + 1, Openers, Level, False, False, True);
end Silver_Report_Projection_Continuations;
