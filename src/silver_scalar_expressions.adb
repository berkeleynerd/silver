with Silver_Scalar_Literals;

package body Silver_Scalar_Expressions with SPARK_Mode => On is
   package Scalars renames Silver_Scalars;
   use type Scalars.Wide;
   use type Silver_Scalar_Literals.Literal_Value;

   function Lookup_Model
     (Text : String; Names : Environment; First, After : Literal_Position;
      Index : Binding_Count) return Binding_Count is
     (if First = 0 or else After <= First or else Index = 0 then 0
      elsif Equal_Name (Text, Names.Items (Index).First, Names.Items (Index).After,
                        First, After)
      then Index else Lookup_Model (Text, Names, First, After, Index - 1));

   function Lookup
     (Text : String; Names : Environment; First, After : Literal_Position)
      return Binding_Count is
      Index : Binding_Count := Names.Count;
   begin
      if First = 0 or else After <= First then return 0; end if;
      while Index > 0 loop
         pragma Loop_Invariant (Index <= Names.Count);
         pragma Loop_Invariant (Static =>
           Lookup_Model (Text, Names, First, After, Names.Count)
             = Lookup_Model (Text, Names, First, After, Index));
         pragma Loop_Variant (Decreases => Index);
         if Equal_Name (Text, Names.Items (Index).First, Names.Items (Index).After,
                        First, After)
         then return Index; end if;
         Index := Index - 1;
      end loop;
      return 0;
   end Lookup;

   function Skip (Text : String; Position : Literal_Position) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Runtime => (if Position = 0 then Skip'Result = 0
                else Skip'Result in Position .. Text'Last + 1),
         Static => Skip'Result =
           (if Position = 0 then 0 else Trivia_End (Text, Position)));
   function Skip (Text : String; Position : Literal_Position) return Literal_Position is
      Next : Cursor;
   begin
      if Position = 0 then return 0; end if;
      Next := Position;
      Skip_Trivia (Text, Next);
      return Next;
   end Skip;

   function Symbol (Text : String; Position : Literal_Position; Item : Character)
      return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Symbol'Result = 0
         or else Symbol'Result in Position + 1 .. Text'Last + 1;
   function Symbol (Text : String; Position : Literal_Position; Item : Character)
      return Literal_Position is
     (declare First : constant Literal_Position := Skip (Text, Position);
      begin (if First = 0 or else First > Text'Last or else Text (First) /= Item
             then 0 else First + 1));

   function Name_After (Text : String; Position : Literal_Position) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Runtime => Name_After'Result = 0
         or else Name_After'Result in Position + 1 .. Text'Last + 1,
         Static => Name_After'Result =
           (if Position = 0 then 0 else Identifier_End (Text, Position)));
   function Name_After (Text : String; Position : Literal_Position) return Literal_Position is
      Next : Cursor;
      Matched : Boolean;
   begin
      if Position = 0 then return 0; end if;
      Next := Position;
      Match_Identifier (Text, Next, Matched);
      return (if Matched then Next else 0);
   end Name_After;

   function Literal_Result
     (Number : Silver_Scalar_Literals.Literal_Result; Negative : Boolean)
      return Expression_Result
     with Post => Literal_Result'Result.After = 0
       or else (Literal_Result'Result.After = Number.After
         and then Literal_Result'Result.Operands = 1);
   function Literal_Result
     (Number : Silver_Scalar_Literals.Literal_Result; Negative : Boolean)
      return Expression_Result is
     (declare Checked : constant Scalars.Check_Result := Scalars.Checked
        ((if Negative then -Number.Value else Number.Value),
         (if Negative then -Number.Value else Number.Value));
      begin (if Number.After = 0 or else not Checked.Safe then Invalid
             else (Number.After, Checked.Bounds, 1, True)));

   function Unary_Result (Operand : Expression_Result; Negative : Boolean)
      return Expression_Result
     with Post => Unary_Result'Result.After = 0
       or else (Unary_Result'Result.After = Operand.After
         and then Unary_Result'Result.Operands = Operand.Operands);
   function Unary_Result (Operand : Expression_Result; Negative : Boolean)
      return Expression_Result is
     (declare Checked : constant Scalars.Check_Result :=
        (if Negative then Scalars.Negate (Operand.Bounds) else (True, Operand.Bounds));
      begin (if Operand.After = 0 or else not Checked.Safe then Invalid
             else (Operand with delta Bounds => Checked.Bounds)));

   function Binary_Result
     (Left, Right : Expression_Result; Operator : Character) return Expression_Result
     with Post => Binary_Result'Result.After = 0
       or else (Binary_Result'Result.After = Right.After
         and then Binary_Result'Result.Operands >= Left.Operands
         and then Binary_Result'Result.Operands >= Right.Operands);
   function Binary_Result
     (Left, Right : Expression_Result; Operator : Character) return Expression_Result is
     (declare Checked : constant Scalars.Check_Result :=
        (case Operator is
           when '+' => Scalars.Add (Left.Bounds, Right.Bounds),
           when '-' => Scalars.Subtract (Left.Bounds, Right.Bounds),
           when '*' => Scalars.Multiply (Left.Bounds, Right.Bounds),
           when others => Scalars.Invalid);
      begin (if Left.After = 0 or else Right.After = 0 or else not Checked.Safe
               or else Left.Operands > Max_Operands - Right.Operands
             then Invalid else (Right.After, Checked.Bounds, Left.Operands + Right.Operands,
                                Left.Static and then Right.Static)));

   function Close_Result (Text : String; Value : Expression_Result) return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Value.After <= Text'Last + 1,
       Post => Close_Result'Result.After = 0
         or else (Close_Result'Result.After in Value.After + 1 .. Text'Last + 1
           and then Close_Result'Result.Operands = Value.Operands);
   function Close_Result (Text : String; Value : Expression_Result) return Expression_Result is
     (declare After : constant Literal_Position := Symbol (Text, Value.After, ')');
      begin (if After = 0 then Invalid else (Value with delta After => After)));

   function Read_Atom
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First, Mask_After : Literal_Position; Allow_Sign : Boolean)
      return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Environment (Text, Names)
         and then Valid_Name_State (Text, Mask_First, Mask_After),
       Post => Read_Atom'Result.After = 0
         or else (Read_Atom'Result.After in Position + 1 .. Text'Last + 1
           and then Read_Atom'Result.Operands > 0);
   function Read_Atom
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First, Mask_After : Literal_Position; Allow_Sign : Boolean)
      return Expression_Result is
     (declare First : constant Literal_Position := Skip (Text, Position);
              After : constant Literal_Position := Name_After (Text, First);
              Index : constant Binding_Count := Lookup (Text, Names, First, After);
      begin
        (if First = 0 or else First > Text'Last then Invalid
         elsif Text (First) in '+' | '-' then
           (if not Allow_Sign then Invalid else Literal_Result
              (Silver_Scalar_Literals.Read_Integer (Text, Skip (Text, First + 1)), Text (First) = '-'))
         else
           (declare Number : constant Silver_Scalar_Literals.Literal_Result :=
              Silver_Scalar_Literals.Read_Integer (Text, First);
            begin
              (if Number.After /= 0 then Literal_Result (Number, False)
               elsif Index = 0 or else (Mask_First /= 0 and then
                 Equal_Name (Text, Mask_First, Mask_After, First, After))
               then Invalid
               else (After, Scalars.Normalize (Names.Items (Index).Bounds), 1, Names.Items (Index).Static)))));

   function Read_Unary
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First, Mask_After : Literal_Position) return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position in 1 .. Text'Last and then Text (Position) in '+' | '-'
         and then Valid_Environment (Text, Names)
         and then Valid_Name_State (Text, Mask_First, Mask_After),
       Post => Read_Unary'Result.After = 0
         or else (Read_Unary'Result.After in Position + 1 .. Text'Last + 1
           and then Read_Unary'Result.Operands > 0),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 1);
   function Read_Unary
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First, Mask_After : Literal_Position) return Expression_Result is
     (declare Next : constant Literal_Position := Skip (Text, Position + 1);
              Number : constant Silver_Scalar_Literals.Literal_Result :=
                Silver_Scalar_Literals.Read_Integer (Text, Next);
      begin Close_Result (Text,
        (if Number.After /= 0 then Literal_Result (Number, Text (Position) = '-')
         else Unary_Result
           (Read_Expression (Text, Next, Names, Mask_First, Mask_After, False), Text (Position) = '-'))));

   function Read_Compound
     (Text : String; Position : Literal_Position; Names : Environment;
      Left : Expression_Result; Mask_First, Mask_After : Literal_Position)
      return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Environment (Text, Names)
         and then Valid_Name_State (Text, Mask_First, Mask_After)
         and then (Left.After = 0 or else
           (Left.After in Position + 1 .. Text'Last + 1 and then Left.Operands > 0)),
       Post => Read_Compound'Result.After = 0
         or else (Read_Compound'Result.After in Position + 1 .. Text'Last + 1
           and then Read_Compound'Result.Operands > 0),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 1);
   function Read_Compound
     (Text : String; Position : Literal_Position; Names : Environment;
      Left : Expression_Result; Mask_First, Mask_After : Literal_Position)
      return Expression_Result is
     (declare Next : constant Literal_Position := Skip (Text, Left.After);
      begin
        (if Next = 0 or else Next > Text'Last then Invalid
         elsif Text (Next) = ')' then (Left with delta After => Next + 1)
         elsif Text (Next) not in '+' | '-' | '*' then Invalid
         else Close_Result (Text, Binary_Result
           (Left, Read_Expression (Text, Next + 1, Names, Mask_First, Mask_After, False), Text (Next)))));

   function Read_Group
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First, Mask_After : Literal_Position) return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position in 1 .. Text'Last and then Valid_Environment (Text, Names)
         and then Valid_Name_State (Text, Mask_First, Mask_After),
       Post => Read_Group'Result.After = 0
         or else (Read_Group'Result.After in Position + 1 .. Text'Last + 1
           and then Read_Group'Result.Operands > 0),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 2);
   function Read_Group
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First, Mask_After : Literal_Position) return Expression_Result is
     (declare First : constant Literal_Position := Skip (Text, Position + 1);
      begin
        (if First > Text'Last then Invalid
         elsif Text (First) in '+' | '-' then Read_Unary (Text, First, Names, Mask_First, Mask_After)
         else Read_Compound (Text, Position, Names,
           Read_Expression (Text, First, Names, Mask_First, Mask_After), Mask_First, Mask_After)));

   function Read_Expression
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First : Literal_Position := 0; Mask_After : Literal_Position := 0;
      Allow_Sign : Boolean := True) return Expression_Result is
     (declare First : constant Literal_Position := Skip (Text, Position);
      begin
        (if First = 0 or else First > Text'Last then Invalid
         elsif Text (First) = Character'Val (40) then Read_Group (Text, First, Names, Mask_First, Mask_After)
         else Read_Atom (Text, First, Names, Mask_First, Mask_After, Allow_Sign)));
end Silver_Scalar_Expressions;
