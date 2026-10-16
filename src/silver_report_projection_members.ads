with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Values;
with Silver_Report_Projection_Member_Bounds;
with Silver_Report_Projection_Keys;
with Silver_Report_Projection_Spans;
with Silver_Report_Observations;

package Silver_Report_Projection_Members
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
   use type Observations.Member_State;

   package Bounds renames Silver_Report_Projection_Member_Bounds;
   function Container_At
     (Raw : Bytes.Sequence; Bounds : Observations.Span; Kind : Container_Kind)
      return Boolean renames Silver_Report_Projection_Member_Bounds.Container_At;
   function Cursor_Ready
     (Raw : Bytes.Sequence; Bounds : Observations.Span; Position : Big_Natural;
      Kind : Container_Kind) return Boolean renames Silver_Report_Projection_Member_Bounds.Cursor_Ready;

   procedure Member_Context
     (Raw : Bytes.Sequence; Object : Observations.Span; Position : Big_Natural)
     with Global => null,
       Pre => Cursor_Ready (Raw, Object, Position, Object_Container),
       Post =>
         (declare M : constant Observations.Member :=
            Observations.Member_Spec (Raw, Object, Position);
          begin M.State /= Observations.Broken
            and then (if M.State = Observations.Finished then
              Observations.Space_End (Raw, Position) = Object.Last
              and then (if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
                Spans.Retained (Raw, Position, Object.Last)))
            and then (if M.State = Observations.Present then
              M.Value.First >= Position and then M.Next >= M.Value.Last + 1
              and then Values.Ready (Raw, M.Value.First)
              and then Model.Scan_State (Raw, M.Value.First - 1).Depth > 0
              and then Cursor_Ready (Raw, Object, M.Next, Object_Container)
              and then Model.Scan_State (Raw, M.Value.First - 1).Depth =
                Model.Scan_State (Raw, Object.First).Depth
              and then Model.Scan_State (Raw, M.Value.First - 1).Stack
                (Model.Scan_State (Raw, M.Value.First - 1).Depth).Key =
                  Keys.Raw_Key (Raw, M.Key.First, M.Key.Last)
              and then Keys.Frames_Preserved
                (Model.Scan_State (Raw, Position - 1),
                 Model.Scan_State (Raw, M.Value.First - 1),
                 Model.Scan_State (Raw, Object.First).Depth)
              and then Keys.Frames_Preserved
                (Model.Scan_State (Raw, Position - 1),
                 Model.Scan_State (Raw, M.Next - 1),
                 Model.Scan_State (Raw, Object.First).Depth)
              and then (if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
                Spans.Retained (Raw, Position, M.Value.First - 1)
                and then Spans.Retained (Raw, M.Value.Last + 1, M.Next))));

   function Any_Item_Spec (Raw : Bytes.Sequence; Items : Observations.Span; Position : Big_Natural)
     return Observations.Member is
     (declare P : constant Big_Natural := Observations.Space_End (Raw, Position);
      begin
        (if P = Items.Last then Observations.End_Member
         elsif P >= Items.Last then Observations.Bad_Member
         else
           (declare L : constant Big_Natural := Observations.Value_Spec (Raw, P);
            begin
              (if L = 0 or else L >= Items.Last then Observations.Bad_Member
               else
                 (declare T : constant Big_Natural := Observations.Space_End (Raw, L + 1);
                  begin
                    (if T = Items.Last then (Observations.Present, Observations.Missing, (P, L), T)
                     elsif T >= Items.Last or else Bytes.Get (Raw, T) /= ',' then Observations.Bad_Member
                     else
                       (declare N : constant Big_Natural := Observations.Space_End (Raw, T + 1);
                        begin
                          (if N >= Items.Last then Observations.Bad_Member
                           else (Observations.Present, Observations.Missing, (P, L), N)))))))))
     with Pre => Observations.Valid (Raw, Items)
       and then Position >= Items.First + 1 and then Position <= Bytes.Length (Raw) + 1;

   procedure Any_Item_Context
     (Raw : Bytes.Sequence; Items : Observations.Span; Position : Big_Natural)
     with Global => null,
       Pre => Cursor_Ready (Raw, Items, Position, Array_Container),
       Post =>
         (declare M : constant Observations.Member := Any_Item_Spec (Raw, Items, Position);
                  P : constant Big_Natural := Observations.Space_End (Raw, Position);
          begin M.State /= Observations.Broken and then P <= Items.Last
            and then (if M.State = Observations.Finished then P = Items.Last
              and then (if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
                Spans.Retained (Raw, Position, Items.Last)))
            and then (if M.State = Observations.Present then
              Observations.Valid (Raw, M.Value)
              and then M.Value.First = P and then M.Value.Last = Observations.Value_Spec (Raw, P)
              and then M.Next >= M.Value.Last + 1 and then M.Next <= Items.Last
              and then Values.Ready (Raw, M.Value.First)
              and then Model.Scan_State (Raw, M.Value.First - 1).Depth > 0
              and then Cursor_Ready (Raw, Items, M.Next, Array_Container)
              and then Model.Scan_State (Raw, M.Value.First - 1).Depth =
                Model.Scan_State (Raw, Items.First).Depth
              and then Keys.Frames_Preserved
                (Model.Scan_State (Raw, Position - 1),
                 Model.Scan_State (Raw, M.Value.First - 1),
                 Model.Scan_State (Raw, Items.First).Depth)
              and then Keys.Frames_Preserved
                (Model.Scan_State (Raw, Position - 1),
                 Model.Scan_State (Raw, M.Next - 1),
                 Model.Scan_State (Raw, Items.First).Depth)
              and then (if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
                Spans.Retained (Raw, Position, M.Value.First - 1)
                and then Spans.Retained (Raw, M.Value.Last + 1, M.Next))));

   procedure Item_Context
     (Raw : Bytes.Sequence; Items : Observations.Span; Position : Big_Natural)
     with Global => null,
       Pre => Cursor_Ready (Raw, Items, Position, Array_Container),
       Post =>
         (declare M : constant Observations.Member :=
            Observations.Item_Spec (Raw, Items, Position);
                  P : constant Big_Natural := Observations.Space_End (Raw, Position);
          begin P <= Items.Last
            and then (if M.State = Observations.Finished then P = Items.Last
              and then (if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
                Spans.Retained (Raw, Position, Items.Last)))
            and then (if M.State = Observations.Broken then P < Items.Last
              and then Bytes.Get (Raw, P) /= '{'
              and then (if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
                Spans.Retained (Raw, Position, P)))
            and then (if M.State = Observations.Present then
              M.Value.First >= Position and then M.Next >= M.Value.Last + 1
              and then Values.Ready (Raw, M.Value.First)
              and then Model.Scan_State (Raw, M.Value.First - 1).Depth > 0
              and then Bytes.Get (Raw, M.Value.First) = '{'
              and then Cursor_Ready (Raw, Items, M.Next, Array_Container)
              and then Model.Scan_State (Raw, M.Value.First - 1).Depth =
                Model.Scan_State (Raw, Items.First).Depth
              and then (if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
                Spans.Retained (Raw, Position, M.Value.First - 1)
                and then Spans.Retained (Raw, M.Value.Last + 1, M.Next))));
end Silver_Report_Projection_Members;
