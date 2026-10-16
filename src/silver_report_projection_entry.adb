with Silver_Report_Projection_Bridge;
with Silver_Report_Projection_Parents;
package body Silver_Report_Projection_Entry with SPARK_Mode => On is
   package Bridge renames Silver_Report_Projection_Bridge;
   package Parents renames Silver_Report_Projection_Parents;

   procedure Entry_Step (S : State; Item : Character)
     with Global => null,
       Pre => not S.Failed and then Parents.Ready_Value (S, Item)
         and then Item in '{' | '['
         and then not Model.Advance_Spec (S, Item).Following.Failed,
       Post => Model.Advance_Spec (S, Item).Following.Depth > 0
         and then Model.Advance_Spec (S, Item).Following.Depth = S.Depth + 1
         and then Model.Advance_Spec (S, Item).Following.Mode = Between_Tokens
         and then Model.Advance_Spec (S, Item).Following.Stack
           (Model.Advance_Spec (S, Item).Following.Depth).Role = Model.Child_Role (S, Item)
   is
   begin
      null;
   end Entry_Step;

   procedure Enter_Container (Raw : Bytes.Sequence; Start : Big_Natural) is
   begin
      Bridge.Prefix_Context (Raw, Start - 1);
      Bridge.Prefix_Context (Raw, Start);
      Entry_Step (Model.Scan_State (Raw, Start - 1), Bytes.Get (Raw, Start));
   end Enter_Container;
end Silver_Report_Projection_Entry;
