with Silver_Profile;
with Silver_Output_Lexical;
with Silver_Scalars;
with Silver_Array_Bindings;

package Silver_Scalar_Expressions with SPARK_Mode => On is
   use Silver_Profile;
   use Silver_Output_Lexical;
   Max_Bindings : constant Positive := Max_Source_Length / 12;
   Max_Operands : constant Positive := 64;
   subtype Binding_Count is Natural range 0 .. Max_Bindings;
   subtype Binding_Index is Positive range 1 .. Max_Bindings;
   subtype Operand_Count is Natural range 0 .. Max_Operands;
   type Binding is record
      First, After : Literal_Position;
      Bounds : Silver_Scalars.Interval;
      Static : Boolean;
      Declared_Bounds : Silver_Scalars.Interval;
      Mutable : Boolean;
   end record;
   Empty_Binding : constant Binding :=
     (0, 0, Silver_Scalars.Empty, False, Silver_Scalars.Empty, False);
   type Binding_Array is array (Binding_Index) of Binding;
   type Environment is record
      Count : Binding_Count;
      Items : Binding_Array;
   end record;
   Empty_Environment : constant Environment := (0, (others => Empty_Binding));
   function Valid_Environment (Text : String; Names : Environment) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_Environment (Text : String; Names : Environment) return Boolean is
     (for all Index in 1 .. Names.Count =>
        Names.Items (Index).First > 0
        and then Valid_Name_State
          (Text, Names.Items (Index).First, Names.Items (Index).After));
   function Lookup_Model
     (Text : String; Names : Environment; First, After : Literal_Position;
      Index : Binding_Count) return Binding_Count
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Environment (Text, Names) and then Index <= Names.Count
         and then First <= Text'Last + 1 and then After <= Text'Last + 1,
       Post => Lookup_Model'Result <= Index,
       Subprogram_Variant => (Decreases => Index);
   function Lookup
     (Text : String; Names : Environment; First, After : Literal_Position)
      return Binding_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Environment (Text, Names)
         and then First <= Text'Last + 1 and then After <= Text'Last + 1,
       Post => (Runtime => Lookup'Result <= Names.Count,
         Static => Lookup'Result = Lookup_Model (Text, Names, First, After, Names.Count));
   function Append (Names : Environment; Item : Binding) return Environment is
     ((Count => Names.Count + 1,
       Items => (Names.Items with delta Names.Count + 1 => Item)))
     with Pre => Names.Count < Max_Bindings;

   --  Elaboration reads exact initialized values. Executable statements use
   --  each mutable object's complete declared range, without flow narrowing.
   function Body_Binding (Item : Binding) return Binding is
     (Item with delta Bounds =>
       (if Item.Mutable then Item.Declared_Bounds else Item.Bounds));
   function Body_Environment (Names : Environment) return Environment
     with Global => null,
       Post => Body_Environment'Result.Count = Names.Count
         and then (for all Index in Binding_Index =>
           Body_Environment'Result.Items (Index) = Body_Binding (Names.Items (Index)));

   type Expression_Result is record
      After : Literal_Position;
      Bounds : Silver_Scalars.Interval;
      Operands : Operand_Count;
      Static : Boolean;
   end record;
   Invalid : constant Expression_Result := (0, Silver_Scalars.Empty, 0, False);
   --  Unary signs on literals may be bare; every other unary or binary
   --  operation is explicitly parenthesized. The mask
   --  excludes a newly declared loop index from its own bounds, as Ada requires.
   function Read_Expression
     (Text : String; Position : Literal_Position; Names : Environment;
      Mask_First : Literal_Position := 0; Mask_After : Literal_Position := 0;
      Allow_Sign : Boolean := True;
      Arrays : Silver_Array_Bindings.Metadata := Silver_Array_Bindings.Empty_Metadata;
      Initials : Silver_Array_Bindings.Element_Array := Silver_Array_Bindings.Empty_Values;
      Elaborating : Boolean := False)
      return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Environment (Text, Names)
         and then Valid_Name_State (Text, Mask_First, Mask_After)
         and then Silver_Array_Bindings.Valid_Metadata (Text, Arrays),
       Post => Read_Expression'Result.After = 0
         or else (Read_Expression'Result.After in Position + 1 .. Text'Last + 1
           and then Read_Expression'Result.Operands > 0),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 3);
end Silver_Scalar_Expressions;
