package Silver_Numbers with SPARK_Mode => On is
   --  Exact positional base-10 relation. Removing the rightmost digit must
   --  produce the quotient, while that digit is the remainder; the empty
   --  prefix represents zero. This uses no bounded or saturating parser.
   function Represents (Text : String; Value : Natural) return Boolean
     with Ghost,
          Global => null,
          Pre => Text'Length <= Natural'Width,
          Subprogram_Variant => (Decreases => Text'Length);

   function Decimal (Value : Natural) return String
     with Global => null,
          Post => Decimal'Result'Length in 1 .. Natural'Width
            and then (for all Item of Decimal'Result => Item in '0' .. '9')
            and then Represents (Decimal'Result, Value)
            and then (Decimal'Result'Length = 1
              or else Decimal'Result (Decimal'Result'First) /= '0');
end Silver_Numbers;
