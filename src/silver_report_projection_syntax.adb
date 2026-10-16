package body Silver_Report_Projection_Syntax with SPARK_Mode => On is
   procedure Space_Context (Raw : Bytes.Sequence; Position : Big_Natural) is
      Before : constant State := Model.Scan_State (Raw, Position - 1);
   begin
      Bridge.Prefix_Context (Raw, Position - 1);
      if Position <= Bytes.Length (Raw)
        and then Observations.Space (Bytes.Get (Raw, Position))
      then
         Bridge.Prefix_Context (Raw, Position);
         pragma Assert (Model.Scan_State (Raw, Position) = Before);
         Space_Context (Raw, Position + 1);
      end if;
   end Space_Context;

   procedure Colon_Context (Raw : Bytes.Sequence; Position : Big_Natural) is
      P : constant Big_Natural := Observations.Space_End (Raw, Position);
      Before : constant State := Model.Scan_State (Raw, Position - 1);
   begin
      Space_Context (Raw, Position);
      Bridge.Prefix_Context (Raw, P - 1);
      if P > Bytes.Length (Raw) then
         pragma Assert (False);
         return;
      end if;
      Bridge.Prefix_Context (Raw, P);
      pragma Assert (not Model.White (Bytes.Get (Raw, P)));
      pragma Assert (Bytes.Get (Raw, P) = ':');
      pragma Assert (if Model.Keeping (Before) then
        Model.Advance_Spec (Model.Scan_State (Raw, P - 1), Bytes.Get (Raw, P)).Length = 1
        and then Model.Advance_Spec
          (Model.Scan_State (Raw, P - 1), Bytes.Get (Raw, P)).Bytes (1) = ':');
      pragma Assert (Model.Scan_State (Raw, P) =
        (Before with delta Stack =>
          (Before.Stack with delta Before.Depth =>
            (Before.Stack (Before.Depth) with delta Position => Object_Value))));
   end Colon_Context;
end Silver_Report_Projection_Syntax;
