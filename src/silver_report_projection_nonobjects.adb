with Silver_Report_Projection_Types;
with Silver_Report_Projection_Structure;
with Silver_Report_Projection_Syntax;
with Silver_Report_Projection_Spans;
package body Silver_Report_Projection_Nonobjects with SPARK_Mode => On is
   use Silver_Report_Projection_Types;
   package Structure renames Silver_Report_Projection_Structure;
   package Syntax renames Silver_Report_Projection_Syntax;
   package Spans renames Silver_Report_Projection_Spans;

   function Outside_Object (S : State) return Boolean is
     (S.Depth = 0 or else S.Stack (1).Container = Array_Container);

   procedure Step (S : State; Item : Character)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then not Model.Advance_Spec (S, Item).Following.Failed
         and then Outside_Object (S) and then (S.Started or else Item /= '{'),
       Post => Outside_Object (Model.Advance_Spec (S, Item).Following)
         and then Model.Advance_Spec (S, Item).Following.Started =
           (S.Started or else not Model.White (Item))
         and then Model.Advance_Spec (S, Item).Length = 1
         and then Model.Advance_Spec (S, Item).Bytes (1) = Item
   is
   begin
      Structure.Emission_Scope (S, Item);
   end Step;

   procedure Prefix (Raw : Bytes.Sequence; Start, Count : Big_Natural)
     with Global => null,
       Pre => Bridge.Complete (Raw)
         and then Start >= 1 and then Start <= Bytes.Length (Raw)
         and then Count <= Bytes.Length (Raw)
         and then not Scan.Space (Bytes.Get (Raw, Start))
         and then Bytes.Get (Raw, Start) /= '{'
         and then (for all I in Raw =>
           (if I < Start then Scan.Space (Bytes.Get (Raw, I)))),
       Post => Outside_Object (Model.Scan_State (Raw, Count))
         and then Model.Scan_State (Raw, Count).Started = (Count >= Start)
         and then Spans.Retained (Raw, 1, Count),
       Subprogram_Variant => (Decreases => Count)
   is
   begin
      if Count > 0 then
         Prefix (Raw, Start, Count - 1);
         Bridge.Prefix_Context (Raw, Count - 1);
         Bridge.Prefix_Context (Raw, Count);
         Step (Model.Scan_State (Raw, Count - 1), Bytes.Get (Raw, Count));
      end if;
   end Prefix;

   procedure Unchanged (Raw : Bytes.Sequence) is
   begin
      Syntax.Space_Context (Raw, 1);
      Prefix (Raw, Scan.Space_End (Raw, 1), Bytes.Length (Raw));
      Spans.Retained_Range (Raw, 1, Bytes.Length (Raw));
   end Unchanged;
end Silver_Report_Projection_Nonobjects;
