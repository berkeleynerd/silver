with Silver_Report_Projection_Bridge;
with Silver_Report_Projection_Structure;
with Silver_Report_Projection_Parents;
with Silver_Report_Projection_Syntax;
with Silver_Report_Projection_Separators;
with Silver_Report_Projection_Member_Steps;

package body Silver_Report_Projection_Members with SPARK_Mode => On is
   package Bridge renames Silver_Report_Projection_Bridge;
   package Structure renames Silver_Report_Projection_Structure;
   use type Observations.Member;
   package Parents renames Silver_Report_Projection_Parents;
   package Syntax renames Silver_Report_Projection_Syntax;
   package Separators renames Silver_Report_Projection_Separators;
   package Steps renames Silver_Report_Projection_Member_Steps;

   procedure Frames_Transitive (A, B, C : State; Base : Positive)
     with Global => null,
       Pre => Keys.Frames_Preserved (A, B, Base) and then Keys.Frames_Preserved (B, C, Base),
       Post => Keys.Frames_Preserved (A, C, Base)
   is
   begin
      null;
   end Frames_Transitive;

   procedure Frames_Reflexive (S : State; Base : Positive)
     with Global => null, Pre => Base <= S.Depth,
       Post => Keys.Frames_Preserved (S, S, Base)
   is
   begin
      null;
   end Frames_Reflexive;

   procedure Value_Interior_Shape
     (Raw : Bytes.Sequence; Start, Position : Big_Natural)
     with Global => null,
       Pre => Values.Ready (Raw, Start) and then Start < Position
         and then Position <= Observations.Value_Spec (Raw, Start),
       Post => Values.Value_Shape
         (Model.Scan_State (Raw, Position - 1), Model.Scan_State (Raw, Start - 1).Depth,
          Bytes.Get (Raw, Start))
   is
   begin
      Values.Value_Boundary (Raw, Start);
      pragma Assert (Values.Inside_Value
        (Model.Scan_State (Raw, Position - 1), Model.Scan_State (Raw, Start - 1).Depth,
         Bytes.Get (Raw, Position)));
   end Value_Interior_Shape;

   procedure Interior_Position
     (Raw : Bytes.Sequence; Outer : Observations.Span; Position : Big_Natural;
      Kind : Container_Kind)
     with Global => null,
       Pre => Container_At (Raw, Outer, Kind)
         and then Outer.First < Position and then Position <= Outer.Last,
       Post => Model.Scan_State (Raw, Outer.First).Depth > 0
         and then Model.Scan_State (Raw, Position - 1).Depth >=
           Model.Scan_State (Raw, Outer.First).Depth
         and then Model.Scan_State (Raw, Position - 1).Stack
           (Model.Scan_State (Raw, Outer.First).Depth).Container = Kind
   is
   begin
      Bounds.Container_Boundary (Raw, Outer, Kind);
      Value_Interior_Shape (Raw, Outer.First, Position);
      Bridge.Prefix_Context (Raw, Outer.First - 1);
      Bridge.Prefix_Context (Raw, Outer.First);
      Steps.Opening (Model.Scan_State (Raw, Outer.First - 1), Bytes.Get (Raw, Outer.First));
      pragma Assert (Values.Value_Shape
        (Model.Scan_State (Raw, Position - 1), Model.Scan_State (Raw, Outer.First - 1).Depth,
         Bytes.Get (Raw, Outer.First)));
   end Interior_Position;

   procedure Ended_Context (S : State)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed and then Separators.After_Value (S),
       Post => Structure.Well_Formed (Separators.Ended (S))
         and then not Separators.Ended (S).Failed
         and then Separators.Ended (S).Mode = Between_Tokens
         and then Separators.Ended (S).Depth = S.Depth
         and then Separators.Ended (S).Stack (S.Depth).Position in Object_Separator | Array_Separator
         and then Parents.Same (S, Separators.Ended (S), S.Depth)
         and then Model.Keeping (S) = Model.Keeping (Separators.Ended (S))
   is
   begin
      null;
   end Ended_Context;

   procedure Closing_Separator (S : State; Item : Character)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then S.Mode = Between_Tokens and then S.Depth > 0
         and then S.Stack (S.Depth).Position in Object_Separator | Array_Separator
         and then Item /= ',' and then not Model.White (Item)
         and then not Model.Advance_Spec (S, Item).Following.Failed,
       Post => Model.Advance_Spec (S, Item).Following.Depth = S.Depth - 1
   is
   begin
      null;
   end Closing_Separator;

   procedure Cursor_Head
     (Raw : Bytes.Sequence; Outer : Observations.Span; Position : Big_Natural;
      Kind : Container_Kind)
     with Global => null, Pre => Cursor_Ready (Raw, Outer, Position, Kind),
       Post =>
         (declare P : constant Big_Natural := Observations.Space_End (Raw, Position);
          begin P <= Outer.Last and then Cursor_Ready (Raw, Outer, P, Kind)
            and then Model.Scan_State (Raw, P - 1) = Model.Scan_State (Raw, Position - 1)
            and then (if P < Outer.Last then
              (if Kind = Object_Container then Bytes.Get (Raw, P) = '"'
               else Values.Ready (Raw, P)))
            and then (if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
              Spans.Retained (Raw, Position, P)))
   is
      P : constant Big_Natural := Observations.Space_End (Raw, Position);
   begin
      Bounds.Container_Boundary (Raw, Outer, Kind);
      Bounds.Leading_Position (Raw, Outer, Position, Kind);
      if Position < Outer.Last then
         Syntax.Space_Context (Raw, Position);
      end if;
      Bridge.Prefix_Context (Raw, P - 1);
      Bridge.Prefix_Context (Raw, P);
      if P < Outer.Last then
         if Kind = Object_Container then
            Steps.Key_Or_Close (Model.Scan_State (Raw, P - 1), Bytes.Get (Raw, P));
            if Bytes.Get (Raw, P) = '}' then
               Interior_Position (Raw, Outer, P + 1, Kind);
               pragma Assert (Model.Scan_State (Raw, P).Depth >=
                 Model.Scan_State (Raw, Outer.First).Depth);
               pragma Assert (False);
            end if;
         else
            Steps.Array_Value_Or_Close (Model.Scan_State (Raw, P - 1), Bytes.Get (Raw, P));
            if Bytes.Get (Raw, P) = ']' then
               Interior_Position (Raw, Outer, P + 1, Kind);
               pragma Assert (Model.Scan_State (Raw, P).Depth >=
                 Model.Scan_State (Raw, Outer.First).Depth);
               pragma Assert (False);
            end if;
         end if;
         if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
            Steps.Cursor_Retention (Model.Scan_State (Raw, P - 1), Bytes.Get (Raw, P));
         end if;
      else
         if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
            Steps.Closing_Retention (Model.Scan_State (Raw, P - 1), Bytes.Get (Raw, P));
         end if;
      end if;
      if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
         Steps.Join_Retained (Raw, Position, P - 1, P);
      end if;
   end Cursor_Head;

   procedure Member_Header
     (Raw : Bytes.Sequence; Object : Observations.Span; Position : Big_Natural;
      Key : out Observations.Span; Start : out Big_Natural)
     with Global => null,
       Pre => Cursor_Ready (Raw, Object, Position, Object_Container)
         and then Observations.Space_End (Raw, Position) < Object.Last,
       Post => Key.First = Observations.Space_End (Raw, Position)
         and then Key.Last = Observations.Value_Spec (Raw, Key.First)
         and then Observations.Valid (Raw, Key) and then Key.Last < Object.Last
         and then
           (declare C : constant Big_Natural := Observations.Space_End (Raw, Key.Last + 1);
            begin C < Object.Last and then Bytes.Get (Raw, C) = ':'
              and then Start = Observations.Space_End (Raw, C + 1))
         and then Start > Key.Last and then Start < Object.Last
         and then Values.Ready (Raw, Start)
         and then Model.Scan_State (Raw, Start - 1).Depth > 0
         and then Model.Scan_State (Raw, Start - 1).Depth = Model.Scan_State (Raw, Object.First).Depth
         and then Model.Scan_State (Raw, Start - 1).Stack
           (Model.Scan_State (Raw, Start - 1).Depth).Key = Keys.Raw_Key (Raw, Key.First, Key.Last)
         and then Keys.Frames_Preserved
           (Model.Scan_State (Raw, Position - 1), Model.Scan_State (Raw, Start - 1),
            Model.Scan_State (Raw, Object.First).Depth)
         and then (if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
           Spans.Retained (Raw, Position, Start - 1))
   is
      P : constant Big_Natural := Observations.Space_End (Raw, Position);
      K : constant Big_Natural := Observations.Value_Spec (Raw, P);
      C : constant Big_Natural := Observations.Space_End (Raw, K + 1);
   begin
      Cursor_Head (Raw, Object, Position, Object_Container);
      Bounds.Container_Boundary (Raw, Object, Object_Container);
      Keys.Key_Boundary (Raw, P);
      Bounds.Key_Before_End (Raw, Object, P);
      Syntax.Colon_Context (Raw, K + 1);
      Steps.Space_Before_End (Raw, K + 1, Object.Last);
      pragma Assert (C < Object.Last);
      Syntax.Space_Context (Raw, C + 1);
      Steps.Space_Before_End (Raw, C + 1, Object.Last);
      Start := Observations.Space_End (Raw, C + 1);
      Bridge.Prefix_Context (Raw, Start - 1);
      Bridge.Prefix_Context (Raw, Start);
      Steps.Value_Starter_At (Model.Scan_State (Raw, Start - 1), Bytes.Get (Raw, Start));
      pragma Assert (Start < Object.Last);
      Key := (P, K);
      if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
         Steps.Join_Retained (Raw, Position, P - 1, K);
         Steps.Join_Retained (Raw, Position, K, C);
         Steps.Join_Retained (Raw, Position, C, Start - 1);
      end if;
   end Member_Header;

   procedure Frames_From_Parents (Left, Right : State; Base : Positive)
     with Global => null,
       Pre => Base <= Max_Depth and then Parents.Same (Left, Right, Base),
       Post => Keys.Frames_Preserved (Left, Right, Base)
   is
   begin
      null;
   end Frames_From_Parents;

   procedure Value_Tail
     (Raw : Bytes.Sequence; Outer : Observations.Span; Start : Big_Natural;
      Kind : Container_Kind; Next : out Big_Natural)
     with Global => null,
       Pre => Container_At (Raw, Outer, Kind) and then Values.Ready (Raw, Start)
         and then Outer.First < Start and then Start < Outer.Last
         and then Model.Scan_State (Raw, Start - 1).Depth = Model.Scan_State (Raw, Outer.First).Depth,
       Post =>
         (declare L : constant Big_Natural := Observations.Value_Spec (Raw, Start);
                  T : constant Big_Natural := Observations.Space_End (Raw, L + 1);
          begin L >= Start and then L < Outer.Last and then T <= Outer.Last
            and then (if T < Outer.Last then Bytes.Get (Raw, T) = ','
              and then Next = Observations.Space_End (Raw, T + 1) and then Next < Outer.Last
              else Next = T)
            and then Next > L and then Cursor_Ready (Raw, Outer, Next, Kind)
            and then Keys.Frames_Preserved
              (Model.Scan_State (Raw, Start - 1), Model.Scan_State (Raw, Next - 1),
               Model.Scan_State (Raw, Outer.First).Depth)
            and then (if Model.Keeping (Model.Scan_State (Raw, Start - 1)) then
              Spans.Retained (Raw, L + 1, Next)))
   is
      L : constant Big_Natural := Observations.Value_Spec (Raw, Start);
      T : constant Big_Natural := Observations.Space_End (Raw, L + 1);
   begin
      Bounds.Container_Boundary (Raw, Outer, Kind);
      Values.Value_Boundary (Raw, Start);
      Bounds.Value_Before_End (Raw, Outer, Start, Kind);
      Interior_Position (Raw, Outer, Start, Kind);
      Bridge.Prefix_Context (Raw, L);
      Ended_Context (Model.Scan_State (Raw, L));
      Parents.Same_Transitive
        (Model.Scan_State (Raw, Start - 1), Model.Scan_State (Raw, L),
         Separators.Ended (Model.Scan_State (Raw, L)), Model.Scan_State (Raw, Outer.First).Depth);
      Separators.Separator_Context (Raw, L + 1);
      Separators.Space_After_Value (Raw, L + 1);
      Steps.Space_Before_End (Raw, L + 1, Outer.Last);
      Bridge.Prefix_Context (Raw, T - 1);
      Bridge.Prefix_Context (Raw, T);
      pragma Assert (Parents.Same
        (Model.Scan_State (Raw, Start - 1), Model.Scan_State (Raw, T - 1),
         Model.Scan_State (Raw, Outer.First).Depth));
      if T < Outer.Last then
         if Bytes.Get (Raw, T) /= ',' then
            Closing_Separator (Separators.Ended (Model.Scan_State (Raw, L)), Bytes.Get (Raw, T));
            Interior_Position (Raw, Outer, T + 1, Kind);
            pragma Assert (Model.Scan_State (Raw, T).Depth < Model.Scan_State (Raw, Outer.First).Depth);
            pragma Assert (Model.Scan_State (Raw, T).Depth >= Model.Scan_State (Raw, Outer.First).Depth);
            pragma Assert (False);
         end if;
         Steps.Comma (Separators.Ended (Model.Scan_State (Raw, L)));
         Parents.Same_Transitive
           (Model.Scan_State (Raw, Start - 1), Separators.Ended (Model.Scan_State (Raw, L)),
            Model.Scan_State (Raw, T), Model.Scan_State (Raw, Outer.First).Depth);
         pragma Assert (Model.Keeping (Model.Scan_State (Raw, T)) =
           Model.Keeping (Model.Scan_State (Raw, Start - 1)));
         Syntax.Space_Context (Raw, T + 1);
         Steps.Space_Before_End (Raw, T + 1, Outer.Last);
         Next := Observations.Space_End (Raw, T + 1);
         Bridge.Prefix_Context (Raw, Next - 1);
         Bridge.Prefix_Context (Raw, Next);
         pragma Assert (Model.Scan_State (Raw, Next - 1) = Model.Scan_State (Raw, T));
         Parents.Same_Transitive
           (Model.Scan_State (Raw, Start - 1), Model.Scan_State (Raw, T),
            Model.Scan_State (Raw, Next - 1), Model.Scan_State (Raw, Outer.First).Depth);
         pragma Assert (Model.Scan_State (Raw, Next - 1).Stack
           (Model.Scan_State (Raw, Outer.First).Depth).Position =
             (if Kind = Object_Container then Next_Key else Next_Item));
         if Kind = Object_Container then
            Steps.Key_Or_Close (Model.Scan_State (Raw, Next - 1), Bytes.Get (Raw, Next));
            pragma Assert (Bytes.Get (Raw, Next) /= '}');
         else
            Steps.Array_Value_Or_Close (Model.Scan_State (Raw, Next - 1), Bytes.Get (Raw, Next));
            pragma Assert (Bytes.Get (Raw, Next) /= ']');
         end if;
         pragma Assert (Next < Outer.Last);
         pragma Assert (Model.Scan_State (Raw, Next - 1).Mode = Between_Tokens);
         pragma Assert (Model.Scan_State (Raw, Next - 1).Depth =
           Model.Scan_State (Raw, Outer.First).Depth);
         pragma Assert (Model.Scan_State (Raw, Next - 1).Stack
           (Model.Scan_State (Raw, Outer.First).Depth).Container = Kind);
         pragma Assert (Model.Scan_State (Raw, Next - 1).Stack
           (Model.Scan_State (Raw, Outer.First).Depth).Position =
             (if Kind = Object_Container then Next_Key else Next_Item));
         pragma Assert (Cursor_Ready (Raw, Outer, Next, Kind));
         if Model.Keeping (Model.Scan_State (Raw, Start - 1)) then
            Steps.Cursor_Retention (Model.Scan_State (Raw, Next - 1), Bytes.Get (Raw, Next));
            Steps.Join_Retained (Raw, L + 1, T, Next - 1);
            Steps.Join_Retained (Raw, L + 1, Next - 1, Next);
         end if;
         Frames_From_Parents
           (Model.Scan_State (Raw, Start - 1), Model.Scan_State (Raw, Next - 1),
            Model.Scan_State (Raw, Outer.First).Depth);
      else
         Next := T;
         Frames_From_Parents
           (Model.Scan_State (Raw, Start - 1), Model.Scan_State (Raw, Next - 1),
            Model.Scan_State (Raw, Outer.First).Depth);
      end if;
   end Value_Tail;

   procedure Member_Result
     (Raw : Bytes.Sequence; Object : Observations.Span; Position : Big_Natural;
      Key, Value : Observations.Span; Next : Big_Natural)
     with Global => null,
       Pre => Observations.Valid (Raw, Object)
         and then Position >= Object.First + 1 and then Position <= Bytes.Length (Raw) + 1
         and then Observations.Valid (Raw, Key) and then Observations.Valid (Raw, Value)
         and then Key.First = Observations.Space_End (Raw, Position)
         and then Key.First < Object.Last and then Bytes.Get (Raw, Key.First) = '"'
         and then Key.Last = Observations.Value_Spec (Raw, Key.First) and then Key.Last < Object.Last
         and then
           (declare C : constant Big_Natural := Observations.Space_End (Raw, Key.Last + 1);
            begin C < Object.Last and then Bytes.Get (Raw, C) = ':'
              and then Value.First = Observations.Space_End (Raw, C + 1))
         and then Value.Last = Observations.Value_Spec (Raw, Value.First) and then Value.Last < Object.Last
         and then
           (declare T : constant Big_Natural := Observations.Space_End (Raw, Value.Last + 1);
            begin T <= Object.Last and then
              (if T = Object.Last then Next = T else Bytes.Get (Raw, T) = ','
                and then Next = Observations.Space_End (Raw, T + 1) and then Next < Object.Last)),
       Post =>
         (declare M : constant Observations.Member := Observations.Member_Spec (Raw, Object, Position);
          begin M.State = Observations.Present
            and then M.Key.First = Key.First and then M.Key.Last = Key.Last
            and then M.Value.First = Value.First and then M.Value.Last = Value.Last
            and then M.Next = Next)
   is
   begin
      null;
   end Member_Result;

   procedure Member_Context
     (Raw : Bytes.Sequence; Object : Observations.Span; Position : Big_Natural)
   is
      P : constant Big_Natural := Observations.Space_End (Raw, Position);
      Key : Observations.Span;
      Start, Next : Big_Natural := 0;
   begin
      Cursor_Head (Raw, Object, Position, Object_Container);
      if P < Object.Last then
         Member_Header (Raw, Object, Position, Key, Start);
         Value_Tail (Raw, Object, Start, Object_Container, Next);
         Member_Result (Raw, Object, Position, Key, (Start, Observations.Value_Spec (Raw, Start)), Next);
         pragma Assert (Model.Keeping (Model.Scan_State (Raw, Start - 1)) =
           Model.Keeping (Model.Scan_State (Raw, Position - 1)));
         Frames_Transitive
           (Model.Scan_State (Raw, Position - 1), Model.Scan_State (Raw, Start - 1),
            Model.Scan_State (Raw, Next - 1), Model.Scan_State (Raw, Object.First).Depth);
      else
         pragma Assert (Observations.Member_Spec (Raw, Object, Position) = Observations.End_Member);
      end if;
   end Member_Context;

   procedure Any_Item_Context
     (Raw : Bytes.Sequence; Items : Observations.Span; Position : Big_Natural)
   is
      P : constant Big_Natural := Observations.Space_End (Raw, Position);
      Next : Big_Natural := 0;
   begin
      Cursor_Head (Raw, Items, Position, Array_Container);
      if P < Items.Last then
         Value_Tail (Raw, Items, P, Array_Container, Next);
         pragma Assert (Any_Item_Spec (Raw, Items, Position) =
           (Observations.Present, Observations.Missing, (P, Observations.Value_Spec (Raw, P)), Next));
         Frames_Reflexive (Model.Scan_State (Raw, P - 1), Model.Scan_State (Raw, Items.First).Depth);
      end if;
   end Any_Item_Context;

   procedure Item_Context
     (Raw : Bytes.Sequence; Items : Observations.Span; Position : Big_Natural)
   is
   begin
      Any_Item_Context (Raw, Items, Position);
      Cursor_Head (Raw, Items, Position, Array_Container);
   end Item_Context;
end Silver_Report_Projection_Members;
