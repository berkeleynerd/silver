with Silver_Profile;

package Silver_Scalar_Literals with SPARK_Mode => On is
   use Silver_Profile;
   subtype Literal_Position is Natural range 0 .. Max_Source_Length + 1;
   Max_Magnitude : constant := 2_147_483_648;
   subtype Literal_Value is Long_Long_Integer range 0 .. Max_Magnitude;
   subtype Literal_Base is Long_Long_Integer range 2 .. 16;
   type Literal_Result is record
      After : Literal_Position;
      Value : Literal_Value;
   end record;
   Invalid : constant Literal_Result := (After => 0, Value => 0);

   --  The functional specification is source-checked and interpreted in Lean;
   --  the executable scanner below is proved equal to it by GNATprove.
   function Model (Text : String; Position : Literal_Position)
      return Literal_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1;

   --  Ada integer spellings, with magnitude and nonnegative exponent each
   --  bounded by 2**31. Unary signs and the signed value check belong to the
   --  expression parser; this admits the magnitude of Integer'First.
   --  Whitespace belongs to the caller, never inside a literal.
   function Read_Integer (Text : String; Position : Literal_Position)
      return Literal_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Runtime => Read_Integer'Result.After = 0
         or else (Read_Integer'Result.After > Position
           and then Read_Integer'Result.After <= Text'Last + 1),
         Static => Read_Integer'Result = Model (Text, Position));
end Silver_Scalar_Literals;
