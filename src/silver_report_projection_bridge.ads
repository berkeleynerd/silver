with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Structure;
with Silver_Report_Projection;
with Silver_Report_Observations;
with Silver_Report_Projection_Parents;

--  Correspondence between the streaming grammar and the auditor's independent
--  unbounded byte scanner. Offsets in original reports are mathematical values.
package Silver_Report_Projection_Bridge
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;
   package Structure renames Silver_Report_Projection_Structure;
   package Observations renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;
   package Parents renames Silver_Report_Projection_Parents;

   function Complete (Raw : Bytes.Sequence) return Boolean is
     (Silver_Report_Projection.Complete
        (Model.Scan_State (Raw, Bytes.Length (Raw))));

   procedure Reachable_Context (Raw : Bytes.Sequence; Count : Big_Natural)
     with Global => null, Pre => Count <= Bytes.Length (Raw),
       Post => Structure.Well_Formed (Model.Scan_State (Raw, Count)),
       Subprogram_Variant => (Decreases => Count);

   procedure Failed_Persists
     (Raw : Bytes.Sequence; First, Last : Big_Natural)
     with Global => null,
       Pre => First <= Last and then Last <= Bytes.Length (Raw),
       Post => (if Model.Scan_State (Raw, First).Failed then
         Model.Scan_State (Raw, Last).Failed),
       Subprogram_Variant => (Decreases => Last - First);

   procedure Prefix_Context (Raw : Bytes.Sequence; Count : Big_Natural)
     with Global => null,
       Pre => Count <= Bytes.Length (Raw) and then Complete (Raw),
       Post => Structure.Well_Formed (Model.Scan_State (Raw, Count))
         and then not Model.Scan_State (Raw, Count).Failed;

   function Container_Context
     (S : State; Base : Depth_Range; Openers : Observations.Nesting;
      Level : Observations.Nesting_Level; Quoted, Escaped : Boolean)
      return Boolean is
     (Level > 0 and then Base + Level <= Max_Depth
      and then S.Depth = Base + Level
      and then Quoted = Structure.String_Mode (S)
      and then Escaped = (S.Mode = After_Escape)
      and then (for all I in 1 .. Level =>
        Openers (I) = (if S.Stack (Base + I).Container = Object_Container
                       then '{' else '[')));

   function End_Context (S : State; Base : Depth_Range) return Boolean is
     (S.Depth = Base and then S.Mode = Between_Tokens
      and then (if Base = 0 then S.Finished
        else S.Stack (Base).Position in Object_Separator | Array_Separator));

   procedure Container_String_Step
     (S : State; Item : Character; Base : Depth_Range;
      Openers : Observations.Nesting; Level : Observations.Nesting_Level; Escaped : Boolean)
     with Pre => Structure.Well_Formed (S) and then not S.Failed
       and then Container_Context (S, Base, Openers, Level, True, Escaped)
       and then not Model.Advance_Spec (S, Item).Following.Failed,
       Post => Container_Context (Model.Advance_Spec (S, Item).Following,
         Base, Openers, Level, Escaped or else Item /= '"', not Escaped and then Item = '\');

   procedure Structural_Step
     (S : State; Item : Character; Base : Depth_Range;
      Openers : Observations.Nesting; Level : Observations.Nesting_Level)
     with Pre => Structure.Well_Formed (S) and then not S.Failed
       and then Container_Context (S, Base, Openers, Level, False, False)
       and then not Model.Advance_Spec (S, Item).Following.Failed,
       Post =>
         (if Item not in '"' | '{' | '[' | '}' | ']' then
            Container_Context (Model.Advance_Spec (S, Item).Following,
              Base, Openers, Level, False, False))
         and then (if Item = '"' then Container_Context
            (Model.Advance_Spec (S, Item).Following, Base, Openers, Level, True, False))
         and then (if Item in '{' | '[' then Base + Level < Max_Depth
           and then Container_Context
             (Model.Advance_Spec (S, Item).Following, Base,
              Observations.Pushed (Openers, Level + 1, Item), Level + 1, False, False))
         and then (if Item in '}' | ']' then
           ((Item = '}' and then Openers (Level) = '{')
            or else (Item = ']' and then Openers (Level) = '['))
           and then (if Level = 1 then End_Context (Model.Advance_Spec (S, Item).Following, Base)
             else Container_Context
               (Model.Advance_Spec (S, Item).Following, Base, Openers, Level - 1, False, False)));

   procedure Container_End
     (Raw : Bytes.Sequence; Start, Position : Big_Natural;
      Base : Depth_Range; Openers : Observations.Nesting;
      Level : Observations.Nesting_Level; Quoted, Escaped : Boolean)
     with Global => null,
       Pre => Complete (Raw) and then Start >= 1 and then Start < Position
         and then Position <= Bytes.Length (Raw) + 1
         and then Container_Context
           (Model.Scan_State (Raw, Position - 1), Base, Openers, Level, Quoted, Escaped),
       Post => Observations.Value_From
         (Raw, Start, Position, Openers, Level, Quoted, Escaped, True) >= Position
         and then End_Context
           (Model.Scan_State (Raw, Observations.Value_From
              (Raw, Start, Position, Openers, Level, Quoted, Escaped, True)), Base)
         and then Parents.Same
           (Model.Scan_State (Raw, Position - 1),
            Model.Scan_State (Raw, Observations.Value_From
              (Raw, Start, Position, Openers, Level, Quoted, Escaped, True)), Base)
         and then (for all I in Raw =>
           (if Position <= I and then I <= Observations.Value_From
              (Raw, Start, Position, Openers, Level, Quoted, Escaped, True) then
             Model.Scan_State (Raw, I - 1).Depth > Base
             and then Model.Scan_State (Raw, I - 1).Stack (Base + 1).Container =
               Model.Scan_State (Raw, Position - 1).Stack (Base + 1).Container
             and then Parents.Whole
               (Model.Scan_State (Raw, Position - 1), Model.Scan_State (Raw, I - 1), Base))),
       Subprogram_Variant => (Decreases => Bytes.Length (Raw) + 1 - Position);
end Silver_Report_Projection_Bridge;
