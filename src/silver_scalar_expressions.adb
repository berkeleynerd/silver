with Silver_Scalar_Literals;

package body Silver_Scalar_Expressions with SPARK_Mode => On is
   package Scalars renames Silver_Scalars;
   package Array_Bindings renames Silver_Array_Bindings;
   use type Scalars.Wide;
   use type Silver_Scalar_Literals.Literal_Value;

   function Body_Environment (Names : Environment) return Environment is
     (Count => Names.Count,
      Items => (for Index in Binding_Index => Body_Binding (Names.Items (Index))));

   function Lookup_Model
     (Text : String; Names : Environment; First, After : Literal_Position;
      Index : Binding_Count;
      Qualifier_First : Literal_Position := 0;
      Qualifier_After : Literal_Position := 0) return Binding_Count is
     (if First = 0 or else After <= First or else Index = 0 then 0
      elsif Equal_Name (Text, Names.Items (Index).First, Names.Items (Index).After,
                        First, After)
        and then (if Qualifier_First = 0 then Names.Items (Index).Qualifier_First = 0
          else Names.Items (Index).Qualifier_First > 0
            and then Equal_Name (Text, Names.Items (Index).Qualifier_First,
              Names.Items (Index).Qualifier_After, Qualifier_First, Qualifier_After))
      then Index else Lookup_Model
        (Text, Names, First, After, Index - 1, Qualifier_First, Qualifier_After));

   function Lookup
     (Text : String; Names : Environment; First, After : Literal_Position;
      Qualifier_First : Literal_Position := 0;
      Qualifier_After : Literal_Position := 0)
      return Binding_Count is
      Index : Binding_Count := Names.Count;
   begin
      if First = 0 or else After <= First then return 0; end if;
      while Index > 0 loop
         pragma Loop_Invariant (Index <= Names.Count);
         pragma Loop_Invariant (Static =>
           Lookup_Model (Text, Names, First, After, Names.Count, Qualifier_First, Qualifier_After)
             = Lookup_Model (Text, Names, First, After, Index, Qualifier_First, Qualifier_After));
         pragma Loop_Variant (Decreases => Index);
         if Equal_Name (Text, Names.Items (Index).First, Names.Items (Index).After,
                        First, After)
           and then (if Qualifier_First = 0 then Names.Items (Index).Qualifier_First = 0
             else Names.Items (Index).Qualifier_First > 0
               and then Equal_Name (Text, Names.Items (Index).Qualifier_First,
                 Names.Items (Index).Qualifier_After, Qualifier_First, Qualifier_After))
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

   function Read_Reference (Text : String; Position : Literal_Position)
      return Name_Reference is
     (declare First : constant Literal_Position := Skip (Text, Position);
              After : constant Literal_Position := Name_After (Text, First);
              Dot_First : constant Literal_Position := Skip (Text, After);
      begin
        (if First = 0 or else After <= First then Invalid_Reference
         elsif Dot_First > 0 and then Dot_First <= Text'Last and then Text (Dot_First) = '.'
           and then (Dot_First = Text'Last or else Text (Dot_First + 1) /= '.') then
           (declare Member_First : constant Literal_Position := Skip (Text, Dot_First + 1);
                    Member_After : constant Literal_Position := Name_After (Text, Member_First);
            begin
              (if Member_First = 0 or else Member_After <= Member_First
               then Invalid_Reference else (Member_First, Member_After, First, After)))
         else (First, After, 0, 0)));

   function Read_Array_Attribute
     (Text : String; Position : Literal_Position; Names : Environment;
      Arrays : Silver_Array_Bindings.Metadata;
      Mask_First : Literal_Position := 0; Mask_After : Literal_Position := 0;
      Range_Query : Boolean := False) return Expression_Result is
      First : constant Literal_Position := Skip (Text, Position);
      After : constant Literal_Position := Name_After (Text, First);
      Attribute_First : constant Literal_Position := Skip
        (Text, Symbol (Text, After, Character'Val (39)));
      Attribute_After : constant Literal_Position := Name_After (Text, Attribute_First);
      Target : constant Array_Bindings.Binding_Count := Array_Bindings.Lookup
        (Text, Arrays, First, After);
      Type_Id : constant Array_Bindings.Type_Count := Array_Bindings.Lookup_Type
        (Text, Arrays.Types, First, After);
      Bounds : Scalars.Interval;
   begin
      if First = 0 or else After <= First or else Attribute_First = 0
        or else Attribute_After <= Attribute_First
        or else Lookup (Text, Names, First, After) /= 0
        or else (Mask_First /= 0
          and then Equal_Name (Text, Mask_First, Mask_After, First, After))
      then return Invalid; end if;
      if Target /= 0 then
         if Arrays.Items (Target).Boolean_Elements then return Invalid; end if;
         Bounds := Arrays.Items (Target).Bounds;
      elsif Type_Id /= 0 then
         Bounds := Arrays.Types.Items (Type_Id).Bounds;
      else return Invalid;
      end if;
      if Range_Query then
         if not Name_Is (Text, Attribute_First, Attribute_After, "range")
         then return Invalid; end if;
      elsif Name_Is (Text, Attribute_First, Attribute_After, "first") then
         Bounds := Scalars.Singleton (Bounds.Lower);
      elsif Name_Is (Text, Attribute_First, Attribute_After, "last") then
         Bounds := Scalars.Singleton (Bounds.Upper);
      elsif Name_Is (Text, Attribute_First, Attribute_After, "length") then
         Bounds := Scalars.Singleton (Scalars.Value
           ((Scalars.Wide (Bounds.Upper) - Scalars.Wide (Bounds.Lower)) + 1));
      else return Invalid;
      end if;
      return (Attribute_After, Bounds, 1, True);
   end Read_Array_Attribute;

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
           when '/' => Scalars.Divide (Left.Bounds, Right.Bounds),
           when 'm' => Scalars.Modulo (Left.Bounds, Right.Bounds),
           when 'r' => Scalars.Remainder (Left.Bounds, Right.Bounds),
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

   function Read_Array_Atom
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First, Mask_After : Literal_Position;
      Target : Array_Bindings.Binding_Index; Arrays : Array_Bindings.Metadata;
      Initials : Array_Bindings.Element_Array; Elaborating : Boolean)
      return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Environment (Text, Names)
         and then Valid_Name_State (Text, Mask_First, Mask_After)
         and then Array_Bindings.Valid_Metadata (Text, Arrays)
         and then Target <= Arrays.Count,
       Post => Read_Array_Atom'Result.After = 0
         or else (Read_Array_Atom'Result.After in Position + 1 .. Text'Last + 1
           and then Read_Array_Atom'Result.Operands > 0),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 0);
   function Read_Array_Atom
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First, Mask_After : Literal_Position;
      Target : Array_Bindings.Binding_Index; Arrays : Array_Bindings.Metadata;
      Initials : Array_Bindings.Element_Array; Elaborating : Boolean)
      return Expression_Result is
     (declare Open_After : constant Literal_Position := Symbol (Text, Position, Character'Val (40));
      begin
        (if Open_After = 0 or else Arrays.Items (Target).Boolean_Elements then Invalid
         else
           (declare Subscript : constant Expression_Result := Read_Expression
              (Text, Open_After, Names, Mask_First, Mask_After,
               Arrays => Arrays, Array_Reads => No_Elements);
                    Close_After : constant Literal_Position := Symbol (Text, Subscript.After, ')');
            begin
              (if Close_After <= Position
                 or else Subscript.Operands = Max_Operands
                 or else not Array_Bindings.Contains (Arrays.Items (Target), Subscript.Bounds)
               then Invalid
               else (Close_After,
                 Array_Bindings.Read_Bounds (Arrays, Initials, Elaborating, Target, Subscript.Bounds),
                 Subscript.Operands + 1, False)))));

   function Read_Atom
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First, Mask_After : Literal_Position; Allow_Sign : Boolean;
      Arrays : Array_Bindings.Metadata;
      Initials : Array_Bindings.Element_Array; Elaborating : Boolean;
      Array_Reads : Array_Read_Mode)
      return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Environment (Text, Names)
         and then Valid_Name_State (Text, Mask_First, Mask_After)
         and then Array_Bindings.Valid_Metadata (Text, Arrays),
       Post => Read_Atom'Result.After = 0
         or else (Read_Atom'Result.After in Position + 1 .. Text'Last + 1
           and then Read_Atom'Result.Operands > 0),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 0);
   function Read_Atom
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First, Mask_After : Literal_Position; Allow_Sign : Boolean;
      Arrays : Array_Bindings.Metadata;
      Initials : Array_Bindings.Element_Array; Elaborating : Boolean;
      Array_Reads : Array_Read_Mode)
      return Expression_Result is
     (declare First : constant Literal_Position := Skip (Text, Position);
              Reference : constant Name_Reference := Read_Reference (Text, First);
              After : constant Literal_Position := Reference.After;
              Index : constant Binding_Count := Lookup
                (Text, Names, Reference.First, After,
                 Reference.Qualifier_First, Reference.Qualifier_After);
              Target : constant Array_Bindings.Binding_Count :=
                (if Reference.Qualifier_First = 0 then
                   Array_Bindings.Lookup (Text, Arrays, Reference.First, After) else 0);
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
               elsif After = 0 then Invalid
               elsif Mask_First /= 0
                 and then (if Reference.Qualifier_First = 0 then
                   Equal_Name (Text, Mask_First, Mask_After, Reference.First, After)
                   else Equal_Name (Text, Mask_First, Mask_After,
                     Reference.Qualifier_First, Reference.Qualifier_After))
               then Invalid
               --  A scoped scalar index hides an outer array of the same spelling.
               elsif Index /= 0 then
                 (After, Scalars.Normalize (Names.Items (Index).Bounds), 1, Names.Items (Index).Static)
               elsif Reference.Qualifier_First /= 0 then Invalid
               elsif Symbol (Text, After, Character'Val (39)) /= 0 then
                 Read_Array_Attribute (Text, Position, Names, Arrays, Mask_First, Mask_After)
               elsif Target = 0 or else Array_Reads = No_Elements
                 or else (Array_Reads = Mutable_Elements and then not Arrays.Items (Target).Mutable)
               then Invalid
               else Read_Array_Atom
                 (Text, After, Names, Mask_First, Mask_After, Target, Arrays, Initials, Elaborating)))));

   function Read_Unary
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First, Mask_After : Literal_Position; Arrays : Array_Bindings.Metadata;
      Initials : Array_Bindings.Element_Array; Elaborating : Boolean;
      Array_Reads : Array_Read_Mode) return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position in 1 .. Text'Last and then Text (Position) in '+' | '-'
         and then Valid_Environment (Text, Names)
         and then Valid_Name_State (Text, Mask_First, Mask_After)
         and then Array_Bindings.Valid_Metadata (Text, Arrays),
       Post => Read_Unary'Result.After = 0
         or else (Read_Unary'Result.After in Position + 1 .. Text'Last + 1
           and then Read_Unary'Result.Operands > 0),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 1);
   function Read_Unary
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First, Mask_After : Literal_Position; Arrays : Array_Bindings.Metadata;
      Initials : Array_Bindings.Element_Array; Elaborating : Boolean;
      Array_Reads : Array_Read_Mode) return Expression_Result is
     (declare Next : constant Literal_Position := Skip (Text, Position + 1);
              Number : constant Silver_Scalar_Literals.Literal_Result :=
                Silver_Scalar_Literals.Read_Integer (Text, Next);
      begin Close_Result (Text,
        (if Number.After /= 0 then Literal_Result (Number, Text (Position) = '-')
         else Unary_Result
           (Read_Expression (Text, Next, Names, Mask_First, Mask_After, False, Arrays, Initials, Elaborating, Array_Reads), Text (Position) = '-'))));

   function Binary_After (Text : String; Position : Literal_Position) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Binary_After'Result = 0
         or else Binary_After'Result in Position + 1 .. Text'Last + 1;
   function Binary_After (Text : String; Position : Literal_Position) return Literal_Position is
     (declare After : constant Literal_Position := Name_After (Text, Position);
      begin
        (if Position = 0 or else Position > Text'Last then 0
         elsif Text (Position) in '+' | '-' | '*' then Position + 1
         elsif Text (Position) = '/' then
           (if Position < Text'Last and then Text (Position + 1) = '=' then 0 else Position + 1)
         elsif After /= 0 and then
           (Name_Is (Text, Position, After, "mod") or else Name_Is (Text, Position, After, "rem"))
         then After else 0));

   function Read_Compound
     (Text : String; Position : Literal_Position; Names : Environment;
      Left : Expression_Result; Mask_First, Mask_After : Literal_Position;
      Arrays : Array_Bindings.Metadata;
      Initials : Array_Bindings.Element_Array; Elaborating : Boolean;
      Array_Reads : Array_Read_Mode)
      return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Environment (Text, Names)
         and then Valid_Name_State (Text, Mask_First, Mask_After)
         and then Array_Bindings.Valid_Metadata (Text, Arrays)
         and then (Left.After = 0 or else
           (Left.After in Position + 1 .. Text'Last + 1 and then Left.Operands > 0)),
       Post => Read_Compound'Result.After = 0
         or else (Read_Compound'Result.After in Position + 1 .. Text'Last + 1
           and then Read_Compound'Result.Operands > 0),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 1);
   function Read_Compound
     (Text : String; Position : Literal_Position; Names : Environment;
      Left : Expression_Result; Mask_First, Mask_After : Literal_Position;
      Arrays : Array_Bindings.Metadata;
      Initials : Array_Bindings.Element_Array; Elaborating : Boolean;
      Array_Reads : Array_Read_Mode)
      return Expression_Result is
     (declare Next : constant Literal_Position := Skip (Text, Left.After);
              After : constant Literal_Position := Binary_After (Text, Next);
      begin
        (if Next = 0 or else Next > Text'Last then Invalid
         elsif Text (Next) = ')' then (Left with delta After => Next + 1)
         elsif After = 0 then Invalid
         else Close_Result (Text, Binary_Result
           (Left, Read_Expression (Text, After, Names, Mask_First, Mask_After, False, Arrays, Initials, Elaborating, Array_Reads), Lowercase (Text (Next))))));

   function Read_Group
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First, Mask_After : Literal_Position; Arrays : Array_Bindings.Metadata;
      Initials : Array_Bindings.Element_Array; Elaborating : Boolean;
      Array_Reads : Array_Read_Mode) return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position in 1 .. Text'Last and then Valid_Environment (Text, Names)
         and then Valid_Name_State (Text, Mask_First, Mask_After)
         and then Array_Bindings.Valid_Metadata (Text, Arrays),
       Post => Read_Group'Result.After = 0
         or else (Read_Group'Result.After in Position + 1 .. Text'Last + 1
           and then Read_Group'Result.Operands > 0),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 2);
   function Read_Group
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First, Mask_After : Literal_Position; Arrays : Array_Bindings.Metadata;
      Initials : Array_Bindings.Element_Array; Elaborating : Boolean;
      Array_Reads : Array_Read_Mode) return Expression_Result is
     (declare First : constant Literal_Position := Skip (Text, Position + 1);
      begin
        (if First > Text'Last then Invalid
         elsif Text (First) in '+' | '-' then Read_Unary (Text, First, Names, Mask_First, Mask_After, Arrays => Arrays, Initials => Initials, Elaborating => Elaborating, Array_Reads => Array_Reads)
         else Read_Compound (Text, Position, Names,
           Read_Expression (Text, First, Names, Mask_First, Mask_After, Arrays => Arrays, Initials => Initials, Elaborating => Elaborating, Array_Reads => Array_Reads), Mask_First, Mask_After, Arrays => Arrays, Initials => Initials, Elaborating => Elaborating, Array_Reads => Array_Reads)));

   function Read_Expression
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First : Literal_Position := 0; Mask_After : Literal_Position := 0;
      Allow_Sign : Boolean := True;
      Arrays : Silver_Array_Bindings.Metadata := Silver_Array_Bindings.Empty_Metadata;
      Initials : Silver_Array_Bindings.Element_Array := Silver_Array_Bindings.Empty_Values;
      Elaborating : Boolean := False;
      Array_Reads : Array_Read_Mode := All_Elements) return Expression_Result is
     (declare First : constant Literal_Position := Skip (Text, Position);
      begin
        (if First = 0 or else First > Text'Last then Invalid
         elsif Text (First) = Character'Val (40) then Read_Group (Text, First, Names, Mask_First, Mask_After, Arrays => Arrays, Initials => Initials, Elaborating => Elaborating, Array_Reads => Array_Reads)
         else Read_Atom (Text, First, Names, Mask_First, Mask_After, Allow_Sign, Arrays, Initials, Elaborating, Array_Reads)));
end Silver_Scalar_Expressions;
