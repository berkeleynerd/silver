package body Silver_Report_Projection_Structure with SPARK_Mode => On is
   procedure Initial_Context is
   begin
      null;
   end Initial_Context;

   procedure Advance_Context (Before : State; Item : Character) is
   begin
      if Before.Failed then
         return;
      end if;
      case Before.Mode is
         when Between_Tokens => null;
         when In_String => null;
         when After_Escape => null;
         when Unicode_Escape => null;
         when In_Number => null;
         when In_Literal => null;
      end case;
   end Advance_Context;

   procedure Context_Scope (S : State)
     with Pre => Well_Formed (S) and then not S.Failed,
       Post =>
         (if Model.Erasing_Value (S) then Tree_Value_Context (S))
         and then (if not Model.Keeping (S) then Inside_Tree_Value (S))
         and then (if S.Mode /= Between_Tokens and then not S.Token_Keep then
           Inside_Tree_Value (S) or else Tree_Value_Context (S))
   is
   begin
      if S.Depth >= 1 then pragma Assert (Frame_Valid (S, 1)); end if;
      if S.Depth >= 2 then pragma Assert (Frame_Valid (S, 2)); end if;
      if S.Depth >= 3 then pragma Assert (Frame_Valid (S, 3)); end if;
      if S.Depth > 0 then pragma Assert (Frame_Valid (S, S.Depth)); end if;
   end Context_Scope;

   procedure Emission_Scope (Before : State; Item : Character) is
      Next : constant Transition := Model.Advance_Spec (Before, Item);
   begin
      if Before.Failed or else Next.Following.Failed then
         return;
      end if;
      Context_Scope (Before);
      case Before.Mode is
         when Between_Tokens =>
            pragma Assert (Next.Length /= 0 or else not Model.Keeping (Before));
         when In_Number =>
            if Model.Number_Ends (Before.Number, Item) then
               pragma Assert (Next.Length /= 0 or else not Model.Keeping (Before));
            else
               pragma Assert (Next.Length /= 0 or else not Before.Token_Keep);
            end if;
         when In_String | After_Escape | Unicode_Escape | In_Literal =>
            pragma Assert (Next.Length /= 0 or else not Before.Token_Keep);
      end case;
   end Emission_Scope;
end Silver_Report_Projection_Structure;
