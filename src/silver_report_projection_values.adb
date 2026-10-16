with Silver_Report_Projection_Emissions;

package body Silver_Report_Projection_Values with SPARK_Mode => On is
   package Emissions renames Silver_Report_Projection_Emissions;

   procedure Value_Boundary (Raw : Bytes.Sequence; Start : Big_Natural) is
      Before : constant State := Model.Scan_State (Raw, Start - 1);
      Item : constant Character := Bytes.Get (Raw, Start);
      Base : constant Depth_Range := Before.Depth;
      After : constant State := Model.Scan_State (Raw, Start);
      Last : constant Big_Natural := Observations.Value_Spec (Raw, Start);
   begin
      Bridge.Prefix_Context (Raw, Start - 1);
      Bridge.Prefix_Context (Raw, Start);
      pragma Assert (After = Model.Advance_Spec (Before, Item).Following);
      Parents.Start_Value (Before, Item);
      pragma Assert (Parents.Whole (Before, After, Base));
      if Item in '{' | '[' then
         Bridge.Container_End
           (Raw, Start, Start + 1, Base,
            Observations.Pushed (Observations.Empty_Nesting, 1, Item), 1, False, False);
         pragma Assert (After.Depth = Base + 1);
         pragma Assert (After.Stack (Base + 1).Container =
           (if Item = '{' then Object_Container else Array_Container));
         pragma Assert (Last = Observations.Value_From
           (Raw, Start, Start + 1, Observations.Pushed (Observations.Empty_Nesting, 1, Item),
            1, False, False, True));
         pragma Assert (for all I in Raw => (if Start < I and then I <= Last then
           Value_Shape (Model.Scan_State (Raw, I - 1), Base, Item)));
      elsif Item = '"' then
         Tokens.String_End (Raw, Start, Start + 1, Base, False);
         pragma Assert (Last = Observations.Value_From
           (Raw, Start, Start + 1, Observations.Empty_Nesting, 0, True, False, False));
         pragma Assert (for all I in Raw => (if Start < I and then I <= Last then
           Value_Shape (Model.Scan_State (Raw, I - 1), Base, Item)));
      else
         Tokens.Primitive_End (Raw, Start, Start + 1, Base);
         pragma Assert (Last = Observations.Value_From
           (Raw, Start, Start + 1, Observations.Empty_Nesting, 0, False, False, False));
         pragma Assert (for all I in Raw => (if Start < I and then I <= Last then
           Value_Shape (Model.Scan_State (Raw, I - 1), Base, Item)));
      end if;
      pragma Assert (for all I in Raw => (if Start < I and then I <= Last then
        Parents.Whole (After, Model.Scan_State (Raw, I - 1), Base)));
      Parents.Same_Transitive (Before, After, Model.Scan_State (Raw, Last), Base);
      Parents.Lift_Whole
        (Raw, Start + 1, Last, Before, After, Base);
   end Value_Boundary;

   procedure Tree_Token (S : State; Item : Character)
     with Pre => Structure.Well_Formed (S) and then not S.Failed
       and then Structure.Tree_Value_Context (S)
       and then S.Mode /= Between_Tokens
       and then (if Structure.String_Mode (S) then not S.String_Is_Key)
       and then (if S.Mode = In_Number then not Model.Number_Ends (S.Number, Item)),
       Post => Model.Advance_Spec (S, Item).Length = 0
   is
   begin
      null;
   end Tree_Token;

   procedure Silent_Interior
     (Raw : Bytes.Sequence; Start, Last : Big_Natural)
     with Pre => Ready (Raw, Start) and then Start <= Last
       and then Last <= Bytes.Length (Raw)
       and then Structure.Tree_Value_Context (Model.Scan_State (Raw, Start - 1))
       and then (for all I in Raw =>
         (if Start < I and then I <= Last then
           Parents.Whole
             (Model.Scan_State (Raw, Start - 1), Model.Scan_State (Raw, I - 1),
              Model.Scan_State (Raw, Start - 1).Depth)
           and then Inside_Value
             (Model.Scan_State (Raw, I - 1), Model.Scan_State (Raw, Start - 1).Depth,
              Bytes.Get (Raw, I)))),
       Post => Spans.Silent (Raw, Start + 1, Last),
       Subprogram_Variant => (Decreases => Last - Start)
   is
   begin
      if Last > Start then
         Silent_Interior (Raw, Start, Last - 1);
         Bridge.Prefix_Context (Raw, Last - 1);
         declare
            S : constant State := Model.Scan_State (Raw, Last - 1);
            Item : constant Character := Bytes.Get (Raw, Last);
         begin
            if S.Depth > 3 then
               Emissions.Tree_Interior (S, Item);
            else
               Tree_Token (S, Item);
            end if;
         end;
      end if;
   end Silent_Interior;

   procedure Tree_Projection (Raw : Bytes.Sequence; Start : Big_Natural) is
   begin
      Value_Boundary (Raw, Start);
      Bridge.Prefix_Context (Raw, Start - 1);
      Bridge.Prefix_Context (Raw, Start);
      Emissions.Tree_Start (Model.Scan_State (Raw, Start - 1), Bytes.Get (Raw, Start));
      Silent_Interior (Raw, Start, Observations.Value_Spec (Raw, Start));
      Spans.Silent_Range (Raw, Start + 1, Observations.Value_Spec (Raw, Start));
   end Tree_Projection;

   procedure Valid_Frame (S : State; I : Positive)
     with Pre => Structure.Well_Formed (S) and then not S.Failed and then I <= S.Depth,
       Post => Structure.Frame_Valid (S, I)
   is
   begin
      null;
   end Valid_Frame;

   procedure Retained_State (Before, Current : State; Starter, Item : Character)
     with Pre => Structure.Well_Formed (Current) and then not Current.Failed
       and then (Retained_Context (Before)
         or else (Before.Depth = 1 and then Before.Stack (1).Role = Root_Object
           and then Starter /= '[')
         or else (Before.Depth = 2 and then Before.Stack (2).Role = Check_List
           and then Starter /= '{'))
       and then (Current = Before or else
         (Parents.Whole (Before, Current, Before.Depth)
          and then Inside_Value (Current, Before.Depth, Item)
          and then Value_Shape (Current, Before.Depth, Starter))),
       Post => not Structure.Tree_Value_Context (Current)
         and then not Structure.Inside_Tree_Value (Current)
   is
   begin
      if Current.Depth >= 3 then
         Valid_Frame (Current, 1);
         Valid_Frame (Current, 2);
         Valid_Frame (Current, 3);
         if Before.Depth = 1 and then Current /= Before
           and then Before.Stack (1).Key in Flow_Key | Proof_Key
         then
            pragma Assert (Starter = '{');
            pragma Assert (Current.Stack (2).Container = Object_Container);
            pragma Assert (Current.Stack (2).Role /= Check_List);
            pragma Assert (Current.Stack (3).Role /= Check_Record);
         elsif Before.Depth = 2 then
            pragma Assert (Starter = '[');
            pragma Assert (Current.Stack (3).Container = Array_Container);
            pragma Assert (Current.Stack (3).Role /= Check_Record);
         end if;
      end if;
   end Retained_State;

   procedure Retained_Interior
     (Raw : Bytes.Sequence; Start, Last : Big_Natural)
     with Pre => Ready (Raw, Start) and then Start <= Last
       and then Last <= Bytes.Length (Raw)
       and then Retained_Value (Raw, Start)
       and then (for all I in Raw =>
         (if Start < I and then I <= Last then
           Parents.Whole
             (Model.Scan_State (Raw, Start - 1), Model.Scan_State (Raw, I - 1),
              Model.Scan_State (Raw, Start - 1).Depth)
           and then Inside_Value
             (Model.Scan_State (Raw, I - 1), Model.Scan_State (Raw, Start - 1).Depth,
              Bytes.Get (Raw, I))
           and then Value_Shape
             (Model.Scan_State (Raw, I - 1), Model.Scan_State (Raw, Start - 1).Depth,
              Bytes.Get (Raw, Start)))),
       Post => Spans.Retained (Raw, Start, Last),
       Subprogram_Variant => (Decreases => Last - Start)
   is
   begin
      if Last > Start then
         Retained_Interior (Raw, Start, Last - 1);
      end if;
      Bridge.Prefix_Context (Raw, Last - 1);
      Bridge.Prefix_Context (Raw, Last);
      Retained_State (Model.Scan_State (Raw, Start - 1), Model.Scan_State (Raw, Last - 1),
                      Bytes.Get (Raw, Start), Bytes.Get (Raw, Last));
      Emissions.Retained (Model.Scan_State (Raw, Last - 1), Bytes.Get (Raw, Last));
   end Retained_Interior;

   procedure Retained_Projection (Raw : Bytes.Sequence; Start : Big_Natural) is
   begin
      Value_Boundary (Raw, Start);
      Retained_Interior (Raw, Start, Observations.Value_Spec (Raw, Start));
      Spans.Retained_Range (Raw, Start, Observations.Value_Spec (Raw, Start));
   end Retained_Projection;
end Silver_Report_Projection_Values;
