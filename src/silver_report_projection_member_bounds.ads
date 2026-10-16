with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Values;
with Silver_Report_Projection_Keys;
with Silver_Report_Projection_Spans;
with Silver_Report_Observations;

package Silver_Report_Projection_Member_Bounds
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;
   package Values renames Silver_Report_Projection_Values;
   package Keys renames Silver_Report_Projection_Keys;
   package Spans renames Silver_Report_Projection_Spans;
   package Observations renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;

   function Container_At
     (Raw : Bytes.Sequence; Bounds : Observations.Span; Kind : Container_Kind)
      return Boolean is
     (Observations.Valid (Raw, Bounds) and then Values.Ready (Raw, Bounds.First)
      and then Bytes.Get (Raw, Bounds.First) =
        (if Kind = Object_Container then '{' else '[')
      and then Bounds.Last = Observations.Value_Spec (Raw, Bounds.First));

   function Cursor_Ready
     (Raw : Bytes.Sequence; Bounds : Observations.Span; Position : Big_Natural;
      Kind : Container_Kind) return Boolean is
     (Container_At (Raw, Bounds, Kind)
      and then Bounds.First < Position and then Position <= Bounds.Last
      and then (Position = Bounds.Last or else
        (declare S : constant State := Model.Scan_State (Raw, Position - 1);
         begin S.Mode = Between_Tokens and then S.Depth > 0
           and then S.Depth = Model.Scan_State (Raw, Bounds.First).Depth
           and then S.Stack (S.Depth).Container = Kind
           and then (if Kind = Object_Container then
             S.Stack (S.Depth).Position in First_Key | Next_Key
             else S.Stack (S.Depth).Position in First_Item | Next_Item))));

   procedure Container_Boundary
     (Raw : Bytes.Sequence; Bounds : Observations.Span; Kind : Container_Kind)
     with Global => null, Pre => Container_At (Raw, Bounds, Kind),
       Post => Bounds.Last > Bounds.First
         and then Model.Scan_State (Raw, Bounds.First).Depth > 0
         and then Model.Scan_State (Raw, Bounds.Last).Depth + 1 =
           Model.Scan_State (Raw, Bounds.First).Depth
         and then Bytes.Get (Raw, Bounds.Last) =
           (if Kind = Object_Container then '}' else ']')
         and then Cursor_Ready (Raw, Bounds, Bounds.First + 1, Kind)
         and then (for all I in Raw =>
           (if Bounds.First < I and then I <= Bounds.Last then
             Model.Scan_State (Raw, I - 1).Depth >= Model.Scan_State (Raw, Bounds.First).Depth));

   procedure Leading_Position
     (Raw : Bytes.Sequence; Bounds : Observations.Span;
      Position : Big_Natural; Kind : Container_Kind)
     with Global => null, Pre => Cursor_Ready (Raw, Bounds, Position, Kind),
       Post => Observations.Space_End (Raw, Position) <= Bounds.Last
         and then Cursor_Ready (Raw, Bounds, Observations.Space_End (Raw, Position), Kind)
         and then (if Observations.Space_End (Raw, Position) < Bounds.Last then
           Model.Scan_State (Raw, Observations.Space_End (Raw, Position) - 1) =
             Model.Scan_State (Raw, Position - 1))
         and then not Observations.Space (Bytes.Get (Raw, Observations.Space_End (Raw, Position)))
         and then (if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
           Spans.Retained (Raw, Position, Observations.Space_End (Raw, Position) - 1));

   procedure Value_Before_End
     (Raw : Bytes.Sequence; Bounds : Observations.Span;
      Start : Big_Natural; Kind : Container_Kind)
     with Global => null,
       Pre => Container_At (Raw, Bounds, Kind) and then Values.Ready (Raw, Start)
         and then Bounds.First < Start and then Start < Bounds.Last
         and then Model.Scan_State (Raw, Start - 1).Depth =
           Model.Scan_State (Raw, Bounds.First).Depth,
       Post => Observations.Value_Spec (Raw, Start) < Bounds.Last;

   procedure Key_Before_End
     (Raw : Bytes.Sequence; Object : Observations.Span; Start : Big_Natural)
     with Global => null,
       Pre => Cursor_Ready (Raw, Object, Start, Object_Container)
         and then Start < Object.Last and then Bytes.Get (Raw, Start) = '"',
       Post => Observations.Value_Spec (Raw, Start) < Object.Last;
end Silver_Report_Projection_Member_Bounds;
