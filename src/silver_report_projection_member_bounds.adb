with Silver_Report_Projection_Bridge;
with Silver_Report_Projection_Syntax;
with Silver_Report_Projection_Member_Steps;
with Silver_Report_Observation_Composition;

package body Silver_Report_Projection_Member_Bounds with SPARK_Mode => On is
   package Bridge renames Silver_Report_Projection_Bridge;
   package Syntax renames Silver_Report_Projection_Syntax;
   package Steps renames Silver_Report_Projection_Member_Steps;
   package Composition renames Silver_Report_Observation_Composition;

   procedure Container_Boundary
     (Raw : Bytes.Sequence; Bounds : Observations.Span; Kind : Container_Kind)
   is
      Item : constant Character := Bytes.Get (Raw, Bounds.First);
   begin
      Values.Value_Boundary (Raw, Bounds.First);
      Bridge.Prefix_Context (Raw, Bounds.First - 1);
      Bridge.Prefix_Context (Raw, Bounds.First);
      Steps.Opening (Model.Scan_State (Raw, Bounds.First - 1), Item);
      pragma Assert (Model.Scan_State (Raw, Bounds.First) =
        Model.Advance_Spec (Model.Scan_State (Raw, Bounds.First - 1), Item).Following);
      pragma Assert (Bounds.Last > Bounds.First);
      pragma Assert (Bounds.Last = Observations.Value_From
        (Raw, Bounds.First, Bounds.First + 1,
         Observations.Pushed (Observations.Empty_Nesting, 1, Item), 1, False, False, True));
      Composition.Container_Closes
        (Raw, Bounds.First, Bounds.First + 1,
         Observations.Pushed (Observations.Empty_Nesting, 1, Item), 1, False, False);
   end Container_Boundary;

   procedure Leading_Position
     (Raw : Bytes.Sequence; Bounds : Observations.Span;
      Position : Big_Natural; Kind : Container_Kind)
   is
   begin
      Container_Boundary (Raw, Bounds, Kind);
      Steps.Space_Before_End (Raw, Position, Bounds.Last);
      if Position < Bounds.Last then
         Syntax.Space_Context (Raw, Position);
      end if;
   end Leading_Position;

   procedure Value_Before_End
     (Raw : Bytes.Sequence; Bounds : Observations.Span;
      Start : Big_Natural; Kind : Container_Kind)
   is
      Last : constant Big_Natural := Observations.Value_Spec (Raw, Start);
   begin
      Container_Boundary (Raw, Bounds, Kind);
      Values.Value_Boundary (Raw, Start);
      if Last = Bounds.Last then
         pragma Assert (False);
      elsif Last > Bounds.Last then
         pragma Assert (Start < Bounds.Last + 1 and then Bounds.Last + 1 <= Last);
         pragma Assert (Values.Inside_Value
           (Model.Scan_State (Raw, Bounds.Last + 1 - 1),
            Model.Scan_State (Raw, Start - 1).Depth, Bytes.Get (Raw, Bounds.Last + 1)));
         pragma Assert (Model.Scan_State (Raw, Bounds.Last).Depth >=
           Model.Scan_State (Raw, Start - 1).Depth);
         pragma Assert (False);
      end if;
   end Value_Before_End;

   procedure Key_Before_End
     (Raw : Bytes.Sequence; Object : Observations.Span; Start : Big_Natural)
   is
      Last : constant Big_Natural := Observations.Value_Spec (Raw, Start);
   begin
      Container_Boundary (Raw, Object, Object_Container);
      Keys.Key_Boundary (Raw, Start);
      if Last = Object.Last then
         pragma Assert (False);
      elsif Last > Object.Last then
         pragma Assert (Start + 1 <= Object.Last + 1 and then Object.Last + 1 <= Last);
         pragma Assert (Model.Scan_State (Raw, Object.Last).Depth =
           Model.Scan_State (Raw, Start - 1).Depth);
         pragma Assert (False);
      end if;
   end Key_Before_End;
end Silver_Report_Projection_Member_Bounds;
