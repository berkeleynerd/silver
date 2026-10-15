package body Silver_Scalar_Literals with SPARK_Mode => On is
   function Digit (Item : Character) return Long_Long_Integer is
     (if Item in '0' .. '9' then Character'Pos (Item) - Character'Pos ('0')
      elsif Item in 'A' .. 'F' then (Character'Pos (Item) - Character'Pos ('A')) + 10
      elsif Item in 'a' .. 'f' then (Character'Pos (Item) - Character'Pos ('a')) + 10
      else 16);

   function Numeral_Tail
     (Text : String; Base : Literal_Base; Position : Literal_Position;
      Value : Literal_Value; Need_Digit : Boolean) return Literal_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position in 1 .. Text'Last + 1,
       Post => Numeral_Tail'Result.After = 0
         or else (Numeral_Tail'Result.After <= Text'Last + 1
           and then (if Need_Digit then Numeral_Tail'Result.After > Position
                     else Numeral_Tail'Result.After >= Position)),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position);
   function Numeral_Tail
     (Text : String; Base : Literal_Base; Position : Literal_Position;
      Value : Literal_Value; Need_Digit : Boolean) return Literal_Result is
     (if Position > Text'Last then
        (if Need_Digit then Invalid else (After => Position, Value => Value))
      elsif Digit (Text (Position)) < Base then
        (if Value > (Max_Magnitude - Digit (Text (Position))) / Base then Invalid
         else Numeral_Tail (Text, Base, Position + 1,
           Value * Base + Digit (Text (Position)), False))
      elsif Text (Position) = '_' then
        (if Need_Digit then Invalid
         else Numeral_Tail (Text, Base, Position + 1, Value, True))
      else (if Need_Digit then Invalid else (After => Position, Value => Value)));

   function Numeral_Model (Text : String; Position : Literal_Position; Base : Literal_Base)
      return Literal_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Numeral_Model'Result.After = 0
         or else (Numeral_Model'Result.After > Position
           and then Numeral_Model'Result.After <= Text'Last + 1);
   function Numeral_Model (Text : String; Position : Literal_Position; Base : Literal_Base)
      return Literal_Result is
     (if Position = 0 then Invalid else Numeral_Tail (Text, Base, Position, 0, True));

   function Numeral (Text : String; Position : Literal_Position; Base : Literal_Base)
      return Literal_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Runtime => Numeral'Result.After = 0
         or else (Numeral'Result.After > Position
           and then Numeral'Result.After <= Text'Last + 1),
         Static => Numeral'Result = Numeral_Model (Text, Position, Base));
   function Numeral (Text : String; Position : Literal_Position; Base : Literal_Base)
      return Literal_Result is
      Next : Literal_Position := Position;
      Value : Literal_Value := 0;
      Need_Digit : Boolean := True;
   begin
      if Next = 0 then return Invalid; end if;
      while Next <= Text'Last loop
         pragma Loop_Invariant (Next in Position .. Text'Last + 1);
         pragma Loop_Invariant (Next = Position or else Next > Position);
         pragma Loop_Invariant (if Next = Position then Need_Digit);
         pragma Loop_Invariant (Static => Numeral_Model (Text, Position, Base)
           = Numeral_Tail (Text, Base, Next, Value, Need_Digit));
         pragma Loop_Variant (Increases => Next);
         if Digit (Text (Next)) < Base then
            if Value > (Max_Magnitude - Digit (Text (Next))) / Base then
               return Invalid;
            end if;
            Value := Value * Base + Digit (Text (Next));
            Need_Digit := False;
         elsif Text (Next) = '_' then
            if Need_Digit then return Invalid; end if;
            Need_Digit := True;
         else
            exit;
         end if;
         Next := Next + 1;
      end loop;
      if Need_Digit then return Invalid; end if;
      return (After => Next, Value => Value);
   end Numeral;

   type Mantissa_Result is record
      After : Literal_Position;
      Value : Literal_Value;
      Base : Literal_Base;
   end record;
   Invalid_Mantissa : constant Mantissa_Result := (After => 0, Value => 0, Base => 10);

   function Mantissa_Model (Text : String; Position : Literal_Position) return Mantissa_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Mantissa_Model'Result.After = 0
         or else (Mantissa_Model'Result.After > Position
           and then Mantissa_Model'Result.After <= Text'Last + 1);
   function Mantissa_Model (Text : String; Position : Literal_Position) return Mantissa_Result is
     (declare Leading : constant Literal_Result := Numeral_Model (Text, Position, 10);
      begin
       (if Leading.After = 0 then Invalid_Mantissa
        elsif Leading.After <= Text'Last and then Text (Leading.After) in '#' | ':' then
          (if Leading.Value not in Literal_Base then Invalid_Mantissa else
             (declare Number : constant Literal_Result :=
                Numeral_Model (Text, Leading.After + 1, Leading.Value);
              begin (if Number.After = 0 then Invalid_Mantissa
                elsif Number.After > Text'Last or else Text (Number.After) /= Text (Leading.After)
                then Invalid_Mantissa
                else (After => Number.After + 1, Value => Number.Value, Base => Leading.Value))))
        else (After => Leading.After, Value => Leading.Value, Base => 10)));

   function Read_Mantissa (Text : String; Position : Literal_Position) return Mantissa_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Runtime => Read_Mantissa'Result.After = 0
         or else (Read_Mantissa'Result.After > Position
           and then Read_Mantissa'Result.After <= Text'Last + 1),
         Static => Read_Mantissa'Result = Mantissa_Model (Text, Position));
   function Read_Mantissa (Text : String; Position : Literal_Position) return Mantissa_Result is
      Leading : constant Literal_Result := Numeral (Text, Position, 10);
   begin
      if Leading.After = 0 then return Invalid_Mantissa; end if;
      if Leading.After <= Text'Last and then Text (Leading.After) in '#' | ':' then
         if Leading.Value not in Literal_Base then return Invalid_Mantissa; end if;
         declare
            Number : constant Literal_Result := Numeral (Text, Leading.After + 1, Leading.Value);
         begin
            if Number.After = 0 then return Invalid_Mantissa; end if;
            if Number.After > Text'Last or else Text (Number.After) /= Text (Leading.After) then
               return Invalid_Mantissa;
            end if;
            return (After => Number.After + 1, Value => Number.Value, Base => Leading.Value);
         end;
      end if;
      return (After => Leading.After, Value => Leading.Value, Base => 10);
   end Read_Mantissa;

   type Scale_Result is record
      Valid : Boolean;
      Value : Literal_Value;
   end record;
   Invalid_Scale : constant Scale_Result := (Valid => False, Value => 0);

   function Scale_Model (Base : Literal_Base; Value, Exponent : Literal_Value) return Scale_Result
     with Ghost => Static, Global => null,
       Subprogram_Variant => (Decreases => Exponent);
   function Scale_Model (Base : Literal_Base; Value, Exponent : Literal_Value) return Scale_Result is
     (if Exponent = 0 or else Value = 0 then (Valid => True, Value => Value)
      elsif Exponent > 31 then Invalid_Scale
      elsif Value > Max_Magnitude / Base then Invalid_Scale
      else Scale_Model (Base, Value * Base, Exponent - 1));

   function Power (Base : Literal_Base; Value, Exponent : Literal_Value) return Scale_Result
     with Global => null, Post => (Static => Power'Result = Scale_Model (Base, Value, Exponent));
   function Power (Base : Literal_Base; Value, Exponent : Literal_Value) return Scale_Result is
      Result : Literal_Value := Value;
   begin
      if Exponent = 0 or else Value = 0 then
         return (Valid => True, Value => Value);
      end if;
      if Exponent > 31 then return Invalid_Scale; end if;
      for Index in 1 .. Exponent loop
         pragma Loop_Invariant (Static => Scale_Model (Base, Value, Exponent)
           = Scale_Model (Base, Result, (Exponent - Index) + 1));
         if Result > Max_Magnitude / Base then return Invalid_Scale; end if;
         Result := Result * Base;
      end loop;
      return (Valid => True, Value => Result);
   end Power;

   function Exponent_Start (Text : String; Position : Literal_Position) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position in 1 .. Text'Last + 1,
       Post => Exponent_Start'Result in Position .. Text'Last + 1;
   function Exponent_Start (Text : String; Position : Literal_Position) return Literal_Position is
     (if Position <= Text'Last and then Text (Position) = '+' then Position + 1 else Position);

   function Exponent_Model (Text : String; Number : Mantissa_Result) return Literal_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Number.After in 1 .. Text'Last + 1,
       Post => Exponent_Model'Result.After = 0
         or else Exponent_Model'Result.After in Number.After .. Text'Last + 1;
   function Exponent_Model (Text : String; Number : Mantissa_Result) return Literal_Result is
     (if Number.After <= Text'Last and then Text (Number.After) in 'e' | 'E' then
        (declare Exponent : constant Literal_Result :=
           Numeral_Model (Text, Exponent_Start (Text, Number.After + 1), 10);
         begin (if Exponent.After = 0 then Invalid else
           (declare Scaled : constant Scale_Result := Scale_Model (Number.Base, Number.Value, Exponent.Value);
            begin (if not Scaled.Valid then Invalid else (After => Exponent.After, Value => Scaled.Value)))))
      else (After => Number.After, Value => Number.Value));

   function Read_Exponent (Text : String; Number : Mantissa_Result) return Literal_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Number.After in 1 .. Text'Last + 1,
       Post => (Runtime => Read_Exponent'Result.After = 0
         or else Read_Exponent'Result.After in Number.After .. Text'Last + 1,
         Static => Read_Exponent'Result = Exponent_Model (Text, Number));
   function Read_Exponent (Text : String; Number : Mantissa_Result) return Literal_Result is
   begin
      if Number.After <= Text'Last and then Text (Number.After) in 'e' | 'E' then
         declare
            Exponent : constant Literal_Result :=
              Numeral (Text, Exponent_Start (Text, Number.After + 1), 10);
         begin
            if Exponent.After = 0 then return Invalid; end if;
            declare
               Scaled : constant Scale_Result := Power (Number.Base, Number.Value, Exponent.Value);
            begin
               if not Scaled.Valid then return Invalid; end if;
               return (After => Exponent.After, Value => Scaled.Value);
            end;
         end;
      end if;
      return (After => Number.After, Value => Number.Value);
   end Read_Exponent;

   function Model (Text : String; Position : Literal_Position) return Literal_Result is
     (declare Number : constant Mantissa_Result := Mantissa_Model (Text, Position);
      begin (if Number.After = 0 then Invalid else
        (declare Result : constant Literal_Result := Exponent_Model (Text, Number);
         begin (if Result.After = 0 or else
           (Result.After <= Text'Last and then Is_Identifier_Character (Text (Result.After)))
           then Invalid else Result))));

   function Read_Integer (Text : String; Position : Literal_Position)
      return Literal_Result is
      Number : constant Mantissa_Result := Read_Mantissa (Text, Position);
   begin
      if Number.After = 0 then return Invalid; end if;
      declare
         Result : constant Literal_Result := Read_Exponent (Text, Number);
      begin
         if Result.After = 0 or else
           (Result.After <= Text'Last and then Is_Identifier_Character (Text (Result.After)))
         then return Invalid; end if;
         return Result;
      end;
   end Read_Integer;
end Silver_Scalar_Literals;
