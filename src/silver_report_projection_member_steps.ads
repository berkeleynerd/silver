with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Structure;
with Silver_Report_Projection_Parents;
with Silver_Report_Projection_Spans;
with Silver_Report_Observations;

package Silver_Report_Projection_Member_Steps
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;
   package Structure renames Silver_Report_Projection_Structure;
   package Parents renames Silver_Report_Projection_Parents;
   package Spans renames Silver_Report_Projection_Spans;
   package Observations renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;

   procedure Space_Before_End (Raw : Bytes.Sequence; Position, Last : Big_Natural)
     with Global => null,
       Pre => Position >= 1 and then Position <= Last and then Last <= Bytes.Length (Raw)
         and then not Observations.Space (Bytes.Get (Raw, Last)),
       Post => Observations.Space_End (Raw, Position) <= Last,
       Subprogram_Variant => (Decreases => Last - Position);

   procedure Opening (S : State; Item : Character)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then Parents.Ready_Value (S, Item) and then Item in '{' | '['
         and then not Model.Advance_Spec (S, Item).Following.Failed,
       Post => S.Depth < Max_Depth
         and then Model.Advance_Spec (S, Item).Following.Depth = S.Depth + 1
         and then Model.Advance_Spec (S, Item).Following.Mode = Between_Tokens
         and then Model.Advance_Spec (S, Item).Following.Stack (S.Depth + 1).Container =
           (if Item = '{' then Object_Container else Array_Container)
         and then Model.Advance_Spec (S, Item).Following.Stack (S.Depth + 1).Position =
           (if Item = '{' then First_Key else First_Item);

   procedure Closing (S : State; Item : Character; Base : Depth_Range)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed and then S.Depth > Base
         and then not Model.Advance_Spec (S, Item).Following.Failed
         and then Model.Advance_Spec (S, Item).Following.Depth = Base,
       Post => S.Depth = Base + 1 and then Item =
         (if S.Stack (S.Depth).Container = Object_Container then '}' else ']');

   procedure Key_Or_Close (S : State; Item : Character)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then S.Mode = Between_Tokens and then S.Depth > 0
         and then S.Stack (S.Depth).Container = Object_Container
         and then S.Stack (S.Depth).Position in First_Key | Next_Key
         and then not Observations.Space (Item)
         and then not Model.Advance_Spec (S, Item).Following.Failed,
       Post => Item = '"' or else
         (Item = '}' and then S.Stack (S.Depth).Position = First_Key
          and then Model.Advance_Spec (S, Item).Following.Depth = S.Depth - 1);

   procedure Value_Starter_At (S : State; Item : Character)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then S.Mode = Between_Tokens and then S.Depth > 0
         and then S.Stack (S.Depth).Position = Object_Value
         and then not Observations.Space (Item)
         and then not Model.Advance_Spec (S, Item).Following.Failed,
       Post => Parents.Ready_Value (S, Item);

   procedure Comma (S : State)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then S.Mode = Between_Tokens and then S.Depth > 0
         and then S.Stack (S.Depth).Position in Object_Separator | Array_Separator
         and then not Model.Advance_Spec (S, ',').Following.Failed,
       Post => Model.Advance_Spec (S, ',').Following.Depth = S.Depth
         and then Model.Advance_Spec (S, ',').Following.Mode = Between_Tokens
         and then Model.Advance_Spec (S, ',').Following.Stack (S.Depth).Position =
           (if S.Stack (S.Depth).Container = Object_Container then Next_Key else Next_Item)
         and then Parents.Same (S, Model.Advance_Spec (S, ',').Following, S.Depth);

   procedure Join_Retained (Raw : Bytes.Sequence; First, Split, Last : Big_Natural)
     with Global => null,
       Pre => First >= 1 and then First <= Split + 1 and then Split <= Last
         and then Last <= Bytes.Length (Raw)
         and then Spans.Retained (Raw, First, Split)
         and then Spans.Retained (Raw, Split + 1, Last),
       Post => Spans.Retained (Raw, First, Last);
end Silver_Report_Projection_Member_Steps;
