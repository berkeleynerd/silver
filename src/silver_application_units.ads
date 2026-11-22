with Silver_Profile;

package Silver_Application_Units
  with SPARK_Mode => On
is
   --  One source budget covers the complete application, rather than giving
   --  each additional compilation unit a separate source-length allowance.
   Max_Source_Length : constant Positive := Silver_Profile.Max_Source_Length;
   subtype Source_Buffer is String (1 .. Max_Source_Length);
   subtype Source_Length is Natural range 0 .. Max_Source_Length;
   subtype Unit_Position is Positive range 1 .. Max_Source_Length + 1;

   type Unit_Kind is
     (Package_Specification, Package_Body, Main_Body);

   --  Half-open byte offsets into the shared pool. No separator is inserted
   --  between units; lexical interpretation remains local to the selected unit.
   type Span is record
      First : Unit_Position := 1;
      After : Unit_Position := 1;
   end record;
   type Span_Array is array (Unit_Kind) of Span;

   type Bundle is record
      Pool : Source_Buffer := (others => Character'Val (0));
      Used : Source_Length := 0;
      Units : Span_Array := (others => (First => 1, After => 1));
   end record;

   --  Guarded subtraction keeps this predicate total even for oversized input
   --  Strings: its own evaluation never adds arbitrary source lengths.
   function Fits
     (Specification_Source, Body_Source, Main_Source : String) return Boolean
   is
     (Specification_Source'Length > 0
      and then Body_Source'Length > 0
      and then Main_Source'Length > 0
      and then Specification_Source'Length <= Max_Source_Length
      and then Body_Source'Length <=
        Max_Source_Length - Specification_Source'Length
      and then Main_Source'Length <=
        (Max_Source_Length - Specification_Source'Length) - Body_Source'Length)
     with Global => null;

   function Valid (Sources : Bundle) return Boolean is
     (Sources.Units (Package_Specification).First = 1
      and then Sources.Units (Package_Specification).First <
        Sources.Units (Package_Specification).After
      and then Sources.Units (Package_Body).First =
        Sources.Units (Package_Specification).After
      and then Sources.Units (Package_Body).First <
        Sources.Units (Package_Body).After
      and then Sources.Units (Main_Body).First =
        Sources.Units (Package_Body).After
      and then Sources.Units (Main_Body).First <
        Sources.Units (Main_Body).After
      and then Sources.Units (Main_Body).After = Sources.Used + 1)
     with Global => null;

   function Unit_Span (Sources : Bundle; Kind : Unit_Kind) return Span
     with Global => null,
          Pre => Valid (Sources),
          Post => Unit_Span'Result = Sources.Units (Kind)
            and then Unit_Span'Result.First < Unit_Span'Result.After
            and then Unit_Span'Result.After <= Sources.Used + 1;

   --  The result retains the unit's global pool offsets. String equality in
   --  Pack's contract compares contents even when the input bounds differ.
   function Unit_Source (Sources : Bundle; Kind : Unit_Kind) return String
     with Global => null,
          Pre => Valid (Sources),
          Post => Unit_Source'Result'First = Sources.Units (Kind).First
            and then Unit_Source'Result'Last = Sources.Units (Kind).After - 1
            and then Unit_Source'Result = Sources.Pool
              (Sources.Units (Kind).First .. Sources.Units (Kind).After - 1);

   --  A one-based prefix lets existing parsers retain their global offsets.
   --  Its end is the selected unit's end, not the complete pool's end.
   function Prefix (Sources : Bundle; Kind : Unit_Kind) return String
     with Global => null,
          Pre => Valid (Sources),
          Post => Prefix'Result'First = 1
            and then Prefix'Result'Last = Sources.Units (Kind).After - 1
            and then Prefix'Result = Sources.Pool
              (1 .. Sources.Units (Kind).After - 1);

   --  This operation only stores exact bytes. It performs no header, name,
   --  lexical, admission or filesystem checks and preserves all trivia.
   function Pack
     (Specification_Source, Body_Source, Main_Source : String) return Bundle
     with Global => null,
          Pre => Fits (Specification_Source, Body_Source, Main_Source),
          Post => Valid (Pack'Result)
            and then Pack'Result.Used =
              Specification_Source'Length + Body_Source'Length + Main_Source'Length
            and then Pack'Result.Units (Package_Specification) =
              (First => 1, After => Specification_Source'Length + 1)
            and then Pack'Result.Units (Package_Body) =
              (First => Specification_Source'Length + 1,
               After => Specification_Source'Length + Body_Source'Length + 1)
            and then Pack'Result.Units (Main_Body) =
              (First => Specification_Source'Length + Body_Source'Length + 1,
               After => Pack'Result.Used + 1)
            and then Unit_Source (Pack'Result, Package_Specification) =
              Specification_Source
            and then Unit_Source (Pack'Result, Package_Body) = Body_Source
            and then Unit_Source (Pack'Result, Main_Body) = Main_Source
            and then (for all Position in Pack'Result.Used + 1 .. Max_Source_Length =>
              Pack'Result.Pool (Position) = Character'Val (0));
end Silver_Application_Units;
