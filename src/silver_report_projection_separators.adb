package body Silver_Report_Projection_Separators with SPARK_Mode => On is
   procedure Space_After_Value (Raw : Bytes.Sequence; Position : Big_Natural) is
      Before : constant State := Model.Scan_State (Raw, Position - 1);
      P : constant Big_Natural := Observations.Space_End (Raw, Position);
   begin
      Bridge.Prefix_Context (Raw, Position - 1);
      if Position > Bytes.Length (Raw) then
         pragma Assert (False);
         return;
      end if;
      if Observations.Space (Bytes.Get (Raw, Position)) then
         Bridge.Prefix_Context (Raw, Position);
         pragma Assert (Model.Scan_State (Raw, Position) = Ended (Before));
         Syntax.Space_Context (Raw, Position + 1);
         pragma Assert (P = Observations.Space_End (Raw, Position + 1));
         Bridge.Prefix_Context (Raw, P - 1);
         if P > Bytes.Length (Raw) then
            pragma Assert (False);
         end if;
      end if;
   end Space_After_Value;

   procedure Delimiter_Step (S : State; C : Character)
     with Global => null,
       Pre => not S.Failed and then After_Value (S) and then C in ',' | '}' | ']'
         and then (if S.Mode = In_Number then Model.Number_Ends (S.Number, C)),
       Post => Model.Advance_Spec (S, C) = Model.Advance_Spec (Ended (S), C)
         and then (if Model.Keeping (S) and then not Model.Advance_Spec (S, C).Following.Failed then
           Model.Advance_Spec (S, C).Length = 1
           and then Model.Advance_Spec (S, C).Bytes (1) = C)
   is
   begin
      if S.Mode = Between_Tokens then
         Model.Advance_Congruence (S, Ended (S), C);
      end if;
   end Delimiter_Step;

   procedure Separator_Context (Raw : Bytes.Sequence; Position : Big_Natural) is
      Before : constant State := Model.Scan_State (Raw, Position - 1);
      P : constant Big_Natural := Observations.Space_End (Raw, Position);
   begin
      Bridge.Prefix_Context (Raw, Position - 1);
      Space_After_Value (Raw, Position);
      Bridge.Prefix_Context (Raw, P - 1);
      Bridge.Prefix_Context (Raw, P);
      declare
         C : constant Character := Bytes.Get (Raw, P);
      begin
         pragma Assert (C in ',' | '}' | ']');
         Delimiter_Step (Model.Scan_State (Raw, P - 1), C);
         if P = Position then
            Delimiter_Step (Before, C);
         else
            Model.Advance_Congruence
              (Model.Scan_State (Raw, P - 1), Ended (Before), C);
         end if;
         pragma Assert (Model.Scan_State (Raw, P) =
           Model.Advance_Spec (Ended (Before), C).Following);
      end;
   end Separator_Context;
end Silver_Report_Projection_Separators;
