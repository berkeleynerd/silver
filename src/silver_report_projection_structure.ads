with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;

--  Reachable JSON contexts and the precise scope of the projection's edits.
--  This is separate from stream replay and from the auditor policy theorem.
package Silver_Report_Projection_Structure
  with SPARK_Mode => On, Ghost => Static
is
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;

   function Awaits_Value (F : Frame) return Boolean is
     (F.Position in Object_Value | First_Item | Next_Item);

   function Frame_Valid (S : State; I : Positive) return Boolean is
     ((if S.Stack (I).Container = Object_Container then
         S.Stack (I).Position in First_Key | Next_Key | Colon |
           Object_Value | Object_Separator
       else S.Stack (I).Position in First_Item | Next_Item | Array_Separator)
      and then (if I < S.Depth then Awaits_Value (S.Stack (I)))
      and then S.Stack (I).Role =
        (if I = 1 and then S.Stack (I).Container = Object_Container
         then Root_Object
         elsif I > 1 and then S.Stack (I - 1).Role = Root_Object
           and then S.Stack (I - 1).Position = Object_Value
           and then S.Stack (I - 1).Key in Flow_Key | Proof_Key
           and then S.Stack (I).Container = Array_Container then Check_List
         elsif I > 1 and then S.Stack (I - 1).Role = Check_List
           and then S.Stack (I).Container = Object_Container then Check_Record
         else Ordinary)
      and then S.Stack (I).Keep =
        (I = 1 or else
          (S.Stack (I - 1).Keep
           and then not (S.Stack (I - 1).Role = Check_Record
             and then S.Stack (I - 1).Position = Object_Value
             and then S.Stack (I - 1).Key = Tree_Key)))
      and then (if S.Stack (I).Role = Root_Object then I = 1)
      and then (if S.Stack (I).Role = Check_List then I = 2)
      and then (if S.Stack (I).Role = Check_Record then I = 3)
      and then (if not S.Stack (I).Keep then
        I >= 4 and then S.Stack (3).Role = Check_Record
          and then S.Stack (3).Position = Object_Value
          and then S.Stack (3).Key = Tree_Key))
     with Pre => I <= S.Depth;

   function String_Mode (S : State) return Boolean is
     (S.Mode in In_String | After_Escape | Unicode_Escape);

   function Token_Valid (S : State) return Boolean is
     (if S.Mode = Between_Tokens then True
      elsif String_Mode (S) and then S.String_Is_Key then
        S.Depth > 0
          and then S.Stack (S.Depth).Position in First_Key | Next_Key
          and then S.Token_Keep = Model.Keeping (S)
      else (S.Depth = 0 or else Awaits_Value (S.Stack (S.Depth)))
        and then S.Token_Keep =
          (Model.Keeping (S) and then not Model.Erasing_Value (S)));

   function Well_Formed (S : State) return Boolean is
     (S.Failed or else
       ((for all I in 1 .. S.Depth => Frame_Valid (S, I))
        and then Token_Valid (S)
        and then (if not S.Started then
          S.Depth = 0 and then S.Mode = Between_Tokens and then not S.Finished)
        and then (if S.Depth > 0 or else S.Mode /= Between_Tokens then
          S.Started and then not S.Finished)
        and then (if S.Started and then S.Depth = 0
          and then S.Mode = Between_Tokens then S.Finished)));

   --  The exact field selected for replacement: an unescaped check_tree
   --  member of a direct object item in a root flow/proof array.
   function Tree_Value_Context (S : State) return Boolean is
     (S.Depth = 3
      and then S.Stack (1).Container = Object_Container
      and then S.Stack (1).Role = Root_Object
      and then S.Stack (1).Position = Object_Value
      and then S.Stack (1).Key in Flow_Key | Proof_Key
      and then S.Stack (2).Container = Array_Container
      and then S.Stack (2).Role = Check_List
      and then S.Stack (2).Position in First_Item | Next_Item
      and then S.Stack (3).Container = Object_Container
      and then S.Stack (3).Role = Check_Record
      and then S.Stack (3).Position = Object_Value
      and then S.Stack (3).Key = Tree_Key);

   function Inside_Tree_Value (S : State) return Boolean is
     (S.Depth >= 4
      and then S.Stack (1).Role = Root_Object
      and then S.Stack (1).Key in Flow_Key | Proof_Key
      and then S.Stack (2).Role = Check_List
      and then S.Stack (3).Role = Check_Record
      and then S.Stack (3).Position = Object_Value
      and then S.Stack (3).Key = Tree_Key);

   procedure Initial_Context
     with Global => null, Post => Well_Formed (Initial_State);

   procedure Advance_Context (Before : State; Item : Character)
     with Global => null, Pre => Well_Formed (Before),
       Post => Well_Formed (Model.Advance_Spec (Before, Item).Following);

   procedure Emission_Scope (Before : State; Item : Character)
     with Global => null, Pre => Well_Formed (Before),
       Post =>
         (if not Before.Failed
            and then not Model.Advance_Spec (Before, Item).Following.Failed then
           (if Model.Advance_Spec (Before, Item).Length = 2 then
              Model.Advance_Spec (Before, Item).Bytes = "{}"
              and then Before.Mode = Between_Tokens
              and then Tree_Value_Context (Before))
           and then (if Model.Advance_Spec (Before, Item).Length = 1 then
              Model.Advance_Spec (Before, Item).Bytes (1) = Item)
           and then (if Model.Advance_Spec (Before, Item).Length = 0 then
              Inside_Tree_Value (Before)
              or else (Tree_Value_Context (Before)
                and then Before.Mode /= Between_Tokens)));
end Silver_Report_Projection_Structure;
