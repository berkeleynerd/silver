package body Silver_Report_Projection_Emissions with SPARK_Mode => On is
   procedure Retained (S : State; Item : Character) is
   begin
      Structure.Emission_Scope (S, Item);
   end Retained;

   procedure Dropped (S : State; Item : Character) is
   begin
      pragma Assert (not S.Token_Keep or else S.Mode = Between_Tokens);
   end Dropped;

   procedure Whitespace (S : State; Item : Character) is
   begin
      null;
   end Whitespace;

   procedure Tree_Interior (S : State; Item : Character) is
   begin
      for I in 4 .. S.Depth loop
         pragma Assert (Structure.Frame_Valid (S, I));
         pragma Assert (not S.Stack (I).Keep);
         pragma Loop_Invariant (not S.Stack (I).Keep);
      end loop;
      Dropped (S, Item);
   end Tree_Interior;

   procedure Tree_Start (S : State; Item : Character) is
   begin
      pragma Assert (Structure.Frame_Valid (S, 1));
      pragma Assert (Structure.Frame_Valid (S, 2));
      pragma Assert (Structure.Frame_Valid (S, 3));
      pragma Assert (Model.Erasing_Value (S));
   end Tree_Start;
end Silver_Report_Projection_Emissions;
