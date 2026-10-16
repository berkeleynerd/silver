with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Structure;

--  Exact emissions for retained values and the selected opaque tree value.
package Silver_Report_Projection_Emissions
  with SPARK_Mode => On, Ghost => Static
is
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;
   package Structure renames Silver_Report_Projection_Structure;

   procedure Retained (S : State; Item : Character)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then not Model.Advance_Spec (S, Item).Following.Failed
         and then not Structure.Tree_Value_Context (S)
         and then not Structure.Inside_Tree_Value (S),
       Post => Model.Advance_Spec (S, Item).Length = 1
         and then Model.Advance_Spec (S, Item).Bytes (1) = Item;

   procedure Dropped (S : State; Item : Character)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then not Model.Keeping (S),
       Post => Model.Advance_Spec (S, Item).Length = 0;

   procedure Whitespace (S : State; Item : Character)
     with Global => null,
       Pre => not S.Failed and then S.Mode = Between_Tokens
         and then Model.White (Item) and then Model.Keeping (S),
       Post => Model.Advance_Spec (S, Item).Length = 1
         and then Model.Advance_Spec (S, Item).Bytes (1) = Item;

   procedure Tree_Interior (S : State; Item : Character)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then Structure.Inside_Tree_Value (S),
       Post => Model.Advance_Spec (S, Item).Length = 0;

   procedure Tree_Start (S : State; Item : Character)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then Structure.Tree_Value_Context (S)
         and then S.Mode = Between_Tokens and then not Model.White (Item)
         and then not Model.Advance_Spec (S, Item).Following.Failed,
       Post => Model.Advance_Spec (S, Item).Length = 2
         and then Model.Advance_Spec (S, Item).Bytes = "{}";
end Silver_Report_Projection_Emissions;
