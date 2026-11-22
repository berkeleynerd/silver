package body Silver_Application_Units
  with SPARK_Mode => On
is
   function Unit_Span (Sources : Bundle; Kind : Unit_Kind) return Span is
     (Sources.Units (Kind));

   function Unit_Source (Sources : Bundle; Kind : Unit_Kind) return String is
     (Sources.Pool
        (Sources.Units (Kind).First .. Sources.Units (Kind).After - 1));

   function Prefix (Sources : Bundle; Kind : Unit_Kind) return String is
     (Sources.Pool (1 .. Sources.Units (Kind).After - 1));

   function Pack
     (Specification_Source, Body_Source, Main_Source : String) return Bundle
   is
      Specification_After : constant Unit_Position :=
        Specification_Source'Length + 1;
      Body_After : constant Unit_Position :=
        Specification_Source'Length + Body_Source'Length + 1;
      Used : constant Source_Length :=
        Specification_Source'Length + Body_Source'Length + Main_Source'Length;
      Result : Bundle :=
        (Pool => (others => Character'Val (0)),
         Used => Used,
         Units =>
           (Package_Specification => (First => 1, After => Specification_After),
            Package_Body => (First => Specification_After, After => Body_After),
            Main_Body => (First => Body_After, After => Used + 1)));
   begin
      --  Slice assignment slides arbitrary input bounds onto the pool offsets
      --  without changing any byte or adding a newline after an EOF comment.
      Result.Pool (1 .. Specification_After - 1) := Specification_Source;
      Result.Pool (Specification_After .. Body_After - 1) := Body_Source;
      Result.Pool (Body_After .. Used) := Main_Source;
      return Result;
   end Pack;
end Silver_Application_Units;
