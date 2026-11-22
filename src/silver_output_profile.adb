--  Shared declarations and finite statements use the same bounded expressions.
--  Declarations precede guards; assignments preserve fixed object bounds, so
--  statement sequencing and branch joins preserve all binding length shapes.
with Silver_Profile;
with Silver_Output_Lexical;
with Silver_Path_Facts;
with Silver_Integer_Literals;
with Silver_Names;
with Silver_Scalars;
with Silver_Scalar_Literals;
with Silver_Scalar_Expressions;
with Silver_Array_Bindings;
with Silver_Integer_Image;
with Silver_Length_Intervals;
with Silver_Function_Bindings;
with Silver_Procedure_Bindings;

package body Silver_Output_Profile
  with SPARK_Mode => On
is
   use Silver_Profile;
   use Silver_Output_Lexical;
   package Names renames Silver_Names;
   package Scalars renames Silver_Scalars;
   package Scalar_Expressions renames Silver_Scalar_Expressions;
   package Array_Bindings renames Silver_Array_Bindings;
   package Functions renames Silver_Function_Bindings;
   package Procedures renames Silver_Procedure_Bindings;
   package Packages renames Silver_Package_Bindings;
   package Units renames Silver_Application_Units;
   use type Packages.Name_Span;
   use type Packages.Export_Kind;
   use type Packages.Routine_Kind;
   use type Packages.State_Set;
   use type Units.Span_Array;
   use type Procedures.Metadata;
   use type Procedures.Signature;
   use type Procedures.Formal;
   use type Procedures.Parameter_Mode;
   use type Functions.Scalar_Kind;
   use type Functions.Metadata;
   use type Functions.Signature;
   use type Functions.Formal;
   use type Scalars.Wide;
   use type Scalars.Interval;
   use type Names.Operation_Kind;
   use type Scalar_Expressions.Binding;
   use type Array_Bindings.Binding;
   use type Array_Bindings.Array_Type;
   use type Functions.Signature_Array;
   use type Functions.Formal_Array;
   use type Procedures.Signature_Array;
   use type Procedures.Formal_Array;
   use type Scalar_Expressions.Binding_Array;
   use type Array_Bindings.Type_Array;
   use type Array_Bindings.Binding_Array;
   use type Array_Bindings.Element_Array;
   package Image_Lengths renames Silver_Integer_Image;
   package Length_Intervals renames Silver_Length_Intervals;

   function Is_Word_Token (Token : Token_Kind) return Boolean is
     (Token in With_Keyword .. End_Keyword | Constant_Keyword | String_Name
        | Arguments_Name | First_Or_Default_Name | If_Keyword
        | Input_Is_Valid_Name | Then_Keyword | Else_Keyword | Elsif_Keyword | Reject_Name
        | And_Keyword | Length_Name | Or_Keyword | Not_Keyword | Null_Keyword
        | Integer_Name | For_Keyword | In_Keyword | Reverse_Keyword | Loop_Keyword | Range_Keyword
        | Array_Keyword | Of_Keyword | Subtype_Keyword | Type_Keyword
        | Boolean_Name | True_Name | False_Name | Xor_Keyword | Character_Name | Function_Keyword | Return_Keyword | Out_Keyword);

   function Spelling (Token : Token_Kind) return String is
     (case Token is
         when With_Keyword => "with",
         when IO_Name => "silver_io",
         when Procedure_Keyword => "procedure",
         when Main_Name => "main",
         when Is_Keyword => "is",
         when Pragma_Keyword => "pragma",
         when SPARK_Mode_Name => "spark_mode",
         when On_Name => "on",
         when Begin_Keyword => "begin",
         when Put_Line_Name => "put_line",
         when End_Keyword => "end",
         when Left_Parenthesis => "(",
         when Right_Parenthesis => ")",
         when Semicolon => ";",
         when Dot => ".",
         when String_Literal => """",
         when Colon => ":",
         when Constant_Keyword => "constant",
         when String_Name => "string",
         when Assignment => ":=",
         when Arguments_Name => "silver_arguments",
         when First_Or_Default_Name => "first_or_default",
         when If_Keyword => "if",
         when Input_Is_Valid_Name => "input_is_valid",
         when Then_Keyword => "then",
         when Else_Keyword => "else",
         when Elsif_Keyword => "elsif",
         when Reject_Name => "reject",
         when Ampersand => "&",
         when And_Keyword => "and",
         when Or_Keyword => "or",
         when Not_Keyword => "not",
         when Not_Equal => "/=",
         when Less => "<",
         when Greater => ">",
         when Greater_Equal => ">=",
         when Apostrophe => "'",
         when Length_Name => "length",
         when Less_Equal => "<=",
         when Capacity_Literal => "0",
         when Equal => "=",
         when Null_Keyword => "null",
         when Integer_Name => "integer",
         when For_Keyword => "for",
         when In_Keyword => "in",
         when Reverse_Keyword => "reverse",
         when Loop_Keyword => "loop",
         when Range_Delimiter => "..",
         when Range_Keyword => "range",
         when Array_Keyword => "array",
         when Type_Keyword => "type",
         when Subtype_Keyword => "subtype",
         when Character_Name => "character",
         when Out_Keyword => "out",
         when Function_Keyword => "function",
         when Return_Keyword => "return",
         when Boolean_Name => "boolean",
         when True_Name => "true",
         when False_Name => "false",
         when Xor_Keyword => "xor",
         when Of_Keyword => "of",
         when Comma => ",",
         when Arrow => "=>",
         when Argument_Declaration | Declarations | Assignment_Target
            | Target_Reference | Dynamic_Reference | Assignment_Value
            | Output_Expression | Comparison_Expression | Statements | Context_Clauses => "_");

   function Tokens (Form : Form_Kind) return Token_Sequence is
     (case Form is
      when Direct_Form =>
         (Context_Clauses, Procedure_Keyword,
          Main_Name, Is_Keyword, Pragma_Keyword, SPARK_Mode_Name,
          Left_Parenthesis, On_Name, Right_Parenthesis, Semicolon,
          Declarations, Begin_Keyword, Statements, End_Keyword, Main_Name, Semicolon),
      when Argument_Form =>
         (Context_Clauses, Procedure_Keyword, Main_Name,
          Is_Keyword, Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis,
          On_Name, Right_Parenthesis, Semicolon, Argument_Declaration,
          Declarations, Begin_Keyword, Statements, End_Keyword, Main_Name, Semicolon));

   function Normalized (Source : String) return String
     with Global => null, Pre => Source'Length <= Max_Source_Length,
       Post => Normalized'Result'First = 1
         and then Normalized'Result'Length = Source'Length
         and then Normalized'Result = Source
   is
      Text : constant String (1 .. Source'Length) := Source;
   begin
      return Text;
   end Normalized;

   function Allowed_Source (Text : String) return Boolean is
     (for all Item of Text => Is_Allowed_Character (Item));

   subtype Binding_Count is Natural range 0 .. Max_Bindings;
   subtype Binding_Index is Positive range 1 .. Max_Bindings;
   type Binding_Info is record
      First, After, Value_First : Literal_Position;
      Static_Length : Capacity_Value;
      Dynamic, Mutable, Is_Character : Boolean;
      First_Index, Last_Index : Scalars.Value;
   end record;
   Empty_Binding : constant Binding_Info :=
     (First => 0, After => 0, Value_First => 0, Static_Length => 0,
      Dynamic => False, Mutable => False, Is_Character => False,
      First_Index => 1, Last_Index => 0);
   type Binding_Array is array (Binding_Index) of Binding_Info;
   type Binding_Environment is record
      Count : Binding_Count;
      Items : Binding_Array;
   end record;
   Empty_Environment : constant Binding_Environment :=
     (Count => 0, Items => (others => Empty_Binding));

   --  Nonempty bounds grow by at most the source byte capacity per
   --  declaration. Arbitrary null bounds remain exact and do not contribute a
   --  nonempty lower bound to concatenation. This derived ceiling is far below
   --  Integer'Last even after one additional body expression.
   function Fixed_Bounds_Valid
     (Length : Capacity_Value; Dynamic, Is_Character : Boolean;
      First_Index, Last_Index : Scalars.Value; Slot : Binding_Index) return Boolean is
     (if Is_Character then
        not Dynamic and then Length = 1 and then First_Index = 1 and then Last_Index = 1
      elsif Dynamic then Length = 0
      elsif Length = 0 then First_Index > Last_Index
      else First_Index >= 1 and then Last_Index >= First_Index
        and then (Scalars.Wide (Last_Index) - Scalars.Wide (First_Index)) + 1 = Scalars.Wide (Length)
        and then Scalars.Wide (Last_Index) <= Scalars.Wide (Slot) * Scalars.Wide (Max_Source_Length));

   --  A:Boolean:=B; consumes thirteen bytes. Boolean metadata is immutable;
   --  no snapshot stores a predicate's scalar or String refinement facts.
   Max_Boolean_Bindings : constant Positive := Max_Source_Length / 13;
   subtype Boolean_Count is Natural range 0 .. Max_Boolean_Bindings;
   subtype Boolean_Index is Positive range 1 .. Max_Boolean_Bindings;
   type Boolean_Binding is record
      First, After : Literal_Position;
      Mutable : Boolean;
      Qualifier_First, Qualifier_After : Literal_Position := 0;
      Known, Value : Boolean := False;
   end record;
   Empty_Boolean_Binding : constant Boolean_Binding := (0, 0, False, 0, 0, False, False);
   type Boolean_Binding_Array is array (Boolean_Index) of Boolean_Binding;
   type Boolean_Environment is record
      Count : Boolean_Count;
      Items : Boolean_Binding_Array;
   end record;
   Empty_Booleans : constant Boolean_Environment :=
     (0, (others => Empty_Boolean_Binding));
   function Valid_Booleans (Text : String; Booleans : Boolean_Environment) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_Booleans (Text : String; Booleans : Boolean_Environment) return Boolean is
     (for all Index in 1 .. Booleans.Count =>
        Booleans.Items (Index).First > 0
        and then Valid_Name_State
          (Text, Booleans.Items (Index).First, Booleans.Items (Index).After)
        and then Valid_Name_State
          (Text, Booleans.Items (Index).Qualifier_First, Booleans.Items (Index).Qualifier_After));

   function Valid_Names (Text : String; Names : Binding_Environment) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_Names (Text : String; Names : Binding_Environment) return Boolean is
     (for all I in 1 .. Names.Count =>
        Names.Items (I).First > 0
        and then Valid_Name_State (Text, Names.Items (I).First, Names.Items (I).After)
        and then Names.Items (I).Value_First <= Text'Last + 1
        and then Fixed_Bounds_Valid
          (Names.Items (I).Static_Length, Names.Items (I).Dynamic, Names.Items (I).Is_Character,
           Names.Items (I).First_Index, Names.Items (I).Last_Index, I));

   --  Every subtype declaration consumes at least the 32 bytes in
   --  subtype S is Integer range 0..0;. The table is declaration metadata;
   --  only its five call-hiding bits enter recursive statement contexts.
   Max_Subtype_Bindings : constant Positive := Max_Source_Length / 32;
   subtype Subtype_Count is Natural range 0 .. Max_Subtype_Bindings;
   subtype Subtype_Index is Positive range 1 .. Max_Subtype_Bindings;
   type Subtype_Binding is record
      First, After : Literal_Position;
      Bounds : Scalars.Interval;
      Qualifier_First, Qualifier_After : Literal_Position := 0;
   end record;
   Empty_Subtype_Binding : constant Subtype_Binding := (0, 0, Scalars.Empty, 0, 0);
   type Subtype_Binding_Array is array (Subtype_Index) of Subtype_Binding;
   type Subtype_Visibility is array (Names.Operation_Kind) of Boolean;
   type Subtype_Environment is record
      Count : Subtype_Count;
      Items : Subtype_Binding_Array;
      Hidden_Calls : Subtype_Visibility;
      True_Hidden, False_Hidden : Boolean;
   end record;
   Empty_Subtypes : constant Subtype_Environment :=
     (0, (others => Empty_Subtype_Binding), (others => False), False, False);
   function Valid_Subtypes (Text : String; Subtypes : Subtype_Environment) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_Subtypes (Text : String; Subtypes : Subtype_Environment) return Boolean is
     (for all Index in 1 .. Subtypes.Count =>
        Subtypes.Items (Index).First > 0
        and then Valid_Name_State
          (Text, Subtypes.Items (Index).First, Subtypes.Items (Index).After)
        and then Valid_Name_State
          (Text, Subtypes.Items (Index).Qualifier_First, Subtypes.Items (Index).Qualifier_After)
        and then not Scalars.Is_Empty (Subtypes.Items (Index).Bounds));

   type Hidden_Marks is record
      Integer_Hidden, Boolean_Hidden, Character_Hidden : Boolean;
      True_Hidden, False_Hidden : Boolean;
   end record;
   No_Hidden_Marks : constant Hidden_Marks := (others => False);
   type Parser_State is record
      Position : Literal_Position;
      Context_First : Cursor := 1;
      Package_First, Package_After : Literal_Position := 0;
      Functions : Silver_Function_Bindings.Metadata;
      Procedures : Silver_Procedure_Bindings.Metadata;
      Pure, Assigned_In_Functions : Boolean;
      Hiding : Hidden_Marks;
      First_Parameter : Silver_Function_Bindings.Formal_Count;
      First_Procedure_Parameter : Silver_Procedure_Bindings.Formal_Count;
      Names : Binding_Environment;
      Scalar_Names : Scalar_Expressions.Environment;
      Array_Names : Array_Bindings.Environment;
      Subtype_Names : Subtype_Environment;
      Boolean_Names : Boolean_Environment;
      Dynamic_First, Dynamic_After : Literal_Position;
      Target : Binding_Count;
      Capacity : Capacity_Value;
   end record;
   Initial_State : constant Parser_State :=
     (Position => 1, Context_First => 1, Package_First => 0, Package_After => 0, Functions => Functions.Empty_Metadata, Procedures => Procedures.Empty_Metadata,
      Pure => False, Assigned_In_Functions => False, Hiding => No_Hidden_Marks,
      First_Parameter => 0, First_Procedure_Parameter => 0, Names => Empty_Environment,
      Scalar_Names => Scalar_Expressions.Empty_Environment,
      Array_Names => Array_Bindings.Empty_Environment, Subtype_Names => Empty_Subtypes,
      Boolean_Names => Empty_Booleans, Dynamic_First => 0,
      Dynamic_After => 0, Target => 0, Capacity => Max_Source_Length);
   Invalid_State : constant Parser_State :=
     (Position => 0, Context_First => 1, Package_First => 0, Package_After => 0, Functions => Functions.Empty_Metadata, Procedures => Procedures.Empty_Metadata,
      Pure => False, Assigned_In_Functions => False, Hiding => No_Hidden_Marks,
      First_Parameter => 0, First_Procedure_Parameter => 0, Names => Empty_Environment,
      Scalar_Names => Scalar_Expressions.Empty_Environment,
      Array_Names => Array_Bindings.Empty_Environment, Subtype_Names => Empty_Subtypes,
      Boolean_Names => Empty_Booleans, Dynamic_First => 0,
      Dynamic_After => 0, Target => 0, Capacity => 0);

   function Valid_Mutable_Bounds (Scalar_Names : Scalar_Expressions.Environment) return Boolean is
     (for all Index in 1 .. Scalar_Names.Count =>
       (if Scalar_Names.Items (Index).Mutable then
          not Scalars.Is_Empty (Scalar_Names.Items (Index).Bounds)
          and then Scalar_Names.Items (Index).Bounds.Lower >= Scalar_Names.Items (Index).Declared_Bounds.Lower
          and then Scalar_Names.Items (Index).Bounds.Upper <= Scalar_Names.Items (Index).Declared_Bounds.Upper));
   function Valid_Declaration_Values
     (Scalar_Names : Scalar_Expressions.Environment; Count : Scalar_Expressions.Binding_Count)
      return Boolean is
     (Count <= Scalar_Names.Count
      and then (for all Index in 1 .. Count => not Scalars.Is_Empty (Scalar_Names.Items (Index).Bounds)));
   function Valid_State (Text : String; State : Parser_State) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_State (Text : String; State : Parser_State) return Boolean is
     (State.Position <= Text'Last + 1
      and then State.Context_First <= Text'Last + 1
      and then Valid_Name_State (Text, State.Package_First, State.Package_After)
      and then Functions.Valid_Metadata (Text, State.Functions)
      and then Procedures.Valid_Metadata (Text, State.Procedures)
      and then State.First_Parameter <= State.Functions.Parameter_Count + 1
      and then State.First_Procedure_Parameter <= State.Procedures.Parameter_Count + 1
      and then Valid_Names (Text, State.Names)
      and then Scalar_Expressions.Valid_Environment (Text, State.Scalar_Names)
      and then Array_Bindings.Valid_Environment (Text, State.Array_Names)
      and then Valid_Subtypes (Text, State.Subtype_Names)
      and then Valid_Booleans (Text, State.Boolean_Names)
      and then Valid_Mutable_Bounds (State.Scalar_Names)
      and then Valid_Declaration_Values (State.Scalar_Names, State.Scalar_Names.Count)
      and then Valid_Name_State (Text, State.Dynamic_First, State.Dynamic_After)
      and then State.Target <= State.Names.Count);

   function Function_Hides
     (Text : String; Catalog : Functions.Metadata; Word : String) return Boolean is
     (for some Index in 1 .. Catalog.Count =>
        Name_Is (Text, Catalog.Items (Index).First, Catalog.Items (Index).After, Word))
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Functions.Valid_Metadata (Text, Catalog)
         and then Word'First = 1 and then Word'Length in 1 .. Max_Source_Length;
   function Formal_Hides
     (Text : String; State : Parser_State; First, After : Literal_Position) return Boolean is
     (First > 0 and then After > First and then
       ((State.First_Parameter /= 0 and then
         (for some Index in State.First_Parameter .. State.Functions.Parameter_Count =>
            Equal_Name (Text, State.Functions.Parameters (Index).First,
                        State.Functions.Parameters (Index).After, First, After)))
        or else (State.First_Procedure_Parameter /= 0 and then
         (for some Index in State.First_Procedure_Parameter .. State.Procedures.Parameter_Count =>
            Equal_Name (Text, State.Procedures.Parameters (Index).First,
                        State.Procedures.Parameters (Index).After, First, After)))))
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State)
         and then First <= Text'Last + 1 and then After <= Text'Last + 1;

   --  These executable lexical adapters preserve the established functional
   --  lexical meanings. Zero is failure and is propagated by every adapter.
   function Skip_At (Text : String; Position : Literal_Position) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Static => Skip_At'Result <= Text'Last + 1
         and then ( Skip_At'Result =
           (if Position = 0 then 0 else Trivia_End (Text, Position))));
   function Skip_At (Text : String; Position : Literal_Position) return Literal_Position is
      Next : Cursor;
   begin
      if Position = 0 then return 0; end if;
      Next := Position;
      Skip_Trivia (Text, Next);
      return Next;
   end Skip_At;

   function Name_After (Text : String; Position : Literal_Position) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Static => (Name_After'Result = 0
         or else Name_After'Result in Position + 1 .. Text'Last + 1)
         and then ( Name_After'Result =
           (if Position = 0 then 0 else Identifier_End (Text, Position))));
   function Name_After (Text : String; Position : Literal_Position) return Literal_Position is
      Next : Cursor;
      Matched : Boolean;
   begin
      if Position = 0 then return 0; end if;
      Next := Position;
      Match_Identifier (Text, Next, Matched);
      return (if Matched then Next else 0);
   end Name_After;

   function Fixed_After
     (Text : String; Position : Literal_Position; Token : Token_Kind)
      return Literal_Position
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Fixed_After'Result = 0
         or else Fixed_After'Result in Position + 1 .. Text'Last + 1;
   function Fixed_After
     (Text : String; Position : Literal_Position; Token : Token_Kind)
      return Literal_Position is
     (if Position = 0 then 0
      elsif Token_At (Text, Trivia_End (Text, Position), Spelling (Token), Is_Word_Token (Token))
      then Trivia_End (Text, Position) + Spelling (Token)'Length else 0);

   procedure Match_Token
     (Text : String; Position : in out Cursor; Token : Token_Kind;
      Matched : out Boolean)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Static => Position <= Text'Last + 1
         and then Matched = Token_At
           (Text, Position'Old, Spelling (Token), Is_Word_Token (Token))
         and then (if Matched then Position = Position'Old + Spelling (Token)'Length
           else Position = Position'Old))
   is
      Word : constant String := Spelling (Token);
   begin
      Matched := False;
      if Word'Length > (Text'Last - Position) + 1 then return; end if;
      for Index in Word'Range loop
         pragma Loop_Invariant
           (Static => (for all Previous in Word'First .. Index - 1 =>
             Lowercase (Text ((Position + Previous) - 1)) = Word (Previous)));
         if Lowercase (Text ((Position + Index) - 1)) /= Word (Index) then
            return;
         end if;
      end loop;
      if Is_Word_Token (Token) and then Position + Word'Length <= Text'Last
        and then Is_Identifier_Character (Text (Position + Word'Length))
      then return; end if;
      Position := Position + Word'Length;
      Matched := True;
   end Match_Token;

   function Take_Token
     (Text : String; Position : Literal_Position; Token : Token_Kind)
      return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Static => (Take_Token'Result = 0
         or else Take_Token'Result in Position + 1 .. Text'Last + 1)
         and then ( Take_Token'Result = Fixed_After (Text, Position, Token)));
   function Take_Token
     (Text : String; Position : Literal_Position; Token : Token_Kind)
      return Literal_Position
   is
      Next : Cursor;
      Matched : Boolean;
   begin
      if Position = 0 then return 0; end if;
      Next := Position;
      Skip_Trivia (Text, Next);
      Match_Token (Text, Next, Token, Matched);
      return (if Matched then Next else 0);
   end Take_Token;

   function Lookup_From
     (Text : String; Names : Binding_Environment; First, After : Cursor;
      Index : Positive) return Binding_Count
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Names (Text, Names)
         and then First < After and then After <= Text'Last + 1
         and then Index <= Names.Count + 1,
       Post => Lookup_From'Result <= Names.Count,
       Subprogram_Variant => (Increases => Index);
   function Lookup_From
     (Text : String; Names : Binding_Environment; First, After : Cursor;
      Index : Positive) return Binding_Count is
     (if Index > Names.Count then 0
      elsif Equal_Name (Text, Names.Items (Index).First, Names.Items (Index).After, First, After)
      then Index else Lookup_From (Text, Names, First, After, Index + 1));

   function Lookup_Name
     (Text : String; Names : Binding_Environment; First, After : Literal_Position)
      return Binding_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Names (Text, Names)
         and then First <= Text'Last + 1 and then After <= Text'Last + 1,
       Post => (Static => Lookup_Name'Result <= Names.Count
         and then ( Lookup_Name'Result =
           (if First = 0 or else After <= First then 0
            else Lookup_From (Text, Names, First, After, 1))));
   function Lookup_Name
     (Text : String; Names : Binding_Environment; First, After : Literal_Position)
      return Binding_Count
   is
      Index : Positive := 1;
   begin
      if First = 0 or else After <= First then return 0; end if;
      while Index <= Names.Count loop
         pragma Loop_Invariant (Index <= Names.Count + 1);
         pragma Loop_Invariant (Static =>
           Lookup_From (Text, Names, First, After, 1) =
             Lookup_From (Text, Names, First, After, Index));
         pragma Loop_Variant (Increases => Index);
         if Equal_Name (Text, Names.Items (Index).First, Names.Items (Index).After, First, After)
         then return Index; end if;
         Index := Index + 1;
      end loop;
      return 0;
   end Lookup_Name;

   function Lookup_Subtype_Model
     (Text : String; Subtypes : Subtype_Environment; First, After : Literal_Position;
      Index : Subtype_Count;
      Qualifier_First, Qualifier_After : Literal_Position := 0) return Subtype_Count
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Subtypes (Text, Subtypes) and then Index <= Subtypes.Count
         and then First <= Text'Last + 1 and then After <= Text'Last + 1
         and then Valid_Name_State (Text, Qualifier_First, Qualifier_After),
       Post => Lookup_Subtype_Model'Result <= Index,
       Subprogram_Variant => (Decreases => Index);
   function Lookup_Subtype_Model
     (Text : String; Subtypes : Subtype_Environment; First, After : Literal_Position;
      Index : Subtype_Count;
      Qualifier_First, Qualifier_After : Literal_Position := 0) return Subtype_Count is
     (if First = 0 or else After <= First or else Index = 0 then 0
      elsif Equal_Name (Text, Subtypes.Items (Index).First, Subtypes.Items (Index).After,
                        First, After)
        and then (if Qualifier_First = 0 then Subtypes.Items (Index).Qualifier_First = 0
          else Subtypes.Items (Index).Qualifier_First > 0
            and then Equal_Name (Text, Subtypes.Items (Index).Qualifier_First,
              Subtypes.Items (Index).Qualifier_After, Qualifier_First, Qualifier_After))
      then Index else Lookup_Subtype_Model (Text, Subtypes, First, After, Index - 1, Qualifier_First, Qualifier_After));
   function Lookup_Subtype
     (Text : String; Subtypes : Subtype_Environment; First, After : Literal_Position;
      Qualifier_First, Qualifier_After : Literal_Position := 0)
      return Subtype_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Subtypes (Text, Subtypes)
         and then First <= Text'Last + 1 and then After <= Text'Last + 1
         and then Valid_Name_State (Text, Qualifier_First, Qualifier_After),
       Post => (Runtime => Lookup_Subtype'Result <= Subtypes.Count,
         Static => Lookup_Subtype'Result =
           Lookup_Subtype_Model (Text, Subtypes, First, After, Subtypes.Count, Qualifier_First, Qualifier_After));
   function Lookup_Subtype
     (Text : String; Subtypes : Subtype_Environment; First, After : Literal_Position;
      Qualifier_First, Qualifier_After : Literal_Position := 0)
      return Subtype_Count is
      Index : Subtype_Count := Subtypes.Count;
   begin
      if First = 0 or else After <= First then return 0; end if;
      while Index > 0 loop
         pragma Loop_Invariant (Index <= Subtypes.Count);
         pragma Loop_Invariant (Static =>
           Lookup_Subtype_Model (Text, Subtypes, First, After, Subtypes.Count, Qualifier_First, Qualifier_After)
             = Lookup_Subtype_Model (Text, Subtypes, First, After, Index, Qualifier_First, Qualifier_After));
         pragma Loop_Variant (Decreases => Index);
         if Equal_Name (Text, Subtypes.Items (Index).First, Subtypes.Items (Index).After,
                        First, After)
           and then (if Qualifier_First = 0 then Subtypes.Items (Index).Qualifier_First = 0
          else Subtypes.Items (Index).Qualifier_First > 0
            and then Equal_Name (Text, Subtypes.Items (Index).Qualifier_First,
              Subtypes.Items (Index).Qualifier_After, Qualifier_First, Qualifier_After))
         then return Index; end if;
         Index := Index - 1;
      end loop;
      return 0;
   end Lookup_Subtype;

   function Lookup_Boolean_Model
     (Text : String; Booleans : Boolean_Environment; First, After : Literal_Position;
      Index : Boolean_Count;
      Qualifier_First, Qualifier_After : Literal_Position := 0) return Boolean_Count
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Booleans (Text, Booleans) and then Index <= Booleans.Count
         and then First <= Text'Last + 1 and then After <= Text'Last + 1
         and then Valid_Name_State (Text, Qualifier_First, Qualifier_After),
       Post => Lookup_Boolean_Model'Result <= Index,
       Subprogram_Variant => (Decreases => Index);
   function Lookup_Boolean_Model
     (Text : String; Booleans : Boolean_Environment; First, After : Literal_Position;
      Index : Boolean_Count;
      Qualifier_First, Qualifier_After : Literal_Position := 0) return Boolean_Count is
     (if First = 0 or else After <= First or else Index = 0 then 0
      elsif Equal_Name (Text, Booleans.Items (Index).First, Booleans.Items (Index).After,
                        First, After)
        and then (if Qualifier_First = 0 then Booleans.Items (Index).Qualifier_First = 0
          else Booleans.Items (Index).Qualifier_First > 0
            and then Equal_Name (Text, Booleans.Items (Index).Qualifier_First,
              Booleans.Items (Index).Qualifier_After, Qualifier_First, Qualifier_After))
      then Index else Lookup_Boolean_Model (Text, Booleans, First, After, Index - 1, Qualifier_First, Qualifier_After));
   function Lookup_Boolean
     (Text : String; Booleans : Boolean_Environment; First, After : Literal_Position;
      Qualifier_First, Qualifier_After : Literal_Position := 0)
      return Boolean_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Booleans (Text, Booleans)
         and then First <= Text'Last + 1 and then After <= Text'Last + 1
         and then Valid_Name_State (Text, Qualifier_First, Qualifier_After),
       Post => (Runtime => Lookup_Boolean'Result <= Booleans.Count,
         Static => Lookup_Boolean'Result =
           Lookup_Boolean_Model (Text, Booleans, First, After, Booleans.Count, Qualifier_First, Qualifier_After));
   function Lookup_Boolean
     (Text : String; Booleans : Boolean_Environment; First, After : Literal_Position;
      Qualifier_First, Qualifier_After : Literal_Position := 0)
      return Boolean_Count is
      Index : Boolean_Count := Booleans.Count;
   begin
      if First = 0 or else After <= First then return 0; end if;
      while Index > 0 loop
         pragma Loop_Invariant (Index <= Booleans.Count);
         pragma Loop_Invariant (Static =>
           Lookup_Boolean_Model (Text, Booleans, First, After, Booleans.Count, Qualifier_First, Qualifier_After)
             = Lookup_Boolean_Model (Text, Booleans, First, After, Index, Qualifier_First, Qualifier_After));
         pragma Loop_Variant (Decreases => Index);
         if Equal_Name (Text, Booleans.Items (Index).First, Booleans.Items (Index).After,
                        First, After)
           and then (if Qualifier_First = 0 then Booleans.Items (Index).Qualifier_First = 0
          else Booleans.Items (Index).Qualifier_First > 0
            and then Equal_Name (Text, Booleans.Items (Index).Qualifier_First,
              Booleans.Items (Index).Qualifier_After, Qualifier_First, Qualifier_After))
         then return Index; end if;
         Index := Index - 1;
      end loop;
      return 0;
   end Lookup_Boolean;

   function Boolean_Hides_Integer (Text : String; Booleans : Boolean_Environment) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Booleans (Text, Booleans);
   function Boolean_Hides_Integer (Text : String; Booleans : Boolean_Environment) return Boolean is
     (for some Index in 1 .. Booleans.Count =>
        Booleans.Items (Index).Qualifier_First = 0 and then
        Name_Is (Text, Booleans.Items (Index).First, Booleans.Items (Index).After, "integer"));

   function Call_After
     (Text : String; Environment : Binding_Environment; Position : Literal_Position;
      Operation : Names.Operation_Kind;
      Scalar_Names : Scalar_Expressions.Environment := Scalar_Expressions.Empty_Environment;
      Arrays : Array_Bindings.Metadata := Array_Bindings.Empty_Metadata;
      Subtype_Hidden : Boolean := False;
      Booleans : Boolean_Environment := Empty_Booleans;
      Context_First : Cursor := 1;
      Package_First, Package_After : Literal_Position := 0) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Names (Text, Environment)
         and then Scalar_Expressions.Valid_Environment (Text, Scalar_Names)
         and then Array_Bindings.Valid_Metadata (Text, Arrays)
         and then Valid_Booleans (Text, Booleans) and then Position <= Text'Last + 1
         and then Context_First <= Text'Last + 1
         and then Valid_Name_State (Text, Package_First, Package_After),
       Post => Call_After'Result = 0
         or else Call_After'Result in Position + 1 .. Text'Last + 1;
   function Call_After
     (Text : String; Environment : Binding_Environment; Position : Literal_Position;
      Operation : Names.Operation_Kind;
      Scalar_Names : Scalar_Expressions.Environment := Scalar_Expressions.Empty_Environment;
      Arrays : Array_Bindings.Metadata := Array_Bindings.Empty_Metadata;
      Subtype_Hidden : Boolean := False;
      Booleans : Boolean_Environment := Empty_Booleans;
      Context_First : Cursor := 1;
      Package_First, Package_After : Literal_Position := 0) return Literal_Position is
     (declare First : constant Literal_Position := Skip_At (Text, Position);
              After : constant Literal_Position := Name_After (Text, First);
      begin Names.Operation_After
        (Text, Position, Operation, Lookup_Name (Text, Environment, First, After) /= 0
          or else Scalar_Expressions.Lookup (Text, Scalar_Names, First, After) /= 0
          or else Array_Bindings.Lookup (Text, Arrays, First, After) /= 0
           or else Array_Bindings.Lookup_Type (Text, Arrays.Types, First, After) /= 0
          or else Lookup_Boolean (Text, Booleans, First, After) /= 0
          or else Subtype_Hidden, Context_First, Package_First, Package_After));

   type Value_Result is record
      After, Value_First : Literal_Position;
      Minimum_Length, Static_Length : Capacity_Value;
      Dynamic_Seen, Nonliteral_Seen, Empty_Value : Boolean;
      Reference : Binding_Count;
      Operands : Natural range 0 .. Max_Expression_Operands;
      First_Index, Last_Index : Scalars.Interval;
   end record;
   Invalid_Value : constant Value_Result :=
     (After => 0, Value_First => 0, Minimum_Length => 0, Static_Length => 0,
      Dynamic_Seen => False, Nonliteral_Seen => False, Empty_Value => False, Reference => 0, Operands => 0,
      First_Index => Scalars.Singleton (1), Last_Index => Scalars.Singleton (0));
   function Literal_At (Text : String; Position : Literal_Position) return Value_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Static => Literal_At'Result.Value_First <= Text'Last + 1
         and then (Literal_At'Result.After = 0
           or else Literal_At'Result.After in Position + 1 .. Text'Last + 1)
         and then not Literal_At'Result.Dynamic_Seen
         and then Literal_At'Result.Reference = 0
         and then ( Literal_At'Result =
           (if Position /= 0 and then Position <= Text'Last
              and then Text (Position) = Character'Val (34)
              and then Literal_End (Text, Position + 1) /= 0
            then (After => Literal_End (Text, Position + 1), Value_First => Position + 1,
                  Minimum_Length => Literal_Length (Text, Position + 1),
                  Static_Length => Literal_Length (Text, Position + 1),
                  Dynamic_Seen => False, Nonliteral_Seen => False, Empty_Value => False, Reference => 0, Operands => 1,
                  First_Index => Scalars.Singleton (1),
                  Last_Index => Scalars.Singleton (Scalars.Value (Literal_Length (Text, Position + 1))))
            else Invalid_Value)));
   function Literal_At (Text : String; Position : Literal_Position) return Value_Result is
      Next : Cursor;
      Length : Capacity_Value;
      Matched : Boolean;
   begin
      if Position = 0 then return Invalid_Value; end if;
      Next := Position;
      Match_Sized_Literal (Text, Next, Matched, Length);
      if not Matched then return Invalid_Value; end if;
      return (After => Next, Value_First => Position + 1,
              Minimum_Length => Length, Static_Length => Length,
              Dynamic_Seen => False, Nonliteral_Seen => False, Empty_Value => False, Reference => 0, Operands => 1,
              First_Index => Scalars.Singleton (1), Last_Index => Scalars.Singleton (Scalars.Value (Length)));
   end Literal_At;

   --  Character literals contain one graphic ASCII byte between apostrophes.
   --  This includes the three-apostrophe spelling of the apostrophe character.
   function Character_Literal_After
     (Text : String; Position : Literal_Position) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Character_Literal_After'Result = 0
         or else Character_Literal_After'Result = Position + 3;
   function Character_Literal_After
     (Text : String; Position : Literal_Position) return Literal_Position is
     (if Position /= 0 and then Position + 2 <= Text'Last
        and then Text (Position) = Character'Val (39)
        and then Text (Position + 1) in ' ' .. '~'
        and then Text (Position + 2) = Character'Val (39)
      then Position + 3 else 0);

   --  A native conditional fact can override the endpoint interval used by
   --  admission, even in an unreachable arm. In these source contexts slices
   --  therefore require Ada-static endpoints. Scan tokens, not identifier or
   --  literal substrings; the Boolean-chain suffix is deliberately conservative.
   function Guarded_At
     (Text : String; Position : Cursor; Limit : Literal_Position;
      Depth : Natural; Chained, Ending : Boolean) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Limit <= Text'Last + 1
         and then Depth <= Max_Source_Length,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position);
   function Guarded_At
     (Text : String; Position : Cursor; Limit : Literal_Position;
      Depth : Natural; Chained, Ending : Boolean) return Boolean is
      First : constant Literal_Position := Skip_At (Text, Position);
      After : constant Literal_Position := Name_After (Text, First);
      Character_After : constant Literal_Position := Character_Literal_After (Text, First);
      Quoted_After : constant Literal_Position := Literal_At (Text, First).After;
      Next_Chained : constant Boolean :=
        Chained or else (After > First
          and then (Name_Is (Text, First, After, "and")
            or else Name_Is (Text, First, After, "or")
            or else Name_Is (Text, First, After, "xor")));
      Next_Ending : constant Boolean :=
        After > First and then Name_Is (Text, First, After, "end");
      After_Punctuation : constant Boolean :=
        Chained and then (First > Text'Last or else Text (First) /= ';');
   begin
      return (if First >= Limit then Depth /= 0 or else Chained
         elsif Character_After > First then
           Guarded_At (Text, Character_After, Limit, Depth, Chained, False)
         elsif Quoted_After > First then
           Guarded_At (Text, Quoted_After, Limit, Depth, Chained, False)
         elsif After > First then
           (if Name_Is (Text, First, After, "if") then
              (if Ending and then Depth /= 0 then
                 Guarded_At (Text, After, Limit, Depth - 1, Chained, False)
               elsif Ending then Guarded_At (Text, After, Limit, 0, Chained, False)
               elsif Depth = Max_Source_Length then True
               else Guarded_At (Text, After, Limit, Depth + 1, Chained, False))
            else Guarded_At (Text, After, Limit, Depth, Next_Chained, Next_Ending))
         else Guarded_At (Text, First + 1, Limit, Depth,
           After_Punctuation, False));
   end Guarded_At;

   --  A fixed String prefix is resolved before its suffix is interpreted.
   --  Endpoints use the full bounded Integer grammar, including admitted array
   --  reads; those reads retain their own non-nested subscript restriction.
   function Indexed_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment;
      Scalar_Names : Scalar_Expressions.Environment;
      Arrays : Array_Bindings.Metadata; Initials : Array_Bindings.Element_Array;
      Elaborating, Character_Element : Boolean; Context_First : Cursor := 1) return Value_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Context_First <= Text'Last + 1
         and then Position <= Text'Last + 1 and then Valid_Names (Text, Names)
         and then Scalar_Expressions.Valid_Environment (Text, Scalar_Names)
         and then Array_Bindings.Valid_Metadata (Text, Arrays),
       Post => Indexed_At'Result.Value_First <= Text'Last + 1
         and then Indexed_At'Result.Reference <= Names.Count
         and then (Indexed_At'Result.After = 0
           or else (Indexed_At'Result.After in Position + 1 .. Text'Last + 1
             and then Indexed_At'Result.Operands > 0
             and then (if Character_Element then
               Indexed_At'Result.Minimum_Length = 1
               and then Indexed_At'Result.Static_Length = 1
               and then not Indexed_At'Result.Dynamic_Seen
               and then Indexed_At'Result.First_Index = Scalars.Singleton (1)
               and then Indexed_At'Result.Last_Index = Scalars.Singleton (1))));
   function Indexed_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment;
      Scalar_Names : Scalar_Expressions.Environment;
      Arrays : Array_Bindings.Metadata; Initials : Array_Bindings.Element_Array;
      Elaborating, Character_Element : Boolean; Context_First : Cursor := 1) return Value_Result
   is
      First : constant Literal_Position := Skip_At (Text, Position);
      After : constant Literal_Position := Name_After (Text, First);
      Target : constant Binding_Count := Lookup_Name (Text, Names, First, After);
      Low : constant Scalar_Expressions.Expression_Result :=
        Scalar_Expressions.Read_Expression
          (Text, Take_Token (Text, After, Left_Parenthesis), Scalar_Names,
           Arrays => Arrays, Initials => Initials, Elaborating => Elaborating);
      High : Scalar_Expressions.Expression_Result;
      Following : Literal_Position;
      Minimum, Maximum : Scalars.Wide;
   begin
      if Target = 0 or else Names.Items (Target).Is_Character
        or else Names.Items (Target).Dynamic
        or else Scalar_Expressions.Lookup (Text, Scalar_Names, First, After) /= 0
        or else Low.After = 0 or else Scalars.Is_Empty (Low.Bounds)
      then return Invalid_Value; end if;
      if Character_Element then
         Following := Take_Token (Text, Low.After, Right_Parenthesis);
         if Following <= Position or else Low.Operands = Max_Expression_Operands
           or else Low.Bounds.Lower < Names.Items (Target).First_Index
           or else Low.Bounds.Upper > Names.Items (Target).Last_Index
         then return Invalid_Value; end if;
         return (After => Following, Value_First => 0,
           Minimum_Length => 1, Static_Length => 1, Dynamic_Seen => False,
           Nonliteral_Seen => True, Empty_Value => False, Reference => Target,
           Operands => Low.Operands + 1,
           First_Index => Scalars.Singleton (1), Last_Index => Scalars.Singleton (1));
      end if;
      High := Scalar_Expressions.Read_Expression
        (Text, Take_Token (Text, Low.After, Range_Delimiter), Scalar_Names,
         Arrays => Arrays, Initials => Initials, Elaborating => Elaborating);
      Following := Take_Token (Text, High.After, Right_Parenthesis);
      if Following <= Position or else Scalars.Is_Empty (High.Bounds)
        or else Low.Operands + High.Operands >= Max_Expression_Operands
        --  The pinned native array-equality expansion subtracts the actual
        --  endpoints in Integer. Keep every inverted span representable too.
        or else Scalars.Wide (Low.Bounds.Upper) - Scalars.Wide (High.Bounds.Lower)
          > Scalars.Maximum
        or else ((not Low.Static or else not High.Static)
          and then Guarded_At (Text, Context_First, Position, 0, False, False))
        or else (Low.Bounds.Lower <= High.Bounds.Upper
          and then (Low.Bounds.Lower < Names.Items (Target).First_Index
            or else High.Bounds.Upper > Names.Items (Target).Last_Index))
      then return Invalid_Value; end if;
      Minimum := Scalars.Wide'Max
        (0, (Scalars.Wide (High.Bounds.Lower) - Scalars.Wide (Low.Bounds.Upper)) + 1);
      Maximum := Scalars.Wide'Max
        (0, (Scalars.Wide (High.Bounds.Upper) - Scalars.Wide (Low.Bounds.Lower)) + 1);
      if Maximum > Scalars.Wide (Max_Source_Length) then return Invalid_Value; end if;
      return (After => Following, Value_First => 0,
        Minimum_Length => Capacity_Value (Minimum), Static_Length => Capacity_Value (Maximum),
        Dynamic_Seen => False, Nonliteral_Seen => True, Empty_Value => False,
        Reference => Target, Operands => (Low.Operands + High.Operands) + 1,
        First_Index => Low.Bounds, Last_Index => High.Bounds);
   end Indexed_At;

   function Character_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment;
      Scalar_Names : Scalar_Expressions.Environment;
      Arrays : Array_Bindings.Metadata := Array_Bindings.Empty_Metadata;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values;
      Elaborating : Boolean := False) return Value_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Names (Text, Names)
         and then Scalar_Expressions.Valid_Environment (Text, Scalar_Names)
         and then Array_Bindings.Valid_Metadata (Text, Arrays),
       Post => Character_At'Result.Value_First <= Text'Last + 1
         and then Character_At'Result.Reference <= Names.Count
         and then (Character_At'Result.After = 0
           or else (Character_At'Result.After in Position + 1 .. Text'Last + 1
             and then Character_At'Result.Minimum_Length = 1
             and then Character_At'Result.Static_Length = 1
             and then not Character_At'Result.Dynamic_Seen
             and then Character_At'Result.First_Index = Scalars.Singleton (1)
             and then Character_At'Result.Last_Index = Scalars.Singleton (1))),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position);
   function Character_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment;
      Scalar_Names : Scalar_Expressions.Environment;
      Arrays : Array_Bindings.Metadata := Array_Bindings.Empty_Metadata;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values;
      Elaborating : Boolean := False) return Value_Result
   is
      First : constant Literal_Position := Skip_At (Text, Position);
      Quoted : constant Literal_Position := Character_Literal_After (Text, First);
      After : constant Literal_Position := Name_After (Text, First);
      Target : constant Binding_Count := Lookup_Name (Text, Names, First, After);
      Open_After : constant Literal_Position := Take_Token (Text, First, Left_Parenthesis);
      Value : Value_Result;
   begin
      if Open_After /= 0 then
         Value := Character_At (Text, Open_After, Names, Scalar_Names, Arrays, Initials, Elaborating);
         Value.After := Take_Token (Text, Value.After, Right_Parenthesis);
         return Value;
      elsif Quoted /= 0 then
         return (After => Quoted, Value_First => 0,
           Minimum_Length => 1, Static_Length => 1, Dynamic_Seen => False,
           Nonliteral_Seen => False, Empty_Value => False, Reference => 0, Operands => 1,
           First_Index => Scalars.Singleton (1), Last_Index => Scalars.Singleton (1));
      elsif Target /= 0 and then Names.Items (Target).Is_Character
        and then Scalar_Expressions.Lookup (Text, Scalar_Names, First, After) = 0
      then
         return (After => After, Value_First => 0,
           Minimum_Length => 1, Static_Length => 1, Dynamic_Seen => False,
           Nonliteral_Seen => True, Empty_Value => False, Reference => Target, Operands => 1,
           First_Index => Scalars.Singleton (1), Last_Index => Scalars.Singleton (1));
      else
         return Indexed_At (Text, Position, Names, Scalar_Names, Arrays, Initials,
           Elaborating, True, 1);
      end if;
   end Character_At;

   subtype Concatenation_Count is Natural range 0 .. Max_Concatenations;

   --  This independent lexical budget ignores literal bytes and comments.
   --  Consume identifiers whole so N1E+1 cannot hide an operator in an exponent.
   --  Body parsing still establishes syntax.
   function Work_Tail
     (Text : String; Position : Literal_Position; Remaining : Concatenation_Count)
      return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position);
   function Work_Tail
     (Text : String; Position : Literal_Position; Remaining : Concatenation_Count)
      return Boolean is
     (declare First : constant Literal_Position := Skip_At (Text, Position);
              Quoted : constant Value_Result := Literal_At (Text, First);
              After_Name : constant Literal_Position := Name_After (Text, First);
              Number : constant Silver_Scalar_Literals.Literal_Result :=
                Silver_Scalar_Literals.Read_Integer (Text, First);
      begin
        (if First = 0 then False
         elsif First > Text'Last then True
         elsif Character_Literal_After (Text, First) /= 0 then
           Work_Tail (Text, Character_Literal_After (Text, First), Remaining)
         elsif Text (First) = Character'Val (34) then
           Quoted.After /= 0 and then Work_Tail (Text, Quoted.After, Remaining)
         elsif After_Name /= 0 then
           (if Name_Is (Text, First, After_Name, "mod") or else Name_Is (Text, First, After_Name, "rem")
            then Remaining /= 0 and then Work_Tail (Text, After_Name, Remaining - 1)
            else Work_Tail (Text, After_Name, Remaining))
         elsif Number.After /= 0 then Work_Tail (Text, Number.After, Remaining)
         elsif Text (First) = '/' and then First < Text'Last and then Text (First + 1) = '=' then
           Work_Tail (Text, First + 2, Remaining)
         elsif Text (First) in '&' | '+' | '-' | '*' | '/' then
           Remaining /= 0 and then Work_Tail (Text, First + 1, Remaining - 1)
         else Work_Tail (Text, First + 1, Remaining)));

   function Within_Work_Budget (Text : String) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length,
       Post => (Static => Within_Work_Budget'Result = Work_Tail (Text, 1, Max_Concatenations));
   function Within_Work_Budget (Text : String) return Boolean is
      Position : Cursor := 1;
      Remaining : Concatenation_Count := Max_Concatenations;
   begin
      loop
         pragma Loop_Invariant (Position <= Text'Last + 1);
         pragma Loop_Invariant (Static => Work_Tail (Text, 1, Max_Concatenations)
           = Work_Tail (Text, Position, Remaining));
         pragma Loop_Variant (Increases => Position);
         declare
            First : constant Literal_Position := Skip_At (Text, Position);
            Quoted : constant Value_Result := Literal_At (Text, First);
            After_Name : constant Literal_Position := Name_After (Text, First);
            Number : constant Silver_Scalar_Literals.Literal_Result :=
              Silver_Scalar_Literals.Read_Integer (Text, First);
            Current_Tail : constant Boolean := Work_Tail (Text, Position, Remaining)
              with Ghost => Static;
         begin
            pragma Assert
              (Static => Work_Tail (Text, 1, Max_Concatenations) = Current_Tail);
            pragma Assert
              (Static => Current_Tail =
                (if First = 0 then False
                 elsif First > Text'Last then True
                 elsif Character_Literal_After (Text, First) /= 0 then
                   Work_Tail (Text, Character_Literal_After (Text, First), Remaining)
                 elsif Text (First) = Character'Val (34) then
                   Quoted.After /= 0 and then Work_Tail (Text, Quoted.After, Remaining)
                 elsif After_Name /= 0 then
                   (if Name_Is (Text, First, After_Name, "mod")
                     or else Name_Is (Text, First, After_Name, "rem")
                    then Remaining /= 0 and then Work_Tail (Text, After_Name, Remaining - 1)
                    else Work_Tail (Text, After_Name, Remaining))
                 elsif Number.After /= 0 then Work_Tail (Text, Number.After, Remaining)
                 elsif Text (First) = '/' and then First < Text'Last and then Text (First + 1) = '=' then
                   Work_Tail (Text, First + 2, Remaining)
                 elsif Text (First) in '&' | '+' | '-' | '*' | '/' then
                   Remaining /= 0 and then Work_Tail (Text, First + 1, Remaining - 1)
                 else Work_Tail (Text, First + 1, Remaining)));
            if First = 0 then return False; end if;
            if First > Text'Last then return True; end if;
            if Character_Literal_After (Text, First) /= 0 then
               Position := Character_Literal_After (Text, First);
            elsif Text (First) = Character'Val (34) then
               if Quoted.After = 0 then return False; end if;
               Position := Quoted.After;
               pragma Assert
                 (Static => Current_Tail = Work_Tail (Text, Position, Remaining));
            elsif After_Name /= 0 then
               if Name_Is (Text, First, After_Name, "mod") or else Name_Is (Text, First, After_Name, "rem") then
                  if Remaining = 0 then return False; end if;
                  pragma Assert
                    (Static => Current_Tail = Work_Tail (Text, After_Name, Remaining - 1));
                  Remaining := Remaining - 1;
               end if;
               Position := After_Name;
               pragma Assert
                 (Static => Current_Tail = Work_Tail (Text, Position, Remaining));
            elsif Number.After /= 0 then
               Position := Number.After;
               pragma Assert
                 (Static => Current_Tail = Work_Tail (Text, Position, Remaining));
            elsif Text (First) = '/' and then First < Text'Last and then Text (First + 1) = '=' then
               Position := First + 2;
               pragma Assert
                 (Static => Current_Tail = Work_Tail (Text, Position, Remaining));
            elsif Text (First) in '&' | '+' | '-' | '*' | '/' then
               if Remaining = 0 then return False; end if;
               Position := First + 1;
               Remaining := Remaining - 1;
               pragma Assert
                 (Static => Current_Tail = Work_Tail (Text, Position, Remaining));
            else
               Position := First + 1;
               pragma Assert
                 (Static => Current_Tail = Work_Tail (Text, Position, Remaining));
            end if;
            pragma Assert
              (Static => Current_Tail = Work_Tail (Text, Position, Remaining));
            pragma Assert
              (Static => Work_Tail (Text, 1, Max_Concatenations)
                = Work_Tail (Text, Position, Remaining));
         end;
      end loop;
   end Within_Work_Budget;

   function Image_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment;
      Scalar_Names : Scalar_Expressions.Environment; Integer_Hidden : Boolean;
      Arrays : Array_Bindings.Metadata;
      Initials : Array_Bindings.Element_Array; Elaborating : Boolean)
      return Value_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Names (Text, Names)
         and then Scalar_Expressions.Valid_Environment (Text, Scalar_Names)
         and then Array_Bindings.Valid_Metadata (Text, Arrays),
       Post => Image_At'Result.Value_First = 0
         and then Image_At'Result.Reference = 0
         and then (Image_At'Result.After = 0
           or else Image_At'Result.After in Position + 1 .. Text'Last + 1);
   function Image_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment;
      Scalar_Names : Scalar_Expressions.Environment; Integer_Hidden : Boolean;
      Arrays : Array_Bindings.Metadata;
      Initials : Array_Bindings.Element_Array; Elaborating : Boolean)
      return Value_Result is
     (declare First : constant Literal_Position := Skip_At (Text, Position);
              Type_After : constant Literal_Position := Take_Token (Text, First, Integer_Name);
              Attribute_First : constant Literal_Position :=
                Skip_At (Text, Take_Token (Text, Type_After, Apostrophe));
              Attribute_After : constant Literal_Position := Name_After (Text, Attribute_First);
              Value : constant Scalar_Expressions.Expression_Result :=
                Scalar_Expressions.Read_Expression
                  (Text, Take_Token (Text, Attribute_After, Left_Parenthesis), Scalar_Names, Arrays => Arrays, Initials => Initials, Elaborating => Elaborating);
              Following : constant Literal_Position := Take_Token (Text, Value.After, Right_Parenthesis);
      begin
        (if Integer_Hidden or else Type_After = 0
           or else Lookup_Name (Text, Names, First, Type_After) /= 0
           or else Scalar_Expressions.Lookup (Text, Scalar_Names, First, Type_After) /= 0
           or else Array_Bindings.Lookup (Text, Arrays, First, Type_After) /= 0
           or else Array_Bindings.Lookup_Type (Text, Arrays.Types, First, Type_After) /= 0
           or else Attribute_First = 0 or else Attribute_After <= Attribute_First
           or else not Name_Is (Text, Attribute_First, Attribute_After, "image")
           or else Following <= Position
         then Invalid_Value
         else (After => Following, Value_First => 0,
           Minimum_Length => Image_Lengths.Minimum_Length (Value.Bounds),
           Static_Length => Image_Lengths.Maximum_Length (Value.Bounds),
           Dynamic_Seen => False, Nonliteral_Seen => True,
           Empty_Value => Scalars.Is_Empty (Value.Bounds), Reference => 0, Operands => 1,
           First_Index => Scalars.Singleton (1),
           Last_Index => (Scalars.Value (Image_Lengths.Minimum_Length (Value.Bounds)),
                          Scalars.Value (Image_Lengths.Maximum_Length (Value.Bounds))))));

   function Value_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment;
      Scalar_Names : Scalar_Expressions.Environment := Scalar_Expressions.Empty_Environment;
      Integer_Hidden : Boolean := False;
      Arrays : Array_Bindings.Metadata := Array_Bindings.Empty_Metadata;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values;
      Elaborating : Boolean := False; Context_First : Cursor := 1)
      return Value_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Context_First <= Text'Last + 1
         and then Position <= Text'Last + 1 and then Valid_Names (Text, Names)
         and then Scalar_Expressions.Valid_Environment (Text, Scalar_Names)
         and then Array_Bindings.Valid_Metadata (Text, Arrays),
       Post => Value_At'Result.Value_First <= Text'Last + 1
         and then Value_At'Result.Reference <= Names.Count
         and then (Value_At'Result.After = 0
           or else Value_At'Result.After in Position + 1 .. Text'Last + 1);
   function Value_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment;
      Scalar_Names : Scalar_Expressions.Environment := Scalar_Expressions.Empty_Environment;
      Integer_Hidden : Boolean := False;
      Arrays : Array_Bindings.Metadata := Array_Bindings.Empty_Metadata;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values;
      Elaborating : Boolean := False; Context_First : Cursor := 1)
      return Value_Result is
     (declare First : constant Literal_Position := Skip_At (Text, Position);
              Quoted : constant Value_Result := Literal_At (Text, First);
              After : constant Literal_Position := Name_After (Text, First);
              Index : constant Binding_Count := Lookup_Name (Text, Names, First, After);
      begin
        (if Quoted.After /= 0 then Quoted
         elsif Index /= 0 and then not Names.Items (Index).Is_Character
           and then Take_Token (Text, After, Left_Parenthesis) /= 0 then
           Indexed_At (Text, Position, Names, Scalar_Names, Arrays, Initials, Elaborating, False, Context_First)
         elsif Index /= 0 and then not Names.Items (Index).Is_Character
           and then Scalar_Expressions.Lookup (Text, Scalar_Names, First, After) = 0 then
           (After => After, Value_First => Names.Items (Index).Value_First,
            Minimum_Length => Names.Items (Index).Static_Length,
            Static_Length => Names.Items (Index).Static_Length,
            Dynamic_Seen => Names.Items (Index).Dynamic, Nonliteral_Seen => True,
            Empty_Value => False, Reference => Index, Operands => 1,
            First_Index => Scalars.Singleton (Names.Items (Index).First_Index),
            Last_Index => (if Names.Items (Index).Dynamic then (0, Max_Source_Length)
                           else Scalars.Singleton (Names.Items (Index).Last_Index)))
         else Image_At (Text, Position, Names, Scalar_Names, Integer_Hidden, Arrays, Initials, Elaborating)));

   subtype Operand_Count is Natural range 0 .. Max_Expression_Operands;
   type Expression_Result is record
      After : Literal_Position;
      Minimum_Length, Static_Length : Capacity_Value;
      Dynamic_Count : Operand_Count;
      Named_Seen, Empty_Value : Boolean;
      First_Index, Last_Index : Scalars.Interval;
   end record;
   Invalid_Expression : constant Expression_Result :=
     (After => 0, Minimum_Length => 0, Static_Length => 0, Dynamic_Count => 0, Named_Seen => False, Empty_Value => False,
      First_Index => Scalars.Singleton (1), Last_Index => Scalars.Singleton (0));

   --  Parentheses need no stored syntax tree: grouping affects neither affine
   --  lengths nor concatenation order. The depth and operand expectation enforce
   --  the ordinary recursive grammar, while the loop remains source-bounded.
   type Expression_State is record
      Position : Literal_Position;
      Minimum_Length, Static_Length : Capacity_Value;
      Dynamic_Count, Operands : Operand_Count;
      Depth : Literal_Position;
      Named_Seen, Need_Operand, Complete, Empty_Value : Boolean;
      First_Index, Last_Index : Scalars.Interval;
   end record;
   Invalid_Expression_State : constant Expression_State :=
     (Position => 0, Minimum_Length => 0, Static_Length => 0, Dynamic_Count => 0,
      Operands => 0, Depth => 0, Named_Seen => False,
      Need_Operand => True, Complete => False, Empty_Value => False,
            First_Index => Scalars.Singleton (1), Last_Index => Scalars.Singleton (0));

   function Valid_Expression_State
     (Text : String; State : Expression_State) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_Expression_State
     (Text : String; State : Expression_State) return Boolean is
     (State.Position <= Text'Last + 1
      and then State.Dynamic_Count <= State.Operands
      and then (State.Position = 0 or else State.Depth < State.Position));

   function Concatenated_First
     (Left : Expression_State; Right : Value_Result) return Scalars.Interval is
     (if Left.Operands = 0
         or else (Left.Static_Length = 0 and then Left.Dynamic_Count = 0)
      then Right.First_Index
      elsif Left.Minimum_Length > 0 then Left.First_Index
      else Scalars.Join (Left.First_Index, Right.First_Index));

   function Concatenated_Last
     (Left : Expression_State; Right : Value_Result) return Scalars.Interval
   is
      First : constant Scalars.Interval := Concatenated_First (Left, Right);
      Minimum : constant Scalars.Wide :=
        Scalars.Wide (Left.Minimum_Length) + Scalars.Wide (Right.Minimum_Length);
      Maximum : constant Scalars.Wide :=
        (Scalars.Wide (Left.Static_Length) + Scalars.Wide (Right.Static_Length))
          + (Scalars.Wide (Left.Dynamic_Count) + (if Right.Dynamic_Seen then 1 else 0))
            * Scalars.Wide (Max_Source_Length);
      Low : constant Scalars.Wide := (Scalars.Wide (First.Lower) + Minimum) - 1;
      High : constant Scalars.Wide := (Scalars.Wide (First.Upper) + Maximum) - 1;
      Result : Scalars.Interval;
   begin
      --  Null concatenation returns its right operand, including arbitrary
      --  null upper bounds. No canonical lower-minus-one normalization applies.
      if Left.Operands = 0
        or else (Left.Static_Length = 0 and then Left.Dynamic_Count = 0)
      then return Right.Last_Index; end if;
      if Scalars.Is_Empty (First)
        or else Low < Scalars.Minimum or else Low > Scalars.Maximum
        or else High < Scalars.Minimum or else High > Scalars.Maximum
      then return Scalars.Empty; end if;
      Result := (Scalars.Value (Low), Scalars.Value (High));
      if Minimum = 0 then Result := Scalars.Join (Result, Right.Last_Index); end if;
      return Result;
   end Concatenated_Last;

   function Expression_Step
     (Text : String; Names : Binding_Environment; State : Expression_State;
      Scalar_Names : Scalar_Expressions.Environment := Scalar_Expressions.Empty_Environment;
      Integer_Hidden : Boolean := False;
      Arrays : Array_Bindings.Metadata := Array_Bindings.Empty_Metadata;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values;
      Elaborating : Boolean := False; Context_First : Cursor := 1)
      return Expression_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Context_First <= Text'Last + 1
         and then Valid_Names (Text, Names)
         and then Scalar_Expressions.Valid_Environment (Text, Scalar_Names)
         and then Array_Bindings.Valid_Metadata (Text, Arrays)
         and then Valid_Expression_State (Text, State),
       Post => Valid_Expression_State (Text, Expression_Step'Result)
         and then (Expression_Step'Result.Position = 0
           or else Expression_Step'Result.Complete
           or else Expression_Step'Result.Position > State.Position);
   function Expression_Step
     (Text : String; Names : Binding_Environment; State : Expression_State;
      Scalar_Names : Scalar_Expressions.Environment := Scalar_Expressions.Empty_Environment;
      Integer_Hidden : Boolean := False;
      Arrays : Array_Bindings.Metadata := Array_Bindings.Empty_Metadata;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values;
      Elaborating : Boolean := False; Context_First : Cursor := 1)
      return Expression_State is
     (declare Open_After : constant Literal_Position :=
                Take_Token (Text, State.Position, Left_Parenthesis);
              Atom : constant Value_Result := Value_At (Text, State.Position, Names, Scalar_Names, Integer_Hidden, Arrays, Initials, Elaborating, Context_First);
              Join_After : constant Literal_Position :=
                Take_Token (Text, State.Position, Ampersand);
              Close_After : constant Literal_Position :=
                Take_Token (Text, State.Position, Right_Parenthesis);
      begin
        (if State.Position = 0 then Invalid_Expression_State
         elsif State.Complete then State
         elsif State.Need_Operand then
           (if Open_After /= 0 then
              (State with delta Position => Open_After, Depth => State.Depth + 1)
            elsif Atom.After = 0 or else Atom.Operands > Max_Expression_Operands - State.Operands
              or else (Elaborating and then State.Dynamic_Count = 0 and then not Atom.Dynamic_Seen
                and then (Scalars.Is_Empty (Concatenated_First (State, Atom))
                  or else Scalars.Is_Empty (Concatenated_Last (State, Atom))))
              or else Atom.Static_Length > Max_Source_Length - State.Static_Length
              or else Atom.Minimum_Length > Max_Source_Length - State.Minimum_Length
            then Invalid_Expression_State
            else (State with delta Position => Atom.After,
              Minimum_Length => State.Minimum_Length + Atom.Minimum_Length,
              Static_Length => State.Static_Length + Atom.Static_Length,
              Dynamic_Count => State.Dynamic_Count + (if Atom.Dynamic_Seen then 1 else 0),
              Operands => State.Operands + Atom.Operands,
              First_Index => (if Elaborating and then State.Dynamic_Count = 0 and then not Atom.Dynamic_Seen
                then Concatenated_First (State, Atom) else Scalars.Singleton (1)),
              Last_Index => (if Elaborating and then State.Dynamic_Count = 0 and then not Atom.Dynamic_Seen
                then Concatenated_Last (State, Atom) else Scalars.Singleton (0)),
              Named_Seen => State.Named_Seen or else Atom.Nonliteral_Seen,
              Empty_Value => State.Empty_Value or else Atom.Empty_Value,
              Need_Operand => False))
         elsif Join_After /= 0 then
           (State with delta Position => Join_After, Need_Operand => True)
         elsif Close_After /= 0 and then State.Depth /= 0 then
           (State with delta Position => Close_After, Depth => State.Depth - 1)
         elsif State.Depth = 0 then (State with delta Complete => True)
         else Invalid_Expression_State));

   function Expression_Tail
     (Text : String; Names : Binding_Environment; State : Expression_State;
      Scalar_Names : Scalar_Expressions.Environment := Scalar_Expressions.Empty_Environment;
      Integer_Hidden : Boolean := False;
      Arrays : Array_Bindings.Metadata := Array_Bindings.Empty_Metadata;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values;
      Elaborating : Boolean := False; Context_First : Cursor := 1)
      return Expression_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Context_First <= Text'Last + 1
         and then Valid_Names (Text, Names)
         and then Scalar_Expressions.Valid_Environment (Text, Scalar_Names)
         and then Array_Bindings.Valid_Metadata (Text, Arrays)
         and then Valid_Expression_State (Text, State),
       Post => Expression_Tail'Result.After = 0
         or else Expression_Tail'Result.After in State.Position .. Text'Last + 1,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - State.Position);
   function Expression_Tail
     (Text : String; Names : Binding_Environment; State : Expression_State;
      Scalar_Names : Scalar_Expressions.Environment := Scalar_Expressions.Empty_Environment;
      Integer_Hidden : Boolean := False;
      Arrays : Array_Bindings.Metadata := Array_Bindings.Empty_Metadata;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values;
      Elaborating : Boolean := False; Context_First : Cursor := 1)
      return Expression_Result is
     (if State.Position = 0 then Invalid_Expression
      elsif State.Complete then
        (After => State.Position, Minimum_Length => State.Minimum_Length, Static_Length => State.Static_Length,
         Dynamic_Count => State.Dynamic_Count, Named_Seen => State.Named_Seen, Empty_Value => State.Empty_Value,
         First_Index => State.First_Index, Last_Index => State.Last_Index)
      else
        (declare Next : constant Expression_State := Expression_Step (Text, Names, State, Scalar_Names, Integer_Hidden, Arrays, Initials, Elaborating, Context_First);
         begin
           (if Next.Position = 0 then Invalid_Expression
            elsif Next.Complete then
              (After => Next.Position, Minimum_Length => Next.Minimum_Length, Static_Length => Next.Static_Length,
               Dynamic_Count => Next.Dynamic_Count, Named_Seen => Next.Named_Seen, Empty_Value => Next.Empty_Value,
               First_Index => Next.First_Index, Last_Index => Next.Last_Index)
            else Expression_Tail (Text, Names, Next, Scalar_Names, Integer_Hidden, Arrays, Initials, Elaborating, Context_First))));

   function Expression_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment;
      Scalar_Names : Scalar_Expressions.Environment := Scalar_Expressions.Empty_Environment;
      Integer_Hidden : Boolean := False;
      Arrays : Array_Bindings.Metadata := Array_Bindings.Empty_Metadata;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values;
      Elaborating : Boolean := False; Context_First : Cursor := 1)
      return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Context_First <= Text'Last + 1
         and then Position <= Text'Last + 1 and then Valid_Names (Text, Names)
         and then Scalar_Expressions.Valid_Environment (Text, Scalar_Names)
         and then Array_Bindings.Valid_Metadata (Text, Arrays),
       Post => (Static => (Expression_At'Result.After = 0
         or else Expression_At'Result.After in Position + 1 .. Text'Last + 1)
         and then (Expression_At'Result = Expression_Tail (Text, Names,
           (Position => Position, Minimum_Length => 0, Static_Length => 0, Dynamic_Count => 0,
            Operands => 0, Depth => 0, Named_Seen => False,
            Need_Operand => True, Complete => False, Empty_Value => False,
            First_Index => Scalars.Singleton (1), Last_Index => Scalars.Singleton (0)), Scalar_Names, Integer_Hidden, Arrays, Initials, Elaborating, Context_First)));
   function Expression_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment;
      Scalar_Names : Scalar_Expressions.Environment := Scalar_Expressions.Empty_Environment;
      Integer_Hidden : Boolean := False;
      Arrays : Array_Bindings.Metadata := Array_Bindings.Empty_Metadata;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values;
      Elaborating : Boolean := False; Context_First : Cursor := 1)
      return Expression_Result is
      State : Expression_State :=
        (Position => Position, Minimum_Length => 0, Static_Length => 0, Dynamic_Count => 0,
         Operands => 0, Depth => 0, Named_Seen => False,
         Need_Operand => True, Complete => False, Empty_Value => False,
            First_Index => Scalars.Singleton (1), Last_Index => Scalars.Singleton (0));
   begin
      while State.Position /= 0 and then not State.Complete loop
         pragma Loop_Invariant (Valid_Expression_State (Text, State));
         pragma Loop_Invariant (State.Position >= Position);
         pragma Loop_Invariant
           (if not State.Need_Operand then State.Position > Position);
         pragma Loop_Invariant
           (if State.Complete then not State.Need_Operand);
         pragma Loop_Invariant (Static =>
           Expression_Tail (Text, Names,
             (Position => Position, Minimum_Length => 0, Static_Length => 0, Dynamic_Count => 0,
              Operands => 0, Depth => 0, Named_Seen => False,
            Need_Operand => True, Complete => False, Empty_Value => False,
            First_Index => Scalars.Singleton (1), Last_Index => Scalars.Singleton (0)), Scalar_Names, Integer_Hidden, Arrays, Initials, Elaborating, Context_First)
             = Expression_Tail (Text, Names, State, Scalar_Names, Integer_Hidden, Arrays, Initials, Elaborating, Context_First));
         pragma Loop_Variant (Increases => State.Position);
         State := Expression_Step (Text, Names, State, Scalar_Names, Integer_Hidden, Arrays, Initials, Elaborating, Context_First);
      end loop;
      if State.Position = 0 then return Invalid_Expression; end if;
      return (After => State.Position, Minimum_Length => State.Minimum_Length, Static_Length => State.Static_Length,
              Dynamic_Count => State.Dynamic_Count, Named_Seen => State.Named_Seen, Empty_Value => State.Empty_Value,
         First_Index => State.First_Index, Last_Index => State.Last_Index);
   end Expression_At;

   function Fits (Value : Expression_Result; Capacity : Capacity_Value) return Boolean
     with Global => null;
   function Fits (Value : Expression_Result; Capacity : Capacity_Value) return Boolean is
     (Value.After /= 0
      and then (Value.Empty_Value
        or else Value.Static_Length + Value.Dynamic_Count * Capacity <= Max_Source_Length));

   function New_Name_Allowed
     (Text : String; State : Parser_State; First, After : Literal_Position;
      Arguments : Boolean) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State)
         and then First <= Text'Last + 1 and then After <= Text'Last + 1;
   function New_Name_Allowed
     (Text : String; State : Parser_State; First, After : Literal_Position;
      Arguments : Boolean) return Boolean is
     (First /= 0 and then After > First
      and then not Forbidden_Name (Text, First, After)
      and then (State.Package_First = 0 or else not Equal_Name
        (Text, State.Package_First, State.Package_After, First, After))
      and then (not Arguments or else not Forbidden_Argument_Name (Text, First, After))
      and then Lookup_Name (Text, State.Names, First, After) = 0
      and then Scalar_Expressions.Lookup (Text, State.Scalar_Names, First, After) = 0
      and then Array_Bindings.Lookup (Text, State.Array_Names.Names, First, After) = 0
      and then Array_Bindings.Lookup_Type (Text, State.Array_Names.Names.Types, First, After) = 0
      and then Lookup_Boolean (Text, State.Boolean_Names, First, After) = 0
      and then Lookup_Subtype (Text, State.Subtype_Names, First, After) = 0
      and then not Formal_Hides (Text, State, First, After)
      and then (State.Pure or else
        (Functions.Lookup (Text, State.Functions, First, After) = 0
         and then Procedures.Lookup (Text, State.Procedures, First, After) = 0)));

   function Add_Binding
     (State : Parser_State; First, After : Literal_Position;
      Value : Value_Result; Mutable : Boolean; Following : Literal_Position;
      Character_Object : Boolean := False)
      return Parser_State
     with Global => null,
       Pre => State.Names.Count < Max_Bindings
         and then Fixed_Bounds_Valid
           (Value.Static_Length, Value.Dynamic_Seen, Character_Object,
            Value.First_Index.Lower, Value.Last_Index.Lower, State.Names.Count + 1);
   function Add_Binding
     (State : Parser_State; First, After : Literal_Position;
      Value : Value_Result; Mutable : Boolean; Following : Literal_Position;
      Character_Object : Boolean := False)
      return Parser_State is
     (State with delta Position => Following,
        Names => (Count => State.Names.Count + 1,
          Items => (State.Names.Items with delta State.Names.Count + 1 =>
            (First => First, After => After, Value_First => Value.Value_First,
             Static_Length => Value.Static_Length, Dynamic => Value.Dynamic_Seen,
             Mutable => Mutable, Is_Character => Character_Object,
             First_Index => Value.First_Index.Lower, Last_Index => Value.Last_Index.Lower))));

   type Scalar_Constraint_Result is record
      After : Literal_Position;
      Bounds : Scalars.Interval;
   end record;
   function Scalar_Constraint_At
     (Text : String; Position : Literal_Position;
      Scalar_Names : Scalar_Expressions.Environment;
      Base_Bounds : Scalars.Interval := Scalars.Full;
      Arrays : Array_Bindings.Metadata := Array_Bindings.Empty_Metadata) return Scalar_Constraint_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Scalar_Expressions.Valid_Environment (Text, Scalar_Names)
         and then Array_Bindings.Valid_Metadata (Text, Arrays),
       Post => Scalar_Constraint_At'Result.After = 0
         or else Scalar_Constraint_At'Result.After in Position .. Text'Last + 1;
   function Scalar_Constraint_At
     (Text : String; Position : Literal_Position;
      Scalar_Names : Scalar_Expressions.Environment;
      Base_Bounds : Scalars.Interval := Scalars.Full;
      Arrays : Array_Bindings.Metadata := Array_Bindings.Empty_Metadata) return Scalar_Constraint_Result is
     (declare Range_After : constant Literal_Position := Take_Token (Text, Position, Range_Keyword);
      Low : constant Scalar_Expressions.Expression_Result :=
        Scalar_Expressions.Read_Expression (Text, Range_After, Scalar_Names, Arrays => Arrays);
      Delimiter_After : constant Literal_Position :=
        Take_Token (Text, Low.After, Range_Delimiter);
      High : constant Scalar_Expressions.Expression_Result :=
        Scalar_Expressions.Read_Expression
          (Text, Delimiter_After, Scalar_Names, Arrays => Arrays);
      begin
        (if Range_After = 0 then (Position, Base_Bounds)
         elsif Low.After = 0 or else Delimiter_After = 0 or else High.After = 0
           or else not Low.Static or else not High.Static
           or else Scalars.Is_Empty (Low.Bounds) or else Scalars.Is_Empty (High.Bounds)
           or else Low.Bounds.Lower /= Low.Bounds.Upper
           or else High.Bounds.Lower /= High.Bounds.Upper
           or else High.Bounds.Lower < Low.Bounds.Lower
           or else Low.Bounds.Lower < Base_Bounds.Lower
           or else High.Bounds.Lower > Base_Bounds.Upper
         then (0, Scalars.Empty)
         else (High.After, (Low.Bounds.Lower, High.Bounds.Lower))));

   function Scalar_Type_At
     (Text : String; State : Parser_State; Position : Literal_Position)
      return Scalar_Constraint_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State) and then Position <= Text'Last + 1,
       Post => Scalar_Type_At'Result.After = 0
         or else (Scalar_Type_At'Result.After in Position + 1 .. Text'Last + 1
           and then not Scalars.Is_Empty (Scalar_Type_At'Result.Bounds));
   function Scalar_Type_At
     (Text : String; State : Parser_State; Position : Literal_Position)
      return Scalar_Constraint_Result is
     (declare Reference : constant Scalar_Expressions.Name_Reference :=
                Scalar_Expressions.Read_Reference (Text, Position);
              First : constant Literal_Position := Reference.First;
              After : constant Literal_Position := Reference.After;
              Target : constant Subtype_Count :=
                Lookup_Subtype (Text, State.Subtype_Names, First, After,
                  Reference.Qualifier_First, Reference.Qualifier_After);
      begin
        (if First = 0 or else After <= First then (0, Scalars.Empty)
         elsif Reference.Qualifier_First /= 0 then
           (if Target /= 0 then (After, State.Subtype_Names.Items (Target).Bounds)
            else (0, Scalars.Empty))
         elsif Lookup_Name (Text, State.Names, First, After) /= 0
           or else Scalar_Expressions.Lookup (Text, State.Scalar_Names, First, After) /= 0
           or else Array_Bindings.Lookup (Text, State.Array_Names.Names, First, After) /= 0
           or else Array_Bindings.Lookup_Type (Text, State.Array_Names.Names.Types, First, After) /= 0
           or else Lookup_Boolean (Text, State.Boolean_Names, First, After) /= 0
           or else Functions.Lookup (Text, State.Functions, First, After) /= 0
           or else Procedures.Lookup (Text, State.Procedures, First, After) /= 0
           or else Formal_Hides (Text, State, First, After)
           or else (State.Hiding.Integer_Hidden and then Name_Is (Text, First, After, "integer"))
         then (0, Scalars.Empty)
         elsif Name_Is (Text, First, After, "integer") then (After, Scalars.Full)
         elsif Target /= 0 then (After, State.Subtype_Names.Items (Target).Bounds)
         else (0, Scalars.Empty)));

   function Array_Type_At
     (Text : String; State : Parser_State; Position : Literal_Position)
      return Array_Bindings.Type_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State) and then Position <= Text'Last + 1,
       Post => Array_Type_At'Result <= State.Array_Names.Names.Types.Count;
   function Array_Type_At
     (Text : String; State : Parser_State; Position : Literal_Position)
      return Array_Bindings.Type_Count is
     (declare First : constant Literal_Position := Skip_At (Text, Position);
       After : constant Literal_Position := Name_After (Text, First);
      begin (if First = 0 or else After <= First
        or else Lookup_Name (Text, State.Names, First, After) /= 0
        or else Scalar_Expressions.Lookup (Text, State.Scalar_Names, First, After) /= 0
        or else Array_Bindings.Lookup (Text, State.Array_Names.Names, First, After) /= 0
        or else Lookup_Boolean (Text, State.Boolean_Names, First, After) /= 0
        or else Functions.Lookup (Text, State.Functions, First, After) /= 0
        or else Procedures.Lookup (Text, State.Procedures, First, After) /= 0
        or else Formal_Hides (Text, State, First, After)
       then 0 else Array_Bindings.Lookup_Type (Text, State.Array_Names.Names.Types, First, After)));

   function Array_Type_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Array_Type_Declaration_At'Result)
         and then (Array_Type_Declaration_At'Result.Position = 0
           or else Array_Type_Declaration_At'Result.Position > State.Position);
   function Array_Type_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
      First : constant Literal_Position := Skip_At
        (Text, Take_Token (Text, State.Position, Type_Keyword));
      After : constant Literal_Position := Name_After (Text, First);
      Start : constant Literal_Position := Take_Token (Text,
        Take_Token (Text, Take_Token (Text, After, Is_Keyword), Array_Keyword), Left_Parenthesis);
      Low : constant Scalar_Expressions.Expression_Result := Scalar_Expressions.Read_Expression
        (Text, Start, State.Scalar_Names, Arrays => State.Array_Names.Names);
      High : constant Scalar_Expressions.Expression_Result := Scalar_Expressions.Read_Expression
        (Text, Take_Token (Text, Low.After, Range_Delimiter), State.Scalar_Names,
         Arrays => State.Array_Names.Names);
      Component : constant Scalar_Constraint_Result := Scalar_Type_At (Text, State,
        Take_Token (Text, Take_Token (Text, High.After, Right_Parenthesis), Of_Keyword));
      Following : constant Literal_Position := Take_Token (Text, Component.After, Semicolon);
   begin
      if Start = 0 or else Following <= State.Position or else State.Pure
        or else not New_Name_Allowed (Text, State, First, After, Arguments)
        or else Name_Is (Text, First, After, "integer")
        or else State.Array_Names.Names.Types.Count = Array_Bindings.Max_Types
        or else Low.After = 0 or else High.After = 0 or else Component.After = 0
        or else not Low.Static or else not High.Static
        or else Scalars.Is_Empty (Low.Bounds) or else Scalars.Is_Empty (High.Bounds)
        or else Low.Bounds.Lower /= Low.Bounds.Upper or else High.Bounds.Lower /= High.Bounds.Upper
        or else Low.Bounds.Lower > High.Bounds.Lower
        or else Scalars.Wide (High.Bounds.Lower) - Scalars.Wide (Low.Bounds.Lower)
          >= Scalars.Wide (Array_Bindings.Max_Elements)
      then return Invalid_State; end if;
      return (State with delta Position => Following,
        Array_Names => (State.Array_Names with delta Names =>
          (State.Array_Names.Names with delta Types =>
            (Count => State.Array_Names.Names.Types.Count + 1,
             Items => (State.Array_Names.Names.Types.Items with delta
               State.Array_Names.Names.Types.Count + 1 =>
                 (First, After, (Low.Bounds.Lower, High.Bounds.Lower), Component.Bounds))))),
        Subtype_Names => (State.Subtype_Names with delta
          True_Hidden => State.Subtype_Names.True_Hidden or else Name_Is (Text, First, After, "true"),
          False_Hidden => State.Subtype_Names.False_Hidden or else Name_Is (Text, First, After, "false"),
          Hidden_Calls => (for Operation in Names.Operation_Kind =>
            State.Subtype_Names.Hidden_Calls (Operation) or else Name_Is (Text, First, After,
              (case Operation is
                when Names.Output_Call => "put_line",
                when Names.Partial_Output_Call => "put",
                when Names.Argument_Call => "first_or_default",
                when Names.Validity_Call => "input_is_valid",
                when Names.Reject_Call => "reject")))));
   end Array_Type_Declaration_At;

   function Subtype_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Subtype_Declaration_At'Result)
         and then (Subtype_Declaration_At'Result.Position = 0
           or else Subtype_Declaration_At'Result.Position > State.Position);
   function Subtype_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
     (declare First : constant Literal_Position :=
                Skip_At (Text, Take_Token (Text, State.Position, Subtype_Keyword));
              After : constant Literal_Position := Name_After (Text, First);
              Type_First : constant Literal_Position :=
                Skip_At (Text, Take_Token (Text, After, Is_Keyword));
              Type_After : constant Literal_Position := Take_Token (Text, Type_First, Integer_Name);
              Constraint : constant Scalar_Constraint_Result :=
                Scalar_Constraint_At (Text, Type_After, State.Scalar_Names, Arrays => State.Array_Names.Names);
              Following : constant Literal_Position := Take_Token (Text, Constraint.After, Semicolon);
      begin
        (if not New_Name_Allowed (Text, State, First, After, Arguments)
           or else Name_Is (Text, First, After, "integer")
           or else State.Subtype_Names.Count = Max_Subtype_Bindings
           or else Type_After = 0 or else Take_Token (Text, Type_After, Range_Keyword) = 0
           or else Constraint.After = 0 or else Following <= State.Position
           or else Scalars.Is_Empty (Constraint.Bounds)
           or else Lookup_Name (Text, State.Names, Type_First, Type_After) /= 0
           or else Scalar_Expressions.Lookup (Text, State.Scalar_Names, Type_First, Type_After) /= 0
           or else Array_Bindings.Lookup (Text, State.Array_Names.Names, Type_First, Type_After) /= 0
           or else Array_Bindings.Lookup_Type (Text, State.Array_Names.Names.Types, Type_First, Type_After) /= 0
           or else Lookup_Boolean (Text, State.Boolean_Names, Type_First, Type_After) /= 0
           or else Functions.Lookup (Text, State.Functions, Type_First, Type_After) /= 0
           or else Procedures.Lookup (Text, State.Procedures, Type_First, Type_After) /= 0
           or else Formal_Hides (Text, State, Type_First, Type_After)
           or else (State.Hiding.Integer_Hidden and then Name_Is (Text, Type_First, Type_After, "integer"))
           or else (State.Hiding.Boolean_Hidden and then Name_Is (Text, Type_First, Type_After, "boolean"))
           or else (State.Hiding.Character_Hidden and then Name_Is (Text, Type_First, Type_After, "character"))
         then Invalid_State
         else (State with delta Position => Following,
           Subtype_Names =>
             (Count => State.Subtype_Names.Count + 1,
              Items => (State.Subtype_Names.Items with delta State.Subtype_Names.Count + 1 =>
                (First, After, Constraint.Bounds, 0, 0)),
              True_Hidden => State.Subtype_Names.True_Hidden or else Name_Is (Text, First, After, "true"),
              False_Hidden => State.Subtype_Names.False_Hidden or else Name_Is (Text, First, After, "false"),
              Hidden_Calls =>
                (for Operation in Names.Operation_Kind =>
                  State.Subtype_Names.Hidden_Calls (Operation) or else
                    Name_Is (Text, First, After,
                      (case Operation is
                        when Names.Output_Call => "put_line",
                        when Names.Partial_Output_Call => "put",
                        when Names.Argument_Call => "first_or_default",
                        when Names.Validity_Call => "input_is_valid",
                        when Names.Reject_Call => "reject")))))));

   function Scalar_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Scalar_Declaration_At'Result)
         and then (Scalar_Declaration_At'Result.Position = 0
           or else (Scalar_Declaration_At'Result.Position > State.Position
             and then Scalar_Declaration_At'Result.Functions = State.Functions
             and then Scalar_Declaration_At'Result.Procedures = State.Procedures
             and then Scalar_Declaration_At'Result.First_Procedure_Parameter = State.First_Procedure_Parameter
             and then Scalar_Declaration_At'Result.First_Parameter = State.First_Parameter
             and then Scalar_Declaration_At'Result.Pure = State.Pure));
   function Scalar_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
     (declare First : constant Literal_Position := Skip_At (Text, State.Position);
      After : constant Literal_Position := Name_After (Text, First);
      Colon_After : constant Literal_Position := Take_Token (Text, After, Colon);
      Constant_After : constant Literal_Position := Take_Token (Text, Colon_After, Constant_Keyword);
      Type_First : constant Literal_Position := Skip_At (Text,
        (if Constant_After /= 0 then Constant_After else Colon_After));
      Type_Mark : constant Scalar_Constraint_Result := Scalar_Type_At (Text, State, Type_First);
      Type_After : constant Literal_Position := Type_Mark.After;
      Constraint : constant Scalar_Constraint_Result :=
        Scalar_Constraint_At (Text, Type_After, State.Scalar_Names, Type_Mark.Bounds, State.Array_Names.Names);
      Value : constant Scalar_Expressions.Expression_Result :=
        Scalar_Expressions.Read_Expression
          (Text, Take_Token (Text, Constraint.After, Assignment), State.Scalar_Names,
           Arrays => State.Array_Names.Names,
           Initials => State.Array_Names.Values, Elaborating => True);
      Following : constant Literal_Position := Take_Token (Text, Value.After, Semicolon);
      begin
        (if not New_Name_Allowed (Text, State, First, After, Arguments)
        or else Type_After = 0 or else Constraint.After = 0 or else Following <= State.Position
        or else State.Scalar_Names.Count = Scalar_Expressions.Max_Bindings
        or else Scalars.Is_Empty (Value.Bounds) or else Value.Bounds.Lower /= Value.Bounds.Upper
        or else Value.Bounds.Lower < Constraint.Bounds.Lower
        or else Constraint.Bounds.Upper < Value.Bounds.Upper
        or else Name_Is (Text, First, After, "integer")
        or else Lookup_Name (Text, State.Names, Type_First, Type_After) /= 0
        or else Scalar_Expressions.Lookup (Text, State.Scalar_Names, Type_First, Type_After) /= 0
        or else Array_Bindings.Lookup (Text, State.Array_Names.Names, Type_First, Type_After) /= 0
           or else Array_Bindings.Lookup_Type (Text, State.Array_Names.Names.Types, Type_First, Type_After) /= 0
         then Invalid_State
         else (State with delta Position => Following,
        Scalar_Names => Scalar_Expressions.Append
          (State.Scalar_Names,
           (First, After, Value.Bounds, Constant_After /= 0 and then Value.Static,
            Constraint.Bounds, Constant_After = 0, 0, 0)))));

   function Character_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Character_Declaration_At'Result)
         and then (Character_Declaration_At'Result.Position = 0
           or else Character_Declaration_At'Result.Position > State.Position);
   function Character_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
   is
      First : constant Literal_Position := Skip_At (Text, State.Position);
      After : constant Literal_Position := Name_After (Text, First);
      Colon_After : constant Literal_Position := Take_Token (Text, After, Colon);
      Constant_After : constant Literal_Position := Take_Token (Text, Colon_After, Constant_Keyword);
      Type_First : constant Literal_Position := Skip_At
        (Text, (if Constant_After /= 0 then Constant_After else Colon_After));
      Type_After : constant Literal_Position := Take_Token (Text, Type_First, Character_Name);
      Value : constant Value_Result := Character_At
        (Text, Take_Token (Text, Type_After, Assignment), State.Names, State.Scalar_Names,
         State.Array_Names.Names, State.Array_Names.Values, True);
      Following : constant Literal_Position := Take_Token (Text, Value.After, Semicolon);
   begin
      if not New_Name_Allowed (Text, State, First, After, Arguments)
        or else Type_After = 0 or else Following <= State.Position or else State.Names.Count = Max_Bindings
        or else Name_Is (Text, First, After, "character")
        or else Lookup_Name (Text, State.Names, Type_First, Type_After) /= 0
        or else Scalar_Expressions.Lookup (Text, State.Scalar_Names, Type_First, Type_After) /= 0
        or else Array_Bindings.Lookup (Text, State.Array_Names.Names, Type_First, Type_After) /= 0
           or else Array_Bindings.Lookup_Type (Text, State.Array_Names.Names.Types, Type_First, Type_After) /= 0
        or else Lookup_Subtype (Text, State.Subtype_Names, Type_First, Type_After) /= 0
        or else Lookup_Boolean (Text, State.Boolean_Names, Type_First, Type_After) /= 0
           or else Functions.Lookup (Text, State.Functions, Type_First, Type_After) /= 0
           or else Procedures.Lookup (Text, State.Procedures, Type_First, Type_After) /= 0
           or else Formal_Hides (Text, State, Type_First, Type_After)
           or else (State.Hiding.Integer_Hidden and then Name_Is (Text, Type_First, Type_After, "integer"))
           or else (State.Hiding.Boolean_Hidden and then Name_Is (Text, Type_First, Type_After, "boolean"))
           or else (State.Hiding.Character_Hidden and then Name_Is (Text, Type_First, Type_After, "character"))
      then return Invalid_State; end if;
      return Add_Binding (State, First, After, Value, Constant_After = 0,
        Following, Character_Object => True);
   end Character_Declaration_At;

   function String_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, String_Declaration_At'Result)
         and then (String_Declaration_At'Result.Position = 0
           or else String_Declaration_At'Result.Position > State.Position);
   function String_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
     (declare First : constant Literal_Position := Skip_At (Text, State.Position);
              After : constant Literal_Position := Name_After (Text, First);
              Colon_After : constant Literal_Position := Take_Token (Text, After, Colon);
              Constant_After : constant Literal_Position := Take_Token (Text, Colon_After, Constant_Keyword);
              Type_After : constant Literal_Position := Take_Token (Text,
                (if Constant_After /= 0 then Constant_After else Colon_After), String_Name);
              Value : constant Expression_Result := Expression_At
                (Text, Take_Token (Text, Type_After, Assignment), State.Names, State.Scalar_Names,
                 (First /= 0 and then After > First
                   and then Take_Token (Text, First, Integer_Name) = After)
                   or else Boolean_Hides_Integer (Text, State.Boolean_Names)
                   or else State.Hiding.Integer_Hidden,
                 State.Array_Names.Names, State.Array_Names.Values, True, State.Context_First);
              Following : constant Literal_Position := Take_Token (Text, Value.After, Semicolon);
      begin
        (if not New_Name_Allowed (Text, State, First, After, Arguments)
           or else Following = 0 or else State.Names.Count = Max_Bindings
           or else Array_Bindings.Lookup_Type (Text, State.Array_Names.Names.Types,
             Skip_At (Text, (if Constant_After /= 0 then Constant_After else Colon_After)), Type_After) /= 0
           or else not Fits (Value, Max_Source_Length)
           or else Value.Empty_Value or else Value.Minimum_Length /= Value.Static_Length
           or else (Value.Dynamic_Count = 0 and then
             (Scalars.Is_Empty (Value.First_Index) or else Scalars.Is_Empty (Value.Last_Index)
              or else Value.First_Index.Lower /= Value.First_Index.Upper
              or else Value.Last_Index.Lower /= Value.Last_Index.Upper))
           or else not Fixed_Bounds_Valid
             (Value.Static_Length, Value.Dynamic_Count = 1, False,
              Value.First_Index.Lower, Value.Last_Index.Lower, State.Names.Count + 1)
         then Invalid_State
         else Add_Binding (State, First, After,
           (After => Value.After, Value_First => 0, Minimum_Length => Value.Minimum_Length,
            Static_Length => Value.Static_Length, Dynamic_Seen => Value.Dynamic_Count = 1,
            Nonliteral_Seen => Value.Named_Seen, Empty_Value => Value.Empty_Value, Reference => 0,
            Operands => 1, First_Index => Value.First_Index, Last_Index => Value.Last_Index),
           Constant_After = 0, Following)));

   --  Share this exact successor in the model and executable loop.  Distinct
   --  array delta aggregates supply only pointwise equality to the prover.
   function Put_Array_Value (State : Parser_State; Value : Scalars.Value) return Parser_State is
     (State with delta Array_Names => (State.Array_Names with delta
       Used => State.Array_Names.Used + 1,
       Values => (State.Array_Names.Values with delta State.Array_Names.Used + 1 => Value)))
     with Global => null, Pre => State.Array_Names.Used < Array_Bindings.Max_Elements;

   function Add_Array_Binding
     (Text : String; State : Parser_State; First, After : Literal_Position;
      Bounds : Scalars.Interval; Offset, Length : Array_Bindings.Element_Count;
      Mutable : Boolean; Following : Literal_Position;
      Component_Bounds : Scalars.Interval; Boolean_Elements : Boolean := False;
      Type_Id : Array_Bindings.Type_Count := 0) return Parser_State is
     (State with delta Position => Following,
       Array_Names => (State.Array_Names with delta Names =>
         (State.Array_Names.Names with delta Count => State.Array_Names.Names.Count + 1,
          Items => (State.Array_Names.Names.Items with delta State.Array_Names.Names.Count + 1 =>
            (First, After, Bounds, Offset, Length, Mutable, Component_Bounds, Boolean_Elements, Type_Id, 0)))))
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State)
         and then State.Array_Names.Names.Count < Array_Bindings.Max_Bindings
         and then First > 0 and then Valid_Name_State (Text, First, After)
         and then Array_Bindings.Valid_Binding ((First, After, Bounds, Offset, Length, Mutable, Component_Bounds, Boolean_Elements, Type_Id, 0))
         and then Type_Id <= State.Array_Names.Names.Types.Count
         and then (if Type_Id /= 0 then
           Bounds = State.Array_Names.Names.Types.Items (Type_Id).Bounds
           and then Component_Bounds = State.Array_Names.Names.Types.Items (Type_Id).Component_Bounds)
         and then Offset + Length <= State.Array_Names.Used
         and then (if State.Array_Names.Names.Count > 0 then
           State.Array_Names.Names.Items (State.Array_Names.Names.Count).View_Slot = 0 and then Offset >=
           State.Array_Names.Names.Items (State.Array_Names.Names.Count).Offset
             + State.Array_Names.Names.Items (State.Array_Names.Names.Count).Length)
         and then Following <= Text'Last + 1,
       Post => Valid_State (Text, Add_Array_Binding'Result)
         and then Add_Array_Binding'Result.Position = Following;

   --  Keep the fixed-array extensionality checks separate from the
   --  enclosing parser record's logical equality check.
   function Same_Parser_String_Items (Left, Right : Binding_Array) return Boolean is
     (Left'First = Right'First and then Left'Last = Right'Last
      and then (for all Index in Binding_Index => Left (Index) = Right (Index)))
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Parser_Scalar_Items
     (Left, Right : Scalar_Expressions.Binding_Array) return Boolean is
     (Left'First = Right'First and then Left'Last = Right'Last
      and then (for all Index in Scalar_Expressions.Binding_Index => Left (Index) = Right (Index)))
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Parser_Array_Types
     (Left, Right : Array_Bindings.Type_Array) return Boolean is
     (Left'First = Right'First and then Left'Last = Right'Last
      and then (for all Index in Array_Bindings.Type_Index => Left (Index) = Right (Index)))
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);

   function Same_Parser_Array_Items
     (Left, Right : Array_Bindings.Binding_Array) return Boolean is
     (Left'First = Right'First and then Left'Last = Right'Last
      and then (for all Index in Array_Bindings.Binding_Index => Left (Index) = Right (Index)))
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Parser_Elements
     (Left, Right : Array_Bindings.Element_Array) return Boolean is
     (Left'First = Right'First and then Left'Last = Right'Last
      and then (for all Index in Array_Bindings.Element_Index => Left (Index) = Right (Index)))
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Parser_Subtype_Items
     (Left, Right : Subtype_Binding_Array) return Boolean is
     (Left'First = Right'First and then Left'Last = Right'Last
      and then (for all Index in Subtype_Index => Left (Index) = Right (Index)))
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Parser_Subtype_Visibility
     (Left, Right : Subtype_Visibility) return Boolean is
     (Left'First = Right'First and then Left'Last = Right'Last
      and then (for all Operation in Names.Operation_Kind =>
        Left (Operation) = Right (Operation)))
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Parser_Boolean_Items
     (Left, Right : Boolean_Binding_Array) return Boolean is
     (Left'First = Right'First and then Left'Last = Right'Last
      and then (for all Index in Boolean_Index => Left (Index) = Right (Index)))
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Parser_Function_Items
     (Left, Right : Functions.Signature_Array) return Boolean is
     (Left'First = Right'First and then Left'Last = Right'Last
      and then (for all Index in Functions.Function_Index => Left (Index) = Right (Index)))
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Parser_Formal_Items
     (Left, Right : Functions.Formal_Array) return Boolean is
     (Left'First = Right'First and then Left'Last = Right'Last
      and then (for all Index in Functions.Formal_Index => Left (Index) = Right (Index)))
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Parser_Procedure_Items
     (Left, Right : Procedures.Signature_Array) return Boolean is
     (Left'First = Right'First and then Left'Last = Right'Last
      and then (for all Index in Procedures.Procedure_Index => Left (Index) = Right (Index)))
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Parser_Procedure_Formals
     (Left, Right : Procedures.Formal_Array) return Boolean is
     (Left'First = Right'First and then Left'Last = Right'Last
      and then (for all Index in Procedures.Formal_Index => Left (Index) = Right (Index)))
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Parser_State (Left, Right : Parser_State) return Boolean is
     (Left.Position = Right.Position
      and then Left.Context_First = Right.Context_First
      and then Left.Package_First = Right.Package_First
      and then Left.Package_After = Right.Package_After
      and then Left.Functions.Count = Right.Functions.Count
      and then Same_Parser_Function_Items (Left.Functions.Items, Right.Functions.Items)
      and then Left.Functions.Parameter_Count = Right.Functions.Parameter_Count
      and then Same_Parser_Formal_Items (Left.Functions.Parameters, Right.Functions.Parameters)
      and then Left.Procedures.Count = Right.Procedures.Count
      and then Same_Parser_Procedure_Items (Left.Procedures.Items, Right.Procedures.Items)
      and then Left.Procedures.Parameter_Count = Right.Procedures.Parameter_Count
      and then Same_Parser_Procedure_Formals (Left.Procedures.Parameters, Right.Procedures.Parameters)
      and then Left.First_Procedure_Parameter = Right.First_Procedure_Parameter
      and then Left.Pure = Right.Pure
      and then Left.Assigned_In_Functions = Right.Assigned_In_Functions
      and then Left.Hiding = Right.Hiding
      and then Left.First_Parameter = Right.First_Parameter
      and then Left.Names.Count = Right.Names.Count
      and then Same_Parser_String_Items (Left.Names.Items, Right.Names.Items)
      and then Left.Scalar_Names.Count = Right.Scalar_Names.Count
      and then Same_Parser_Scalar_Items (Left.Scalar_Names.Items, Right.Scalar_Names.Items)
      and then Left.Array_Names.Names.Types.Count = Right.Array_Names.Names.Types.Count
      and then Same_Parser_Array_Types (Left.Array_Names.Names.Types.Items, Right.Array_Names.Names.Types.Items)
      and then Left.Array_Names.Names.Count = Right.Array_Names.Names.Count
      and then Same_Parser_Array_Items (Left.Array_Names.Names.Items, Right.Array_Names.Names.Items)
      and then Left.Array_Names.Used = Right.Array_Names.Used
      and then Same_Parser_Elements (Left.Array_Names.Values, Right.Array_Names.Values)
      and then Left.Subtype_Names.Count = Right.Subtype_Names.Count
      and then Same_Parser_Subtype_Items (Left.Subtype_Names.Items, Right.Subtype_Names.Items)
      and then Same_Parser_Subtype_Visibility
        (Left.Subtype_Names.Hidden_Calls, Right.Subtype_Names.Hidden_Calls)
      and then Left.Subtype_Names.True_Hidden = Right.Subtype_Names.True_Hidden
      and then Left.Subtype_Names.False_Hidden = Right.Subtype_Names.False_Hidden
      and then Left.Boolean_Names.Count = Right.Boolean_Names.Count
      and then Same_Parser_Boolean_Items (Left.Boolean_Names.Items, Right.Boolean_Names.Items)
      and then Left.Dynamic_First = Right.Dynamic_First and then Left.Dynamic_After = Right.Dynamic_After
      and then Left.Target = Right.Target and then Left.Capacity = Right.Capacity)
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);

   procedure Lemma_Parser_State_Equality (Left, Right : Parser_State)
     with Ghost => Static, Global => null,
       Pre => Same_Parser_State (Left, Right),
       Post => Left = Right and then Same_Parser_State (Left, Right)
   is
   begin
      --  Isolate Ada record equality from the declaration's branch context.
      --  The checked Logical_Equal premise supplies logical state identity.
      null;
   end Lemma_Parser_State_Equality;

   procedure Lemma_Parser_State_Same (Left, Right : Parser_State)
     with Ghost => Static, Global => null,
       Pre => Left = Right,
       Post => Same_Parser_State (Left, Right)
   is
   begin
      --  All component arrays have fixed bounds. Equal records therefore
      --  have equal same-index cells, including inactive storage and types.
      pragma Assert (Static => Left.Functions.Items = Right.Functions.Items);
      pragma Assert (Static =>
        (for all Index in Functions.Function_Index =>
          Left.Functions.Items (Index) = Right.Functions.Items (Index)));
      pragma Assert (Static => Same_Parser_Function_Items
        (Left.Functions.Items, Right.Functions.Items));
      pragma Assert (Static => Left.Functions.Parameters = Right.Functions.Parameters);
      pragma Assert (Static =>
        (for all Index in Functions.Formal_Index =>
          Left.Functions.Parameters (Index) = Right.Functions.Parameters (Index)));
      pragma Assert (Static => Same_Parser_Formal_Items
        (Left.Functions.Parameters, Right.Functions.Parameters));
      pragma Assert (Static => Left.Procedures.Items = Right.Procedures.Items);
      pragma Assert (Static =>
        (for all Index in Procedures.Procedure_Index =>
          Left.Procedures.Items (Index) = Right.Procedures.Items (Index)));
      pragma Assert (Static => Same_Parser_Procedure_Items
        (Left.Procedures.Items, Right.Procedures.Items));
      pragma Assert (Static => Left.Procedures.Parameters = Right.Procedures.Parameters);
      pragma Assert (Static =>
        (for all Index in Procedures.Formal_Index =>
          Left.Procedures.Parameters (Index) = Right.Procedures.Parameters (Index)));
      pragma Assert (Static => Same_Parser_Procedure_Formals
        (Left.Procedures.Parameters, Right.Procedures.Parameters));
      pragma Assert (Static => Left.Names.Items = Right.Names.Items);
      pragma Assert (Static =>
        (for all Index in Binding_Index =>
          Left.Names.Items (Index) = Right.Names.Items (Index)));
      pragma Assert (Static => Same_Parser_String_Items
        (Left.Names.Items, Right.Names.Items));
      pragma Assert (Static => Left.Scalar_Names.Items = Right.Scalar_Names.Items);
      pragma Assert (Static =>
        (for all Index in Scalar_Expressions.Binding_Index =>
          Left.Scalar_Names.Items (Index) = Right.Scalar_Names.Items (Index)));
      pragma Assert (Static => Same_Parser_Scalar_Items
        (Left.Scalar_Names.Items, Right.Scalar_Names.Items));
      pragma Assert (Static => Left.Array_Names.Names.Types.Items = Right.Array_Names.Names.Types.Items);
      pragma Assert (Static =>
        (for all Index in Array_Bindings.Type_Index =>
          Left.Array_Names.Names.Types.Items (Index) = Right.Array_Names.Names.Types.Items (Index)));
      pragma Assert (Static => Same_Parser_Array_Types
        (Left.Array_Names.Names.Types.Items, Right.Array_Names.Names.Types.Items));
      pragma Assert (Static => Left.Array_Names.Names.Items = Right.Array_Names.Names.Items);
      pragma Assert (Static =>
        (for all Index in Array_Bindings.Binding_Index =>
          Left.Array_Names.Names.Items (Index) = Right.Array_Names.Names.Items (Index)));
      pragma Assert (Static => Same_Parser_Array_Items
        (Left.Array_Names.Names.Items, Right.Array_Names.Names.Items));
      pragma Assert (Static => Left.Array_Names.Values = Right.Array_Names.Values);
      pragma Assert (Static =>
        (for all Index in Array_Bindings.Element_Index =>
          Left.Array_Names.Values (Index) = Right.Array_Names.Values (Index)));
      pragma Assert (Static => Same_Parser_Elements
        (Left.Array_Names.Values, Right.Array_Names.Values));
      pragma Assert (Static => Left.Subtype_Names.Items = Right.Subtype_Names.Items);
      pragma Assert (Static =>
        (for all Index in Subtype_Index =>
          Left.Subtype_Names.Items (Index) = Right.Subtype_Names.Items (Index)));
      pragma Assert (Static => Same_Parser_Subtype_Items
        (Left.Subtype_Names.Items, Right.Subtype_Names.Items));
      pragma Assert (Static => Left.Subtype_Names.Hidden_Calls = Right.Subtype_Names.Hidden_Calls);
      pragma Assert (Static =>
        (for all Index in Names.Operation_Kind =>
          Left.Subtype_Names.Hidden_Calls (Index) = Right.Subtype_Names.Hidden_Calls (Index)));
      pragma Assert (Static => Same_Parser_Subtype_Visibility
        (Left.Subtype_Names.Hidden_Calls, Right.Subtype_Names.Hidden_Calls));
      pragma Assert (Static => Left.Boolean_Names.Items = Right.Boolean_Names.Items);
      pragma Assert (Static =>
        (for all Index in Boolean_Index =>
          Left.Boolean_Names.Items (Index) = Right.Boolean_Names.Items (Index)));
      pragma Assert (Static => Same_Parser_Boolean_Items
        (Left.Boolean_Names.Items, Right.Boolean_Names.Items));
   end Lemma_Parser_State_Same;

   --  A Boolean initializer is checked in the declaration's incoming state.
   --  This cursor-only interface deliberately stores neither truth nor facts.
   function Boolean_Initializer_Model
     (Text : String; State : Parser_State; Position, Mask_First, Mask_After : Literal_Position)
      return Literal_Position
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State) and then Position <= Text'Last + 1
         and then Valid_Name_State (Text, Mask_First, Mask_After),
       Post => Boolean_Initializer_Model'Result = 0
         or else Boolean_Initializer_Model'Result in Position + 1 .. Text'Last + 1;
   function Boolean_Initializer_After
     (Text : String; State : Parser_State; Position, Mask_First, Mask_After : Literal_Position)
      return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State) and then Position <= Text'Last + 1
         and then Valid_Name_State (Text, Mask_First, Mask_After),
       Post => (Runtime => Boolean_Initializer_After'Result = 0
         or else Boolean_Initializer_After'Result in Position + 1 .. Text'Last + 1,
         Static => Boolean_Initializer_After'Result = Boolean_Initializer_Model
           (Text, State, Position, Mask_First, Mask_After));

   function Array_Values_Model
     (Text : String; Source_State, Result_State : Parser_State;
      Position : Literal_Position; Length, Parsed : Array_Bindings.Element_Count;
      Component_Bounds : Scalars.Interval)
      return Parser_State
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Source_State) and then Valid_State (Text, Result_State)
         and then Position <= Text'Last + 1 and then Parsed <= Length
         and then Length <= Array_Bindings.Max_Elements - Source_State.Array_Names.Used
         and then Result_State.Array_Names.Used = Source_State.Array_Names.Used + Parsed,
       Post => Valid_State (Text, Array_Values_Model'Result)
         and then (if Array_Values_Model'Result.Position /= 0 then
           Array_Values_Model'Result.Position >= Position
           and then Array_Values_Model'Result =
             (Result_State with delta Position => Array_Values_Model'Result.Position,
               Array_Names => (Result_State.Array_Names with delta
                 Used => Source_State.Array_Names.Used + Length,
                 Values => Array_Values_Model'Result.Array_Names.Values))
           and then (for all Slot in 1 .. Result_State.Array_Names.Used =>
             Array_Values_Model'Result.Array_Names.Values (Slot) =
               Result_State.Array_Names.Values (Slot))),
       Subprogram_Variant => (Decreases => Length - Parsed);
   function Array_Values_Model
     (Text : String; Source_State, Result_State : Parser_State;
      Position : Literal_Position; Length, Parsed : Array_Bindings.Element_Count;
      Component_Bounds : Scalars.Interval)
      return Parser_State is
     (if Position = 0 then Invalid_State
      elsif Parsed = Length then (Result_State with delta Position => Position)
      else
        (declare Value : constant Scalar_Expressions.Expression_Result :=
           Scalar_Expressions.Read_Expression
             (Text, Position, Source_State.Scalar_Names,
              Arrays => Source_State.Array_Names.Names,
              Initials => Source_State.Array_Names.Values, Elaborating => True);
         begin
           (if Value.After = 0 or else Scalars.Is_Empty (Value.Bounds)
              or else Value.Bounds.Lower /= Value.Bounds.Upper
              or else Value.Bounds.Lower < Component_Bounds.Lower
              or else Value.Bounds.Upper > Component_Bounds.Upper
            then Invalid_State
            else
              (declare Next_State : constant Parser_State :=
                 Put_Array_Value (Result_State, Value.Bounds.Lower);
                       Next_Position : constant Literal_Position :=
                         (if Parsed + 1 < Length then Take_Token (Text, Value.After, Comma)
                          else Value.After);
               begin Array_Values_Model
                 (Text, Source_State, Next_State, Next_Position, Length, Parsed + 1, Component_Bounds)))));

   function Boolean_Array_Values_Model
     (Text : String; Source_State, Result_State : Parser_State;
      Position : Literal_Position; Length, Parsed : Array_Bindings.Element_Count;
      Mask_First, Mask_After : Literal_Position)
      return Parser_State
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Source_State) and then Valid_State (Text, Result_State)
         and then Position <= Text'Last + 1 and then Parsed <= Length
         and then Valid_Name_State (Text, Mask_First, Mask_After)
         and then Length <= Array_Bindings.Max_Elements - Source_State.Array_Names.Used
         and then Result_State.Array_Names.Used = Source_State.Array_Names.Used + Parsed,
       Post => Valid_State (Text, Boolean_Array_Values_Model'Result)
         and then (if Boolean_Array_Values_Model'Result.Position /= 0 then
           Boolean_Array_Values_Model'Result.Position >= Position
           and then Boolean_Array_Values_Model'Result =
             (Result_State with delta Position => Boolean_Array_Values_Model'Result.Position,
               Array_Names => (Result_State.Array_Names with delta
                 Used => Source_State.Array_Names.Used + Length,
                 Values => Boolean_Array_Values_Model'Result.Array_Names.Values))
           and then (for all Slot in 1 .. Result_State.Array_Names.Used =>
             Boolean_Array_Values_Model'Result.Array_Names.Values (Slot) =
               Result_State.Array_Names.Values (Slot))),
       Subprogram_Variant => (Decreases => Length - Parsed);
   function Boolean_Array_Values_Model
     (Text : String; Source_State, Result_State : Parser_State;
      Position : Literal_Position; Length, Parsed : Array_Bindings.Element_Count;
      Mask_First, Mask_After : Literal_Position)
      return Parser_State is
     (if Position = 0 then Invalid_State
      elsif Parsed = Length then (Result_State with delta Position => Position)
      else
        (declare Value_After : constant Literal_Position := Boolean_Initializer_Model
           (Text, Source_State, Position, Mask_First, Mask_After);
         begin
           (if Value_After = 0 then Invalid_State
            else
              (declare Next_State : constant Parser_State :=
                 Put_Array_Value (Result_State, 0);
                       Next_Position : constant Literal_Position :=
                         (if Parsed + 1 < Length then Take_Token (Text, Value_After, Comma)
                          else Value_After);
               begin Boolean_Array_Values_Model
                 (Text, Source_State, Next_State, Next_Position, Length, Parsed + 1, Mask_First, Mask_After)))));

   Integer_Type_Word : constant String := "integer";
   Boolean_Type_Word : constant String := "boolean";
   Character_Type_Word : constant String := "character";
   Validity_Call_Word : constant String := "input_is_valid";

   function Array_Declaration_Model
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Array_Declaration_Model'Result)
         and then (Array_Declaration_Model'Result.Position = 0
           or else Array_Declaration_Model'Result.Position > State.Position);
   function Array_Declaration_Model
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
     (declare First : constant Literal_Position := Skip_At (Text, State.Position);
              After : constant Literal_Position := Name_After (Text, First);
              Colon_After : constant Literal_Position := Take_Token (Text, After, Colon);
              Constant_After : constant Literal_Position := Take_Token (Text, Colon_After, Constant_Keyword);
              Named_First : constant Literal_Position := Skip_At
                (Text, (if Constant_After /= 0 then Constant_After else Colon_After));
              Named_After : constant Literal_Position := Name_After (Text, Named_First);
              Named_Id : constant Array_Bindings.Type_Count := Array_Type_At (Text, State, Named_First);
              Array_After : constant Literal_Position := Take_Token
                (Text, (if Constant_After /= 0 then Constant_After else Colon_After), Array_Keyword);
              Low : constant Scalar_Expressions.Expression_Result :=
                (if Named_Id /= 0 then (Named_After, Scalars.Singleton
                   (State.Array_Names.Names.Types.Items (Named_Id).Bounds.Lower), 1, True)
                 else Scalar_Expressions.Read_Expression
                (Text, Take_Token (Text, Array_After, Left_Parenthesis), State.Scalar_Names,
                 Arrays => State.Array_Names.Names, Initials => State.Array_Names.Values, Elaborating => True));
              High : constant Scalar_Expressions.Expression_Result :=
                (if Named_Id /= 0 then (Named_After, Scalars.Singleton
                   (State.Array_Names.Names.Types.Items (Named_Id).Bounds.Upper), 1, True)
                 else Scalar_Expressions.Read_Expression
                (Text, Take_Token (Text, Low.After, Range_Delimiter), State.Scalar_Names,
                 Arrays => State.Array_Names.Names, Initials => State.Array_Names.Values, Elaborating => True));
              Type_First : constant Literal_Position := (if Named_Id /= 0 then Named_First else
                Skip_At (Text, Take_Token (Text,
                Take_Token (Text, High.After, Right_Parenthesis), Of_Keyword)));
              Integer_Type : constant Scalar_Constraint_Result :=
                (if Named_Id /= 0 then
                   (Named_After, State.Array_Names.Names.Types.Items (Named_Id).Component_Bounds)
                 else Scalar_Type_At (Text, State, Type_First));
              Boolean_Elements : constant Boolean := Integer_Type.After = 0
                and then Take_Token (Text, Type_First, Boolean_Name) /= 0;
              Type_Mark : constant Scalar_Constraint_Result :=
                (if Boolean_Elements then (Take_Token (Text, Type_First, Boolean_Name), Scalars.Full)
                 else Integer_Type);
              Type_After : constant Literal_Position := Type_Mark.After;
              Position : constant Literal_Position := Take_Token (Text,
                Take_Token (Text, Type_After, Assignment), Left_Parenthesis);
      begin
        (if not New_Name_Allowed (Text, State, First, After, Arguments)
           or else (if Boolean_Elements then Name_Is (Text, First, After, Boolean_Type_Word)
                    else Name_Is (Text, First, After, Integer_Type_Word))
           or else (Array_After = 0 and then Named_Id = 0) or else Position = 0
           or else State.Array_Names.Names.Count = Array_Bindings.Max_Bindings
           or else (State.Array_Names.Names.Count > 0 and then
             State.Array_Names.Names.Items (State.Array_Names.Names.Count).View_Slot /= 0)
           or else Low.After = 0 or else High.After = 0 or else not Low.Static or else not High.Static
           or else Scalars.Is_Empty (Low.Bounds) or else Scalars.Is_Empty (High.Bounds)
           or else Low.Bounds.Lower /= Low.Bounds.Upper or else High.Bounds.Lower /= High.Bounds.Upper
           or else Low.Bounds.Lower > High.Bounds.Lower
           or else Scalars.Wide (High.Bounds.Lower) - Scalars.Wide (Low.Bounds.Lower)
             >= Scalars.Wide (Array_Bindings.Max_Elements - State.Array_Names.Used)
           or else Lookup_Name (Text, State.Names, Type_First, Type_After) /= 0
           or else Scalar_Expressions.Lookup (Text, State.Scalar_Names, Type_First, Type_After) /= 0
           or else Array_Bindings.Lookup (Text, State.Array_Names.Names, Type_First, Type_After) /= 0
           or else (Named_Id = 0 and then Array_Bindings.Lookup_Type (Text, State.Array_Names.Names.Types, Type_First, Type_After) /= 0)
           or else Lookup_Boolean (Text, State.Boolean_Names, Type_First, Type_After) /= 0
           or else Functions.Lookup (Text, State.Functions, Type_First, Type_After) /= 0
           or else Procedures.Lookup (Text, State.Procedures, Type_First, Type_After) /= 0
           or else Formal_Hides (Text, State, Type_First, Type_After)
           or else (State.Hiding.Integer_Hidden and then Name_Is (Text, Type_First, Type_After, Integer_Type_Word))
           or else (State.Hiding.Boolean_Hidden and then Name_Is (Text, Type_First, Type_After, Boolean_Type_Word))
           or else (State.Hiding.Character_Hidden and then Name_Is (Text, Type_First, Type_After, Character_Type_Word))
           or else (Boolean_Elements and then
             Lookup_Subtype (Text, State.Subtype_Names, Type_First, Type_After) /= 0)
         then Invalid_State
         else
           (declare Length : constant Array_Bindings.Element_Count := Array_Bindings.Element_Count
              ((Scalars.Wide (High.Bounds.Lower) - Scalars.Wide (Low.Bounds.Lower)) + 1);
                    Choice : constant Scalar_Expressions.Expression_Result :=
                      (if Length = 1 then Scalar_Expressions.Read_Expression
                         (Text, Position, State.Scalar_Names, Arrays => State.Array_Names.Names,
                          Initials => State.Array_Names.Values, Elaborating => True)
                       else Scalar_Expressions.Invalid);
                    Values_First : constant Literal_Position :=
                      (if Length = 1 then Take_Token (Text, Choice.After, Arrow) else Position);
            begin
              (if Length = 1 and then
                 (Values_First = 0 or else not Choice.Static or else Scalars.Is_Empty (Choice.Bounds)
                  or else Choice.Bounds.Lower /= Low.Bounds.Lower
                  or else Choice.Bounds.Upper /= Low.Bounds.Lower)
               then Invalid_State
               else
                 (declare Values : constant Parser_State :=
                    (if Boolean_Elements then Boolean_Array_Values_Model
                       (Text, State, State, Values_First, Length, 0, First, After)
                     else Array_Values_Model (Text, State, State, Values_First, Length, 0, Type_Mark.Bounds));
                          Following : constant Literal_Position := Take_Token
                            (Text, Take_Token (Text, Values.Position, Right_Parenthesis), Semicolon);
                  begin
                    (if Values.Position = 0 or else Following <= State.Position then Invalid_State
                     else Add_Array_Binding
                       (Text, Values, First, After, (Low.Bounds.Lower, High.Bounds.Lower),
                        State.Array_Names.Used, Length, Constant_After = 0, Following, Type_Mark.Bounds, Boolean_Elements, Named_Id)))))));

   function Array_Values_At
     (Text : String; Source_State, Result_State : Parser_State;
      Position : Literal_Position; Length, Parsed : Array_Bindings.Element_Count;
      Component_Bounds : Scalars.Interval)
      return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Source_State) and then Valid_State (Text, Result_State)
         and then Position <= Text'Last + 1 and then Parsed <= Length
         and then Length <= Array_Bindings.Max_Elements - Source_State.Array_Names.Used
         and then Result_State.Array_Names.Used = Source_State.Array_Names.Used + Parsed,
       Post => (Runtime => Valid_State (Text, Array_Values_At'Result)
         and then (if Array_Values_At'Result.Position /= 0 then
           Array_Values_At'Result.Position >= Position
           and then Array_Values_At'Result =
             (Result_State with delta Position => Array_Values_At'Result.Position,
               Array_Names => (Result_State.Array_Names with delta
                 Used => Source_State.Array_Names.Used + Length,
                 Values => Array_Values_At'Result.Array_Names.Values))
           and then (for all Slot in 1 .. Result_State.Array_Names.Used =>
             Array_Values_At'Result.Array_Names.Values (Slot) =
               Result_State.Array_Names.Values (Slot))),
         Static => Array_Values_At'Result = Array_Values_Model
           (Text, Source_State, Result_State, Position, Length, Parsed, Component_Bounds)
         and then Same_Parser_State (Array_Values_At'Result, Array_Values_Model
           (Text, Source_State, Result_State, Position, Length, Parsed, Component_Bounds)));
   function Array_Values_At
     (Text : String; Source_State, Result_State : Parser_State;
      Position : Literal_Position; Length, Parsed : Array_Bindings.Element_Count;
      Component_Bounds : Scalars.Interval)
      return Parser_State is
      Result : Parser_State := Result_State;
      Current : Literal_Position := Position;
      Parsed_Count : Array_Bindings.Element_Count := Parsed;
   begin
      if Current = 0 then return Invalid_State; end if;
      while Parsed_Count < Length loop
         pragma Loop_Invariant (Parsed_Count in Parsed .. Length);
         pragma Loop_Invariant (Length <= Array_Bindings.Max_Elements - Source_State.Array_Names.Used);
         pragma Loop_Invariant (Result.Array_Names.Used = Source_State.Array_Names.Used + Parsed_Count);
         pragma Loop_Invariant (Current in Position .. Text'Last + 1);
         pragma Loop_Invariant (Valid_State (Text, Result));
         pragma Loop_Invariant
           (Result = (Result_State with delta Array_Names =>
              (Result_State.Array_Names with delta Used => Result.Array_Names.Used,
                Values => Result.Array_Names.Values)));
         pragma Loop_Invariant
           (for all Slot in 1 .. Result_State.Array_Names.Used =>
             Result.Array_Names.Values (Slot) = Result_State.Array_Names.Values (Slot));
         pragma Loop_Invariant (Static =>
           Array_Values_Model (Text, Source_State, Result_State, Position, Length, Parsed, Component_Bounds)
             = Array_Values_Model (Text, Source_State, Result, Current, Length, Parsed_Count, Component_Bounds));
         pragma Loop_Invariant (Static => Same_Parser_State
           (Array_Values_Model (Text, Source_State, Result_State, Position, Length, Parsed, Component_Bounds),
            Array_Values_Model (Text, Source_State, Result, Current, Length, Parsed_Count, Component_Bounds)));
         pragma Loop_Variant (Increases => Parsed_Count);
         declare
            Before : constant Parser_State := Result with Ghost => Static;
            Value : constant Scalar_Expressions.Expression_Result :=
              Scalar_Expressions.Read_Expression
                (Text, Current, Source_State.Scalar_Names, Arrays => Source_State.Array_Names.Names,
                 Initials => Source_State.Array_Names.Values, Elaborating => True);
            Tail : constant Parser_State :=
              Array_Values_Model (Text, Source_State, Before, Current, Length, Parsed_Count, Component_Bounds)
                with Ghost => Static;
         begin
            pragma Assert (Static => Same_Parser_State (Result, Before));
            if Value.After = 0 or else Scalars.Is_Empty (Value.Bounds)
              or else Value.Bounds.Lower /= Value.Bounds.Upper
              or else Value.Bounds.Lower < Component_Bounds.Lower
              or else Value.Bounds.Upper > Component_Bounds.Upper
            then return Invalid_State; end if;
            declare
               Next_State : constant Parser_State :=
                 Put_Array_Value (Before, Value.Bounds.Lower) with Ghost => Static;
               Next_Position : constant Literal_Position :=
                 (if Parsed_Count + 1 < Length then Take_Token (Text, Value.After, Comma)
                  else Value.After) with Ghost => Static;
               Next_Parsed : constant Array_Bindings.Element_Count := Parsed_Count + 1
                 with Ghost => Static;
            begin
               pragma Assert (Static => Tail =
                 Array_Values_Model (Text, Source_State, Next_State, Next_Position, Length, Next_Parsed, Component_Bounds));
               Parsed_Count := Parsed_Count + 1;
               Result := Put_Array_Value (Result, Value.Bounds.Lower);
               Current := Value.After;
               if Parsed_Count < Length then
                  Current := Take_Token (Text, Current, Comma);
                  if Current = 0 then return Invalid_State; end if;
               end if;
               pragma Assert (Static => Result = Next_State
                 and then Current = Next_Position and then Parsed_Count = Next_Parsed);
               pragma Assert (Static => Same_Parser_State (Result, Next_State));
               pragma Assert (Static => Tail =
                 Array_Values_Model (Text, Source_State, Result, Current, Length, Parsed_Count, Component_Bounds));
            end;
         end;
      end loop;
      declare
         Completed : constant Parser_State :=
           Array_Values_Model (Text, Source_State, Result, Current, Length, Parsed_Count, Component_Bounds)
             with Ghost => Static;
      begin
         pragma Assert (Static => Completed = (Result with delta Position => Current));
      end;
      return (Result with delta Position => Current);
   end Array_Values_At;

   function Boolean_Array_Values_At
     (Text : String; Source_State, Result_State : Parser_State;
      Position : Literal_Position; Length, Parsed : Array_Bindings.Element_Count;
      Mask_First, Mask_After : Literal_Position)
      return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Source_State) and then Valid_State (Text, Result_State)
         and then Position <= Text'Last + 1 and then Parsed <= Length
         and then Valid_Name_State (Text, Mask_First, Mask_After)
         and then Length <= Array_Bindings.Max_Elements - Source_State.Array_Names.Used
         and then Result_State.Array_Names.Used = Source_State.Array_Names.Used + Parsed,
       Post => (Runtime => Valid_State (Text, Boolean_Array_Values_At'Result)
         and then (if Boolean_Array_Values_At'Result.Position /= 0 then
           Boolean_Array_Values_At'Result.Position >= Position
           and then Boolean_Array_Values_At'Result =
             (Result_State with delta Position => Boolean_Array_Values_At'Result.Position,
               Array_Names => (Result_State.Array_Names with delta
                 Used => Source_State.Array_Names.Used + Length,
                 Values => Boolean_Array_Values_At'Result.Array_Names.Values))
           and then (for all Slot in 1 .. Result_State.Array_Names.Used =>
             Boolean_Array_Values_At'Result.Array_Names.Values (Slot) =
               Result_State.Array_Names.Values (Slot))),
         Static => Boolean_Array_Values_At'Result = Boolean_Array_Values_Model
           (Text, Source_State, Result_State, Position, Length, Parsed, Mask_First, Mask_After)
         and then Same_Parser_State (Boolean_Array_Values_At'Result, Boolean_Array_Values_Model
           (Text, Source_State, Result_State, Position, Length, Parsed, Mask_First, Mask_After)));
   function Boolean_Array_Values_At
     (Text : String; Source_State, Result_State : Parser_State;
      Position : Literal_Position; Length, Parsed : Array_Bindings.Element_Count;
      Mask_First, Mask_After : Literal_Position)
      return Parser_State is
      Result : Parser_State := Result_State;
      Current : Literal_Position := Position;
      Parsed_Count : Array_Bindings.Element_Count := Parsed;
   begin
      if Current = 0 then
         Lemma_Parser_State_Equality
           (Invalid_State, Boolean_Array_Values_Model
              (Text, Source_State, Result_State, Position, Length, Parsed,
               Mask_First, Mask_After));
         return Invalid_State;
      end if;
      while Parsed_Count < Length loop
         pragma Loop_Invariant (Parsed_Count in Parsed .. Length);
         pragma Loop_Invariant (Length <= Array_Bindings.Max_Elements - Source_State.Array_Names.Used);
         pragma Loop_Invariant (Result.Array_Names.Used = Source_State.Array_Names.Used + Parsed_Count);
         pragma Loop_Invariant (Current in Position .. Text'Last + 1);
         pragma Loop_Invariant (Valid_State (Text, Result));
         pragma Loop_Invariant
           (Result = (Result_State with delta Array_Names =>
              (Result_State.Array_Names with delta Used => Result.Array_Names.Used,
                Values => Result.Array_Names.Values)));
         pragma Loop_Invariant
           (for all Slot in 1 .. Result_State.Array_Names.Used =>
             Result.Array_Names.Values (Slot) = Result_State.Array_Names.Values (Slot));
         pragma Loop_Invariant (Static =>
           Boolean_Array_Values_Model (Text, Source_State, Result_State, Position, Length, Parsed, Mask_First, Mask_After)
             = Boolean_Array_Values_Model (Text, Source_State, Result, Current, Length, Parsed_Count, Mask_First, Mask_After));
         pragma Loop_Invariant (Static => Same_Parser_State
           (Boolean_Array_Values_Model (Text, Source_State, Result_State, Position, Length, Parsed, Mask_First, Mask_After),
            Boolean_Array_Values_Model (Text, Source_State, Result, Current, Length, Parsed_Count, Mask_First, Mask_After)));
         pragma Loop_Variant (Increases => Parsed_Count);
         declare
            Before : constant Parser_State := Result with Ghost => Static;
            Value_After : constant Literal_Position := Boolean_Initializer_After
              (Text, Source_State, Current, Mask_First, Mask_After);
            Tail : constant Parser_State :=
              Boolean_Array_Values_Model (Text, Source_State, Before, Current, Length, Parsed_Count, Mask_First, Mask_After)
                with Ghost => Static;
         begin
            pragma Assert (Static => Same_Parser_State (Result, Before));
            if Value_After = 0 then
               Lemma_Parser_State_Equality
                 (Invalid_State, Boolean_Array_Values_Model
                    (Text, Source_State, Result_State, Position, Length, Parsed,
                     Mask_First, Mask_After));
               return Invalid_State;
            end if;
            declare
               Next_State : constant Parser_State :=
                 Put_Array_Value (Before, 0) with Ghost => Static;
               Next_Position : constant Literal_Position :=
                 (if Parsed_Count + 1 < Length then Take_Token (Text, Value_After, Comma)
                  else Value_After) with Ghost => Static;
               Next_Parsed : constant Array_Bindings.Element_Count := Parsed_Count + 1
                 with Ghost => Static;
            begin
               pragma Assert (Static => Tail =
                 Boolean_Array_Values_Model (Text, Source_State, Next_State, Next_Position, Length, Next_Parsed, Mask_First, Mask_After));
               Parsed_Count := Parsed_Count + 1;
               Result := Put_Array_Value (Result, 0);
               Current := Value_After;
               if Parsed_Count < Length then
                  Current := Take_Token (Text, Current, Comma);
                  if Current = 0 then
                     Lemma_Parser_State_Equality
                       (Invalid_State, Boolean_Array_Values_Model
                          (Text, Source_State, Result_State, Position, Length, Parsed,
                           Mask_First, Mask_After));
                     return Invalid_State;
                  end if;
               end if;
               pragma Assert (Static => Result = Next_State
                 and then Current = Next_Position and then Parsed_Count = Next_Parsed);
               pragma Assert (Static => Same_Parser_State (Result, Next_State));
               pragma Assert (Static => Tail =
                 Boolean_Array_Values_Model (Text, Source_State, Result, Current, Length, Parsed_Count, Mask_First, Mask_After));
            end;
         end;
      end loop;
      declare
         Completed : constant Parser_State :=
           Boolean_Array_Values_Model (Text, Source_State, Result, Current, Length, Parsed_Count, Mask_First, Mask_After)
             with Ghost => Static;
      begin
         return Final_State : constant Parser_State :=
           (Result with delta Position => Current)
         do
            pragma Assert (Static => Completed = Final_State);
            pragma Assert (Static => Valid_State (Text, Final_State));
            Lemma_Parser_State_Equality
              (Final_State,
               Boolean_Array_Values_Model
                 (Text, Source_State, Result_State, Position, Length, Parsed,
                  Mask_First, Mask_After));
         end return;
      end;
   end Boolean_Array_Values_At;

   function Array_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => (Runtime => Valid_State (Text, Array_Declaration_At'Result)
         and then (Array_Declaration_At'Result.Position = 0
           or else Array_Declaration_At'Result.Position > State.Position),
         Static => Array_Declaration_At'Result = Array_Declaration_Model (Text, State, Arguments));
   function Array_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
      Result : constant Parser_State :=
     (declare First : constant Literal_Position := Skip_At (Text, State.Position);
              After : constant Literal_Position := Name_After (Text, First);
              Colon_After : constant Literal_Position := Take_Token (Text, After, Colon);
              Constant_After : constant Literal_Position := Take_Token (Text, Colon_After, Constant_Keyword);
              Named_First : constant Literal_Position := Skip_At
                (Text, (if Constant_After /= 0 then Constant_After else Colon_After));
              Named_After : constant Literal_Position := Name_After (Text, Named_First);
              Named_Id : constant Array_Bindings.Type_Count := Array_Type_At (Text, State, Named_First);
              Array_After : constant Literal_Position := Take_Token
                (Text, (if Constant_After /= 0 then Constant_After else Colon_After), Array_Keyword);
              Low : constant Scalar_Expressions.Expression_Result :=
                (if Named_Id /= 0 then (Named_After, Scalars.Singleton
                   (State.Array_Names.Names.Types.Items (Named_Id).Bounds.Lower), 1, True)
                 else Scalar_Expressions.Read_Expression
                (Text, Take_Token (Text, Array_After, Left_Parenthesis), State.Scalar_Names,
                 Arrays => State.Array_Names.Names, Initials => State.Array_Names.Values, Elaborating => True));
              High : constant Scalar_Expressions.Expression_Result :=
                (if Named_Id /= 0 then (Named_After, Scalars.Singleton
                   (State.Array_Names.Names.Types.Items (Named_Id).Bounds.Upper), 1, True)
                 else Scalar_Expressions.Read_Expression
                (Text, Take_Token (Text, Low.After, Range_Delimiter), State.Scalar_Names,
                 Arrays => State.Array_Names.Names, Initials => State.Array_Names.Values, Elaborating => True));
              Type_First : constant Literal_Position := (if Named_Id /= 0 then Named_First else
                Skip_At (Text, Take_Token (Text,
                Take_Token (Text, High.After, Right_Parenthesis), Of_Keyword)));
              Integer_Type : constant Scalar_Constraint_Result :=
                (if Named_Id /= 0 then
                   (Named_After, State.Array_Names.Names.Types.Items (Named_Id).Component_Bounds)
                 else Scalar_Type_At (Text, State, Type_First));
              Boolean_Elements : constant Boolean := Integer_Type.After = 0
                and then Take_Token (Text, Type_First, Boolean_Name) /= 0;
              Type_Mark : constant Scalar_Constraint_Result :=
                (if Boolean_Elements then (Take_Token (Text, Type_First, Boolean_Name), Scalars.Full)
                 else Integer_Type);
              Type_After : constant Literal_Position := Type_Mark.After;
              Position : constant Literal_Position := Take_Token (Text,
                Take_Token (Text, Type_After, Assignment), Left_Parenthesis);
      begin
        (if not New_Name_Allowed (Text, State, First, After, Arguments)
           or else (if Boolean_Elements then Name_Is (Text, First, After, Boolean_Type_Word)
                    else Name_Is (Text, First, After, Integer_Type_Word))
           or else (Array_After = 0 and then Named_Id = 0) or else Position = 0
           or else State.Array_Names.Names.Count = Array_Bindings.Max_Bindings
           or else (State.Array_Names.Names.Count > 0 and then
             State.Array_Names.Names.Items (State.Array_Names.Names.Count).View_Slot /= 0)
           or else Low.After = 0 or else High.After = 0 or else not Low.Static or else not High.Static
           or else Scalars.Is_Empty (Low.Bounds) or else Scalars.Is_Empty (High.Bounds)
           or else Low.Bounds.Lower /= Low.Bounds.Upper or else High.Bounds.Lower /= High.Bounds.Upper
           or else Low.Bounds.Lower > High.Bounds.Lower
           or else Scalars.Wide (High.Bounds.Lower) - Scalars.Wide (Low.Bounds.Lower)
             >= Scalars.Wide (Array_Bindings.Max_Elements - State.Array_Names.Used)
           or else Lookup_Name (Text, State.Names, Type_First, Type_After) /= 0
           or else Scalar_Expressions.Lookup (Text, State.Scalar_Names, Type_First, Type_After) /= 0
           or else Array_Bindings.Lookup (Text, State.Array_Names.Names, Type_First, Type_After) /= 0
           or else (Named_Id = 0 and then Array_Bindings.Lookup_Type (Text, State.Array_Names.Names.Types, Type_First, Type_After) /= 0)
           or else Lookup_Boolean (Text, State.Boolean_Names, Type_First, Type_After) /= 0
           or else Functions.Lookup (Text, State.Functions, Type_First, Type_After) /= 0
           or else Procedures.Lookup (Text, State.Procedures, Type_First, Type_After) /= 0
           or else Formal_Hides (Text, State, Type_First, Type_After)
           or else (State.Hiding.Integer_Hidden and then Name_Is (Text, Type_First, Type_After, Integer_Type_Word))
           or else (State.Hiding.Boolean_Hidden and then Name_Is (Text, Type_First, Type_After, Boolean_Type_Word))
           or else (State.Hiding.Character_Hidden and then Name_Is (Text, Type_First, Type_After, Character_Type_Word))
           or else (Boolean_Elements and then
             Lookup_Subtype (Text, State.Subtype_Names, Type_First, Type_After) /= 0)
         then Invalid_State
         else
           (declare Length : constant Array_Bindings.Element_Count := Array_Bindings.Element_Count
              ((Scalars.Wide (High.Bounds.Lower) - Scalars.Wide (Low.Bounds.Lower)) + 1);
                    Choice : constant Scalar_Expressions.Expression_Result :=
                      (if Length = 1 then Scalar_Expressions.Read_Expression
                         (Text, Position, State.Scalar_Names, Arrays => State.Array_Names.Names,
                          Initials => State.Array_Names.Values, Elaborating => True)
                       else Scalar_Expressions.Invalid);
                    Values_First : constant Literal_Position :=
                      (if Length = 1 then Take_Token (Text, Choice.After, Arrow) else Position);
            begin
              (if Length = 1 and then
                 (Values_First = 0 or else not Choice.Static or else Scalars.Is_Empty (Choice.Bounds)
                  or else Choice.Bounds.Lower /= Low.Bounds.Lower
                  or else Choice.Bounds.Upper /= Low.Bounds.Lower)
               then Invalid_State
               else
                 (declare Values : constant Parser_State :=
                    (if Boolean_Elements then Boolean_Array_Values_At
                       (Text, State, State, Values_First, Length, 0, First, After)
                     else Array_Values_At (Text, State, State, Values_First, Length, 0, Type_Mark.Bounds));
                          Following : constant Literal_Position := Take_Token
                            (Text, Take_Token (Text, Values.Position, Right_Parenthesis), Semicolon);
                  begin
                    (if Values.Position = 0 or else Following <= State.Position then Invalid_State
                     else Add_Array_Binding
                       (Text, Values, First, After, (Low.Bounds.Lower, High.Bounds.Lower),
                        State.Array_Names.Used, Length, Constant_After = 0, Following, Type_Mark.Bounds, Boolean_Elements, Named_Id)))))));
      Model_State : constant Parser_State :=
        Array_Declaration_Model (Text, State, Arguments) with Ghost => Static;
   begin
      pragma Assert (Static => Same_Parser_State (Result, Model_State));
      Lemma_Parser_State_Equality (Result, Model_State);
      return Result;
   end Array_Declaration_At;

   function Boolean_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Boolean_Declaration_At'Result)
         and then (Boolean_Declaration_At'Result.Position = 0
           or else (Boolean_Declaration_At'Result.Position > State.Position
             and then Boolean_Declaration_At'Result.Functions = State.Functions
             and then Boolean_Declaration_At'Result.Procedures = State.Procedures
             and then Boolean_Declaration_At'Result.First_Procedure_Parameter = State.First_Procedure_Parameter
             and then Boolean_Declaration_At'Result.First_Parameter = State.First_Parameter
             and then Boolean_Declaration_At'Result.Pure = State.Pure));

   function Function_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Function_Declaration_At'Result)
         and then (Function_Declaration_At'Result.Position = 0
           or else Function_Declaration_At'Result.Position > State.Position);

   function Procedure_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Procedure_Declaration_At'Result)
         and then (Procedure_Declaration_At'Result.Position = 0
           or else Procedure_Declaration_At'Result.Position > State.Position);

   function Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Declaration_At'Result)
         and then (Declaration_At'Result.Position = 0
           or else Declaration_At'Result.Position > State.Position);
   function Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
     (declare Function_State : constant Parser_State := Function_Declaration_At (Text, State, Arguments);
              Procedure_State : constant Parser_State := Procedure_Declaration_At (Text, State, Arguments);
              Array_Type_State : constant Parser_State := Array_Type_Declaration_At (Text, State, Arguments);
              Subtype_State : constant Parser_State := Subtype_Declaration_At (Text, State, Arguments);
              Scalar_State : constant Parser_State := Scalar_Declaration_At (Text, State, Arguments);
              Array_State : constant Parser_State := Array_Declaration_At (Text, State, Arguments);
              Boolean_State : constant Parser_State := Boolean_Declaration_At (Text, State, Arguments);
              Character_State : constant Parser_State := Character_Declaration_At (Text, State, Arguments);
      begin (if Function_State.Position /= 0 then Function_State
             elsif Procedure_State.Position /= 0 then Procedure_State
             elsif Array_Type_State.Position /= 0 then Array_Type_State
             elsif Subtype_State.Position /= 0 then Subtype_State
             elsif Scalar_State.Position /= 0 then Scalar_State
             elsif Array_State.Position /= 0 then Array_State
             elsif Boolean_State.Position /= 0 then Boolean_State
             elsif Character_State.Position /= 0 then Character_State
             else String_Declaration_At (Text, State, Arguments)));

   function Argument_At (Text : String; State : Parser_State) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Argument_At'Result);
   function Argument_At (Text : String; State : Parser_State) return Parser_State is
     (declare First : constant Literal_Position := Skip_At (Text, State.Position);
              After : constant Literal_Position := Name_After (Text, First);
              Start : constant Literal_Position := Take_Token (Text,
                Take_Token (Text, Take_Token (Text, Take_Token (Text, After, Colon),
                  Constant_Keyword), String_Name), Assignment);
              Hidden : constant Boolean := First /= 0 and then After > First
                and then Take_Token (Text, First, First_Or_Default_Name) = After;
              Prefix : constant Literal_Position := Names.Association_After (Text,
                Take_Token (Text, Names.Operation_After
                  (Text, Start, Names.Argument_Call, Hidden, State.Context_First,
                   State.Package_First, State.Package_After), Left_Parenthesis), True);
              Default_Value : constant Value_Result := Literal_At (Text, Skip_At (Text, Prefix));
              Following : constant Literal_Position := Take_Token (Text,
                Take_Token (Text, Default_Value.After, Right_Parenthesis), Semicolon);
      begin
        (if not New_Name_Allowed (Text, State, First, After, True)
           or else Following = 0 or else State.Names.Count /= 0
         then Invalid_State
         else (Add_Binding (State, First, After,
           (After => Following, Value_First => 0, Minimum_Length => 0, Static_Length => 0,
            Dynamic_Seen => True, Nonliteral_Seen => True, Empty_Value => False, Reference => 0,
            Operands => 1, First_Index => Scalars.Singleton (1), Last_Index => (0, Max_Source_Length)), False, Following)
           with delta Dynamic_First => First, Dynamic_After => After)));

   function Declarations_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Declarations_At'Result),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - State.Position);
   function Declarations_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
     (if State.Position = 0 then Invalid_State
      elsif Take_Token (Text, State.Position, Begin_Keyword) /= 0 then State
      elsif Declaration_At (Text, State, Arguments).Position = 0 then Invalid_State
      else Declarations_At (Text, Declaration_At (Text, State, Arguments), Arguments));

   function Read_Declarations
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => (Static => Valid_State (Text, Read_Declarations'Result)
         and then ( Read_Declarations'Result = Declarations_At (Text, State, Arguments)));
   function Read_Declarations
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
      Result : Parser_State := State;
   begin
      while Result.Position /= 0 loop
         pragma Loop_Invariant (Valid_State (Text, Result));
         pragma Loop_Invariant (Static =>
           Declarations_At (Text, State, Arguments) = Declarations_At (Text, Result, Arguments));
         pragma Loop_Variant (Increases => Result.Position);
         if Take_Token (Text, Result.Position, Begin_Keyword) /= 0 then return Result; end if;
         Result := Declaration_At (Text, Result, Arguments);
      end loop;
      return Invalid_State;
   end Read_Declarations;

   function Target_At
     (Text : String; State : Parser_State; Same_Target : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Target_At'Result);
   function Target_At
     (Text : String; State : Parser_State; Same_Target : Boolean) return Parser_State is
     (declare First : constant Literal_Position := Skip_At (Text, State.Position);
              After : constant Literal_Position := Name_After (Text, First);
              Index : constant Binding_Count := Lookup_Name (Text, State.Names, First, After);
      begin
        (if Index = 0
           or else Scalar_Expressions.Lookup (Text, State.Scalar_Names, First, After) /= 0
           or else not State.Names.Items (Index).Mutable
           or else (Same_Target and then Index /= State.Target)
         then Invalid_State
         else (State with delta Position => After, Target => Index)));

   function Dynamic_At (Text : String; State : Parser_State) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Dynamic_At'Result);
   function Dynamic_At (Text : String; State : Parser_State) return Parser_State is
     (declare First : constant Literal_Position := Skip_At (Text, State.Position);
              After : constant Literal_Position := Name_After (Text, First);
      begin
        (if First = 0 or else After = 0 or else State.Dynamic_First = 0
           or else not Equal_Name (Text, State.Dynamic_First, State.Dynamic_After, First, After)
         then Invalid_State else (State with delta Position => After)));

   function Assignment_At (Text : String; State : Parser_State) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Assignment_At'Result);
   function Assignment_At (Text : String; State : Parser_State) return Parser_State is
     (declare Value : constant Expression_Result := Expression_At (Text, State.Position, State.Names, State.Scalar_Names, Arrays => State.Array_Names.Names,
           Initials => State.Array_Names.Values, Elaborating => True, Context_First => State.Context_First);
      begin
        (if not Fits (Value, State.Capacity) or else State.Target = 0
           or else State.Names.Items (State.Target).Is_Character
           or else Value.Empty_Value or else Value.Minimum_Length /= Value.Static_Length
           or else Value.Static_Length /= State.Names.Items (State.Target).Static_Length
           or else Value.Dynamic_Count /=
             (if State.Names.Items (State.Target).Dynamic then 1 else 0)
         then Invalid_State else (State with delta Position => Value.After)));

   function Output_At (Text : String; State : Parser_State) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Output_At'Result);
   function Output_At (Text : String; State : Parser_State) return Parser_State is
     (declare Value : constant Expression_Result := Expression_At (Text, State.Position, State.Names, State.Scalar_Names, Arrays => State.Array_Names.Names,
           Initials => State.Array_Names.Values, Elaborating => True, Context_First => State.Context_First);
      begin
        (if not Fits (Value, State.Capacity)
         then Invalid_State else (State with delta Position => Value.After)));

   function Comparison_At (Text : String; State : Parser_State) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Comparison_At'Result);
   function Comparison_At (Text : String; State : Parser_State) return Parser_State is
     (declare Left : constant Expression_Result := Expression_At (Text, State.Position, State.Names, State.Scalar_Names, Arrays => State.Array_Names.Names,
           Initials => State.Array_Names.Values, Elaborating => True, Context_First => State.Context_First);
              Right : constant Expression_Result := Expression_At
                (Text, Take_Token (Text, Left.After, Equal), State.Names, State.Scalar_Names, Arrays => State.Array_Names.Names,
           Initials => State.Array_Names.Values, Elaborating => True, Context_First => State.Context_First);
      begin
        (if not Fits (Left, State.Capacity) or else not Fits (Right, State.Capacity)
           or else not (Left.Named_Seen or else Right.Named_Seen)
         then Invalid_State else (State with delta Position => Right.After)));

   function Capacity_At (Text : String; State : Parser_State) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => (Static => Valid_State (Text, Capacity_At'Result)
         and then Capacity_At'Result =
           (if State.Position = 0 then Invalid_State
            elsif Decimal_At (Text, Trivia_End (Text, State.Position)).After = 0
            then Invalid_State
            else (State with delta
              Position => Decimal_At (Text, Trivia_End (Text, State.Position)).After,
              Capacity => Decimal_At (Text, Trivia_End (Text, State.Position)).Value)));
   function Capacity_At (Text : String; State : Parser_State) return Parser_State is
      Position : constant Literal_Position := Skip_At (Text, State.Position);
      Value : Decimal_Result;
   begin
      if Position = 0 then return Invalid_State; end if;
      Value := Read_Capacity (Text, Position);
      if Value.After = 0 then return Invalid_State; end if;
      return (State with delta Position => Value.After, Capacity => Value.Value);
   end Capacity_At;

   function Step
     (Text : String; Form : Form_Kind; Token : Token_Kind; State : Parser_State)
      return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Step'Result);
   function Step
     (Text : String; Form : Form_Kind; Token : Token_Kind; State : Parser_State)
      return Parser_State is
     (if State.Position = 0 then Invalid_State
      elsif Token = Context_Clauses then
        (State with delta Position => Names.Context_After (Text, Is_Argument_Form (Form)))
      elsif Token = Argument_Declaration then Argument_At (Text, State)
      elsif Token = Declarations then Read_Declarations (Text, State, Is_Argument_Form (Form))
      elsif Token = Assignment_Target then Target_At (Text, State, False)
      elsif Token = Target_Reference then Target_At (Text, State, True)
      elsif Token = Dynamic_Reference then Dynamic_At (Text, State)
      elsif Token = Assignment_Value then Assignment_At (Text, State)
      elsif Token = Output_Expression then Output_At (Text, State)
      elsif Token = Comparison_Expression then Comparison_At (Text, State)
      elsif Token = Capacity_Literal then Capacity_At (Text, State)
      elsif Token = String_Literal then
        (State with delta Position => Literal_At (Text, Skip_At (Text, State.Position)).After)
      else (State with delta Position => Take_Token (Text, State.Position, Token)));

   --  A scan records syntactic effects alongside unchanged binding shapes.
   --  Flags accumulate across both arms; they select report policy, not runtime
   --  execution. Sequential statement tails are iterative; nested control flow
   --  retains only its active scalar identities and shares immutable metadata.
   type Scan_Result is record
      State : Parser_State;
      Assigned, Output : Boolean;
   end record;
   Initial_Scan : constant Scan_Result :=
     (State => Initial_State, Assigned => False, Output => False);
   Invalid_Scan : constant Scan_Result :=
     (State => Invalid_State, Assigned => False, Output => False);

   --  Metadata stays immutable; only active scalar intervals travel with paths.
   type Body_Context is record
      Context_First : Cursor := 1;
      Package_First, Package_After : Literal_Position := 0;
      Names : Binding_Environment;
      Scalar_Names : Scalar_Expressions.Environment;
      Array_Names : Array_Bindings.Metadata;
      Subtype_Hiding : Subtype_Visibility;
      Boolean_Names : Boolean_Environment;
      True_Hidden, False_Hidden, Elaborating, Pure, Integer_Hidden : Boolean;
      Mask_First, Mask_After : Literal_Position;
      Declaration_Count : Scalar_Expressions.Binding_Count;
      Dynamic_First, Dynamic_After : Literal_Position;
   end record;
   package Paths renames Silver_Path_Facts;
   use type Paths.Context;
   use type Paths.Comparison;
   use type Scalars.Interval;
   use type Scalar_Expressions.Binding;
   use type Scalar_Expressions.Expression_Result;
   type Interval_Vector is array (Positive range <>) of Scalars.Interval;
   type Scalar_Flow (Count : Scalar_Expressions.Binding_Count) is record
      Path : Paths.Context;
      Values : Interval_Vector (1 .. Count);
   end record;
   type Body_Scan (Count : Scalar_Expressions.Binding_Count) is record
      Facts : Scalar_Flow (Count);
      Position : Literal_Position;
      Target : Binding_Count;
      Capacity : Capacity_Value;
      Assigned, Output : Boolean;
   end record;
   type Body_Stop is (End_Only, Else_Only, Arm_Boundary, Return_Only);

   function Context_Of (Scan : Scan_Result) return Body_Context is
     (Context_First => Scan.State.Context_First,
      Package_First => Scan.State.Package_First, Package_After => Scan.State.Package_After,
      Names => Scan.State.Names,
      Scalar_Names => Scalar_Expressions.Body_Environment (Scan.State.Scalar_Names),
      Array_Names => Scan.State.Array_Names.Names,
      Subtype_Hiding => Scan.State.Subtype_Names.Hidden_Calls,
      Boolean_Names => Scan.State.Boolean_Names,
      True_Hidden => Scan.State.Subtype_Names.True_Hidden or Scan.State.Hiding.True_Hidden,
      False_Hidden => Scan.State.Subtype_Names.False_Hidden or Scan.State.Hiding.False_Hidden,
      Pure => Scan.State.Pure, Integer_Hidden => Scan.State.Hiding.Integer_Hidden,
      Elaborating => False, Mask_First => 0, Mask_After => 0,
      Declaration_Count => Scan.State.Scalar_Names.Count,
      Dynamic_First => Scan.State.Dynamic_First,
      Dynamic_After => Scan.State.Dynamic_After);
   function Initial_Flow (Context : Body_Context) return Scalar_Flow
     with Global => null,
       Post => Initial_Flow'Result.Count = Context.Scalar_Names.Count
         and then Initial_Flow'Result.Path = Paths.Initial (Context.Dynamic_First /= 0)
         and then (for all Index in Initial_Flow'Result.Values'Range =>
           Initial_Flow'Result.Values (Index) = Context.Scalar_Names.Items (Index).Bounds);
   function Initial_Flow (Context : Body_Context) return Scalar_Flow is
      Result : Scalar_Flow (Context.Scalar_Names.Count);
   begin
      Result.Path := Paths.Initial (Context.Dynamic_First /= 0);
      Result.Values := (others => Scalars.Empty);
      for Index in Result.Values'Range loop
         pragma Loop_Invariant
           (Static => (for all Done in Result.Values'First .. Index - 1 =>
             Result.Values (Done) = Context.Scalar_Names.Items (Done).Bounds));
         Result.Values (Index) := Context.Scalar_Names.Items (Index).Bounds;
      end loop;
      return Result;
   end Initial_Flow;
   function Body_Of_Model (Scan : Scan_Result) return Body_Scan is
     (Count => Scan.State.Scalar_Names.Count,
      Facts => Initial_Flow (Context_Of (Scan)),
      Position => Scan.State.Position, Target => Scan.State.Target,
      Capacity => Scan.State.Capacity, Assigned => Scan.Assigned, Output => Scan.Output)
     with Ghost => Static;
   function Body_Of (Scan : Scan_Result) return Body_Scan
     with Global => null,
       Post => (Static => Body_Of'Result = Body_Of_Model (Scan)
         and then Body_Of'Result.Facts.Count = Context_Of (Scan).Scalar_Names.Count
         and then (for all Index in Body_Of'Result.Facts.Values'Range =>
           Body_Of'Result.Facts.Values (Index) =
             Context_Of (Scan).Scalar_Names.Items (Index).Bounds));
   function Body_Of (Scan : Scan_Result) return Body_Scan is
   begin
      return Result : Body_Scan (Scan.State.Scalar_Names.Count) do
         Result.Facts := Initial_Flow (Context_Of (Scan));
         Result.Position := Scan.State.Position;
         Result.Target := Scan.State.Target;
         Result.Capacity := Scan.State.Capacity;
         Result.Assigned := Scan.Assigned;
         Result.Output := Scan.Output;
      end return;
   end Body_Of;
   function Invalid_Body_Model (Scan : Body_Scan) return Body_Scan is
     (Count => Scan.Count,
      Facts => (Count => Scan.Count, Path => Paths.Empty_Context, Values => Scan.Facts.Values),
      Position => 0, Target => 0, Capacity => 0, Assigned => False, Output => False)
     with Ghost => Static;
   function Invalid_Body (Scan : Body_Scan) return Body_Scan
     with Global => null,
       Post => (Static =>
         Invalid_Body'Result = Invalid_Body_Model (Scan)
         and then Invalid_Body'Result.Count = Scan.Count
         and then (for all Index in Scan.Facts.Values'Range =>
           Invalid_Body'Result.Facts.Values (Index).Lower =
             Scan.Facts.Values (Index).Lower
           and then Invalid_Body'Result.Facts.Values (Index).Upper =
             Scan.Facts.Values (Index).Upper));
   function Invalid_Body (Scan : Body_Scan) return Body_Scan is
   begin
      return Result : Body_Scan (Scan.Count) do
         Result.Facts := Scan.Facts;
         Result.Facts.Path := Paths.Empty_Context;
         Result.Position := 0;
         Result.Target := 0;
         Result.Capacity := 0;
         Result.Assigned := False;
         Result.Output := False;
      end return;
   end Invalid_Body;
   function Expand_Body
     (Context : Body_Context; Scan : Body_Scan; Original : Parser_State) return Scan_Result is
     (State => (Original with delta Position => Scan.Position, Names => Context.Names,
       Scalar_Names => Context.Scalar_Names, Boolean_Names => Context.Boolean_Names,
       Dynamic_First => Context.Dynamic_First, Dynamic_After => Context.Dynamic_After,
       Target => Scan.Target, Capacity => Scan.Capacity),
      Assigned => Scan.Assigned, Output => Scan.Output);
   function Valid_Context (Text : String; Context : Body_Context) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_Context (Text : String; Context : Body_Context) return Boolean is
     (Context.Context_First <= Text'Last + 1
      and then Valid_Name_State (Text, Context.Package_First, Context.Package_After)
      and then Valid_Names (Text, Context.Names)
      and then Scalar_Expressions.Valid_Environment (Text, Context.Scalar_Names)
      and then Array_Bindings.Valid_Metadata (Text, Context.Array_Names)
      and then Valid_Booleans (Text, Context.Boolean_Names)
      and then Valid_Name_State (Text, Context.Mask_First, Context.Mask_After)
      and then Valid_Declaration_Values (Context.Scalar_Names, Context.Declaration_Count)
      and then Valid_Mutable_Bounds (Context.Scalar_Names)
      and then (for all Index in 1 .. Context.Scalar_Names.Count =>
        (if Context.Scalar_Names.Items (Index).Mutable and then not Context.Elaborating then
           Context.Scalar_Names.Items (Index).Bounds = Context.Scalar_Names.Items (Index).Declared_Bounds))
      and then Valid_Name_State (Text, Context.Dynamic_First, Context.Dynamic_After));
   function Included (Value, Bounds : Scalars.Interval) return Boolean is
     (Scalars.Is_Empty (Value)
      or else (not Scalars.Is_Empty (Bounds) and then Value.Lower >= Bounds.Lower
        and then Value.Upper <= Bounds.Upper));
   function Valid_Flow (Context : Body_Context; Facts : Scalar_Flow) return Boolean is
     (Facts.Count = Context.Scalar_Names.Count
      and then (for all Index in Facts.Values'Range =>
        (if Context.Scalar_Names.Items (Index).Mutable then
           not Scalars.Is_Empty (Facts.Values (Index))
           and then Included (Facts.Values (Index), Context.Scalar_Names.Items (Index).Declared_Bounds)
         elsif Index > Context.Declaration_Count then
           Included (Facts.Values (Index), Context.Scalar_Names.Items (Index).Bounds)
         else Facts.Values (Index) = Context.Scalar_Names.Items (Index).Bounds)));
   function Valid_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Boolean is
     (Scan.Position <= Text'Last + 1 and then Scan.Target <= Context.Names.Count
      and then Valid_Flow (Context, Scan.Facts));

   function Joined (Left, Right : Scalar_Flow) return Scalar_Flow
     with Ghost => Static, Global => null, Pre => Left.Count = Right.Count,
       Post => Joined'Result.Count = Left.Count
         and then Joined'Result.Path = Paths.Join (Left.Path, Right.Path)
         and then (for all Index in Joined'Result.Values'Range =>
           Joined'Result.Values (Index) = Scalars.Join (Left.Values (Index), Right.Values (Index))
           and then
             (if Scalars.Is_Empty (Left.Values (Index)) then
                (if Scalars.Is_Empty (Right.Values (Index)) then
                   Scalars.Is_Empty (Joined'Result.Values (Index))
                 else Joined'Result.Values (Index) = Right.Values (Index))
              elsif Scalars.Is_Empty (Right.Values (Index)) then
                Joined'Result.Values (Index) = Left.Values (Index)
              else
                not Scalars.Is_Empty (Joined'Result.Values (Index))
                and then Joined'Result.Values (Index).Lower =
                  Scalars.Value'Min (Left.Values (Index).Lower, Right.Values (Index).Lower)
                and then Joined'Result.Values (Index).Upper =
                  Scalars.Value'Max (Left.Values (Index).Upper, Right.Values (Index).Upper))
           and then
             (if not Scalars.Is_Empty (Left.Values (Index))
               and then Left.Values (Index) = Right.Values (Index)
              then Joined'Result.Values (Index) = Left.Values (Index)));
   function Joined (Left, Right : Scalar_Flow) return Scalar_Flow is
      Result : Scalar_Flow (Left.Count) := Left;
   begin
      Result.Path := Paths.Join (Left.Path, Right.Path);
      for Index in Result.Values'Range loop
         pragma Loop_Invariant (Result.Path = Paths.Join (Left.Path, Right.Path));
         pragma Loop_Invariant
           (Static => (for all Done in Result.Values'First .. Index - 1 =>
             Result.Values (Done) = Scalars.Join (Left.Values (Done), Right.Values (Done))));
         Result.Values (Index) := Scalars.Join (Left.Values (Index), Right.Values (Index));
      end loop;
      return Result;
   end Joined;
   procedure Join_Into (Left : in out Scalar_Flow; Right : Scalar_Flow)
     with Global => null, Pre => Left.Count = Right.Count,
       Post => (Static => Left = Joined (Left'Old, Right)
         and then Left.Count = Left'Old.Count
         and then Left.Path = Paths.Join (Left'Old.Path, Right.Path)
         and then (for all Index in Left.Values'Range =>
           Left.Values (Index) = Scalars.Join (Left'Old.Values (Index), Right.Values (Index))));
   procedure Join_Into (Left : in out Scalar_Flow; Right : Scalar_Flow) is
   begin
      Left.Path := Paths.Join (Left.Path, Right.Path);
      for Index in Left.Values'Range loop
         pragma Loop_Invariant
           (Static => (for all Done in Left.Values'First .. Index - 1 =>
             Left.Values (Done) = Scalars.Join (Left'Loop_Entry.Values (Done), Right.Values (Done))));
         pragma Loop_Invariant
           (Static => (for all Pending in Index .. Left.Values'Last =>
             Left.Values (Pending) = Left'Loop_Entry.Values (Pending)));
         Left.Values (Index) := Scalars.Join (Left.Values (Index), Right.Values (Index));
      end loop;
   end Join_Into;
   --  Declaration constants have nonempty bounds.  This is the only extra
   --  premise needed for Join to preserve their exact stored interval.
   procedure Lemma_Joined_Flow
     (Context : Body_Context; Left, Right : Scalar_Flow)
     with Ghost => Static, Global => null,
       Pre => Valid_Declaration_Values (Context.Scalar_Names, Context.Declaration_Count)
         and then Valid_Flow (Context, Left) and then Valid_Flow (Context, Right),
       Post => Valid_Flow (Context, Joined (Left, Right));
   procedure Lemma_Joined_Flow
     (Context : Body_Context; Left, Right : Scalar_Flow) is
      Result : constant Scalar_Flow (Left.Count) := Joined (Left, Right);
   begin
      for Index in Result.Values'Range loop
         if Context.Scalar_Names.Items (Index).Mutable then
            pragma Assert (not Scalars.Is_Empty (Result.Values (Index)));
            pragma Assert
              (Included (Result.Values (Index),
                Context.Scalar_Names.Items (Index).Declared_Bounds));
         elsif Index > Context.Declaration_Count then
            pragma Assert
              (Included (Result.Values (Index), Context.Scalar_Names.Items (Index).Bounds));
         else
            pragma Assert
              (not Scalars.Is_Empty (Context.Scalar_Names.Items (Index).Bounds));
            pragma Assert
              (Result.Values (Index) = Context.Scalar_Names.Items (Index).Bounds);
         end if;
         pragma Loop_Invariant
           (for all Done in Result.Values'First .. Index =>
             (if Context.Scalar_Names.Items (Done).Mutable then
                not Scalars.Is_Empty (Result.Values (Done))
                and then Included (Result.Values (Done),
                  Context.Scalar_Names.Items (Done).Declared_Bounds)
              elsif Done > Context.Declaration_Count then
                Included (Result.Values (Done), Context.Scalar_Names.Items (Done).Bounds)
              else Result.Values (Done) = Context.Scalar_Names.Items (Done).Bounds));
      end loop;
   end Lemma_Joined_Flow;
   procedure Widen_Into (Context : Body_Context; Facts : in out Scalar_Flow)
     with Global => null, Pre => Facts.Count = Context.Scalar_Names.Count,
       Post => Facts.Path = Facts'Old.Path
         and then (for all Index in Facts.Values'Range =>
           Facts.Values (Index) =
             (if Context.Scalar_Names.Items (Index).Mutable
              then Context.Scalar_Names.Items (Index).Declared_Bounds else Facts'Old.Values (Index)));
   procedure Widen_Into (Context : Body_Context; Facts : in out Scalar_Flow) is
   begin
      for Index in Facts.Values'Range loop
         pragma Loop_Invariant (Facts.Path = Facts'Loop_Entry.Path);
         pragma Loop_Invariant
           (Static => (for all Done in Facts.Values'First .. Index - 1 =>
             Facts.Values (Done) =
               (if Context.Scalar_Names.Items (Done).Mutable
                then Context.Scalar_Names.Items (Done).Declared_Bounds else Facts'Loop_Entry.Values (Done))));
         pragma Loop_Invariant
           (Static => (for all Pending in Index .. Facts.Values'Last =>
             Facts.Values (Pending) = Facts'Loop_Entry.Values (Pending)));
         if Context.Scalar_Names.Items (Index).Mutable then
            Facts.Values (Index) := Context.Scalar_Names.Items (Index).Declared_Bounds;
         end if;
      end loop;
   end Widen_Into;

   function Reading_Names (Context : Body_Context; Facts : Scalar_Flow)
      return Scalar_Expressions.Environment
     with Global => null, Pre => Facts.Count = Context.Scalar_Names.Count,
       Post => Reading_Names'Result.Count = Context.Scalar_Names.Count
         and then (for all Index in Scalar_Expressions.Binding_Index =>
           Reading_Names'Result.Items (Index) =
             (if Index <= Facts.Count
               and then (Context.Scalar_Names.Items (Index).Mutable or else Index > Context.Declaration_Count)
              then (Context.Scalar_Names.Items (Index) with delta Bounds => Facts.Values (Index))
              else Context.Scalar_Names.Items (Index)));
   function Reading_Names (Context : Body_Context; Facts : Scalar_Flow)
      return Scalar_Expressions.Environment is
      Result : Scalar_Expressions.Environment := Context.Scalar_Names;
   begin
      for Index in Facts.Values'Range loop
         pragma Loop_Invariant (Result.Count = Context.Scalar_Names.Count);
         pragma Loop_Invariant
           (Static => (for all Cell in Scalar_Expressions.Binding_Index => Result.Items (Cell) =
             (if Cell < Index and then (Context.Scalar_Names.Items (Cell).Mutable
               or else Cell > Context.Declaration_Count)
              then (Context.Scalar_Names.Items (Cell) with delta Bounds => Facts.Values (Cell))
              else Context.Scalar_Names.Items (Cell))));
         if Result.Items (Index).Mutable or else Index > Context.Declaration_Count then
            Result.Items (Index).Bounds := Facts.Values (Index);
         end if;
      end loop;
      return Result;
   end Reading_Names;
   function Read_Scalar_In_Flow
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Mask_First : Literal_Position := 0; Mask_After : Literal_Position := 0;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Scalar_Expressions.Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts)
         and then Position <= Text'Last + 1 and then Valid_Name_State (Text, Mask_First, Mask_After),
       Post => (Runtime => Read_Scalar_In_Flow'Result.After = 0
         or else (Read_Scalar_In_Flow'Result.After in Position + 1 .. Text'Last + 1
           and then Read_Scalar_In_Flow'Result.Operands > 0),
         Static => Read_Scalar_In_Flow'Result = Scalar_Expressions.Read_Expression
           (Text, Position, Reading_Names (Context, Facts), Mask_First, Mask_After, Arrays => Context.Array_Names,
            Initials => Initials, Elaborating => Context.Elaborating));
   pragma No_Inline (Read_Scalar_In_Flow);
   function Read_Scalar_In_Flow
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Mask_First : Literal_Position := 0; Mask_After : Literal_Position := 0;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Scalar_Expressions.Expression_Result is
      Overlay : constant Scalar_Expressions.Environment := Reading_Names (Context, Facts);
   begin
      return Scalar_Expressions.Read_Expression (Text, Position, Overlay, Mask_First, Mask_After, Arrays => Context.Array_Names,
            Initials => Initials, Elaborating => Context.Elaborating);
   end Read_Scalar_In_Flow;
   --  Counted bounds must not expose constant-component folding to the pinned
   --  frontend. Keep this scratch metadata outside recursive loop frames.
   function Read_Counted_Bound
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Mask_First : Literal_Position; Mask_After : Literal_Position)
      return Scalar_Expressions.Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts)
         and then Position <= Text'Last + 1 and then Valid_Name_State (Text, Mask_First, Mask_After),
       Post => (Runtime => Read_Counted_Bound'Result.After = 0
         or else (Read_Counted_Bound'Result.After in Position + 1 .. Text'Last + 1
           and then Read_Counted_Bound'Result.Operands > 0),
         Static => (if Read_Counted_Bound'Result.After /= 0 then Read_Counted_Bound'Result =
           Read_Scalar_In_Flow (Text, Context, Position, Facts, Mask_First, Mask_After)));
   pragma No_Inline (Read_Counted_Bound);
   function Read_Counted_Bound
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Mask_First : Literal_Position; Mask_After : Literal_Position)
      return Scalar_Expressions.Expression_Result is
      Overlay : constant Scalar_Expressions.Environment := Reading_Names (Context, Facts);
      Gate : constant Scalar_Expressions.Expression_Result := Scalar_Expressions.Read_Expression
        (Text, Position, Overlay, Mask_First, Mask_After, Arrays => Context.Array_Names,
         Elaborating => Context.Elaborating, Array_Reads => Scalar_Expressions.Mutable_Elements);
   begin
      if Gate.After = 0 then return Scalar_Expressions.Invalid; end if;
      return Read_Scalar_In_Flow (Text, Context, Position, Facts, Mask_First, Mask_After);
   end Read_Counted_Bound;
   function Read_String_In_Flow
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts)
         and then Position <= Text'Last + 1,
       Post => (Runtime => Read_String_In_Flow'Result.After = 0
         or else Read_String_In_Flow'Result.After in Position + 1 .. Text'Last + 1,
         Static => Read_String_In_Flow'Result = Expression_At
           (Text, Position, Context.Names, Reading_Names (Context, Facts),
            Integer_Hidden => Context.Integer_Hidden or else Boolean_Hides_Integer (Text, Context.Boolean_Names)
              or else (Context.Mask_First /= 0 and then
                Name_Is (Text, Context.Mask_First, Context.Mask_After, Integer_Type_Word)), Arrays => Context.Array_Names,
            Initials => Initials, Elaborating => Context.Elaborating, Context_First => Context.Context_First));
   pragma No_Inline (Read_String_In_Flow);
   function Read_String_In_Flow
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Expression_Result is
      Overlay : constant Scalar_Expressions.Environment := Reading_Names (Context, Facts);
   begin
      return Expression_At (Text, Position, Context.Names, Overlay,
         Integer_Hidden => Context.Integer_Hidden or else Boolean_Hides_Integer (Text, Context.Boolean_Names)
           or else (Context.Mask_First /= 0 and then
             Name_Is (Text, Context.Mask_First, Context.Mask_After, Integer_Type_Word)), Arrays => Context.Array_Names,
            Initials => Initials, Elaborating => Context.Elaborating, Context_First => Context.Context_First);
   end Read_String_In_Flow;

   function Body_Token_Model
     (Text : String; Context : Body_Context; Scan : Body_Scan; Token : Token_Kind)
      return Body_Scan is
     (Scan with delta Position => Take_Token (Text, Scan.Position, Token))
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan);
   function Body_Token
     (Text : String; Context : Body_Context; Scan : Body_Scan; Token : Token_Kind)
      return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => (Runtime => Valid_Body (Text, Context, Body_Token'Result)
         and then (Body_Token'Result.Position = 0
           or else Body_Token'Result.Position > Scan.Position),
         Static => Body_Token'Result = Body_Token_Model (Text, Context, Scan, Token));
   function Body_Token
     (Text : String; Context : Body_Context; Scan : Body_Scan; Token : Token_Kind)
      return Body_Scan is
   begin
      return Result : Body_Scan (Scan.Count) do
         Result := Scan;
         Result.Position := Take_Token (Text, Scan.Position, Token);
      end return;
   end Body_Token;

   function Summary_Of (Value : Expression_Result) return Length_Intervals.Summary is
     (Value.Minimum_Length, Value.Static_Length, Value.Dynamic_Count, Value.Empty_Value);
   function Bound_Of (Value : Binding_Info) return Paths.Bound is
     (Value.Static_Length, Value.Dynamic);
   function Binding_Summary (Value : Binding_Info) return Length_Intervals.Summary is
     ((if Value.Dynamic then 0 else Value.Static_Length),
      (if Value.Dynamic then 0 else Value.Static_Length), (if Value.Dynamic then 1 else 0), False);

   type Comparison_Result is record
      After : Literal_Position;
      Operator : Paths.Comparison;
   end record;
   function Scalar_Comparison_At (Text : String; Position : Literal_Position)
      return Comparison_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Scalar_Comparison_At'Result.After = 0
         or else Scalar_Comparison_At'Result.After in Position + 1 .. Text'Last + 1;
   function Scalar_Comparison_At (Text : String; Position : Literal_Position)
      return Comparison_Result is
     (if Take_Token (Text, Position, Not_Equal) /= 0 then
        (Take_Token (Text, Position, Not_Equal), Paths.Unequal)
      elsif Take_Token (Text, Position, Less_Equal) /= 0 then
        (Take_Token (Text, Position, Less_Equal), Paths.Less_Equal)
      elsif Take_Token (Text, Position, Greater_Equal) /= 0 then
        (Take_Token (Text, Position, Greater_Equal), Paths.Greater_Equal)
      elsif Take_Token (Text, Position, Equal) /= 0 then
        (Take_Token (Text, Position, Equal), Paths.Equal)
      elsif Take_Token (Text, Position, Less) /= 0 then
        (Take_Token (Text, Position, Less), Paths.Less)
      elsif Take_Token (Text, Position, Greater) /= 0 then
        (Take_Token (Text, Position, Greater), Paths.Greater)
      else (0, Paths.Equal));

   type Length_Result is record
      After : Literal_Position;
      Value : Paths.Bound;
   end record;
   function Length_At
     (Text : String; Context : Body_Context; Position : Literal_Position; Literal : Boolean)
      return Length_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context),
       Post => Length_At'Result.After = 0
         or else Length_At'Result.After in Position + 1 .. Text'Last + 1;
   function Length_At
     (Text : String; Context : Body_Context; Position : Literal_Position; Literal : Boolean)
      return Length_Result is
     (declare
        First : constant Literal_Position := Skip_At (Text, Position);
        After : constant Literal_Position := Name_After (Text, First);
        Index : constant Binding_Count := Lookup_Name (Text, Context.Names, First, After);
        Number : constant Silver_Integer_Literals.Literal_Result :=
          Silver_Integer_Literals.Read_Integer (Text, First);
      begin
        (if Literal and then Number.After /= 0 then (Number.After, (Number.Value, False))
         elsif Index = 0 or else Context.Names.Items (Index).Is_Character
           or else Scalar_Expressions.Lookup (Text, Context.Scalar_Names, First, After) /= 0
         then (0, (0, False))
         else (Take_Token (Text, Take_Token (Text, After, Apostrophe), Length_Name),
           Bound_Of (Context.Names.Items (Index)))));

   type Condition_Result (Count : Scalar_Expressions.Binding_Count) is record
      After : Literal_Position;
      When_True, When_False : Scalar_Flow (Count);
   end record;
   function Invalid_Condition (Facts : Scalar_Flow) return Condition_Result is
     (Count => Facts.Count, After => 0,
      When_True => (Facts with delta Path => Paths.Empty_Context),
      When_False => (Facts with delta Path => Paths.Empty_Context))
     with Ghost => Static;
   function Valid_Condition (Context : Body_Context; Result : Condition_Result) return Boolean is
     (Valid_Flow (Context, Result.When_True) and then Valid_Flow (Context, Result.When_False));
   --  A Character relation requires a typed name or indexed component. Two
   --  unqualified character literals alone are ambiguous among Ada's three
   --  predefined character types. Byte comparisons retain no scalar facts.
   function Character_Condition
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Condition_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts)
         and then Position <= Text'Last + 1,
       Post => Valid_Condition (Context, Character_Condition'Result)
         and then (Character_Condition'Result.After = 0
           or else Character_Condition'Result.After in Position + 1 .. Text'Last + 1);
   function Character_Condition
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Condition_Result is
     (declare
        Overlay : constant Scalar_Expressions.Environment := Reading_Names (Context, Facts);
        Left : constant Value_Result := Character_At
          (Text, Position, Context.Names, Overlay, Context.Array_Names, Initials, Context.Elaborating);
        Operator : constant Comparison_Result := Scalar_Comparison_At (Text, Left.After);
        Right : constant Value_Result := Character_At
          (Text, Operator.After, Context.Names, Overlay, Context.Array_Names, Initials, Context.Elaborating);
      begin
        (if Left.After = 0 or else Operator.After = 0 or else Right.After <= Position
           or else not (Left.Nonliteral_Seen or else Right.Nonliteral_Seen)
         then (Count => Facts.Count, After => 0,
           When_True => (Facts with delta Path => Paths.Empty_Context),
           When_False => (Facts with delta Path => Paths.Empty_Context))
         else (Count => Facts.Count, After => Right.After, When_True => Facts, When_False => Facts)));

   procedure Invalidate_Condition (Facts : Scalar_Flow; Result : out Condition_Result)
     with Global => null, Pre => Result.Count = Facts.Count,
       Post => (Static => Result = Invalid_Condition (Facts));
   procedure Invalidate_Condition (Facts : Scalar_Flow; Result : out Condition_Result) is
   begin
      Result.After := 0;
      Result.When_True := Facts;
      Result.When_False := Facts;
      Result.When_True.Path := Paths.Empty_Context;
      Result.When_False.Path := Paths.Empty_Context;
   end Invalidate_Condition;
   --  Each visible body separately proves its Logical_Equal annotation.
   --  Array extensionality is isolated from the enclosing record layers.
   function Same_Interval (Left, Right : Scalars.Interval) return Boolean is
     (Left.Lower = Right.Lower and then Left.Upper = Right.Upper)
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Path (Left, Right : Paths.Context) return Boolean is
     (Left.Lower = Right.Lower and then Left.Upper = Right.Upper
      and then Left.Valid_Reachable = Right.Valid_Reachable
      and then Left.Invalid_Reachable = Right.Invalid_Reachable
      and then Left.Invalid_Rejected = Right.Invalid_Rejected)
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Values (Left, Right : Interval_Vector) return Boolean is
     (Left'First = Right'First and then Left'Last = Right'Last
      and then (for all Index in Left'Range =>
        Same_Interval (Left (Index), Right (Index))))
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Flow (Left, Right : Scalar_Flow) return Boolean is
     (Left.Count = Right.Count and then Same_Path (Left.Path, Right.Path)
      and then Same_Values (Left.Values, Right.Values))
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Body (Left, Right : Body_Scan) return Boolean is
     (Left.Count = Right.Count and then Same_Flow (Left.Facts, Right.Facts)
      and then Left.Position = Right.Position and then Left.Target = Right.Target
      and then Left.Capacity = Right.Capacity
      and then Left.Assigned = Right.Assigned and then Left.Output = Right.Output)
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);
   function Same_Condition (Left, Right : Condition_Result) return Boolean is
     (Left.Count = Right.Count and then Left.After = Right.After
      and then Same_Flow (Left.When_True, Right.When_True)
      and then Same_Flow (Left.When_False, Right.When_False))
     with Ghost => Static, Global => null,
       Annotate => (GNATprove, Logical_Equal);

   procedure Lemma_Condition_Equality (Left, Right : Condition_Result)
     with Ghost => Static, Global => null,
       Pre => Left = Right,
       Post => Same_Condition (Left, Right)
   is
   begin
      --  Ada record equality exposes the discriminant and scalar components.
      pragma Assert (Static => Left.Count = Right.Count);
      pragma Assert (Static => Left.After = Right.After);
      pragma Assert (Static => Left.When_True.Count = Left.Count);
      pragma Assert (Static => Left.When_False.Count = Left.Count);
      pragma Assert (Static => Right.When_True.Count = Right.Count);
      pragma Assert (Static => Right.When_False.Count = Right.Count);
      pragma Assert (Static => Left.When_True.Path = Right.When_True.Path);
      pragma Assert (Static => Left.When_False.Path = Right.When_False.Path);
      pragma Assert (Static => Same_Path (Left.When_True.Path, Right.When_True.Path));
      pragma Assert (Static => Same_Path (Left.When_False.Path, Right.When_False.Path));

      --  Predefined array equality alone permits sliding. These component
      --  constraints fix the bounds, including the null range when Count = 0.
      pragma Assert (Static => Left.When_True.Values'First = 1
        and then Left.When_True.Values'Last = Left.Count);
      pragma Assert (Static => Right.When_True.Values'First = 1
        and then Right.When_True.Values'Last = Right.Count);
      pragma Assert (Static => Left.When_False.Values'First = 1
        and then Left.When_False.Values'Last = Left.Count);
      pragma Assert (Static => Right.When_False.Values'First = 1
        and then Right.When_False.Values'Last = Right.Count);
      pragma Assert (Static => Left.When_True.Values = Right.When_True.Values);
      pragma Assert (Static => Left.When_False.Values = Right.When_False.Values);
      pragma Assert (Static =>
        (for all Index in Left.When_True.Values'Range =>
           Left.When_True.Values (Index).Lower = Right.When_True.Values (Index).Lower
           and then Left.When_True.Values (Index).Upper = Right.When_True.Values (Index).Upper));
      pragma Assert (Static =>
        (for all Index in Left.When_False.Values'Range =>
           Left.When_False.Values (Index).Lower = Right.When_False.Values (Index).Lower
           and then Left.When_False.Values (Index).Upper = Right.When_False.Values (Index).Upper));
      pragma Assert (Static =>
        (for all Index in Left.When_True.Values'Range =>
           Same_Interval (Left.When_True.Values (Index), Right.When_True.Values (Index))));
      pragma Assert (Static =>
        (for all Index in Left.When_False.Values'Range =>
           Same_Interval (Left.When_False.Values (Index), Right.When_False.Values (Index))));
      pragma Assert (Static => Same_Values (Left.When_True.Values, Right.When_True.Values));
      pragma Assert (Static => Same_Values (Left.When_False.Values, Right.When_False.Values));
      pragma Assert (Static => Same_Flow (Left.When_True, Right.When_True));
      pragma Assert (Static => Same_Flow (Left.When_False, Right.When_False));
      pragma Assert (Static => Same_Condition (Left, Right));
   end Lemma_Condition_Equality;

   procedure Lemma_Flow_Equality (Left, Right : Scalar_Flow)
     with Ghost => Static, Global => null,
       Pre => Left = Right,
       Post => Same_Flow (Left, Right)
   is
   begin
      --  Embed equal flows in equal conditions and use the checked bridge.
      pragma Assert (Static => Left.Count = Right.Count);
      Lemma_Condition_Equality
        ((Count => Left.Count, After => 0, When_True => Left, When_False => Left),
         (Count => Right.Count, After => 0, When_True => Right, When_False => Right));
      pragma Assert (Static => Same_Flow (Left, Right));
   end Lemma_Flow_Equality;

   procedure Lemma_Body_Equality (Left, Right : Body_Scan)
     with Ghost => Static, Global => null,
       Pre => Left = Right,
       Post => Same_Body (Left, Right) and then Left = Right
   is
   begin
      Lemma_Flow_Equality (Left.Facts, Right.Facts);
   end Lemma_Body_Equality;


   procedure Lemma_Join_Identity (Result, Before, Right : Scalar_Flow)
     with Ghost => Static, Global => null,
       Pre => Result.Count = Before.Count and then Before.Count = Right.Count
         and then Result.Path = Paths.Join (Before.Path, Right.Path)
         and then (for all Index in Result.Values'Range =>
           Result.Values (Index) = Scalars.Join (Before.Values (Index), Right.Values (Index))),
       Post => Same_Flow (Result, Joined (Before, Right))
         and then Result = Joined (Before, Right)
   is
      Model : constant Scalar_Flow (Before.Count) := Joined (Before, Right);
   begin
      Lemma_Flow_Equality (Model, Joined (Before, Right));
      pragma Assert (Static => Same_Path (Result.Path, Model.Path));
      pragma Assert (Static =>
        (for all Index in Result.Values'Range =>
          Same_Interval (Result.Values (Index), Model.Values (Index))));
      pragma Assert (Static => Same_Values (Result.Values, Model.Values));
      pragma Assert (Static => Same_Flow (Result, Model));
   end Lemma_Join_Identity;

   function Scalar_Operator (Operator : Paths.Comparison) return Scalars.Comparison is
     (case Operator is
        when Paths.Equal => Scalars.Equal, when Paths.Unequal => Scalars.Unequal,
        when Paths.Less => Scalars.Less, when Paths.Less_Equal => Scalars.Less_Equal,
        when Paths.Greater => Scalars.Greater, when Paths.Greater_Equal => Scalars.Greater_Equal);
   function Refine_Or_Keep
     (Bounds : Scalars.Interval; Operator : Scalars.Comparison; Threshold : Scalars.Value; Truth : Boolean)
      return Scalars.Interval is
     (declare Refined : constant Scalars.Interval := Scalars.Refine (Bounds, Operator, Threshold, Truth);
      begin (if Scalars.Is_Empty (Refined) then Bounds else Refined))
     with Post => (Static => Included (Refine_Or_Keep'Result, Bounds)
       and then (Scalars.Is_Empty (Refine_Or_Keep'Result) = Scalars.Is_Empty (Bounds)));
   function Bare_Target
     (Text : String; Context : Body_Context; Position, After : Literal_Position)
      return Scalar_Expressions.Binding_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Position <= Text'Last + 1
         and then After <= Text'Last + 1,
       Post => Bare_Target'Result <= Context.Scalar_Names.Count
         and then (Bare_Target'Result = 0
           or else Context.Scalar_Names.Items (Bare_Target'Result).Mutable
           or else Bare_Target'Result > Context.Declaration_Count);
   function Bare_Target
     (Text : String; Context : Body_Context; Position, After : Literal_Position)
      return Scalar_Expressions.Binding_Count is
     (declare First : constant Literal_Position := Skip_At (Text, Position);
      Last : constant Literal_Position := Name_After (Text, First);
      Index : constant Scalar_Expressions.Binding_Count :=
        Scalar_Expressions.Lookup (Text, Context.Scalar_Names, First, Last);
      begin
        (if Index /= 0 and then Last = After
          and then (Context.Scalar_Names.Items (Index).Mutable or else Index > Context.Declaration_Count)
         then Index else 0));
   function Refined_Flow
     (Facts : Scalar_Flow; Index : Scalar_Expressions.Binding_Count;
      Operator : Scalars.Comparison; Threshold : Scalars.Value; Truth : Boolean)
      return Scalar_Flow is
     (if Index = 0 then Facts else
       (Facts with delta Values => (Facts.Values with delta Index =>
         Refine_Or_Keep (Facts.Values (Index), Operator, Threshold, Truth))))
     with Ghost => Static, Pre => Index <= Facts.Count;
   function Scalar_Condition
     (Text : String; Context : Body_Context; Position, Right_Position : Literal_Position;
      Facts : Scalar_Flow; Left, Right : Scalar_Expressions.Expression_Result;
      Operator : Paths.Comparison) return Condition_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts)
         and then Position <= Text'Last + 1 and then Right_Position <= Text'Last + 1
         and then Left.After <= Text'Last + 1 and then Right.After <= Text'Last + 1;
   function Scalar_Condition
     (Text : String; Context : Body_Context; Position, Right_Position : Literal_Position;
      Facts : Scalar_Flow; Left, Right : Scalar_Expressions.Expression_Result;
      Operator : Paths.Comparison) return Condition_Result is
     (declare
        Left_Target : constant Scalar_Expressions.Binding_Count := Bare_Target (Text, Context, Position, Left.After);
        Right_Target : constant Scalar_Expressions.Binding_Count := Bare_Target (Text, Context, Right_Position, Right.After);
        Target : constant Scalar_Expressions.Binding_Count :=
          (if Left_Target /= 0 and then Right.Static and then Right.Bounds.Lower = Right.Bounds.Upper
           then Left_Target
           elsif Right_Target /= 0 and then Left.Static and then Left.Bounds.Lower = Left.Bounds.Upper
           then Right_Target else 0);
        Selected : constant Scalars.Comparison :=
          (if Left_Target /= 0 and then Right.Static and then Right.Bounds.Lower = Right.Bounds.Upper
           then Scalar_Operator (Operator) else Scalars.Swap (Scalar_Operator (Operator)));
        Threshold : constant Scalars.Value :=
          (if Left_Target /= 0 and then Right.Static and then Right.Bounds.Lower = Right.Bounds.Upper
           then Right.Bounds.Lower else Left.Bounds.Lower);
      begin
        (Count => Facts.Count, After => Right.After,
         When_True => Refined_Flow (Facts, Target, Selected, Threshold, True),
         When_False => Refined_Flow (Facts, Target, Selected, Threshold, False)));
   function Boolean_Array_After
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow)
      return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts),
       Post => Boolean_Array_After'Result = 0
         or else Boolean_Array_After'Result in Position + 1 .. Text'Last + 1;
   function Boolean_Array_After
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow)
      return Literal_Position is
     (declare First : constant Literal_Position := Skip_At (Text, Position);
              After : constant Literal_Position := Name_After (Text, First);
              Target : constant Array_Bindings.Binding_Count :=
                Array_Bindings.Lookup (Text, Context.Array_Names, First, After);
              Subscript : constant Scalar_Expressions.Expression_Result :=
                Scalar_Expressions.Read_Expression
                  (Text, Take_Token (Text, After, Left_Parenthesis), Reading_Names (Context, Facts),
                   Context.Mask_First, Context.Mask_After, Arrays => Context.Array_Names,
                   Array_Reads => Scalar_Expressions.No_Elements);
              Close : constant Literal_Position := Take_Token (Text, Subscript.After, Right_Parenthesis);
      begin
        (if First = 0 or else After <= First
           or else Target = 0 or else not Context.Array_Names.Items (Target).Boolean_Elements
           or else Scalar_Expressions.Lookup (Text, Context.Scalar_Names, First, After) /= 0
           or else (Context.Mask_First /= 0 and then Equal_Name
             (Text, Context.Mask_First, Context.Mask_After, First, After))
           or else Subscript.Operands = Scalar_Expressions.Max_Operands
           or else not Array_Bindings.Contains (Context.Array_Names.Items (Target), Subscript.Bounds)
           or else Close <= Position
         then 0 else Close));

   function Boolean_Atom_After
     (Text : String; Context : Body_Context; Position : Literal_Position)
      return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context),
       Post => Boolean_Atom_After'Result = 0
         or else Boolean_Atom_After'Result in Position + 1 .. Text'Last + 1;
   function Boolean_Atom_After
     (Text : String; Context : Body_Context; Position : Literal_Position)
      return Literal_Position is
     (declare Reference : constant Scalar_Expressions.Name_Reference :=
                Scalar_Expressions.Read_Reference (Text, Position);
              First : constant Literal_Position := Reference.First;
              After : constant Literal_Position := Reference.After;
      begin
        (if First = 0 or else After <= First then 0
         elsif Reference.Qualifier_First /= 0 then
           (if Lookup_Boolean (Text, Context.Boolean_Names, First, After,
                 Reference.Qualifier_First, Reference.Qualifier_After) /= 0
            then After else 0)
         elsif (Context.Mask_First /= 0 and then Equal_Name
             (Text, Context.Mask_First, Context.Mask_After, First, After))
           or else Scalar_Expressions.Lookup (Text, Context.Scalar_Names, First, After) /= 0
           or else Lookup_Name (Text, Context.Names, First, After) /= 0
           or else Array_Bindings.Lookup (Text, Context.Array_Names, First, After) /= 0
           or else Array_Bindings.Lookup_Type (Text, Context.Array_Names.Types, First, After) /= 0
         then 0
         elsif Lookup_Boolean (Text, Context.Boolean_Names, First, After) /= 0 then After
         elsif (Name_Is (Text, First, After, "true") and then not Context.True_Hidden)
           or else (Name_Is (Text, First, After, "false") and then not Context.False_Hidden)
         then After else 0));

   function Condition_Model
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Condition_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts),
       Post => Condition_Model'Result.Count = Facts.Count
         and then Valid_Condition (Context, Condition_Model'Result)
         and then (Condition_Model'Result.After = 0
           or else Condition_Model'Result.After in Position + 1 .. Text'Last + 1),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 5);
   function Primary_Model
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Condition_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts),
       Post => Primary_Model'Result.Count = Facts.Count
         and then Valid_Condition (Context, Primary_Model'Result)
         and then (Primary_Model'Result.After = 0
           or else Primary_Model'Result.After in Position + 1 .. Text'Last + 1),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 1);
   function Relation_Model
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Condition_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts),
       Post => Relation_Model'Result.Count = Facts.Count
         and then Valid_Condition (Context, Relation_Model'Result)
         and then (Relation_Model'Result.After = 0
           or else Relation_Model'Result.After in Position + 1 .. Text'Last + 1),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 4);
   function Primary_Model
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Condition_Result is
     (if Position = 0 then Invalid_Condition (Facts) else
        (declare After : constant Literal_Position := Take_Token (Text, Position, Left_Parenthesis);
         begin
           (if After /= 0 then
              (declare Result : constant Condition_Result (Facts.Count) := Condition_Model (Text, Context, After, Facts, Initials => Initials);
               Close : constant Literal_Position := Take_Token (Text, Result.After, Right_Parenthesis);
               begin (if Close = 0 then Invalid_Condition (Facts) else (Result with delta After => Close)))
            elsif Boolean_Array_After (Text, Context, Position, Facts) /= 0 then
              (Facts.Count, Boolean_Array_After (Text, Context, Position, Facts), Facts, Facts)
            elsif Boolean_Atom_After (Text, Context, Position) /= 0 then
              (Facts.Count, Boolean_Atom_After (Text, Context, Position), Facts, Facts)
            elsif Context.Dynamic_First = 0 then Invalid_Condition (Facts)
            else
              (declare After_Call : constant Literal_Position :=
                 Call_After (Text, Context.Names, Position, Names.Validity_Call, Context.Scalar_Names, Context.Array_Names, (Context.Subtype_Hiding (Names.Validity_Call)
                   or else (Context.Mask_First /= 0 and then Name_Is
                     (Text, Context.Mask_First, Context.Mask_After, Validity_Call_Word))), Context.Boolean_Names, Context.Context_First, Context.Package_First, Context.Package_After);
               begin (if After_Call = 0 then Invalid_Condition (Facts) else
                 (Count => Facts.Count, After => After_Call,
                  When_True => (Facts with delta Path => Paths.Assume_Valid (Facts.Path)),
                  When_False => (Facts with delta Path => Paths.Assume_Invalid (Facts.Path))))))));
   function Boolean_Factor_Model
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Condition_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts),
       Post => Boolean_Factor_Model'Result.Count = Facts.Count
         and then Valid_Condition (Context, Boolean_Factor_Model'Result)
         and then (Boolean_Factor_Model'Result.After = 0
           or else Boolean_Factor_Model'Result.After in Position + 1 .. Text'Last + 1),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 2);
   function Boolean_Relation_Model
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Condition_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts),
       Post => Boolean_Relation_Model'Result.Count = Facts.Count
         and then Valid_Condition (Context, Boolean_Relation_Model'Result)
         and then (Boolean_Relation_Model'Result.After = 0
           or else Boolean_Relation_Model'Result.After in Position + 1 .. Text'Last + 1),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 3);
   function Boolean_Factor_Model
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Condition_Result is
     (declare After : constant Literal_Position := Take_Token (Text, Position, Not_Keyword);
      begin (if After = 0 then Primary_Model (Text, Context, Position, Facts, Initials)
        else (declare Result : constant Condition_Result (Facts.Count) :=
                Primary_Model (Text, Context, After, Facts, Initials);
              begin (Result.Count, Result.After, Result.When_False, Result.When_True))));
   function Boolean_Relation_Model
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Condition_Result is
     (declare Left : constant Condition_Result (Facts.Count) :=
                Boolean_Factor_Model (Text, Context, Position, Facts, Initials);
              Operator : constant Comparison_Result := Scalar_Comparison_At (Text, Left.After);
      begin (if Left.After = 0 then Invalid_Condition (Facts)
        elsif Operator.After = 0 then Left
        elsif Operator.Operator not in Paths.Equal | Paths.Unequal then Invalid_Condition (Facts)
        else (declare Right : constant Condition_Result (Facts.Count) :=
                Boolean_Factor_Model (Text, Context, Operator.After, Facts, Initials);
              begin (if Right.After = 0 then Invalid_Condition (Facts)
                else (Facts.Count, Right.After, Facts, Facts)))));
   function Relation_Model
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Condition_Result is
     (if Position = 0 then Invalid_Condition (Facts) else
        (declare
           After : constant Literal_Position := Take_Token (Text, Position, Not_Keyword);
           Left_Length : constant Length_Result := Length_At (Text, Context, Position, False);
           Left_Scalar : constant Scalar_Expressions.Expression_Result := Read_Scalar_In_Flow (Text, Context, Position, Facts, Initials => Initials);
         begin
           (if After /= 0 then
              Boolean_Relation_Model (Text, Context, Position, Facts, Initials)
            elsif Left_Length.After /= 0 then
              (declare
                 Operator : constant Comparison_Result := Scalar_Comparison_At (Text, Left_Length.After);
                 Right_Length : constant Length_Result := Length_At (Text, Context, Operator.After, True);
               begin
                 (if Right_Length.After <= Position then Invalid_Condition (Facts) else
                    (Count => Facts.Count, After => Right_Length.After,
                     When_True => (Facts with delta Path =>
                       Paths.Refine_Bounds (Facts.Path, Operator.Operator, Left_Length.Value, Right_Length.Value, True)),
                     When_False => (Facts with delta Path =>
                       Paths.Refine_Bounds (Facts.Path, Operator.Operator, Left_Length.Value, Right_Length.Value, False)))))
            elsif Left_Scalar.After /= 0 then
              (declare
                 Operator : constant Comparison_Result := Scalar_Comparison_At (Text, Left_Scalar.After);
                 Right_Scalar : constant Scalar_Expressions.Expression_Result :=
                   Read_Scalar_In_Flow (Text, Context, Operator.After, Facts, Initials => Initials);
               begin
                 (if Right_Scalar.After <= Position then Invalid_Condition (Facts)
                  else Scalar_Condition (Text, Context, Position, Operator.After, Facts, Left_Scalar, Right_Scalar, Operator.Operator)))
            elsif Context.Pure then
              Boolean_Relation_Model (Text, Context, Position, Facts, Initials)
            else
              (declare Left : constant Expression_Result := Read_String_In_Flow (Text, Context, Position, Facts, Initials => Initials);
               begin
                 (if Left.After /= 0 then
                    (declare Operator : constant Comparison_Result := Scalar_Comparison_At (Text, Left.After);
                     begin
                       (if Operator.After = 0 or else Operator.Operator not in Paths.Equal | Paths.Unequal
                        then Invalid_Condition (Facts) else
                          (declare Right : constant Expression_Result := Read_String_In_Flow (Text, Context, Operator.After, Facts, Initials => Initials);
                           begin
                             (if Right.After <= Position or else not (Left.Named_Seen or else Right.Named_Seen)
                                or else not Length_Intervals.Fits (Facts.Path, Summary_Of (Left))
                                or else not Length_Intervals.Fits (Facts.Path, Summary_Of (Right))
                              then Invalid_Condition (Facts) else
                                (declare Equal_Facts : constant Paths.Context :=
                                   Length_Intervals.Refine_Equal (Facts.Path, Summary_Of (Left), Summary_Of (Right));
                                 begin (Count => Facts.Count, After => Right.After,
                                   When_True => (Facts with delta Path =>
                                     (if Operator.Operator = Paths.Equal then Equal_Facts else Facts.Path)),
                                   When_False => (Facts with delta Path =>
                                     (if Operator.Operator = Paths.Equal then Facts.Path else Equal_Facts))))))))
                  else
                    (declare Character_Result : constant Condition_Result :=
                       Character_Condition (Text, Context, Position, Facts, Initials);
                     begin (if Character_Result.After /= 0 then Character_Result
                       else Boolean_Relation_Model (Text, Context, Position, Facts, Initials))))))));
   --  The producer expands xor by duplicating both operands. Excluding an xor
   --  inside either operand prevents repeated multiplication of that expansion.
   --  Scan only this expression span; comments, quoted strings and identifier
   --  substrings are not operators.
   function Xor_Free_Model
     (Text : String; Position, After : Literal_Position;
      Quoted, Comment, Word_Start : Boolean) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then After <= Text'Last + 1,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position);
   function Xor_Free_Model
     (Text : String; Position, After : Literal_Position;
      Quoted, Comment, Word_Start : Boolean) return Boolean is
     (if Position = 0 or else Position > After then False
      elsif Position = After then True
      elsif Comment then
        Xor_Free_Model (Text, Position + 1, After, False,
          not Is_Comment_End (Text (Position)), True)
      elsif Quoted then
        (if Text (Position) = Character'Val (34) then
           (if Position + 1 < After and then Text (Position + 1) = Character'Val (34)
            then Xor_Free_Model (Text, Position + 2, After, True, False, True)
            else Xor_Free_Model (Text, Position + 1, After, False, False, True))
         else Xor_Free_Model (Text, Position + 1, After, True, False, True))
      elsif Text (Position) = '-' and then Position + 1 < After
        and then Text (Position + 1) = '-' then
        Xor_Free_Model (Text, Position + 2, After, False, True, True)
      elsif Character_Literal_After (Text, Position) /= 0
        and then Character_Literal_After (Text, Position) <= After then
        Xor_Free_Model (Text, Character_Literal_After (Text, Position), After, False, False, True)
      elsif Text (Position) = Character'Val (34) then
        Xor_Free_Model (Text, Position + 1, After, True, False, True)
      elsif Word_Start and then After - Position >= 3
        and then Lowercase (Text (Position)) = 'x'
        and then Lowercase (Text (Position + 1)) = 'o'
        and then Lowercase (Text (Position + 2)) = 'r'
        and then (Position + 3 = After
          or else not Is_Identifier_Character (Text (Position + 3))) then False
      else Xor_Free_Model (Text, Position + 1, After, False, False,
        not Is_Identifier_Character (Text (Position))));

   function Xor_Free (Text : String; First, After : Literal_Position) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then First <= Text'Last + 1 and then After <= Text'Last + 1,
       Post => (Static => Xor_Free'Result =
         Xor_Free_Model (Text, First, After, False, False, True));
   function Xor_Free (Text : String; First, After : Literal_Position) return Boolean is
      Position : Literal_Position := First;
      Quoted, Comment : Boolean := False;
      Word_Start : Boolean := True;
   begin
      if First = 0 or else First > After then return False; end if;
      while Position < After loop
         pragma Loop_Invariant (Position in First .. After);
         pragma Loop_Invariant (Static =>
           Xor_Free_Model (Text, First, After, False, False, True) =
             Xor_Free_Model (Text, Position, After, Quoted, Comment, Word_Start));
         pragma Loop_Variant (Increases => Position);
         if Comment then
            Comment := not Is_Comment_End (Text (Position));
            Quoted := False;
            Word_Start := True;
            Position := Position + 1;
         elsif Quoted then
            if Text (Position) = Character'Val (34) then
               if Position + 1 < After and then Text (Position + 1) = Character'Val (34) then
                  Position := Position + 2;
               else
                  Quoted := False;
                  Position := Position + 1;
               end if;
            else
               Position := Position + 1;
            end if;
            Word_Start := True;
         elsif Text (Position) = '-' and then Position + 1 < After
           and then Text (Position + 1) = '-' then
            Comment := True;
            Word_Start := True;
            Position := Position + 2;
         elsif Character_Literal_After (Text, Position) /= 0
           and then Character_Literal_After (Text, Position) <= After then
            Position := Character_Literal_After (Text, Position);
            Word_Start := True;
         elsif Text (Position) = Character'Val (34) then
            Quoted := True;
            Word_Start := True;
            Position := Position + 1;
         elsif Word_Start and then After - Position >= 3
           and then Lowercase (Text (Position)) = 'x'
           and then Lowercase (Text (Position + 1)) = 'o'
           and then Lowercase (Text (Position + 2)) = 'r'
           and then (Position + 3 = After
             or else not Is_Identifier_Character (Text (Position + 3))) then
            return False;
         else
            Word_Start := not Is_Identifier_Character (Text (Position));
            Position := Position + 1;
         end if;
      end loop;
      return True;
   end Xor_Free;

   type Chain_Kind is (No_Chain, Short_And, Short_Or, Eager_And, Eager_Or, Eager_Xor);
   function Chain_Token (Text : String; Position : Literal_Position) return Chain_Kind
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1;
   function Chain_Token (Text : String; Position : Literal_Position) return Chain_Kind is
     (if Take_Token (Text, Position, And_Keyword) /= 0 then
        (if Take_Token (Text, Take_Token (Text, Position, And_Keyword), Then_Keyword) /= 0
         then Short_And else Eager_And)
      elsif Take_Token (Text, Position, Or_Keyword) /= 0 then
        (if Take_Token (Text, Take_Token (Text, Position, Or_Keyword), Else_Keyword) /= 0
         then Short_Or else Eager_Or)
      elsif Take_Token (Text, Position, Xor_Keyword) /= 0 then Eager_Xor
      else No_Chain);
   function Chain_After (Text : String; Position : Literal_Position; Operator : Chain_Kind)
      return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Operator /= No_Chain,
       Post => Chain_After'Result = 0 or else Chain_After'Result in Position + 1 .. Text'Last + 1;
   function Chain_After (Text : String; Position : Literal_Position; Operator : Chain_Kind)
      return Literal_Position is
     (case Operator is
        when No_Chain => 0,
        when Short_And => Take_Token (Text, Take_Token (Text, Position, And_Keyword), Then_Keyword),
        when Short_Or => Take_Token (Text, Take_Token (Text, Position, Or_Keyword), Else_Keyword),
        when Eager_And => Take_Token (Text, Position, And_Keyword),
        when Eager_Or => Take_Token (Text, Position, Or_Keyword),
        when Eager_Xor => Take_Token (Text, Position, Xor_Keyword));

   function Condition_Tail
     (Text : String; Context : Body_Context; Result : Condition_Result;
      Operator : Chain_Kind; Chained : Boolean; Incoming : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values;
      Original_Start : Literal_Position) return Condition_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Result.After <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Condition (Context, Result) and then Operator /= No_Chain
         and then Valid_Flow (Context, Incoming) and then Incoming.Count = Result.Count
         and then Original_Start <= Text'Last + 1,
       Post => Condition_Tail'Result.Count = Result.Count
         and then Valid_Condition (Context, Condition_Tail'Result)
         and then (Condition_Tail'Result.After = 0
           or else Condition_Tail'Result.After in Result.After .. Text'Last + 1),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Result.After, Decreases => 6);
   function Condition_Tail
     (Text : String; Context : Body_Context; Result : Condition_Result;
      Operator : Chain_Kind; Chained : Boolean; Incoming : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values;
      Original_Start : Literal_Position) return Condition_Result is
     (if Result.After = 0 then Invalid_Condition (Result.When_True) else
        (declare Selected : constant Chain_Kind := Chain_Token (Text, Result.After);
         begin
           (if Selected = No_Chain then Result
            elsif (Chained and then Operator /= Selected)
              or else (Selected = Eager_Xor
                and then not Xor_Free (Text, Original_Start, Result.After))
            then Invalid_Condition (Result.When_True)
            else
              (declare After : constant Literal_Position := Chain_After (Text, Result.After, Selected);
               begin
                 (if After = 0 then Invalid_Condition (Result.When_True) else
                    (declare Right : constant Condition_Result (Result.Count) := Relation_Model (Text, Context, After,
                       (if Selected = Short_And then Result.When_True
                        elsif Selected = Short_Or then Result.When_False else Incoming), Initials => Initials);
                     begin
                       (if Right.After = 0 or else (Selected = Eager_Xor
                         and then not Xor_Free (Text, After, Right.After)) then Invalid_Condition (Result.When_True) else
                          Condition_Tail (Text, Context,
                            (if Selected = Short_And then
                               (Result.Count, Right.After, Right.When_True, Joined (Result.When_False, Right.When_False))
                             elsif Selected = Short_Or then
                               (Result.Count, Right.After, Joined (Result.When_True, Right.When_True), Right.When_False)
                             else (Result.Count, Right.After, Incoming, Incoming)),
                            Selected, True, Initials => Initials, Incoming => Incoming, Original_Start => Original_Start))))))));
   function Condition_Model
     (Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
      return Condition_Result is
     (declare Result : constant Condition_Result (Facts.Count) := Relation_Model (Text, Context, Position, Facts, Initials => Initials);
      begin (if Result.After = 0 then Invalid_Condition (Facts) else
        (declare Final : constant Condition_Result (Facts.Count) :=
           Condition_Tail (Text, Context, Result, Short_And, False, Initials => Initials, Incoming => Facts, Original_Start => Position);
         begin (if Final.After = 0 then Invalid_Condition (Facts) else Final))));
   procedure Read_Condition_Into
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Result : out Condition_Result;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts) and then Result.Count = Facts.Count,
       Post => (Runtime => Valid_Condition (Context, Result)
         and then (Result.After = 0 or else Result.After in Position + 1 .. Text'Last + 1),
         Static => Result = Condition_Model (Text, Context, Position, Facts, Initials => Initials)),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 7);
   procedure Read_Primary_Into
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Result : out Condition_Result;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts) and then Result.Count = Facts.Count,
       Post => (Runtime => Valid_Condition (Context, Result)
         and then (Result.After = 0 or else Result.After in Position + 1 .. Text'Last + 1),
         Static => Result = Primary_Model (Text, Context, Position, Facts, Initials => Initials)),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 1);
   procedure Read_Relation_Into
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Result : out Condition_Result;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts) and then Result.Count = Facts.Count,
       Post => (Runtime => Valid_Condition (Context, Result)
         and then (Result.After = 0 or else Result.After in Position + 1 .. Text'Last + 1),
         Static => Result = Relation_Model (Text, Context, Position, Facts, Initials => Initials)),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 4);
   procedure Read_Chain_Into
     (Text : String; Context : Body_Context; Result : in out Condition_Result; Incoming : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values;
      Original_Start : Literal_Position)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Result.After in 1 .. Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Condition (Context, Result)
         and then Valid_Flow (Context, Incoming) and then Incoming.Count = Result.Count
         and then Original_Start <= Text'Last + 1
         and then Chain_Token (Text, Result.After) /= No_Chain,
       Post => (Runtime => Valid_Condition (Context, Result)
         and then (Result.After = 0 or else Result.After in Result.After'Old .. Text'Last + 1),
         Static => Result = Condition_Tail (Text, Context, Result'Old, Short_And, False, Initials => Initials, Incoming => Incoming, Original_Start => Original_Start)),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Result.After, Decreases => 6);
   procedure Read_Primary_Into
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Result : out Condition_Result;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values) is
      After : constant Literal_Position := Take_Token (Text, Position, Left_Parenthesis);
   begin
      if Position = 0 then
         Invalidate_Condition (Facts, Result);
         --  Invalid input.
         pragma Assert (Static => Valid_Flow (Context, Result.When_True));
         pragma Assert (Static => Valid_Flow (Context, Result.When_False));
      elsif After /= 0 then
         declare
            --  Name the recursive model input and the closing cursor before
            --  transporting either through the caller's mutable result.
            Inner : constant Condition_Result (Facts.Count) :=
              Condition_Model (Text, Context, After, Facts, Initials => Initials) with Ghost => Static;
            Close : constant Literal_Position :=
              Take_Token (Text, Inner.After, Right_Parenthesis) with Ghost => Static;
            Expected : constant Condition_Result (Facts.Count) :=
              Primary_Model (Text, Context, Position, Facts, Initials => Initials) with Ghost => Static;
         begin
            --  Discharge the selected model branch before the runtime call.
            --  Logical equality retains nested array bounds as well as values.
            pragma Assert (Static => Same_Condition
              (Expected,
               (if Close = 0 then Invalid_Condition (Facts)
                else (Inner with delta After => Close))));
            pragma Assert (Static => Expected.After = Close);

            --  Grouping forwards the caller's buffer; no runtime vector is local.
            Read_Condition_Into (Text, Context, After, Facts, Result, Initials => Initials);
            pragma Assert (Static => Result = Condition_Model (Text, Context, After, Facts, Initials => Initials));
            pragma Assert (Static => Result = Inner);
            Lemma_Condition_Equality (Result, Inner);
            pragma Assert (Static => Same_Condition (Result, Inner));
            Result.After := Take_Token (Text, Result.After, Right_Parenthesis);
            pragma Assert (Static => Result.After = Close);
            if Result.After = 0 then
               Invalidate_Condition (Facts, Result);
               Lemma_Condition_Equality (Result, Invalid_Condition (Facts));
               pragma Assert (Static => Same_Condition (Result, Invalid_Condition (Facts)));
            else
               pragma Assert (Static => Result =
                 (Condition_Model (Text, Context, After, Facts, Initials => Initials) with delta After => Result.After));
               pragma Assert (Static => Same_Flow (Result.When_True, Inner.When_True));
               pragma Assert (Static => Same_Flow (Result.When_False, Inner.When_False));
               pragma Assert (Static => Same_Condition (Result, (Inner with delta After => Close)));
            end if;
            pragma Assert (Static => Same_Condition (Result, Expected));
            pragma Assert (Static => Result = Expected);
            pragma Assert (Static => Result = Primary_Model (Text, Context, Position, Facts, Initials => Initials));
         end;
         --  Parenthesized condition.
         pragma Assert (Static => Valid_Flow (Context, Result.When_True));
         pragma Assert (Static => Valid_Flow (Context, Result.When_False));
      elsif Boolean_Array_After (Text, Context, Position, Facts) /= 0 then
         Result.After := Boolean_Array_After (Text, Context, Position, Facts);
         Result.When_True := Facts;
         Result.When_False := Facts;
         pragma Assert (Static => Result = Primary_Model (Text, Context, Position, Facts, Initials => Initials));
      elsif Boolean_Atom_After (Text, Context, Position) /= 0 then
         Result.After := Boolean_Atom_After (Text, Context, Position);
         Result.When_True := Facts;
         Result.When_False := Facts;
         pragma Assert (Static => Result = Primary_Model (Text, Context, Position, Facts, Initials => Initials));
      elsif Context.Dynamic_First = 0 then
         Invalidate_Condition (Facts, Result);
         --  No dynamic argument context.
         pragma Assert (Static => Valid_Flow (Context, Result.When_True));
         pragma Assert (Static => Valid_Flow (Context, Result.When_False));
      else
         Result.After := Call_After (Text, Context.Names, Position, Names.Validity_Call, Context.Scalar_Names, Context.Array_Names, (Context.Subtype_Hiding (Names.Validity_Call)
                   or else (Context.Mask_First /= 0 and then Name_Is
                     (Text, Context.Mask_First, Context.Mask_After, Validity_Call_Word))), Context.Boolean_Names, Context.Context_First, Context.Package_First, Context.Package_After);
         Result.When_True := Facts;
         Result.When_False := Facts;
         if Result.After = 0 then
            Invalidate_Condition (Facts, Result);
         else
            Result.When_True.Path := Paths.Assume_Valid (Facts.Path);
            Result.When_False.Path := Paths.Assume_Invalid (Facts.Path);
         end if;
         pragma Assert (Static => Result = Primary_Model (Text, Context, Position, Facts, Initials => Initials));
         --  Input validity predicate.
         pragma Assert (Static => Valid_Flow (Context, Result.When_True));
         pragma Assert (Static => Valid_Flow (Context, Result.When_False));
      end if;
   end Read_Primary_Into;
   procedure Read_Boolean_Factor_Into
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Result : out Condition_Result;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts) and then Result.Count = Facts.Count,
       Post => (Runtime => Valid_Condition (Context, Result)
         and then (Result.After = 0 or else Result.After in Position + 1 .. Text'Last + 1),
         Static => Result = Boolean_Factor_Model (Text, Context, Position, Facts, Initials)),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 2);
   procedure Read_Boolean_Relation_Into
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Result : out Condition_Result;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts) and then Result.Count = Facts.Count,
       Post => (Runtime => Valid_Condition (Context, Result)
         and then (Result.After = 0 or else Result.After in Position + 1 .. Text'Last + 1),
         Static => Result = Boolean_Relation_Model (Text, Context, Position, Facts, Initials)),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 3);
   procedure Read_Boolean_Factor_Into
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Result : out Condition_Result;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values) is
      After : constant Literal_Position := Take_Token (Text, Position, Not_Keyword);
      Temporary_Path : Paths.Context;
      Temporary_Value : Scalars.Interval;
      Expected : constant Condition_Result (Facts.Count) :=
        Boolean_Factor_Model (Text, Context, Position, Facts, Initials) with Ghost => Static;
   begin
      if After = 0 then
         Read_Primary_Into (Text, Context, Position, Facts, Result, Initials);
      else
         declare
            Inner : constant Condition_Result (Facts.Count) :=
              Primary_Model (Text, Context, After, Facts, Initials => Initials) with Ghost => Static;
         begin
            --  Establish the selected model branch before changing the buffer.
            pragma Assert (Static => Same_Condition
              (Expected, (Facts.Count, Inner.After, Inner.When_False, Inner.When_True)));
            Read_Primary_Into (Text, Context, After, Facts, Result, Initials => Initials);
            Lemma_Condition_Equality (Result, Inner);
            Temporary_Path := Result.When_True.Path;
            Result.When_True.Path := Result.When_False.Path;
            Result.When_False.Path := Temporary_Path;
            for Index in Facts.Values'Range loop
               pragma Loop_Invariant (Static => Valid_Condition (Context, Result));
               pragma Loop_Invariant
                 (Static => (for all Done in Facts.Values'First .. Index - 1 =>
                   Result.When_True.Values (Done) = Result'Loop_Entry.When_False.Values (Done)
                   and then Result.When_False.Values (Done) = Result'Loop_Entry.When_True.Values (Done)));
               pragma Loop_Invariant
                 (Static => (for all Pending in Index .. Facts.Values'Last =>
                   Result.When_True.Values (Pending) = Result'Loop_Entry.When_True.Values (Pending)
                   and then Result.When_False.Values (Pending) = Result'Loop_Entry.When_False.Values (Pending)));
               pragma Loop_Invariant (Static => Result.After = Inner.After);
               pragma Loop_Invariant (Static => Same_Path (Result.When_True.Path, Inner.When_False.Path));
               pragma Loop_Invariant (Static => Same_Path (Result.When_False.Path, Inner.When_True.Path));
               pragma Loop_Invariant
                 (Static => (for all Done in Facts.Values'First .. Index - 1 =>
                   Same_Interval (Result.When_True.Values (Done), Inner.When_False.Values (Done))
                   and then Same_Interval (Result.When_False.Values (Done), Inner.When_True.Values (Done))));
               pragma Loop_Invariant
                 (Static => (for all Pending in Index .. Facts.Values'Last =>
                   Same_Interval (Result.When_True.Values (Pending), Inner.When_True.Values (Pending))
                   and then Same_Interval (Result.When_False.Values (Pending), Inner.When_False.Values (Pending))));
               Temporary_Value := Result.When_True.Values (Index);
               Result.When_True.Values (Index) := Result.When_False.Values (Index);
               Result.When_False.Values (Index) := Temporary_Value;
            end loop;
            pragma Assert (Static => Same_Values (Result.When_True.Values, Inner.When_False.Values));
            pragma Assert (Static => Same_Values (Result.When_False.Values, Inner.When_True.Values));
            pragma Assert (Static => Same_Flow (Result.When_True, Inner.When_False));
            pragma Assert (Static => Same_Flow (Result.When_False, Inner.When_True));
            pragma Assert (Static => Same_Condition
              (Result, (Facts.Count, Inner.After, Inner.When_False, Inner.When_True)));
            pragma Assert (Static => Same_Condition (Result, Expected));
         end;
         --  Negation: isolate both flow-validity obligations at this branch exit.
         pragma Assert (Static => Valid_Flow (Context, Result.When_True));
         pragma Assert (Static => Valid_Flow (Context, Result.When_False));
         pragma Assert (Static => Result = Expected);
      end if;
   end Read_Boolean_Factor_Into;
   procedure Read_Boolean_Relation_Into
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Result : out Condition_Result;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values) is
      Operator : Comparison_Result;
      Expected : constant Condition_Result (Facts.Count) :=
        Boolean_Relation_Model (Text, Context, Position, Facts, Initials) with Ghost => Static;
   begin
      Lemma_Condition_Equality
        (Expected, Boolean_Relation_Model (Text, Context, Position, Facts, Initials));
      Read_Boolean_Factor_Into (Text, Context, Position, Facts, Result, Initials);
      Lemma_Condition_Equality
        (Result, Boolean_Factor_Model (Text, Context, Position, Facts, Initials));
      if Result.After = 0 then
         pragma Assert (Static => Same_Condition (Expected, Invalid_Condition (Facts)));
         Invalidate_Condition (Facts, Result);
         Lemma_Condition_Equality (Result, Invalid_Condition (Facts));
         pragma Assert (Static => Same_Condition (Result, Expected));
         return;
      end if;
      Operator := Scalar_Comparison_At (Text, Result.After);
      if Operator.After = 0 then
         pragma Assert (Static => Same_Condition (Result, Expected));
         return;
      end if;
      if Operator.Operator not in Paths.Equal | Paths.Unequal then
         pragma Assert (Static => Same_Condition (Expected, Invalid_Condition (Facts)));
         Invalidate_Condition (Facts, Result);
         Lemma_Condition_Equality (Result, Invalid_Condition (Facts));
         pragma Assert (Static => Same_Condition (Result, Expected));
         return;
      end if;
      declare
         Right_Model : constant Condition_Result (Facts.Count) :=
           Boolean_Factor_Model (Text, Context, Operator.After, Facts, Initials) with Ghost => Static;
         Branch_Result : constant Condition_Result (Facts.Count) :=
           (if Right_Model.After = 0 then Invalid_Condition (Facts)
            else (Facts.Count, Right_Model.After, Facts, Facts)) with Ghost => Static;
      begin
         Lemma_Condition_Equality
           (Right_Model, Boolean_Factor_Model (Text, Context, Operator.After, Facts, Initials));
         Lemma_Condition_Equality
           (Branch_Result, (if Right_Model.After = 0 then Invalid_Condition (Facts)
                            else (Facts.Count, Right_Model.After, Facts, Facts)));
         pragma Assert (Static => Same_Condition (Expected, Branch_Result));
         Read_Boolean_Factor_Into (Text, Context, Operator.After, Facts, Result, Initials);
         Lemma_Condition_Equality
           (Result, Boolean_Factor_Model (Text, Context, Operator.After, Facts, Initials));
         pragma Assert (Static => Same_Condition (Result, Right_Model));
         if Result.After = 0 then
            Invalidate_Condition (Facts, Result);
            Lemma_Condition_Equality (Result, Invalid_Condition (Facts));
         else
            Result.When_True := Facts;
            Result.When_False := Facts;
         end if;
         pragma Assert (Static => Same_Condition (Result, Branch_Result));
      end;
      pragma Assert (Static => Same_Condition (Result, Expected));
   end Read_Boolean_Relation_Into;
   procedure Read_Relation_Into
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Result : out Condition_Result;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values) is
      After : constant Literal_Position := Take_Token (Text, Position, Not_Keyword);
      Left_Length : constant Length_Result := Length_At (Text, Context, Position, False);
      Left_Scalar : constant Scalar_Expressions.Expression_Result := Read_Scalar_In_Flow (Text, Context, Position, Facts, Initials => Initials);
      Expected : constant Condition_Result (Facts.Count) :=
        Relation_Model (Text, Context, Position, Facts, Initials => Initials) with Ghost => Static;
   begin
      Lemma_Condition_Equality
        (Expected, Relation_Model (Text, Context, Position, Facts, Initials => Initials));
      if Position = 0 then
         Invalidate_Condition (Facts, Result);
         --  Invalid input: isolate both flow-validity obligations at this branch exit.
         pragma Assert (Static => Valid_Flow (Context, Result.When_True));
         pragma Assert (Static => Valid_Flow (Context, Result.When_False));
         pragma Assert (Static => Result = Expected);
      elsif After /= 0 then
         Read_Boolean_Relation_Into (Text, Context, Position, Facts, Result, Initials);
         pragma Assert (Static => Result = Expected);
      elsif Left_Length.After /= 0 then
         declare
            Operator : constant Comparison_Result := Scalar_Comparison_At (Text, Left_Length.After);
            Right_Length : constant Length_Result := Length_At (Text, Context, Operator.After, True);
            Branch_Result : constant Condition_Result (Facts.Count) :=
              (if Right_Length.After <= Position then Invalid_Condition (Facts) else
                 (Count => Facts.Count, After => Right_Length.After,
                  When_True => (Facts with delta Path =>
                    Paths.Refine_Bounds (Facts.Path, Operator.Operator, Left_Length.Value, Right_Length.Value, True)),
                  When_False => (Facts with delta Path =>
                    Paths.Refine_Bounds (Facts.Path, Operator.Operator, Left_Length.Value, Right_Length.Value, False))))
              with Ghost => Static;
         begin
            pragma Assert (Static => Same_Condition (Expected, Branch_Result));
            if Right_Length.After <= Position then
               Invalidate_Condition (Facts, Result);
               Lemma_Condition_Equality (Result, Invalid_Condition (Facts));
            else
               Result.After := Right_Length.After;
               Result.When_True := Facts;
               Result.When_False := Facts;
               Result.When_True.Path := Paths.Refine_Bounds
                 (Facts.Path, Operator.Operator, Left_Length.Value, Right_Length.Value, True);
               Result.When_False.Path := Paths.Refine_Bounds
                 (Facts.Path, Operator.Operator, Left_Length.Value, Right_Length.Value, False);
            end if;
            pragma Assert (Static => Same_Condition (Result, Branch_Result));
            pragma Assert (Static => Same_Condition (Result, Expected));
         end;
         --  Length comparison: isolate both flow-validity obligations at this branch exit.
         pragma Assert (Static => Valid_Flow (Context, Result.When_True));
         pragma Assert (Static => Valid_Flow (Context, Result.When_False));
         pragma Assert (Static => Result = Expected);
      elsif Left_Scalar.After /= 0 then
         declare
            Operator : constant Comparison_Result := Scalar_Comparison_At (Text, Left_Scalar.After);
            Right_Scalar : constant Scalar_Expressions.Expression_Result :=
              Read_Scalar_In_Flow (Text, Context, Operator.After, Facts, Initials => Initials);
            Left_Target : constant Scalar_Expressions.Binding_Count := Bare_Target (Text, Context, Position, Left_Scalar.After);
            Right_Target : constant Scalar_Expressions.Binding_Count := Bare_Target (Text, Context, Operator.After, Right_Scalar.After);
            Target : Scalar_Expressions.Binding_Count := 0;
            Selected : Scalars.Comparison := Scalar_Operator (Operator.Operator);
            Threshold : Scalars.Value := Right_Scalar.Bounds.Lower;
            Branch_Result : constant Condition_Result (Facts.Count) :=
              (if Right_Scalar.After <= Position then Invalid_Condition (Facts) else
                 Scalar_Condition
                   (Text, Context, Position, Operator.After, Facts, Left_Scalar, Right_Scalar, Operator.Operator))
              with Ghost => Static;
         begin
            pragma Assert (Static => Same_Condition (Expected, Branch_Result));
            if Right_Scalar.After <= Position then
               Invalidate_Condition (Facts, Result);
               Lemma_Condition_Equality (Result, Invalid_Condition (Facts));
            else
               Result.After := Right_Scalar.After;
               Result.When_True := Facts;
               Result.When_False := Facts;
               if Left_Target /= 0 and then Right_Scalar.Static
                 and then Right_Scalar.Bounds.Lower = Right_Scalar.Bounds.Upper
               then
                  Target := Left_Target;
               elsif Right_Target /= 0 and then Left_Scalar.Static
                 and then Left_Scalar.Bounds.Lower = Left_Scalar.Bounds.Upper
               then
                  Target := Right_Target;
                  Selected := Scalars.Swap (Selected);
                  Threshold := Left_Scalar.Bounds.Lower;
               end if;
               if Target /= 0 then
                  Result.When_True.Values (Target) := Refine_Or_Keep (Facts.Values (Target), Selected, Threshold, True);
                  pragma Assert (Static =>
                    Result.When_True = Refined_Flow (Facts, Target, Selected, Threshold, True));
                  Lemma_Flow_Equality
                    (Result.When_True, Refined_Flow (Facts, Target, Selected, Threshold, True));
                  Result.When_False.Values (Target) := Refine_Or_Keep (Facts.Values (Target), Selected, Threshold, False);
                  pragma Assert (Static =>
                    Result.When_False = Refined_Flow (Facts, Target, Selected, Threshold, False));
               else
                  pragma Assert (Static =>
                    Result.When_True = Refined_Flow (Facts, Target, Selected, Threshold, True));
                  Lemma_Flow_Equality
                    (Result.When_True, Refined_Flow (Facts, Target, Selected, Threshold, True));
               end if;
               pragma Assert (Static =>
                 Result.When_True = Refined_Flow (Facts, Target, Selected, Threshold, True));
               Lemma_Flow_Equality
                 (Result.When_True, Refined_Flow (Facts, Target, Selected, Threshold, True));
               pragma Assert (Static => Same_Flow
                 (Result.When_True, Refined_Flow (Facts, Target, Selected, Threshold, True)));
               pragma Assert (Static =>
                 Result.When_False = Refined_Flow (Facts, Target, Selected, Threshold, False));
               Lemma_Flow_Equality
                 (Result.When_False, Refined_Flow (Facts, Target, Selected, Threshold, False));
               pragma Assert (Static => Same_Flow
                 (Result.When_False, Refined_Flow (Facts, Target, Selected, Threshold, False)));
               pragma Assert (Static => Result =
                 Scalar_Condition
                   (Text, Context, Position, Operator.After, Facts, Left_Scalar, Right_Scalar, Operator.Operator));
               Lemma_Condition_Equality (Result,
                 Scalar_Condition
                   (Text, Context, Position, Operator.After, Facts, Left_Scalar, Right_Scalar, Operator.Operator));
               pragma Assert (Static => Same_Condition (Result,
                 Scalar_Condition
                   (Text, Context, Position, Operator.After, Facts, Left_Scalar, Right_Scalar, Operator.Operator)));
            end if;
            pragma Assert (Static => Same_Condition (Result, Branch_Result));
            pragma Assert (Static => Same_Condition (Result, Expected));
         end;
         --  Scalar comparison: isolate both flow-validity obligations at this branch exit.
         pragma Assert (Static => Valid_Flow (Context, Result.When_True));
         pragma Assert (Static => Valid_Flow (Context, Result.When_False));
         pragma Assert (Static => Result = Expected);
      elsif Context.Pure then
         Read_Boolean_Relation_Into (Text, Context, Position, Facts, Result, Initials);
         pragma Assert (Static => Result = Expected);
      else
         declare Left : constant Expression_Result := Read_String_In_Flow (Text, Context, Position, Facts, Initials => Initials);
         begin
            if Left.After /= 0 then
               declare Operator : constant Comparison_Result := Scalar_Comparison_At (Text, Left.After);
               begin
                  if Operator.After = 0 or else Operator.Operator not in Paths.Equal | Paths.Unequal then
                     pragma Assert (Static => Same_Condition (Expected, Invalid_Condition (Facts)));
                     Invalidate_Condition (Facts, Result);
                     Lemma_Condition_Equality (Result, Invalid_Condition (Facts));
                  else
                     declare Right : constant Expression_Result := Read_String_In_Flow (Text, Context, Operator.After, Facts, Initials => Initials);
                     begin
                        if Right.After <= Position or else not (Left.Named_Seen or else Right.Named_Seen)
                          or else not Length_Intervals.Fits (Facts.Path, Summary_Of (Left))
                          or else not Length_Intervals.Fits (Facts.Path, Summary_Of (Right))
                        then
                           pragma Assert (Static => Same_Condition (Expected, Invalid_Condition (Facts)));
                           Invalidate_Condition (Facts, Result);
                           Lemma_Condition_Equality (Result, Invalid_Condition (Facts));
                        else
                           pragma Assert (Static => Same_Condition (Expected,
                             (Count => Facts.Count, After => Right.After,
                              When_True => (Facts with delta Path =>
                                (if Operator.Operator = Paths.Equal then
                                   Length_Intervals.Refine_Equal (Facts.Path, Summary_Of (Left), Summary_Of (Right))
                                 else Facts.Path)),
                              When_False => (Facts with delta Path =>
                                (if Operator.Operator = Paths.Equal then Facts.Path else
                                   Length_Intervals.Refine_Equal (Facts.Path, Summary_Of (Left), Summary_Of (Right)))))));
                           Result.After := Right.After;
                           Result.When_True := Facts;
                           Result.When_False := Facts;
                           if Operator.Operator = Paths.Equal then
                              Result.When_True.Path := Length_Intervals.Refine_Equal (Facts.Path, Summary_Of (Left), Summary_Of (Right));
                           else
                              Result.When_False.Path := Length_Intervals.Refine_Equal (Facts.Path, Summary_Of (Left), Summary_Of (Right));
                           end if;
                           pragma Assert (Static => Same_Condition (Result, Expected));
                        end if;
                     end;
                  end if;
               end;
            else
               declare Character_Result : constant Condition_Result :=
                 Character_Condition (Text, Context, Position, Facts, Initials);
               begin
                  if Character_Result.After /= 0 then
                     Result := Character_Result;
                     pragma Assert (Static => Same_Condition (Result, Expected));
                  else
                     pragma Assert (Static => Same_Condition (Expected, Boolean_Relation_Model (Text, Context, Position, Facts, Initials)));
                     Read_Boolean_Relation_Into (Text, Context, Position, Facts, Result, Initials);
                     Lemma_Condition_Equality (Result, Boolean_Relation_Model (Text, Context, Position, Facts, Initials));
                  end if;
               end;
            end if;
            pragma Assert (Static => Same_Condition (Result, Expected));
         end;
         --  String comparison or primary: isolate both flow-validity obligations at this branch exit.
         pragma Assert (Static => Valid_Flow (Context, Result.When_True));
         pragma Assert (Static => Valid_Flow (Context, Result.When_False));
         pragma Assert (Static => Result = Expected);
      end if;
      pragma Assert (Static => Result = Relation_Model (Text, Context, Position, Facts, Initials => Initials));
   end Read_Relation_Into;
   procedure Read_Chain_Into
     (Text : String; Context : Body_Context; Result : in out Condition_Result; Incoming : Scalar_Flow;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values;
      Original_Start : Literal_Position) is
      Active_Count : constant Scalar_Expressions.Binding_Count := Result.Count;
      Right : Condition_Result (Active_Count);
      Operator : Chain_Kind := Short_And;
      Chained : Boolean := False;
      Selected : Chain_Kind;
      After : Literal_Position;
   begin
      loop
         pragma Loop_Invariant (Result.After in 1 .. Text'Last + 1);
         pragma Loop_Invariant (Valid_Condition (Context, Result));
         pragma Loop_Invariant (Operator /= No_Chain);
         pragma Loop_Invariant (Result.After >= Result'Loop_Entry.After);
         pragma Loop_Invariant (Static =>
           Condition_Tail (Text, Context, Result'Loop_Entry, Short_And, False, Initials => Initials, Incoming => Incoming, Original_Start => Original_Start) =
             Condition_Tail (Text, Context, Result, Operator, Chained, Initials => Initials, Incoming => Incoming, Original_Start => Original_Start));
         pragma Loop_Invariant (Static => Same_Condition
           (Condition_Tail (Text, Context, Result'Loop_Entry, Short_And, False, Initials => Initials, Incoming => Incoming, Original_Start => Original_Start),
            Condition_Tail (Text, Context, Result, Operator, Chained, Initials => Initials, Incoming => Incoming, Original_Start => Original_Start)));
         pragma Loop_Variant (Increases => Result.After);
         declare
            Before : constant Condition_Result (Active_Count) := Result with Ghost => Static;
            Tail : constant Condition_Result (Active_Count) :=
              Condition_Tail (Text, Context, Before, Operator, Chained, Initials => Initials, Incoming => Incoming, Original_Start => Original_Start) with Ghost => Static;
         begin
            --  The checked logical equality retains the bounds of every array
            --  when the saved input is substituted into a model application.
            pragma Assert (Static => Same_Condition (Result, Before));
            Selected := Chain_Token (Text, Result.After);
            if Selected = No_Chain then
               pragma Assert (Static => Tail = Before);
               pragma Assert (Static => Same_Condition (Tail, Result));
               pragma Assert (Static =>
                 Condition_Tail (Text, Context, Before, Operator, Chained, Initials => Initials, Incoming => Incoming, Original_Start => Original_Start) = Before);
               exit;
            end if;
            if (Chained and then Operator /= Selected)
              or else (Selected = Eager_Xor
                and then not Xor_Free (Text, Original_Start, Result.After)) then
               Result.After := 0;
               Result.When_True.Path := Paths.Empty_Context;
               Result.When_False := Result.When_True;
               pragma Assert (Static => Result = Invalid_Condition (Before.When_True));
               pragma Assert (Static => Tail = Invalid_Condition (Before.When_True));
               pragma Assert (Static => Same_Condition (Result, Tail));
               pragma Assert (Static =>
                 Result = Condition_Tail (Text, Context, Before, Operator, Chained, Initials => Initials, Incoming => Incoming, Original_Start => Original_Start));
               return;
            end if;
            After := Chain_After (Text, Result.After, Selected);
            if After = 0 then
               Result.After := 0;
               Result.When_True.Path := Paths.Empty_Context;
               Result.When_False := Result.When_True;
               pragma Assert (Static => Result = Invalid_Condition (Before.When_True));
               pragma Assert (Static => Tail = Invalid_Condition (Before.When_True));
               pragma Assert (Static => Same_Condition (Result, Tail));
               pragma Assert (Static =>
                 Result = Condition_Tail (Text, Context, Before, Operator, Chained, Initials => Initials, Incoming => Incoming, Original_Start => Original_Start));
               return;
            end if;
            declare
               Right_Model : constant Condition_Result (Active_Count) :=
                 Relation_Model (Text, Context, After,
                   (if Selected = Short_And then Before.When_True
                    elsif Selected = Short_Or then Before.When_False else Incoming), Initials => Initials)
                 with Ghost => Static;
            begin
               --  Transport the ghost initializer before selecting a runtime input.
               Lemma_Condition_Equality
                 (Right_Model, Relation_Model (Text, Context, After,
                   (if Selected = Short_And then Before.When_True
                    elsif Selected = Short_Or then Before.When_False else Incoming), Initials => Initials));
               if Selected = Short_And then
                  pragma Assert (Static => Same_Flow (Result.When_True, Before.When_True));
                  pragma Assert (Static => Same_Condition
                    (Right_Model, Relation_Model (Text, Context, After, Result.When_True, Initials => Initials)));
                  Read_Relation_Into (Text, Context, After, Result.When_True, Right, Initials => Initials);
                  Lemma_Condition_Equality
                    (Right, Relation_Model (Text, Context, After, Result.When_True, Initials => Initials));
                  pragma Assert (Static => Same_Condition (Right, Right_Model));
               elsif Selected = Short_Or then
                  pragma Assert (Static => Same_Flow (Result.When_False, Before.When_False));
                  pragma Assert (Static => Same_Condition
                    (Right_Model, Relation_Model (Text, Context, After, Result.When_False, Initials => Initials)));
                  Read_Relation_Into (Text, Context, After, Result.When_False, Right, Initials => Initials);
                  Lemma_Condition_Equality
                    (Right, Relation_Model (Text, Context, After, Result.When_False, Initials => Initials));
                  pragma Assert (Static => Same_Condition (Right, Right_Model));
               else
                  Read_Relation_Into (Text, Context, After, Incoming, Right, Initials);
                  Lemma_Condition_Equality
                    (Right, Right_Model);
                  pragma Assert (Static => Same_Condition (Right, Right_Model));
               end if;
               pragma Assert (Static => Right = Right_Model);
               pragma Assert (Static => Same_Condition (Right, Right_Model));
               pragma Assert (Static => Right = Relation_Model (Text, Context, After,
                 (if Selected = Short_And then Before.When_True
                    elsif Selected = Short_Or then Before.When_False else Incoming), Initials => Initials));
               if Right.After = 0 or else (Selected = Eager_Xor
                         and then not Xor_Free (Text, After, Right.After)) then
                  Result.After := 0;
                  Result.When_True.Path := Paths.Empty_Context;
                  Result.When_False := Result.When_True;
                  pragma Assert (Static => Result = Invalid_Condition (Before.When_True));
                  pragma Assert (Static => Tail = Invalid_Condition (Before.When_True));
                  pragma Assert (Static => Same_Condition (Result, Tail));
                  pragma Assert (Static =>
                    Result = Condition_Tail (Text, Context, Before, Operator, Chained, Initials => Initials, Incoming => Incoming, Original_Start => Original_Start));
                  return;
               end if;
               declare
                  Combined : constant Condition_Result (Active_Count) :=
                    (if Selected = Short_And then
                       (Active_Count, Right.After, Right.When_True, Joined (Before.When_False, Right.When_False))
                     elsif Selected = Short_Or then
                       (Active_Count, Right.After, Joined (Before.When_True, Right.When_True), Right.When_False)
                     else (Active_Count, Right.After, Incoming, Incoming))
                    with Ghost => Static;
               begin
                  --  Preserve logical identity of the aggregate's joined flows.
                  Lemma_Condition_Equality
                    (Combined,
                     (if Selected = Short_And then
                        (Active_Count, Right.After, Right.When_True, Joined (Before.When_False, Right.When_False))
                      elsif Selected = Short_Or then
                        (Active_Count, Right.After, Joined (Before.When_True, Right.When_True), Right.When_False)
                      else (Active_Count, Right.After, Incoming, Incoming)));
                  if Selected = Short_And then
                     pragma Assert (Static => Same_Flow (Result.When_False, Before.When_False));
                     pragma Assert (Static => Same_Flow (Combined.When_True, Right.When_True));
                     pragma Assert (Static => Same_Flow
                       (Combined.When_False, Joined (Before.When_False, Right.When_False)));
                     Lemma_Joined_Flow (Context, Result.When_False, Right.When_False);
                     pragma Assert (Static => Valid_Flow (Context, Combined.When_True));
                     pragma Assert (Static => Valid_Flow (Context, Combined.When_False));
                     Result.When_True := Right.When_True;
                     Lemma_Flow_Equality (Result.When_True, Right.When_True);
                     declare
                        Join_Input : constant Scalar_Flow (Active_Count) :=
                          Result.When_False with Ghost => Static;
                     begin
                        Lemma_Flow_Equality (Join_Input, Result.When_False);
                        pragma Assert (Static => Same_Flow (Join_Input, Before.When_False));
                        Join_Into (Result.When_False, Right.When_False);
                        Lemma_Join_Identity
                          (Result.When_False, Join_Input, Right.When_False);
                        pragma Assert (Static => Same_Flow
                          (Result.When_False, Joined (Before.When_False, Right.When_False)));
                     end;
                     pragma Assert (Static =>
                       Result.When_False = Joined (Before.When_False, Right.When_False));
                     Lemma_Flow_Equality
                       (Result.When_False, Joined (Before.When_False, Right.When_False));
                  elsif Selected = Short_Or then
                     pragma Assert (Static => Same_Flow (Result.When_True, Before.When_True));
                     pragma Assert (Static => Same_Flow
                       (Combined.When_True, Joined (Before.When_True, Right.When_True)));
                     pragma Assert (Static => Same_Flow (Combined.When_False, Right.When_False));
                     Lemma_Joined_Flow (Context, Result.When_True, Right.When_True);
                     pragma Assert (Static => Valid_Flow (Context, Combined.When_True));
                     pragma Assert (Static => Valid_Flow (Context, Combined.When_False));
                     declare
                        Join_Input : constant Scalar_Flow (Active_Count) :=
                          Result.When_True with Ghost => Static;
                     begin
                        Lemma_Flow_Equality (Join_Input, Result.When_True);
                        pragma Assert (Static => Same_Flow (Join_Input, Before.When_True));
                        Join_Into (Result.When_True, Right.When_True);
                        Lemma_Join_Identity
                          (Result.When_True, Join_Input, Right.When_True);
                        pragma Assert (Static => Same_Flow
                          (Result.When_True, Joined (Before.When_True, Right.When_True)));
                     end;
                     pragma Assert (Static =>
                       Result.When_True = Joined (Before.When_True, Right.When_True));
                     Lemma_Flow_Equality
                       (Result.When_True, Joined (Before.When_True, Right.When_True));
                     Result.When_False := Right.When_False;
                     Lemma_Flow_Equality (Result.When_False, Right.When_False);
                  else
                     Result.When_True := Incoming;
                     Result.When_False := Incoming;
                     Lemma_Flow_Equality (Result.When_True, Incoming);
                     Lemma_Flow_Equality (Result.When_False, Incoming);
                  end if;
                  pragma Assert (Static => Same_Flow (Result.When_True, Combined.When_True));
                  pragma Assert (Static => Same_Flow (Result.When_False, Combined.When_False));
                  Result.After := Right.After;
                  pragma Assert (Static => Result = Combined);
                  pragma Assert (Static => Same_Condition (Result, Combined));
                  pragma Assert (Static => Valid_Condition (Context, Result));
                  pragma Assert (Static => Result =
                    (if Selected = Short_And then
                       (Active_Count, Right.After, Right.When_True, Joined (Before.When_False, Right.When_False))
                     elsif Selected = Short_Or then
                       (Active_Count, Right.After, Joined (Before.When_True, Right.When_True), Right.When_False)
                     else (Active_Count, Right.After, Incoming, Incoming)));
                  pragma Assert (Static => Tail =
                    Condition_Tail (Text, Context, Combined, Selected, True, Initials => Initials, Incoming => Incoming, Original_Start => Original_Start));
                  pragma Assert (Static => Same_Condition
                    (Tail, Condition_Tail (Text, Context, Result, Selected, True, Initials => Initials, Incoming => Incoming, Original_Start => Original_Start)));
                  pragma Assert (Static =>
                    Condition_Tail (Text, Context, Before, Operator, Chained, Initials => Initials, Incoming => Incoming, Original_Start => Original_Start) =
                      Condition_Tail (Text, Context, Result, Selected, True, Initials => Initials, Incoming => Incoming, Original_Start => Original_Start));
               end;
            end;
            Operator := Selected;
            Chained := True;
         end;
      end loop;
   end Read_Chain_Into;
   procedure Read_Condition_Into
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Result : out Condition_Result;
      Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values) is
      Initial_Result : constant Condition_Result (Facts.Count) :=
        Relation_Model (Text, Context, Position, Facts, Initials => Initials) with Ghost => Static;
      --  The raw result before the final invalidation follows the same guarded
      --  tail call as the model; a failed relation keeps its initial record.
      Final_Result : constant Condition_Result (Facts.Count) :=
        (if Initial_Result.After = 0 then Initial_Result
         else Condition_Tail (Text, Context, Initial_Result, Short_And, False, Initials => Initials, Incoming => Facts, Original_Start => Position))
        with Ghost => Static;
      Expected : constant Condition_Result (Facts.Count) :=
        Condition_Model (Text, Context, Position, Facts, Initials => Initials) with Ghost => Static;
   begin
      --  Isolate the model definition from the runtime result's later updates.
      pragma Assert (Static => Expected =
        (if Final_Result.After = 0 then Invalid_Condition (Facts) else Final_Result));
      Lemma_Condition_Equality
        (Expected,
         (if Final_Result.After = 0 then Invalid_Condition (Facts) else Final_Result));
      pragma Assert (Static => Same_Condition
        (Expected,
         (if Final_Result.After = 0 then Invalid_Condition (Facts) else Final_Result)));
      Read_Relation_Into (Text, Context, Position, Facts, Result, Initials => Initials);
      pragma Assert (Static => Result = Initial_Result);
      Lemma_Condition_Equality (Result, Initial_Result);
      pragma Assert (Static => Same_Condition (Result, Initial_Result));
      pragma Assert (Static => Valid_Flow (Context, Result.When_True));
      pragma Assert (Static => Valid_Flow (Context, Result.When_False));
      if Result.After /= 0 then
         declare
            Tail_Result : constant Condition_Result (Facts.Count) :=
              Condition_Tail (Text, Context, Initial_Result, Short_And, False, Initials => Initials, Incoming => Facts, Original_Start => Position)
              with Ghost => Static;
         begin
            Lemma_Condition_Equality
              (Tail_Result, Condition_Tail (Text, Context, Initial_Result, Short_And, False, Initials => Initials, Incoming => Facts, Original_Start => Position));
            --  Select Final_Result's nonzero branch before the buffer changes.
            pragma Assert (Static => Initial_Result.After /= 0);
            pragma Assert (Static => Final_Result = Tail_Result);
            Lemma_Condition_Equality (Final_Result, Tail_Result);
            if Chain_Token (Text, Result.After) /= No_Chain then
               Read_Chain_Into (Text, Context, Result, Initials => Initials, Incoming => Facts, Original_Start => Position);
               --  The exact chain post now transports across logical equality
               --  of its saved input and the already interpreted relation result.
               pragma Assert (Static =>
                 Result = Condition_Tail (Text, Context, Initial_Result, Short_And, False, Initials => Initials, Incoming => Facts, Original_Start => Position));
               pragma Assert (Static => Valid_Flow (Context, Result.When_True));
               pragma Assert (Static => Valid_Flow (Context, Result.When_False));
            else
               pragma Assert (Static =>
                 Condition_Tail (Text, Context, Initial_Result, Short_And, False, Initials => Initials, Incoming => Facts, Original_Start => Position) = Initial_Result);
               pragma Assert (Static => Valid_Flow (Context, Result.When_True));
               pragma Assert (Static => Valid_Flow (Context, Result.When_False));
            end if;
            pragma Assert (Static =>
              Result = Condition_Tail (Text, Context, Initial_Result, Short_And, False, Initials => Initials, Incoming => Facts, Original_Start => Position));
            Lemma_Condition_Equality
              (Result, Condition_Tail (Text, Context, Initial_Result, Short_And, False, Initials => Initials, Incoming => Facts, Original_Start => Position));
            pragma Assert (Static => Same_Condition (Result, Tail_Result));
            pragma Assert (Static => Result = Tail_Result);
            Lemma_Condition_Equality (Result, Tail_Result);
            pragma Assert (Static => Same_Condition (Result, Final_Result));
            pragma Assert (Static => Result = Final_Result);
         end;
      else
         pragma Assert (Static => Initial_Result.After = 0);
         pragma Assert (Static => Final_Result = Initial_Result);
         Lemma_Condition_Equality (Final_Result, Initial_Result);
         pragma Assert (Static => Same_Condition (Result, Initial_Result));
         pragma Assert (Static => Same_Condition (Result, Final_Result));
         pragma Assert (Static => Result = Final_Result);
      end if;
      pragma Assert (Static => Result = Final_Result);
      Lemma_Condition_Equality (Result, Final_Result);
      pragma Assert (Static => Same_Condition (Result, Final_Result));
      if Result.After = 0 then
         Invalidate_Condition (Facts, Result);
         Lemma_Condition_Equality (Result, Invalid_Condition (Facts));
         pragma Assert (Static => Same_Condition (Result, Invalid_Condition (Facts)));
         pragma Assert (Static => Valid_Flow (Context, Result.When_True));
         pragma Assert (Static => Valid_Flow (Context, Result.When_False));
      else
         pragma Assert (Static => Valid_Flow (Context, Result.When_True));
         pragma Assert (Static => Valid_Flow (Context, Result.When_False));
      end if;
      pragma Assert (Static => Same_Condition (Result, Expected));
      pragma Assert (Static => Result = Expected);
      pragma Assert (Static => Result = Condition_Model (Text, Context, Position, Facts, Initials => Initials));
   end Read_Condition_Into;

   function Boolean_Initializer_Model
     (Text : String; State : Parser_State; Position, Mask_First, Mask_After : Literal_Position)
      return Literal_Position is
     (declare Context : constant Body_Context :=
        (Context_Of ((State, False, False)) with delta Scalar_Names => State.Scalar_Names,
          Elaborating => True, Mask_First => Mask_First, Mask_After => Mask_After);
      begin Condition_Model
        (Text, Context, Position, Initial_Flow (Context), State.Array_Names.Values).After);

   function Boolean_Initializer_After
     (Text : String; State : Parser_State; Position, Mask_First, Mask_After : Literal_Position)
      return Literal_Position is
      Context : constant Body_Context :=
        (Context_Of ((State, False, False)) with delta Scalar_Names => State.Scalar_Names,
          Elaborating => True, Mask_First => Mask_First, Mask_After => Mask_After);
      Value : Condition_Result (State.Scalar_Names.Count);
   begin
      Read_Condition_Into
        (Text, Context, Position, Initial_Flow (Context), Value, State.Array_Names.Values);
      return Value.After;
   end Boolean_Initializer_After;

   function Boolean_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
      First : constant Literal_Position := Skip_At (Text, State.Position);
      After : constant Literal_Position := Name_After (Text, First);
      Colon_After : constant Literal_Position := Take_Token (Text, After, Colon);
      Constant_After : constant Literal_Position := Take_Token (Text, Colon_After, Constant_Keyword);
      Type_First : constant Literal_Position := Skip_At
        (Text, (if Constant_After /= 0 then Constant_After else Colon_After));
      Type_After : constant Literal_Position := Take_Token (Text, Type_First, Boolean_Name);
      Value_First : constant Literal_Position := Take_Token (Text, Type_After, Assignment);
      Context : Body_Context := Context_Of ((State, False, False));
      Value : Condition_Result (State.Scalar_Names.Count);
      Following : Literal_Position;
   begin
      if not New_Name_Allowed (Text, State, First, After, Arguments)
        or else Type_After = 0 or else Value_First = 0
        or else State.Boolean_Names.Count = Max_Boolean_Bindings
        or else Name_Is (Text, First, After, "boolean")
        or else Lookup_Name (Text, State.Names, Type_First, Type_After) /= 0
        or else Scalar_Expressions.Lookup (Text, State.Scalar_Names, Type_First, Type_After) /= 0
        or else Array_Bindings.Lookup (Text, State.Array_Names.Names, Type_First, Type_After) /= 0
           or else Array_Bindings.Lookup_Type (Text, State.Array_Names.Names.Types, Type_First, Type_After) /= 0
        or else Lookup_Subtype (Text, State.Subtype_Names, Type_First, Type_After) /= 0
        or else Lookup_Boolean (Text, State.Boolean_Names, Type_First, Type_After) /= 0
           or else Functions.Lookup (Text, State.Functions, Type_First, Type_After) /= 0
           or else Procedures.Lookup (Text, State.Procedures, Type_First, Type_After) /= 0
           or else Formal_Hides (Text, State, Type_First, Type_After)
           or else (State.Hiding.Integer_Hidden and then Name_Is (Text, Type_First, Type_After, "integer"))
           or else (State.Hiding.Boolean_Hidden and then Name_Is (Text, Type_First, Type_After, "boolean"))
           or else (State.Hiding.Character_Hidden and then Name_Is (Text, Type_First, Type_After, "character"))
      then return Invalid_State; end if;
      Context.Scalar_Names := State.Scalar_Names;
      Context.Elaborating := True;
      Context.Mask_First := First;
      Context.Mask_After := After;
      Read_Condition_Into
        (Text, Context, Value_First, Initial_Flow (Context), Value, State.Array_Names.Values);
      Following := Take_Token (Text, Value.After, Semicolon);
      if Following <= State.Position then return Invalid_State; end if;
      return (State with delta Position => Following,
        Boolean_Names =>
          (Count => State.Boolean_Names.Count + 1,
           Items => (State.Boolean_Names.Items with delta State.Boolean_Names.Count + 1 =>
             (First, After, Constant_After = 0, 0, 0, False, False))));
   end Boolean_Declaration_At;

   function Boolean_Target
     (Text : String; Context : Body_Context; Position : Literal_Position) return Boolean_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Position <= Text'Last + 1,
       Post => Boolean_Target'Result <= Context.Boolean_Names.Count;
   function Boolean_Target
     (Text : String; Context : Body_Context; Position : Literal_Position) return Boolean_Count is
     (declare First : constant Literal_Position := Skip_At (Text, Position);
              After : constant Literal_Position := Name_After (Text, First);
      begin (if Scalar_Expressions.Lookup (Text, Context.Scalar_Names, First, After) /= 0
        then 0 else Lookup_Boolean (Text, Context.Boolean_Names, First, After)));

   function Boolean_Assignment_Model
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Boolean_Assignment_Model'Result)
         and then (Boolean_Assignment_Model'Result.Position = 0
           or else Boolean_Assignment_Model'Result.Position > Scan.Position);
   function Boolean_Assignment_Model
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan is
     (declare First : constant Literal_Position := Skip_At (Text, Scan.Position);
              After : constant Literal_Position := Name_After (Text, First);
              Target : constant Boolean_Count := Boolean_Target (Text, Context, Scan.Position);
              Value : constant Condition_Result (Scan.Count) := Condition_Model
                (Text, Context, Take_Token (Text, After, Assignment), Scan.Facts);
      begin (if Target = 0 or else not Context.Boolean_Names.Items (Target).Mutable
        or else Value.After <= Scan.Position then Invalid_Body_Model (Scan)
        else (Scan with delta Position => Value.After, Assigned => True)));

   function Boolean_Assignment_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => (Runtime => Valid_Body (Text, Context, Boolean_Assignment_Body'Result)
         and then (Boolean_Assignment_Body'Result.Position = 0
           or else Boolean_Assignment_Body'Result.Position > Scan.Position),
         Static => Boolean_Assignment_Body'Result = Boolean_Assignment_Model (Text, Context, Scan));
   function Boolean_Assignment_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan is
      First : constant Literal_Position := Skip_At (Text, Scan.Position);
      After : constant Literal_Position := Name_After (Text, First);
      Target : constant Boolean_Count := Boolean_Target (Text, Context, Scan.Position);
      Value : Condition_Result (Scan.Count);
   begin
      Read_Condition_Into (Text, Context, Take_Token (Text, After, Assignment), Scan.Facts, Value);
      if Target = 0 or else not Context.Boolean_Names.Items (Target).Mutable
        or else Value.After <= Scan.Position
      then return Invalid_Body (Scan); end if;
      return (Scan with delta Position => Value.After, Assigned => True);
   end Boolean_Assignment_Body;

   function Scalar_Target
     (Text : String; Context : Body_Context; Position : Literal_Position)
      return Scalar_Expressions.Binding_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Position <= Text'Last + 1,
       Post => Scalar_Target'Result <= Context.Scalar_Names.Count;
   function Scalar_Target
     (Text : String; Context : Body_Context; Position : Literal_Position)
      return Scalar_Expressions.Binding_Count is
     (declare First : constant Literal_Position := Skip_At (Text, Position);
      After : constant Literal_Position := Name_After (Text, First);
      begin Scalar_Expressions.Lookup (Text, Context.Scalar_Names, First, After));

   type String_Target_Result is record
      After : Literal_Position;
      Target : Binding_Count;
   end record;
   function Body_String_Target
     (Text : String; Context : Body_Context; Position : Literal_Position)
      return String_Target_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Position <= Text'Last + 1,
       Post => Body_String_Target'Result.Target <= Context.Names.Count
         and then (Body_String_Target'Result.After = 0
           or else Body_String_Target'Result.After in Position + 1 .. Text'Last + 1);
   function Body_String_Target
     (Text : String; Context : Body_Context; Position : Literal_Position)
      return String_Target_Result is
     (declare First : constant Literal_Position := Skip_At (Text, Position);
      After : constant Literal_Position := Name_After (Text, First);
      Index : constant Binding_Count := Lookup_Name (Text, Context.Names, First, After);
      begin
        (if Index = 0
          or else Scalar_Expressions.Lookup (Text, Context.Scalar_Names, First, After) /= 0
          or else not Context.Names.Items (Index).Mutable
         then (0, 0) else (After, Index)));

   function Scalar_Assignment_Model
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Scalar_Assignment_Model'Result)
         and then (Scalar_Assignment_Model'Result.Position = 0
           or else Scalar_Assignment_Model'Result.Position > Scan.Position);
   function Scalar_Assignment_Model
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan is
     (declare First : constant Literal_Position := Skip_At (Text, Scan.Position);
      After : constant Literal_Position := Name_After (Text, First);
      Target : constant Scalar_Expressions.Binding_Count :=
        Scalar_Expressions.Lookup (Text, Context.Scalar_Names, First, After);
      Value : constant Scalar_Expressions.Expression_Result :=
        Read_Scalar_In_Flow
          (Text, Context, Take_Token (Text, After, Assignment), Scan.Facts);
      begin
        (if Target = 0 or else not Context.Scalar_Names.Items (Target).Mutable
           or else Value.After <= Scan.Position
           or else Scalars.Is_Empty (Value.Bounds)
           or else Value.Bounds.Lower < Context.Scalar_Names.Items (Target).Declared_Bounds.Lower
           or else Value.Bounds.Upper > Context.Scalar_Names.Items (Target).Declared_Bounds.Upper
         then Invalid_Body_Model (Scan)
         else (Scan with delta Position => Value.After, Assigned => True,
           Facts => (Scan.Facts with delta Values => (Scan.Facts.Values with delta Target => Value.Bounds)))));

   function Scalar_Assignment_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => (Runtime => Valid_Body (Text, Context, Scalar_Assignment_Body'Result)
         and then (Scalar_Assignment_Body'Result.Position = 0
           or else Scalar_Assignment_Body'Result.Position > Scan.Position),
         Static => Scalar_Assignment_Body'Result = Scalar_Assignment_Model (Text, Context, Scan));
   function Scalar_Assignment_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan is
      First : constant Literal_Position := Skip_At (Text, Scan.Position);
      After : constant Literal_Position := Name_After (Text, First);
      Target : constant Scalar_Expressions.Binding_Count :=
        Scalar_Expressions.Lookup (Text, Context.Scalar_Names, First, After);
      Value : constant Scalar_Expressions.Expression_Result :=
        Read_Scalar_In_Flow (Text, Context, Take_Token (Text, After, Assignment), Scan.Facts);
   begin
      if Target = 0 or else not Context.Scalar_Names.Items (Target).Mutable
        or else Value.After <= Scan.Position or else Scalars.Is_Empty (Value.Bounds)
        or else Value.Bounds.Lower < Context.Scalar_Names.Items (Target).Declared_Bounds.Lower
        or else Value.Bounds.Upper > Context.Scalar_Names.Items (Target).Declared_Bounds.Upper
      then return Invalid_Body (Scan); end if;
      return Result : Body_Scan (Scan.Count) do
         Result := Scan;
         Result.Position := Value.After;
         Result.Assigned := True;
         Result.Facts.Values (Target) := Value.Bounds;
      end return;
   end Scalar_Assignment_Body;

   function Array_Target
     (Text : String; Context : Body_Context; Position : Literal_Position)
      return Array_Bindings.Binding_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Position <= Text'Last + 1,
       Post => Array_Target'Result <= Context.Array_Names.Count;
   function Array_Target
     (Text : String; Context : Body_Context; Position : Literal_Position)
      return Array_Bindings.Binding_Count is
     (declare First : constant Literal_Position := Skip_At (Text, Position);
              After : constant Literal_Position := Name_After (Text, First);
      begin (if Scalar_Expressions.Lookup (Text, Context.Scalar_Names, First, After) /= 0
             then 0 else Array_Bindings.Lookup (Text, Context.Array_Names, First, After)));

   function Array_Assignment_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Array_Assignment_Body'Result)
         and then (Array_Assignment_Body'Result.Position = 0
           or else Array_Assignment_Body'Result.Position > Scan.Position);
   function Array_Assignment_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan is
      First : constant Literal_Position := Skip_At (Text, Scan.Position);
      After : constant Literal_Position := Name_After (Text, First);
      Target : constant Array_Bindings.Binding_Count := Array_Target (Text, Context, Scan.Position);
      Subscript : constant Scalar_Expressions.Expression_Result := Scalar_Expressions.Read_Expression
        (Text, Take_Token (Text, After, Left_Parenthesis), Reading_Names (Context, Scan.Facts),
         Arrays => Context.Array_Names, Array_Reads => Scalar_Expressions.No_Elements);
      Value : constant Scalar_Expressions.Expression_Result := Read_Scalar_In_Flow
        (Text, Context, Take_Token (Text, Take_Token (Text, Subscript.After, Right_Parenthesis), Assignment), Scan.Facts);
   begin
      if Target = 0 or else not Context.Array_Names.Items (Target).Mutable
        or else Context.Array_Names.Items (Target).Boolean_Elements
        or else not Array_Bindings.Contains (Context.Array_Names.Items (Target), Subscript.Bounds)
        or else Subscript.Operands = Scalar_Expressions.Max_Operands
        or else Value.After <= Scan.Position or else Scalars.Is_Empty (Value.Bounds)
        or else Value.Bounds.Lower < Context.Array_Names.Items (Target).Component_Bounds.Lower
        or else Value.Bounds.Upper > Context.Array_Names.Items (Target).Component_Bounds.Upper
      then return Invalid_Body (Scan); end if;
      return (Scan with delta Position => Value.After, Assigned => True);
   end Array_Assignment_Body;

   function Boolean_Array_Assignment_Model
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Boolean_Array_Assignment_Model'Result)
         and then (Boolean_Array_Assignment_Model'Result.Position = 0
           or else Boolean_Array_Assignment_Model'Result.Position > Scan.Position);
   function Boolean_Array_Assignment_Model
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan is
     (declare Target : constant Array_Bindings.Binding_Count := Array_Target (Text, Context, Scan.Position);
              Target_After : constant Literal_Position :=
                Boolean_Array_After (Text, Context, Scan.Position, Scan.Facts);
              Value : constant Condition_Result (Scan.Count) := Condition_Model
                (Text, Context, Take_Token (Text, Target_After, Assignment), Scan.Facts);
      begin
        (if Target = 0 or else not Context.Array_Names.Items (Target).Boolean_Elements
           or else not Context.Array_Names.Items (Target).Mutable or else Target_After = 0
           or else Value.After <= Scan.Position then Invalid_Body_Model (Scan)
         else (Scan with delta Position => Value.After, Assigned => True)));

   function Boolean_Array_Assignment_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => (Runtime => Valid_Body (Text, Context, Boolean_Array_Assignment_Body'Result)
         and then (Boolean_Array_Assignment_Body'Result.Position = 0
           or else Boolean_Array_Assignment_Body'Result.Position > Scan.Position),
         Static => Boolean_Array_Assignment_Body'Result = Boolean_Array_Assignment_Model (Text, Context, Scan));
   function Boolean_Array_Assignment_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan is
      Target : constant Array_Bindings.Binding_Count := Array_Target (Text, Context, Scan.Position);
      Target_After : constant Literal_Position :=
        Boolean_Array_After (Text, Context, Scan.Position, Scan.Facts);
      Value : Condition_Result (Scan.Count);
   begin
      Read_Condition_Into
        (Text, Context, Take_Token (Text, Target_After, Assignment), Scan.Facts, Value);
      if Target = 0 or else not Context.Array_Names.Items (Target).Boolean_Elements
        or else not Context.Array_Names.Items (Target).Mutable or else Target_After = 0
        or else Value.After <= Scan.Position then return Invalid_Body (Scan); end if;
      return (Scan with delta Position => Value.After, Assigned => True);
   end Boolean_Array_Assignment_Body;

   function Array_Actual_After
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Type_Id : Array_Bindings.Type_Count) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context),
       Post => Array_Actual_After'Result = 0
         or else Array_Actual_After'Result in Position + 1 .. Text'Last + 1;
   function Array_Actual_After
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Type_Id : Array_Bindings.Type_Count) return Literal_Position is
     (declare First : constant Literal_Position := Skip_At (Text, Position);
       After : constant Literal_Position := Name_After (Text, First);
       Target : constant Array_Bindings.Binding_Count := Array_Target (Text, Context, Position);
      begin (if Type_Id = 0 or else Target = 0
        or else Context.Array_Names.Items (Target).Type_Id /= Type_Id
       then 0 else After));

   function Actual_Model
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Parameter : Functions.Formal) return Literal_Position
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts),
       Post => Actual_Model'Result = 0
         or else Actual_Model'Result in Position + 1 .. Text'Last + 1;
   function Actual_Model
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Parameter : Functions.Formal) return Literal_Position is
     (if Parameter.Type_Id /= 0 then Array_Actual_After (Text, Context, Position, Parameter.Type_Id)
      elsif Parameter.Kind = Functions.Boolean_Kind then
        Condition_Model (Text, Context, Position, Facts).After
      else (declare Value : constant Scalar_Expressions.Expression_Result :=
        Read_Scalar_In_Flow (Text, Context, Position, Facts);
       begin (if Value.After = 0 or else Scalars.Is_Empty (Value.Bounds)
          or else not Included (Value.Bounds, Parameter.Bounds)
         then 0 else Value.After)));
   function Actual_After
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Parameter : Functions.Formal) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts),
       Post => (Runtime => Actual_After'Result = 0
         or else Actual_After'Result in Position + 1 .. Text'Last + 1,
         Static => Actual_After'Result = Actual_Model (Text, Context, Position, Facts, Parameter));
   function Actual_After
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Parameter : Functions.Formal) return Literal_Position is
   begin
      if Parameter.Type_Id /= 0 then
         return Array_Actual_After (Text, Context, Position, Parameter.Type_Id);
      elsif Parameter.Kind = Functions.Boolean_Kind then
         declare Value : Condition_Result (Facts.Count);
         begin
            Read_Condition_Into (Text, Context, Position, Facts, Value);
            return Value.After;
         end;
      else
         declare Value : constant Scalar_Expressions.Expression_Result :=
           Read_Scalar_In_Flow (Text, Context, Position, Facts);
         begin
            return (if Value.After = 0 or else Scalars.Is_Empty (Value.Bounds)
              or else not Included (Value.Bounds, Parameter.Bounds) then 0 else Value.After);
         end;
      end if;
   end Actual_After;

   --  Each formal consumes at least seven disjoint source bytes. This set
   --  records selected formal slots, without copying actuals or their source.
   type Formal_Set is array (Functions.Formal_Index) of Boolean;
   No_Formals : constant Formal_Set := (others => False);
   function Mark_Formal (Seen : Formal_Set; Formal : Functions.Formal_Index) return Formal_Set
     with Global => null,
       Post => (for all Index in Functions.Formal_Index =>
         Mark_Formal'Result (Index) = (if Index = Formal then True else Seen (Index)));
   function Mark_Formal (Seen : Formal_Set; Formal : Functions.Formal_Index) return Formal_Set is
     (Seen with delta Formal => True);
   type Actual_Association is record
      Formal : Functions.Formal_Count;
      Payload_First : Literal_Position;
      Named : Boolean;
   end record;
   Invalid_Association : constant Actual_Association := (0, 0, False);

   function Function_Formal_Model
     (Text : String; Catalog : Functions.Metadata; First, Last : Functions.Formal_Index;
      Name_First, Name_After : Literal_Position) return Functions.Formal_Count
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Functions.Valid_Metadata (Text, Catalog)
         and then First <= Last and then Last <= Catalog.Parameter_Count
         and then Name_First <= Text'Last + 1 and then Name_After <= Text'Last + 1,
       Post => Function_Formal_Model'Result = 0
         or else Function_Formal_Model'Result in First .. Last,
       Subprogram_Variant => (Decreases => Last - First);
   function Function_Formal_Model
     (Text : String; Catalog : Functions.Metadata; First, Last : Functions.Formal_Index;
      Name_First, Name_After : Literal_Position) return Functions.Formal_Count is
     (if Name_First = 0 or else Name_After <= Name_First then 0
      elsif Equal_Name (Text, Catalog.Parameters (First).First,
                        Catalog.Parameters (First).After, Name_First, Name_After)
      then First
      elsif First = Last then 0
      else Function_Formal_Model (Text, Catalog, First + 1, Last, Name_First, Name_After));
   function Function_Formal_At
     (Text : String; Catalog : Functions.Metadata; First, Last : Functions.Formal_Index;
      Name_First, Name_After : Literal_Position) return Functions.Formal_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Functions.Valid_Metadata (Text, Catalog)
         and then First <= Last and then Last <= Catalog.Parameter_Count
         and then Name_First <= Text'Last + 1 and then Name_After <= Text'Last + 1,
       Post => (Runtime => Function_Formal_At'Result = 0
         or else Function_Formal_At'Result in First .. Last,
         Static => Function_Formal_At'Result =
           Function_Formal_Model (Text, Catalog, First, Last, Name_First, Name_After));
   function Function_Formal_At
     (Text : String; Catalog : Functions.Metadata; First, Last : Functions.Formal_Index;
      Name_First, Name_After : Literal_Position) return Functions.Formal_Count is
      Index : Functions.Formal_Index := First;
   begin
      if Name_First = 0 or else Name_After <= Name_First then return 0; end if;
      loop
         pragma Loop_Invariant (Index in First .. Last);
         pragma Loop_Invariant (Static =>
           Function_Formal_Model (Text, Catalog, First, Last, Name_First, Name_After) =
             Function_Formal_Model (Text, Catalog, Index, Last, Name_First, Name_After));
         pragma Loop_Variant (Increases => Index);
         if Equal_Name (Text, Catalog.Parameters (Index).First,
                        Catalog.Parameters (Index).After, Name_First, Name_After)
         then return Index; end if;
         if Index = Last then return 0; end if;
         Index := Index + 1;
      end loop;
   end Function_Formal_At;

   function Procedure_Formal_Model
     (Text : String; Catalog : Procedures.Metadata; First, Last : Procedures.Formal_Index;
      Name_First, Name_After : Literal_Position) return Procedures.Formal_Count
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Procedures.Valid_Metadata (Text, Catalog)
         and then First <= Last and then Last <= Catalog.Parameter_Count
         and then Name_First <= Text'Last + 1 and then Name_After <= Text'Last + 1,
       Post => Procedure_Formal_Model'Result = 0
         or else Procedure_Formal_Model'Result in First .. Last,
       Subprogram_Variant => (Decreases => Last - First);
   function Procedure_Formal_Model
     (Text : String; Catalog : Procedures.Metadata; First, Last : Procedures.Formal_Index;
      Name_First, Name_After : Literal_Position) return Procedures.Formal_Count is
     (if Name_First = 0 or else Name_After <= Name_First then 0
      elsif Equal_Name (Text, Catalog.Parameters (First).First,
                        Catalog.Parameters (First).After, Name_First, Name_After)
      then First
      elsif First = Last then 0
      else Procedure_Formal_Model (Text, Catalog, First + 1, Last, Name_First, Name_After));
   function Procedure_Formal_At
     (Text : String; Catalog : Procedures.Metadata; First, Last : Procedures.Formal_Index;
      Name_First, Name_After : Literal_Position) return Procedures.Formal_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Procedures.Valid_Metadata (Text, Catalog)
         and then First <= Last and then Last <= Catalog.Parameter_Count
         and then Name_First <= Text'Last + 1 and then Name_After <= Text'Last + 1,
       Post => (Runtime => Procedure_Formal_At'Result = 0
         or else Procedure_Formal_At'Result in First .. Last,
         Static => Procedure_Formal_At'Result =
           Procedure_Formal_Model (Text, Catalog, First, Last, Name_First, Name_After));
   function Procedure_Formal_At
     (Text : String; Catalog : Procedures.Metadata; First, Last : Procedures.Formal_Index;
      Name_First, Name_After : Literal_Position) return Procedures.Formal_Count is
      Index : Procedures.Formal_Index := First;
   begin
      if Name_First = 0 or else Name_After <= Name_First then return 0; end if;
      loop
         pragma Loop_Invariant (Index in First .. Last);
         pragma Loop_Invariant (Static =>
           Procedure_Formal_Model (Text, Catalog, First, Last, Name_First, Name_After) =
             Procedure_Formal_Model (Text, Catalog, Index, Last, Name_First, Name_After));
         pragma Loop_Variant (Increases => Index);
         if Equal_Name (Text, Catalog.Parameters (Index).First,
                        Catalog.Parameters (Index).After, Name_First, Name_After)
         then return Index; end if;
         if Index = Last then return 0; end if;
         Index := Index + 1;
      end loop;
   end Procedure_Formal_At;

   function Function_Association
     (Text : String; Position : Literal_Position; Catalog : Functions.Metadata;
      First, Last, Ordinal : Functions.Formal_Index; Named : Boolean) return Actual_Association
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Functions.Valid_Metadata (Text, Catalog)
         and then First <= Ordinal and then Ordinal <= Last and then Last <= Catalog.Parameter_Count,
       Post => Function_Association'Result.Payload_First <= Text'Last + 1
         and then (Function_Association'Result.Formal = 0
           or else (Function_Association'Result.Formal in First .. Last
             and then Function_Association'Result.Payload_First >= Position));
   function Function_Association
     (Text : String; Position : Literal_Position; Catalog : Functions.Metadata;
      First, Last, Ordinal : Functions.Formal_Index; Named : Boolean) return Actual_Association is
     (declare Name_First : constant Literal_Position := Skip_At (Text, Position);
              Name_End : constant Literal_Position := Name_After (Text, Name_First);
              Payload : constant Literal_Position := Take_Token (Text, Name_End, Arrow);
      begin (if Position = 0 then Invalid_Association
       elsif Payload /= 0 then
         (Function_Formal_At (Text, Catalog, First, Last, Name_First, Name_End), Payload, True)
       elsif Named then Invalid_Association
       else (Ordinal, Position, False)));

   function Procedure_Association
     (Text : String; Position : Literal_Position; Catalog : Procedures.Metadata;
      First, Last, Ordinal : Procedures.Formal_Index; Named : Boolean) return Actual_Association
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Procedures.Valid_Metadata (Text, Catalog)
         and then First <= Ordinal and then Ordinal <= Last and then Last <= Catalog.Parameter_Count,
       Post => Procedure_Association'Result.Payload_First <= Text'Last + 1
         and then (Procedure_Association'Result.Formal = 0
           or else (Procedure_Association'Result.Formal in First .. Last
             and then Procedure_Association'Result.Payload_First >= Position));
   function Procedure_Association
     (Text : String; Position : Literal_Position; Catalog : Procedures.Metadata;
      First, Last, Ordinal : Procedures.Formal_Index; Named : Boolean) return Actual_Association is
     (declare Name_First : constant Literal_Position := Skip_At (Text, Position);
              Name_End : constant Literal_Position := Name_After (Text, Name_First);
              Payload : constant Literal_Position := Take_Token (Text, Name_End, Arrow);
      begin (if Position = 0 then Invalid_Association
       elsif Payload /= 0 then
         (Procedure_Formal_At (Text, Catalog, First, Last, Name_First, Name_End), Payload, True)
       elsif Named then Invalid_Association
       else (Ordinal, Position, False)));

   function Function_Actuals_Tail_Model
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Functions.Metadata;
      First, Last, Ordinal : Functions.Formal_Index; Named : Boolean; Seen : Formal_Set)
      return Literal_Position
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts) and then Functions.Valid_Metadata (Text, Catalog)
         and then First <= Ordinal and then Ordinal <= Last and then Last <= Catalog.Parameter_Count,
       Post => Function_Actuals_Tail_Model'Result = 0
         or else Function_Actuals_Tail_Model'Result in Position + 1 .. Text'Last + 1,
       Subprogram_Variant => (Decreases => Last - Ordinal);
   function Function_Actuals_Tail_Model
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Functions.Metadata;
      First, Last, Ordinal : Functions.Formal_Index; Named : Boolean; Seen : Formal_Set)
      return Literal_Position is
     (declare Association : constant Actual_Association :=
        Function_Association (Text, Position, Catalog, First, Last, Ordinal, Named);
      begin (if Association.Formal = 0 or else Seen (Association.Formal) then 0
       else (declare After : constant Literal_Position := Actual_Model
         (Text, Context, Association.Payload_First, Facts, Catalog.Parameters (Association.Formal));
        begin (if After = 0 then 0
         elsif Ordinal = Last then Take_Token (Text, After, Right_Parenthesis)
         elsif Take_Token (Text, After, Comma) = 0 then 0
         else Function_Actuals_Tail_Model
           (Text, Context, Take_Token (Text, After, Comma), Facts, Catalog,
            First, Last, Ordinal + 1, Association.Named,
            Mark_Formal (Seen, Association.Formal))))));

   function Actuals_Model
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Functions.Metadata;
      First, Last : Functions.Formal_Index) return Literal_Position
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts)
         and then Functions.Valid_Metadata (Text, Catalog)
         and then First <= Last and then Last <= Catalog.Parameter_Count,
       Post => Actuals_Model'Result = 0
         or else Actuals_Model'Result in Position + 1 .. Text'Last + 1;
   function Actuals_Model
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Functions.Metadata;
      First, Last : Functions.Formal_Index) return Literal_Position is
     (Function_Actuals_Tail_Model
        (Text, Context, Position, Facts, Catalog, First, Last, First, False, No_Formals));

   procedure Lemma_Function_Actuals_Advance
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Functions.Metadata;
      First, Last, Ordinal : Functions.Formal_Index; Named : Boolean; Seen : Formal_Set;
      Association : Actual_Association; After : Literal_Position)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts) and then Functions.Valid_Metadata (Text, Catalog)
         and then First <= Ordinal and then Ordinal < Last and then Last <= Catalog.Parameter_Count
         and then Association = Function_Association (Text, Position, Catalog, First, Last, Ordinal, Named)
         and then Association.Formal in First .. Last
         and then Association.Payload_First <= Text'Last + 1 and then not Seen (Association.Formal)
         and then After /= 0 and then After <= Text'Last + 1
         and then After = Actual_Model
           (Text, Context, Association.Payload_First, Facts, Catalog.Parameters (Association.Formal))
         and then Take_Token (Text, After, Comma) /= 0,
       Post => Function_Actuals_Tail_Model
         (Text, Context, Position, Facts, Catalog, First, Last, Ordinal, Named, Seen) =
           Function_Actuals_Tail_Model
             (Text, Context, Take_Token (Text, After, Comma), Facts, Catalog,
              First, Last, Ordinal + 1, Association.Named,
              Mark_Formal (Seen, Association.Formal));
   procedure Lemma_Function_Actuals_Advance
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Functions.Metadata;
      First, Last, Ordinal : Functions.Formal_Index; Named : Boolean; Seen : Formal_Set;
      Association : Actual_Association; After : Literal_Position) is
   begin
      null;
   end Lemma_Function_Actuals_Advance;

   function Actuals_After
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Functions.Metadata;
      First, Last : Functions.Formal_Index) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts)
         and then Functions.Valid_Metadata (Text, Catalog)
         and then First <= Last and then Last <= Catalog.Parameter_Count,
       Post => (Runtime => Actuals_After'Result = 0
         or else Actuals_After'Result in Position + 1 .. Text'Last + 1,
         Static => Actuals_After'Result =
           Actuals_Model (Text, Context, Position, Facts, Catalog, First, Last));
   function Actuals_After
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Functions.Metadata;
      First, Last : Functions.Formal_Index) return Literal_Position is
      Index : Functions.Formal_Index := First;
      Cursor : Literal_Position := Position;
      Named : Boolean := False;
      Seen : Formal_Set := No_Formals;
      Expected : constant Literal_Position :=
        Actuals_Model (Text, Context, Position, Facts, Catalog, First, Last) with Ghost => Static;
   begin
      loop
         pragma Loop_Invariant (Index in First .. Last);
         pragma Loop_Invariant (Cursor <= Text'Last + 1);
         pragma Loop_Invariant (Cursor >= Position);
         pragma Loop_Invariant (Static =>
           Expected = Function_Actuals_Tail_Model
               (Text, Context, Cursor, Facts, Catalog, First, Last, Index, Named, Seen));
         pragma Loop_Variant (Increases => Index);
         declare Association : constant Actual_Association :=
           Function_Association (Text, Cursor, Catalog, First, Last, Index, Named);
            After, Following : Literal_Position;
         begin
            if Association.Formal = 0 or else Seen (Association.Formal) then return 0; end if;
            After := Actual_After
              (Text, Context, Association.Payload_First, Facts, Catalog.Parameters (Association.Formal));
            if After = 0 then return 0; end if;
            if Index = Last then return Take_Token (Text, After, Right_Parenthesis); end if;
            Following := Take_Token (Text, After, Comma);
            if Following = 0 then return 0; end if;
            Lemma_Function_Actuals_Advance
              (Text, Context, Cursor, Facts, Catalog, First, Last,
               Index, Named, Seen, Association, After);
            Cursor := Following;
            Seen := Mark_Formal (Seen, Association.Formal);
            Named := Association.Named;
         end;
         Index := Index + 1;
      end loop;
   end Actuals_After;
   type Call_Result is record
      After : Literal_Position;
      Kind : Functions.Scalar_Kind;
      Bounds : Scalars.Interval;
   end record;
   Invalid_Call : constant Call_Result := (0, Functions.Integer_Kind, Scalars.Empty);
   function Callee_At
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Catalog : Functions.Metadata) return Functions.Function_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Functions.Valid_Metadata (Text, Catalog),
       Post => Callee_At'Result <= Catalog.Count;
   function Callee_At
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Catalog : Functions.Metadata) return Functions.Function_Count is
     (declare First : constant Literal_Position := Skip_At (Text, Position);
       After : constant Literal_Position := Name_After (Text, First);
      begin (if First = 0 or else After <= First
        or else Lookup_Name (Text, Context.Names, First, After) /= 0
        or else Scalar_Expressions.Lookup (Text, Context.Scalar_Names, First, After) /= 0
        or else Lookup_Boolean (Text, Context.Boolean_Names, First, After) /= 0
        or else Array_Bindings.Lookup (Text, Context.Array_Names, First, After) /= 0
           or else Array_Bindings.Lookup_Type (Text, Context.Array_Names.Types, First, After) /= 0
       then 0 else Functions.Lookup (Text, Catalog, First, After)));
   function Call_Model
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Functions.Metadata) return Call_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts) and then Functions.Valid_Metadata (Text, Catalog),
       Post => Call_Model'Result.After = 0
         or else Call_Model'Result.After in Position + 1 .. Text'Last + 1;
   function Call_Model
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Functions.Metadata) return Call_Result is
     (declare Callee : constant Functions.Function_Count := Callee_At (Text, Context, Position, Catalog);
      begin (if Callee = 0 then Invalid_Call
       else (declare Item : constant Functions.Signature := Catalog.Items (Callee);
         Start : constant Literal_Position := Take_Token
           (Text, Name_After (Text, Skip_At (Text, Position)), Left_Parenthesis);
         After : constant Literal_Position := Actuals_Model
           (Text, Context, Start, Facts, Catalog, Item.Formal_First, Item.Formal_First + Item.Count - 1);
        begin (if After <= Position then Invalid_Call
         else (After, Item.Result_Kind, Item.Result_Bounds)))));
   function Read_Call
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Functions.Metadata) return Call_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts) and then Functions.Valid_Metadata (Text, Catalog),
       Post => (Runtime => Read_Call'Result.After = 0
         or else Read_Call'Result.After in Position + 1 .. Text'Last + 1,
         Static => Read_Call'Result = Call_Model (Text, Context, Position, Facts, Catalog));
   function Read_Call
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Functions.Metadata) return Call_Result is
      Callee : constant Functions.Function_Count := Callee_At (Text, Context, Position, Catalog);
   begin
      if Callee = 0 then return Invalid_Call; end if;
      declare Item : constant Functions.Signature := Catalog.Items (Callee);
         Start : constant Literal_Position := Take_Token
           (Text, Name_After (Text, Skip_At (Text, Position)), Left_Parenthesis);
         After : constant Literal_Position := Actuals_After
           (Text, Context, Start, Facts, Catalog, Item.Formal_First, Item.Formal_First + Item.Count - 1);
      begin
         return (if After <= Position then Invalid_Call
                 else (After, Item.Result_Kind, Item.Result_Bounds));
      end;
   end Read_Call;
   function Call_Assignment_Result
     (Context : Body_Context; Scan : Body_Scan;
      Scalar : Scalar_Expressions.Binding_Count; Flag : Boolean_Count;
      Value : Call_Result) return Body_Scan
     with Global => null,
       Pre => Scalar <= Context.Scalar_Names.Count and then Scalar <= Scan.Count
         and then Flag <= Context.Boolean_Names.Count;
   function Call_Assignment_Result
     (Context : Body_Context; Scan : Body_Scan;
      Scalar : Scalar_Expressions.Binding_Count; Flag : Boolean_Count;
      Value : Call_Result) return Body_Scan is
     (if Value.After <= Scan.Position then Invalid_Body (Scan)
      elsif Scalar /= 0 then
        (if Value.Kind /= Functions.Integer_Kind
          or else not Context.Scalar_Names.Items (Scalar).Mutable
          or else Scalars.Is_Empty (Value.Bounds)
          or else not Included (Value.Bounds, Context.Scalar_Names.Items (Scalar).Declared_Bounds)
         then Invalid_Body (Scan)
         else (Scan with delta Position => Value.After, Assigned => True,
           Facts => (Scan.Facts with delta Values => (Scan.Facts.Values with delta Scalar => Value.Bounds))))
      elsif Flag /= 0 and then Context.Boolean_Names.Items (Flag).Mutable
        and then Value.Kind = Functions.Boolean_Kind
      then (Scan with delta Position => Value.After, Assigned => True)
      else Invalid_Body (Scan));
   function Call_Assignment_Model
     (Text : String; Context : Body_Context; Scan : Body_Scan;
      Catalog : Functions.Metadata) return Body_Scan
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan)
         and then Functions.Valid_Metadata (Text, Catalog);
   function Call_Assignment_Model
     (Text : String; Context : Body_Context; Scan : Body_Scan;
      Catalog : Functions.Metadata) return Body_Scan is
     (Call_Assignment_Result (Context, Scan, Scalar_Target (Text, Context, Scan.Position),
       Boolean_Target (Text, Context, Scan.Position), Call_Model
         (Text, Context, Take_Token (Text, Name_After (Text, Skip_At (Text, Scan.Position)), Assignment),
          Scan.Facts, Catalog)));
   function Call_Assignment_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan;
      Catalog : Functions.Metadata) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan)
         and then Functions.Valid_Metadata (Text, Catalog),
       Post => (Runtime => Valid_Body (Text, Context, Call_Assignment_Body'Result)
         and then (Call_Assignment_Body'Result.Position = 0
           or else Call_Assignment_Body'Result.Position > Scan.Position),
         Static => Call_Assignment_Body'Result = Call_Assignment_Model (Text, Context, Scan, Catalog));
   function Call_Assignment_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan;
      Catalog : Functions.Metadata) return Body_Scan is
     (Call_Assignment_Result (Context, Scan, Scalar_Target (Text, Context, Scan.Position),
       Boolean_Target (Text, Context, Scan.Position), Read_Call
         (Text, Context, Take_Token (Text, Name_After (Text, Skip_At (Text, Scan.Position)), Assignment),
          Scan.Facts, Catalog)));

   type Name_Scan_Step is record
      Next : Literal_Position;
      Free : Boolean;
   end record;
   function Actual_Name_Step
     (Text : String; Position, After, Target_First, Target_After : Literal_Position)
      return Name_Scan_Step
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then After <= Text'Last + 1
         and then Target_First > 0 and then Valid_Name_State (Text, Target_First, Target_After),
       Post => Actual_Name_Step'Result.Next = 0
         or else Actual_Name_Step'Result.Next in Position + 1 .. After;
   function Actual_Name_Step
     (Text : String; Position, After, Target_First, Target_After : Literal_Position)
      return Name_Scan_Step is
      First : constant Literal_Position := Skip_At (Text, Position);
      Number_After : constant Literal_Position := Silver_Scalar_Literals.Read_Integer (Text, First).After;
      Word_After : Literal_Position;
      Quoted : Value_Result;
      Character_After : Literal_Position;
   begin
      if Position = 0 or else Position >= After then return (0, False); end if;
      if First >= After then return (After, True); end if;
      Character_After := Character_Literal_After (Text, First);
      if Character_After /= 0 and then Character_After <= After then
         return (Character_After, True);
      end if;
      if Text (First) = Character'Val (34) then
         Quoted := Literal_At (Text, First);
         return (if Quoted.After > First and then Quoted.After <= After
                 then (Quoted.After, True) else (0, False));
      end if;
      --  Based digits and exponent spellings are part of the literal token.
      if Number_After /= 0 and then Number_After <= After then
         return (Number_After, True);
      end if;
      --  An attribute designator is syntax, not a read of an object whose
      --  identifier happens to have the same spelling.
      if Text (First) = Character'Val (39) then
         Word_After := Name_After (Text, Skip_At (Text, First + 1));
         return (if Word_After > First and then Word_After <= After
                 then (Word_After, True) else (First + 1, True));
      end if;
      --  A validity selector reads no local object. Other selected names
      --  are excluded by actual parsing; a range's second dot is not a selector.
      Word_After :=
        (if Text (First) = '.' and then First > 1 and then Text (First - 1) /= '.'
         then Take_Token (Text, Take_Token (Text, First, Dot), Input_Is_Valid_Name)
         else 0);
      if Word_After > First and then Word_After <= After then
         return (Word_After, True);
      end if;
      declare Reference : constant Scalar_Expressions.Name_Reference :=
        Scalar_Expressions.Read_Reference (Text, First);
      begin
         if Reference.Qualifier_First /= 0 and then Reference.After <= After then
            return (Reference.After, True);
         end if;
      end;
      Word_After := Name_After (Text, First);
      if Word_After > First and then Word_After <= After then
         return (Word_After, not Equal_Name (Text, First, Word_After, Target_First, Target_After));
      end if;
      return (First + 1, True);
   end Actual_Name_Step;
   function Actual_Name_Free_Model
     (Text : String; Position, After, Target_First, Target_After : Literal_Position) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then After <= Text'Last + 1
         and then Target_First > 0 and then Valid_Name_State (Text, Target_First, Target_After),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position);
   function Actual_Name_Free_Model
     (Text : String; Position, After, Target_First, Target_After : Literal_Position) return Boolean is
     (if Position = 0 or else Position > After then False
      elsif Position = After then True
      else (declare Next : constant Name_Scan_Step :=
        Actual_Name_Step (Text, Position, After, Target_First, Target_After);
       begin Next.Next /= 0 and then Next.Free and then
         Actual_Name_Free_Model (Text, Next.Next, After, Target_First, Target_After)));
   function Actual_Name_Free
     (Text : String; First, After, Target_First, Target_After : Literal_Position) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then First <= Text'Last + 1 and then After <= Text'Last + 1
         and then Target_First > 0 and then Valid_Name_State (Text, Target_First, Target_After),
       Post => (Static => Actual_Name_Free'Result =
         Actual_Name_Free_Model (Text, First, After, Target_First, Target_After));
   function Actual_Name_Free
     (Text : String; First, After, Target_First, Target_After : Literal_Position) return Boolean is
      Position : Literal_Position := First;
   begin
      if Position = 0 or else Position > After then return False; end if;
      while Position < After loop
         pragma Loop_Invariant (Position in First .. After);
         pragma Loop_Invariant (Static =>
           Actual_Name_Free_Model (Text, First, After, Target_First, Target_After) =
             Actual_Name_Free_Model (Text, Position, After, Target_First, Target_After));
         pragma Loop_Variant (Increases => Position);
         declare Next : constant Name_Scan_Step :=
           Actual_Name_Step (Text, Position, After, Target_First, Target_After);
         begin
            if Next.Next = 0 or else not Next.Free then return False; end if;
            Position := Next.Next;
         end;
      end loop;
      return True;
   end Actual_Name_Free;

   type Procedure_Actual_Result is record
      First, After : Literal_Position;
      Scalar : Scalar_Expressions.Binding_Count;
      Flag : Boolean_Count;
   end record;
   Invalid_Procedure_Actual : constant Procedure_Actual_Result := (0, 0, 0, 0);
   function Procedure_Target_Actual
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Parameter : Procedures.Formal) return Procedure_Actual_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts),
       Post => Procedure_Target_Actual'Result.Scalar <= Context.Scalar_Names.Count
         and then Procedure_Target_Actual'Result.Flag <= Context.Boolean_Names.Count
         and then (if Procedure_Target_Actual'Result.After /= 0
           and then Procedure_Target_Actual'Result.Scalar /= 0 then
             Context.Scalar_Names.Items (Procedure_Target_Actual'Result.Scalar).Mutable
             and then not Scalars.Is_Empty (Parameter.Bounds)
             and then Included (Parameter.Bounds,
               Context.Scalar_Names.Items (Procedure_Target_Actual'Result.Scalar).Declared_Bounds))
         and then (Procedure_Target_Actual'Result.After = 0
           or else (Procedure_Target_Actual'Result.First >= Position
             and then Procedure_Target_Actual'Result.First > 0
             and then Procedure_Target_Actual'Result.After in
               Procedure_Target_Actual'Result.First + 1 .. Text'Last + 1));
   function Procedure_Target_Actual
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Parameter : Procedures.Formal) return Procedure_Actual_Result is
      First : constant Literal_Position := Skip_At (Text, Position);
      After : constant Literal_Position := Name_After (Text, First);
      Scalar : constant Scalar_Expressions.Binding_Count := Scalar_Target (Text, Context, Position);
      Flag : constant Boolean_Count := Boolean_Target (Text, Context, Position);
   begin
      if First = 0 or else After <= First or else Parameter.Type_Id /= 0 then return Invalid_Procedure_Actual; end if;
      if Parameter.Kind = Functions.Integer_Kind then
         if Scalar = 0 or else not Context.Scalar_Names.Items (Scalar).Mutable
           or else Scalars.Is_Empty (Parameter.Bounds)
           or else not Included (Parameter.Bounds, Context.Scalar_Names.Items (Scalar).Declared_Bounds)
           or else (Parameter.Mode = Procedures.Input_Output
             and then (Scalars.Is_Empty (Facts.Values (Scalar))
               or else not Included (Facts.Values (Scalar), Parameter.Bounds)))
         then return Invalid_Procedure_Actual; end if;
         return (First, After, Scalar, 0);
      else
         if Flag = 0 or else not Context.Boolean_Names.Items (Flag).Mutable
         then return Invalid_Procedure_Actual; end if;
         return (First, After, 0, Flag);
      end if;
   end Procedure_Target_Actual;
   function Procedure_Actual_After
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Parameter : Procedures.Formal) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts),
       Post => Procedure_Actual_After'Result = 0
         or else Procedure_Actual_After'Result in Position + 1 .. Text'Last + 1;
   function Procedure_Actual_After
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Parameter : Procedures.Formal) return Literal_Position is
     (if Parameter.Mode = Procedures.Input then
        Actual_After (Text, Context, Position, Facts,
          (Parameter.First, Parameter.After, Parameter.Kind, Parameter.Bounds, Parameter.Type_Id))
      else Procedure_Target_Actual (Text, Context, Position, Facts, Parameter).After);
   function Procedure_Actuals_Tail_Model
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Procedures.Metadata;
      First, Last, Ordinal : Procedures.Formal_Index; Named : Boolean; Seen : Formal_Set)
      return Literal_Position
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts) and then Procedures.Valid_Metadata (Text, Catalog)
         and then First <= Ordinal and then Ordinal <= Last and then Last <= Catalog.Parameter_Count,
       Post => Procedure_Actuals_Tail_Model'Result = 0
         or else Procedure_Actuals_Tail_Model'Result in Position + 1 .. Text'Last + 1,
       Subprogram_Variant => (Decreases => Last - Ordinal);
   function Procedure_Actuals_Tail_Model
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Procedures.Metadata;
      First, Last, Ordinal : Procedures.Formal_Index; Named : Boolean; Seen : Formal_Set)
      return Literal_Position is
     (declare Association : constant Actual_Association :=
        Procedure_Association (Text, Position, Catalog, First, Last, Ordinal, Named);
      begin (if Association.Formal = 0 or else Seen (Association.Formal) then 0
       else (declare After : constant Literal_Position := Procedure_Actual_After
         (Text, Context, Association.Payload_First, Facts, Catalog.Parameters (Association.Formal));
        begin (if After = 0 then 0
         elsif Ordinal = Last then Take_Token (Text, After, Right_Parenthesis)
         elsif Take_Token (Text, After, Comma) = 0 then 0
         else Procedure_Actuals_Tail_Model
           (Text, Context, Take_Token (Text, After, Comma), Facts, Catalog,
            First, Last, Ordinal + 1, Association.Named,
            Mark_Formal (Seen, Association.Formal))))));

   function Procedure_Actuals_Model
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Procedures.Metadata;
      First, Last : Procedures.Formal_Index) return Literal_Position
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts)
         and then Procedures.Valid_Metadata (Text, Catalog)
         and then First <= Last and then Last <= Catalog.Parameter_Count,
       Post => Procedure_Actuals_Model'Result = 0
         or else Procedure_Actuals_Model'Result in Position + 1 .. Text'Last + 1;
   function Procedure_Actuals_Model
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Procedures.Metadata;
      First, Last : Procedures.Formal_Index) return Literal_Position is
     (Procedure_Actuals_Tail_Model
        (Text, Context, Position, Facts, Catalog, First, Last, First, False, No_Formals));
   function Procedure_Actuals_After
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Procedures.Metadata;
      First, Last : Procedures.Formal_Index) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Facts)
         and then Procedures.Valid_Metadata (Text, Catalog)
         and then First <= Last and then Last <= Catalog.Parameter_Count,
       Post => (Runtime => Procedure_Actuals_After'Result = 0
         or else Procedure_Actuals_After'Result in Position + 1 .. Text'Last + 1,
         Static => Procedure_Actuals_After'Result =
           Procedure_Actuals_Model (Text, Context, Position, Facts, Catalog, First, Last));
   function Procedure_Actuals_After
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Facts : Scalar_Flow; Catalog : Procedures.Metadata;
      First, Last : Procedures.Formal_Index) return Literal_Position is
      Index : Procedures.Formal_Index := First;
      Cursor : Literal_Position := Position;
      Named : Boolean := False;
      Seen : Formal_Set := No_Formals;
   begin
      loop
         pragma Loop_Invariant (Index in First .. Last);
         pragma Loop_Invariant (Cursor <= Text'Last + 1);
         pragma Loop_Invariant (Cursor >= Position);
         pragma Loop_Invariant (Static =>
           Procedure_Actuals_Model (Text, Context, Position, Facts, Catalog, First, Last) =
             Procedure_Actuals_Tail_Model
               (Text, Context, Cursor, Facts, Catalog, First, Last, Index, Named, Seen));
         pragma Loop_Variant (Increases => Index);
         declare Association : constant Actual_Association :=
           Procedure_Association (Text, Cursor, Catalog, First, Last, Index, Named);
         begin
            if Association.Formal = 0 or else Seen (Association.Formal) then return 0; end if;
            Cursor := Procedure_Actual_After
              (Text, Context, Association.Payload_First, Facts, Catalog.Parameters (Association.Formal));
            if Cursor = 0 then return 0; end if;
            Seen := Mark_Formal (Seen, Association.Formal);
            Named := Association.Named;
         end;
         if Index = Last then return Take_Token (Text, Cursor, Right_Parenthesis); end if;
         Cursor := Take_Token (Text, Cursor, Comma);
         if Cursor = 0 then return 0; end if;
         Index := Index + 1;
      end loop;
   end Procedure_Actuals_After;

   --  Replay associations to inspect only actual payloads. A selector is a
   --  callee-formal label even when its spelling is a writable caller name.
   --  The unique-association pass owns Seen; this pass checks every payload.
   function Procedure_Payloads_Free_Model
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Incoming : Scalar_Flow; Catalog : Procedures.Metadata;
      First, Last, Ordinal : Procedures.Formal_Index; Named : Boolean;
      Call_After, Target_First, Target_After : Literal_Position) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Incoming) and then Procedures.Valid_Metadata (Text, Catalog)
         and then First <= Ordinal and then Ordinal <= Last and then Last <= Catalog.Parameter_Count
         and then Call_After <= Text'Last + 1
         and then Target_First > 0 and then Valid_Name_State (Text, Target_First, Target_After),
       Subprogram_Variant => (Decreases => Last - Ordinal);
   function Procedure_Payloads_Free_Model
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Incoming : Scalar_Flow; Catalog : Procedures.Metadata;
      First, Last, Ordinal : Procedures.Formal_Index; Named : Boolean;
      Call_After, Target_First, Target_After : Literal_Position) return Boolean is
     (declare Association : constant Actual_Association :=
        Procedure_Association (Text, Position, Catalog, First, Last, Ordinal, Named);
      begin (if Call_After = 0 or else Association.Formal = 0 then False
       else (declare After : constant Literal_Position := Procedure_Actual_After
         (Text, Context, Association.Payload_First, Incoming, Catalog.Parameters (Association.Formal));
        begin (if After = 0 then False
         elsif not ((Skip_At (Text, Association.Payload_First) = Target_First and then After = Target_After)
           or else Actual_Name_Free_Model
             (Text, Association.Payload_First, After, Target_First, Target_After)) then False
         elsif Ordinal = Last then Take_Token (Text, After, Right_Parenthesis) = Call_After
         elsif Take_Token (Text, After, Comma) = 0 then False
         else Procedure_Payloads_Free_Model
           (Text, Context, Take_Token (Text, After, Comma), Incoming, Catalog,
            First, Last, Ordinal + 1, Association.Named, Call_After, Target_First, Target_After)))));
   function Procedure_Payloads_Free
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Incoming : Scalar_Flow; Catalog : Procedures.Metadata; First, Last : Procedures.Formal_Index;
      Call_After, Target_First, Target_After : Literal_Position) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Valid_Flow (Context, Incoming) and then Procedures.Valid_Metadata (Text, Catalog)
         and then First <= Last and then Last <= Catalog.Parameter_Count
         and then Call_After <= Text'Last + 1
         and then Target_First > 0 and then Valid_Name_State (Text, Target_First, Target_After),
       Post => (Static => Procedure_Payloads_Free'Result = Procedure_Payloads_Free_Model
         (Text, Context, Position, Incoming, Catalog, First, Last, First, False,
          Call_After, Target_First, Target_After));
   function Procedure_Payloads_Free
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Incoming : Scalar_Flow; Catalog : Procedures.Metadata; First, Last : Procedures.Formal_Index;
      Call_After, Target_First, Target_After : Literal_Position) return Boolean is
      Index : Procedures.Formal_Index := First;
      Cursor : Literal_Position := Position;
      Named : Boolean := False;
   begin
      loop
         pragma Loop_Invariant (Index in First .. Last);
         pragma Loop_Invariant (Cursor <= Text'Last + 1);
         pragma Loop_Invariant (Static =>
           Procedure_Payloads_Free_Model
             (Text, Context, Position, Incoming, Catalog, First, Last, First, False,
              Call_After, Target_First, Target_After) =
           Procedure_Payloads_Free_Model
             (Text, Context, Cursor, Incoming, Catalog, First, Last, Index, Named,
              Call_After, Target_First, Target_After));
         pragma Loop_Variant (Increases => Index);
         declare Association : constant Actual_Association :=
           Procedure_Association (Text, Cursor, Catalog, First, Last, Index, Named);
         begin
            if Call_After = 0 or else Association.Formal = 0 then return False; end if;
            declare After : constant Literal_Position := Procedure_Actual_After
              (Text, Context, Association.Payload_First, Incoming, Catalog.Parameters (Association.Formal));
            begin
               if After = 0 then return False; end if;
               if not ((Skip_At (Text, Association.Payload_First) = Target_First and then After = Target_After)
                 or else Actual_Name_Free
                   (Text, Association.Payload_First, After, Target_First, Target_After))
               then return False; end if;
               if Index = Last then return Take_Token (Text, After, Right_Parenthesis) = Call_After; end if;
               Cursor := Take_Token (Text, After, Comma);
               if Cursor = 0 then return False; end if;
               Named := Association.Named;
            end;
         end;
         Index := Index + 1;
      end loop;
   end Procedure_Payloads_Free;

   function Procedure_Update_Step
     (Text : String; Context : Body_Context; Incoming : Scalar_Flow; Scan : Body_Scan;
      Parameter : Procedures.Formal; Catalog : Procedures.Metadata; First, Last : Procedures.Formal_Index;
      Call_First, Call_After : Literal_Position) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan)
         and then Valid_Flow (Context, Incoming) and then Procedures.Valid_Metadata (Text, Catalog)
         and then First <= Last and then Last <= Catalog.Parameter_Count
         and then Call_First <= Text'Last + 1 and then Call_After <= Text'Last + 1,
       Post => Valid_Body (Text, Context, Procedure_Update_Step'Result)
         and then (Procedure_Update_Step'Result.Position = 0
           or else Procedure_Update_Step'Result.Position > Scan.Position);
   function Procedure_Update_Step
     (Text : String; Context : Body_Context; Incoming : Scalar_Flow; Scan : Body_Scan;
      Parameter : Procedures.Formal; Catalog : Procedures.Metadata; First, Last : Procedures.Formal_Index;
      Call_First, Call_After : Literal_Position) return Body_Scan is
   begin
      if Parameter.Mode = Procedures.Input then
         declare After : constant Literal_Position :=
           Procedure_Actual_After (Text, Context, Scan.Position, Incoming, Parameter);
         begin
            return (if After <= Scan.Position then Invalid_Body (Scan)
                    else (Scan with delta Position => After));
         end;
      else
         declare Target : constant Procedure_Actual_Result :=
           Procedure_Target_Actual (Text, Context, Scan.Position, Incoming, Parameter);
         begin
            if Target.After = 0 or else Target.First < Call_First or else Target.After > Call_After
              or else not Procedure_Payloads_Free
                (Text, Context, Call_First, Incoming, Catalog, First, Last,
                 Call_After, Target.First, Target.After)
            then return Invalid_Body (Scan); end if;
            if Target.Scalar = 0 then
               return (Scan with delta Position => Target.After, Assigned => True);
            else
               return (Scan with delta Position => Target.After, Assigned => True,
                 Facts => (Scan.Facts with delta Values =>
                   (Scan.Facts.Values with delta Target.Scalar => Parameter.Bounds)));
            end if;
         end;
      end if;
   end Procedure_Update_Step;

   function Procedure_Updates_Tail_Model
     (Text : String; Context : Body_Context; Incoming : Scalar_Flow; Scan : Body_Scan;
      Catalog : Procedures.Metadata; First, Last, Ordinal : Procedures.Formal_Index;
      Named : Boolean; Seen : Formal_Set; Call_First, Call_After : Literal_Position) return Body_Scan
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan)
         and then Valid_Flow (Context, Incoming) and then Procedures.Valid_Metadata (Text, Catalog)
         and then First <= Ordinal and then Ordinal <= Last and then Last <= Catalog.Parameter_Count
         and then Call_First <= Text'Last + 1 and then Call_After <= Text'Last + 1,
       Post => Valid_Body (Text, Context, Procedure_Updates_Tail_Model'Result)
         and then (Procedure_Updates_Tail_Model'Result.Position = 0
           or else Procedure_Updates_Tail_Model'Result.Position > Scan.Position),
       Subprogram_Variant => (Decreases => Last - Ordinal);
   function Procedure_Updates_Tail_Model
     (Text : String; Context : Body_Context; Incoming : Scalar_Flow; Scan : Body_Scan;
      Catalog : Procedures.Metadata; First, Last, Ordinal : Procedures.Formal_Index;
      Named : Boolean; Seen : Formal_Set; Call_First, Call_After : Literal_Position) return Body_Scan is
     (declare Association : constant Actual_Association :=
        Procedure_Association (Text, Scan.Position, Catalog, First, Last, Ordinal, Named);
      begin (if Association.Formal = 0 or else Seen (Association.Formal) then Invalid_Body_Model (Scan)
       else (declare Next : constant Body_Scan := Procedure_Update_Step
         (Text, Context, Incoming, (Scan with delta Position => Association.Payload_First),
          Catalog.Parameters (Association.Formal), Catalog, First, Last, Call_First, Call_After);
        begin (if Next.Position = 0 then Invalid_Body_Model (Scan)
         elsif Ordinal = Last then Body_Token (Text, Context, Next, Right_Parenthesis)
         else (declare Following : constant Body_Scan := Body_Token (Text, Context, Next, Comma);
           begin (if Following.Position = 0 then Invalid_Body_Model (Scan)
            else Procedure_Updates_Tail_Model
              (Text, Context, Incoming, Following, Catalog, First, Last, Ordinal + 1,
               Association.Named, Mark_Formal (Seen, Association.Formal), Call_First, Call_After)))))));

   function Procedure_Updates_Model
     (Text : String; Context : Body_Context; Incoming : Scalar_Flow; Scan : Body_Scan;
      Catalog : Procedures.Metadata; First, Last : Procedures.Formal_Index;
      Call_First, Call_After : Literal_Position) return Body_Scan
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan)
         and then Valid_Flow (Context, Incoming) and then Procedures.Valid_Metadata (Text, Catalog)
         and then First <= Last and then Last <= Catalog.Parameter_Count
         and then Call_First <= Text'Last + 1 and then Call_After <= Text'Last + 1,
       Post => Valid_Body (Text, Context, Procedure_Updates_Model'Result)
         and then (Procedure_Updates_Model'Result.Position = 0
           or else Procedure_Updates_Model'Result.Position > Scan.Position);
   function Procedure_Updates_Model
     (Text : String; Context : Body_Context; Incoming : Scalar_Flow; Scan : Body_Scan;
      Catalog : Procedures.Metadata; First, Last : Procedures.Formal_Index;
      Call_First, Call_After : Literal_Position) return Body_Scan is
     (Procedure_Updates_Tail_Model
        (Text, Context, Incoming, Scan, Catalog, First, Last, First, False, No_Formals,
         Call_First, Call_After));
   function Procedure_Updates
     (Text : String; Context : Body_Context; Scan : Body_Scan;
      Catalog : Procedures.Metadata; First, Last : Procedures.Formal_Index;
      Call_First, Call_After : Literal_Position) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan)
         and then Procedures.Valid_Metadata (Text, Catalog)
         and then First <= Last and then Last <= Catalog.Parameter_Count
         and then Call_First <= Text'Last + 1 and then Call_After <= Text'Last + 1,
       Post => (Runtime => Valid_Body (Text, Context, Procedure_Updates'Result)
         and then (Procedure_Updates'Result.Position = 0
           or else Procedure_Updates'Result.Position > Scan.Position),
         Static => Procedure_Updates'Result =
           Procedure_Updates_Model (Text, Context, Scan.Facts, Scan, Catalog, First, Last, Call_First, Call_After));
   function Procedure_Updates
     (Text : String; Context : Body_Context; Scan : Body_Scan;
      Catalog : Procedures.Metadata; First, Last : Procedures.Formal_Index;
      Call_First, Call_After : Literal_Position) return Body_Scan is
      Index : Procedures.Formal_Index := First;
      Current : Body_Scan (Scan.Count) := Scan;
      Before : Body_Scan (Scan.Count);
      Named : Boolean := False;
      Seen : Formal_Set := No_Formals;
   begin
      loop
         pragma Loop_Invariant (Index in First .. Last);
         pragma Loop_Invariant (Valid_Body (Text, Context, Current));
         pragma Loop_Invariant (Current.Position >= Scan.Position);
         pragma Loop_Invariant (Static =>
           Procedure_Updates_Model (Text, Context, Scan.Facts, Scan, Catalog, First, Last, Call_First, Call_After) =
             Procedure_Updates_Tail_Model
               (Text, Context, Scan.Facts, Current, Catalog, First, Last, Index, Named, Seen,
                Call_First, Call_After));
         pragma Loop_Variant (Increases => Index);
         Lemma_Body_Equality
           (Procedure_Updates_Model
              (Text, Context, Scan.Facts, Scan, Catalog, First, Last, Call_First, Call_After),
            Procedure_Updates_Tail_Model
              (Text, Context, Scan.Facts, Current, Catalog, First, Last, Index, Named, Seen,
               Call_First, Call_After));
         Before := Current;
         declare Association : constant Actual_Association :=
           Procedure_Association (Text, Current.Position, Catalog, First, Last, Index, Named);
         begin
            if Association.Formal = 0 or else Seen (Association.Formal) then return Invalid_Body (Before); end if;
            Current.Position := Association.Payload_First;
            Current := Procedure_Update_Step
              (Text, Context, Scan.Facts, Current, Catalog.Parameters (Association.Formal),
               Catalog, First, Last, Call_First, Call_After);
            if Current.Position = 0 then return Invalid_Body (Before); end if;
            Seen := Mark_Formal (Seen, Association.Formal);
            Named := Association.Named;
         end;
         if Index = Last then return Body_Token (Text, Context, Current, Right_Parenthesis); end if;
         Current := Body_Token (Text, Context, Current, Comma);
         if Current.Position = 0 then return Invalid_Body (Before); end if;
         Index := Index + 1;
      end loop;
   end Procedure_Updates;

   function Procedure_Callee_At
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Catalog : Procedures.Metadata) return Procedures.Procedure_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Context (Text, Context)
         and then Procedures.Valid_Metadata (Text, Catalog),
       Post => Procedure_Callee_At'Result <= Catalog.Count;
   function Procedure_Callee_At
     (Text : String; Context : Body_Context; Position : Literal_Position;
      Catalog : Procedures.Metadata) return Procedures.Procedure_Count is
     (declare First : constant Literal_Position := Skip_At (Text, Position);
       After : constant Literal_Position := Name_After (Text, First);
      begin (if First = 0 or else After <= First
        or else Lookup_Name (Text, Context.Names, First, After) /= 0
        or else Scalar_Expressions.Lookup (Text, Context.Scalar_Names, First, After) /= 0
        or else Lookup_Boolean (Text, Context.Boolean_Names, First, After) /= 0
        or else Array_Bindings.Lookup (Text, Context.Array_Names, First, After) /= 0
           or else Array_Bindings.Lookup_Type (Text, Context.Array_Names.Types, First, After) /= 0
       then 0 else Procedures.Lookup (Text, Catalog, First, After)));
   function Procedure_Call_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Procedures.Metadata) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan)
         and then Procedures.Valid_Metadata (Text, Catalog),
       Post => Valid_Body (Text, Context, Procedure_Call_Body'Result)
         and then (Procedure_Call_Body'Result.Position = 0
           or else Procedure_Call_Body'Result.Position > Scan.Position);
   function Procedure_Call_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Procedures.Metadata) return Body_Scan is
      Callee : constant Procedures.Procedure_Count := Procedure_Callee_At (Text, Context, Scan.Position, Catalog);
   begin
      if Callee = 0 then return Invalid_Body (Scan); end if;
      declare
         Item : constant Procedures.Signature := Catalog.Items (Callee);
         Start : constant Literal_Position := Take_Token
           (Text, Name_After (Text, Skip_At (Text, Scan.Position)), Left_Parenthesis);
         After : constant Literal_Position := Procedure_Actuals_After
           (Text, Context, Start, Scan.Facts, Catalog, Item.Formal_First, Item.Formal_First + Item.Count - 1);
      begin
         if Start = 0 or else After <= Scan.Position then return Invalid_Body (Scan); end if;
         return Procedure_Updates (Text, Context, (Scan with delta Position => Start), Catalog,
           Item.Formal_First, Item.Formal_First + Item.Count - 1, Start, After);
      end;
   end Procedure_Call_Body;

   function Basic_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Functions.Valid_Metadata (Text, Catalog)
         and then Procedures.Valid_Metadata (Text, Procedure_Catalog)
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Basic_Body'Result)
         and then (Basic_Body'Result.Position = 0
           or else Basic_Body'Result.Position > Scan.Position);
   function Basic_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata) return Body_Scan is
      Result : Body_Scan (Scan.Count) := Scan;
      Value : Expression_Result;
      Target : String_Target_Result;
      Character_Value : Value_Result;
   begin
      if Result.Position = 0 then return Invalid_Body (Scan); end if;
      if Take_Token (Text, Result.Position, Null_Keyword) /= 0 then
         Result := Body_Token (Text, Context, Result, Null_Keyword);
      elsif not Context.Pure and then Call_After (Text, Context.Names, Result.Position, Names.Output_Call, Context.Scalar_Names, Context.Array_Names, Context.Subtype_Hiding (Names.Output_Call), Context.Boolean_Names, Context.Context_First, Context.Package_First, Context.Package_After) /= 0 then
         Result.Position := Call_After (Text, Context.Names, Result.Position, Names.Output_Call, Context.Scalar_Names, Context.Array_Names, Context.Subtype_Hiding (Names.Output_Call), Context.Boolean_Names, Context.Context_First, Context.Package_First, Context.Package_After);
         Result := Body_Token (Text, Context, Result, Left_Parenthesis);
         Result.Position := Names.Association_After (Text, Result.Position, False);
         Value := Read_String_In_Flow (Text, Context, Result.Position, Result.Facts);
         if Value.After = 0 or else Result.Facts.Path.Invalid_Reachable
           or else not Length_Intervals.Fits (Result.Facts.Path, Summary_Of (Value))
         then return Invalid_Body (Scan); end if;
         Result.Position := Value.After;
         Result := Body_Token (Text, Context, Result, Right_Parenthesis);
         Result.Output := True;
      elsif not Context.Pure and then Call_After (Text, Context.Names, Result.Position, Names.Partial_Output_Call, Context.Scalar_Names, Context.Array_Names, Context.Subtype_Hiding (Names.Partial_Output_Call), Context.Boolean_Names, Context.Context_First, Context.Package_First, Context.Package_After) /= 0 then
         Result.Position := Call_After (Text, Context.Names, Result.Position, Names.Partial_Output_Call, Context.Scalar_Names, Context.Array_Names, Context.Subtype_Hiding (Names.Partial_Output_Call), Context.Boolean_Names, Context.Context_First, Context.Package_First, Context.Package_After);
         Result := Body_Token (Text, Context, Result, Left_Parenthesis);
         Result.Position := Names.Association_After (Text, Result.Position, False);
         Value := Read_String_In_Flow (Text, Context, Result.Position, Result.Facts);
         if Value.After = 0 or else Result.Facts.Path.Invalid_Reachable
           or else not Length_Intervals.Fits (Result.Facts.Path, Summary_Of (Value))
         then return Invalid_Body (Scan); end if;
         Result.Position := Value.After;
         Result := Body_Token (Text, Context, Result, Right_Parenthesis);
         Result.Output := True;
      elsif Context.Dynamic_First /= 0
        and then Call_After (Text, Context.Names, Result.Position, Names.Reject_Call, Context.Scalar_Names, Context.Array_Names, Context.Subtype_Hiding (Names.Reject_Call), Context.Boolean_Names, Context.Context_First, Context.Package_First, Context.Package_After) /= 0
      then
         Result.Position := Call_After (Text, Context.Names, Result.Position, Names.Reject_Call, Context.Scalar_Names, Context.Array_Names, Context.Subtype_Hiding (Names.Reject_Call), Context.Boolean_Names, Context.Context_First, Context.Package_First, Context.Package_After);
         Result.Facts.Path := Paths.Rejected (Result.Facts.Path);
      elsif Scalar_Target (Text, Context, Result.Position) /= 0 then
         declare Called : constant Body_Scan := Call_Assignment_Body (Text, Context, Result, Catalog);
         begin
            Result := (if Called.Position /= 0 then Called
                       else Scalar_Assignment_Body (Text, Context, Result));
         end;
      elsif not Context.Pure and then Array_Target (Text, Context, Result.Position) /= 0 then
         if Context.Array_Names.Items (Array_Target (Text, Context, Result.Position)).Boolean_Elements then
            Result := Boolean_Array_Assignment_Body (Text, Context, Result);
         else
            Result := Array_Assignment_Body (Text, Context, Result);
         end if;
      elsif Boolean_Target (Text, Context, Result.Position) /= 0 then
         declare Called : constant Body_Scan := Call_Assignment_Body (Text, Context, Result, Catalog);
         begin
            Result := (if Called.Position /= 0 then Called
                       else Boolean_Assignment_Body (Text, Context, Result));
         end;
      elsif Procedure_Callee_At (Text, Context, Result.Position, Procedure_Catalog) /= 0 then
         Result := Procedure_Call_Body (Text, Context, Result, Procedure_Catalog);
      elsif Context.Pure then
         return Invalid_Body (Scan);
      else
         Target := Body_String_Target (Text, Context, Result.Position);
         Result.Position := Target.After;
         Result.Target := Target.Target;
         if Result.Target = 0 then return Invalid_Body (Scan); end if;
         if Context.Names.Items (Result.Target).Is_Character then
            Result := Body_Token (Text, Context, Result, Assignment);
            Character_Value := Character_At
              (Text, Result.Position, Context.Names, Reading_Names (Context, Result.Facts),
               Context.Array_Names);
            if Character_Value.After = 0 then return Invalid_Body (Scan); end if;
            Result.Position := Character_Value.After;
         elsif Take_Token (Text, Result.Position, Left_Parenthesis) /= 0 then
            Character_Value := Indexed_At
              (Text, Scan.Position, Context.Names, Reading_Names (Context, Result.Facts),
               Context.Array_Names, Array_Bindings.Empty_Values, False, True, 1);
            Result.Position := Character_Value.After;
            Result := Body_Token (Text, Context, Result, Assignment);
            Character_Value := Character_At
              (Text, Result.Position, Context.Names, Reading_Names (Context, Result.Facts),
               Context.Array_Names);
            if Character_Value.After = 0 then return Invalid_Body (Scan); end if;
            Result.Position := Character_Value.After;
         else
            Result := Body_Token (Text, Context, Result, Assignment);
            Value := Read_String_In_Flow (Text, Context, Result.Position, Result.Facts);
            if Value.After = 0
              or else not Length_Intervals.Fits (Result.Facts.Path, Summary_Of (Value))
              or else not Length_Intervals.Same_Length
                (Result.Facts.Path, Summary_Of (Value), Binding_Summary (Context.Names.Items (Result.Target)))
            then return Invalid_Body (Scan); end if;
            Result.Position := Value.After;
         end if;
         Result.Assigned := True;
      end if;
      Result := Body_Token (Text, Context, Result, Semicolon);
      if Result.Position <= Scan.Position then return Invalid_Body (Scan); end if;
      return Result;
   end Basic_Body;

   function At_Body_Stop (Text : String; Position : Literal_Position; Stop : Body_Stop)
      return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1;
   function At_Body_Stop (Text : String; Position : Literal_Position; Stop : Body_Stop)
      return Boolean is
     (case Stop is
        when Return_Only => Take_Token (Text, Position, Return_Keyword) /= 0,
        when End_Only => Take_Token (Text, Position, End_Keyword) /= 0,
        when Else_Only => Take_Token (Text, Position, Else_Keyword) /= 0,
        when Arm_Boundary => Take_Token (Text, Position, Elsif_Keyword) /= 0
          or else Take_Token (Text, Position, Else_Keyword) /= 0
          or else Take_Token (Text, Position, End_Keyword) /= 0);

   function Statement_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Functions.Valid_Metadata (Text, Catalog)
         and then Procedures.Valid_Metadata (Text, Procedure_Catalog)
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Statement_Body'Result)
         and then (Statement_Body'Result.Position = 0
           or else Statement_Body'Result.Position > Scan.Position),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 2);
   function Loop_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Functions.Valid_Metadata (Text, Catalog)
         and then Procedures.Valid_Metadata (Text, Procedure_Catalog)
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Loop_Body'Result)
         and then (Loop_Body'Result.Position = 0
           or else Loop_Body'Result.Position > Scan.Position),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 1);
   function Conditional_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Functions.Valid_Metadata (Text, Catalog)
         and then Procedures.Valid_Metadata (Text, Procedure_Catalog)
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Conditional_Body'Result)
         and then (Conditional_Body'Result.Position = 0
           or else Conditional_Body'Result.Position > Scan.Position),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 1);
   function Alternative_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Functions.Valid_Metadata (Text, Catalog)
         and then Procedures.Valid_Metadata (Text, Procedure_Catalog)
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Alternative_Body'Result)
         and then (Alternative_Body'Result.Position = 0
           or else Alternative_Body'Result.Position >= Scan.Position),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 1);

   function Body_Tail_Model
     (Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata)
      return Body_Scan
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Functions.Valid_Metadata (Text, Catalog)
         and then Procedures.Valid_Metadata (Text, Procedure_Catalog)
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Body_Tail_Model'Result)
         and then (Body_Tail_Model'Result.Position = 0
           or else Body_Tail_Model'Result.Position >= Scan.Position),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 3);
   function Body_Tail_Model
     (Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata)
      return Body_Scan is
     (if Scan.Position = 0 then Invalid_Body_Model (Scan)
      elsif At_Body_Stop (Text, Scan.Position, Stop) then Scan
      else
        (declare Result : constant Body_Scan (Scan.Count) := Statement_Body (Text, Context, Scan, Catalog, Procedure_Catalog);
         begin (if Result.Position <= Scan.Position then Invalid_Body_Model (Result)
           else Body_Tail_Model (Text, Context, Result, Stop, Catalog, Procedure_Catalog))));
   function Body_Tail
     (Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata)
      return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Functions.Valid_Metadata (Text, Catalog)
         and then Procedures.Valid_Metadata (Text, Procedure_Catalog)
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => (Runtime => Valid_Body (Text, Context, Body_Tail'Result)
         and then (Body_Tail'Result.Position = 0 or else Body_Tail'Result.Position >= Scan.Position),
         Static => Body_Tail'Result = Body_Tail_Model (Text, Context, Scan, Stop, Catalog, Procedure_Catalog)),
       --  The executable wrapper also calls its rank-3 ghost model in contracts.
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 4);
   function Body_Tail
     (Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata)
      return Body_Scan is
      Result : Body_Scan (Scan.Count) := Scan;
      Before : Literal_Position;
   begin
      while Result.Position /= 0 and then not At_Body_Stop (Text, Result.Position, Stop) loop
         pragma Loop_Invariant (Valid_Body (Text, Context, Result));
         pragma Loop_Invariant (Result.Position >= Scan.Position);
         pragma Loop_Invariant (Static => Body_Tail_Model (Text, Context, Scan, Stop, Catalog, Procedure_Catalog)
           = Body_Tail_Model (Text, Context, Result, Stop, Catalog, Procedure_Catalog));
         pragma Loop_Variant (Increases => Result.Position);
         declare
            --  Keep the model step in an ordinary ghost declaration: the
            --  pinned translator rejects this local inside a declare-expression.
            Next : constant Body_Scan (Scan.Count) :=
              Statement_Body (Text, Context, Result, Catalog, Procedure_Catalog) with Ghost => Static;
            --  Numeric-variant recursive model bodies are available on ordinary
            --  ghost calls, but not on calls occurring inside assertions.
            Tail : constant Body_Scan (Scan.Count) :=
              Body_Tail_Model (Text, Context, Result, Stop, Catalog, Procedure_Catalog) with Ghost => Static;
         begin
            --  The same Statement_Body application supplies the executable step.
            pragma Assert
              (Static => Tail = Body_Tail_Model (Text, Context, Result, Stop, Catalog, Procedure_Catalog)
                and then Tail =
                (if Next.Position <= Result.Position then Invalid_Body_Model (Next)
                 else Body_Tail_Model (Text, Context, Next, Stop, Catalog, Procedure_Catalog)));
            Before := Result.Position;
            Result := Statement_Body (Text, Context, Result, Catalog, Procedure_Catalog);
            pragma Assert
              (Static => Body_Tail_Model (Text, Context, Scan, Stop, Catalog, Procedure_Catalog) =
                (if Result.Position <= Before then Invalid_Body_Model (Result)
                 else Body_Tail_Model (Text, Context, Result, Stop, Catalog, Procedure_Catalog)));
            if Result.Position <= Before then
               pragma Assert
                 (Static => Invalid_Body (Result) =
                    Body_Tail_Model (Text, Context, Scan, Stop, Catalog, Procedure_Catalog));
               return Invalid_Body (Result);
            end if;
         end;
      end loop;
      declare
         Original_Tail : constant Body_Scan (Scan.Count) :=
           Body_Tail_Model (Text, Context, Scan, Stop, Catalog, Procedure_Catalog) with Ghost => Static;
         Tail : constant Body_Scan (Scan.Count) :=
           Body_Tail_Model (Text, Context, Result, Stop, Catalog, Procedure_Catalog) with Ghost => Static;
      begin
         pragma Assert (Static => Original_Tail = Tail);
         if Result.Position = 0 then
            pragma Assert
              (Static => Tail = Body_Tail_Model (Text, Context, Result, Stop, Catalog, Procedure_Catalog)
                and then Tail = Invalid_Body_Model (Result));
            pragma Assert
              (Static => Invalid_Body (Result) =
                 Body_Tail_Model (Text, Context, Scan, Stop, Catalog, Procedure_Catalog));
            return Invalid_Body (Result);
         end if;
         pragma Assert (Static => Tail = Body_Tail_Model (Text, Context, Result, Stop, Catalog, Procedure_Catalog)
           and then Tail = Result);
         --  Expose transitive equality of the interval array separately from
         --  the surrounding scan fields before discharging model equality.
         Lemma_Flow_Equality (Original_Tail.Facts, Tail.Facts);
         Lemma_Flow_Equality (Tail.Facts, Result.Facts);
         pragma Assert (Static => Original_Tail = Result);
         pragma Assert
           (Static => Result = Body_Tail_Model (Text, Context, Scan, Stop, Catalog, Procedure_Catalog));
         return Result;
      end;
   end Body_Tail;

   function Read_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata)
      return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Functions.Valid_Metadata (Text, Catalog)
         and then Procedures.Valid_Metadata (Text, Procedure_Catalog)
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => (Runtime => Valid_Body (Text, Context, Read_Body'Result)
         and then (Read_Body'Result.Position = 0
           or else Read_Body'Result.Position > Scan.Position),
         Static => Read_Body'Result =
           (if Statement_Body (Text, Context, Scan, Catalog, Procedure_Catalog).Position = 0 then Invalid_Body (Statement_Body (Text, Context, Scan, Catalog, Procedure_Catalog))
            else Body_Tail_Model (Text, Context, Statement_Body (Text, Context, Scan, Catalog, Procedure_Catalog), Stop, Catalog, Procedure_Catalog))),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 3);
   function Read_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata)
      return Body_Scan is
      Result : constant Body_Scan (Scan.Count) := Statement_Body (Text, Context, Scan, Catalog, Procedure_Catalog);
   begin
      if Result.Position = 0 then return Invalid_Body (Result); end if;
      return Body_Tail (Text, Context, Result, Stop, Catalog, Procedure_Catalog);
   end Read_Body;

   function Statement_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata) return Body_Scan is
     (if Scan.Position = 0 then Invalid_Body (Scan)
      elsif Take_Token (Text, Scan.Position, If_Keyword) /= 0
      then Conditional_Body (Text, Context, Scan, Catalog, Procedure_Catalog)
      elsif Take_Token (Text, Scan.Position, For_Keyword) /= 0
      then Loop_Body (Text, Context, Scan, Catalog, Procedure_Catalog) else Basic_Body (Text, Context, Scan, Catalog, Procedure_Catalog));

   function Loop_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata) return Body_Scan is
      Result : Body_Scan (Scan.Count) := Body_Token (Text, Context, Scan, For_Keyword);
      First : constant Literal_Position := Skip_At (Text, Result.Position);
      After : constant Literal_Position := Name_After (Text, First);
      Low, High : Scalar_Expressions.Expression_Result;
      Index_Bounds : Scalars.Interval;
      Definite : Boolean;
   begin
      if First = 0 or else After <= First
        or else (Forbidden_Name (Text, First, After)
          and then not Name_Is (Text, First, After, "string"))
        or else (Context.Dynamic_First /= 0
          and then Name_Is (Text, First, After, "silver_arguments"))
        or else (Context.Package_First /= 0 and then Equal_Name
          (Text, Context.Package_First, Context.Package_After, First, After))
        or else Context.Scalar_Names.Count = Scalar_Expressions.Max_Bindings
      then return Invalid_Body (Scan); end if;
      if Take_Token (Text, After, Of_Keyword) /= 0 then
         if Context.Pure then return Invalid_Body (Scan); end if;
         Result.Position := Take_Token (Text, After, Of_Keyword);
         if Take_Token (Text, Result.Position, Reverse_Keyword) /= 0 then
            Result.Position := Take_Token (Text, Result.Position, Reverse_Keyword);
         end if;
         declare
            Array_First : constant Literal_Position := Skip_At (Text, Result.Position);
            Array_After : constant Literal_Position := Name_After (Text, Array_First);
            Target : constant Array_Bindings.Binding_Count :=
              Array_Target (Text, Context, Result.Position);
         begin
            --  Resolve the constant iterable once, before extending the scope.
            --  Ada hides the new binder's name in its iterator specification.
            if Array_First = 0 or else Array_After <= Array_First
              or else Equal_Name (Text, First, After, Array_First, Array_After)
              or else Target = 0 or else Context.Array_Names.Items (Target).Mutable
              or else Context.Array_Names.Items (Target).Boolean_Elements
            then return Invalid_Body (Scan); end if;
            Result.Position := Take_Token (Text, Array_After, Loop_Keyword);
            Index_Bounds := Context.Array_Names.Items (Target).Component_Bounds;
         end;
         Definite := True;
      else
         Result.Position := Take_Token (Text, After, In_Keyword);
         if Take_Token (Text, Result.Position, Reverse_Keyword) /= 0 then
            Result.Position := Take_Token (Text, Result.Position, Reverse_Keyword);
         end if;
         --  Ada captures bounds in entry flow before body reads are widened.
         declare Shape : constant Scalar_Expressions.Expression_Result :=
           Scalar_Expressions.Read_Array_Attribute (Text, Result.Position, Context.Scalar_Names,
             Context.Array_Names, First, After, Range_Query => True);
         begin
            if Shape.After /= 0 then
               Result.Position := Take_Token (Text, Shape.After, Loop_Keyword);
               Index_Bounds := Shape.Bounds;
               Definite := True;
            else
               Low := Read_Counted_Bound (Text, Context, Result.Position, Scan.Facts, First, After);
               Result.Position := Take_Token (Text, Low.After, Range_Delimiter);
               High := Read_Counted_Bound (Text, Context, Result.Position, Scan.Facts, First, After);
               Result.Position := Take_Token (Text, High.After, Loop_Keyword);
               Index_Bounds :=
                 (if Scalars.Is_Empty (Low.Bounds) or else Scalars.Is_Empty (High.Bounds)
                  then Scalars.Empty else Scalars.Normalize ((Low.Bounds.Lower, High.Bounds.Upper)));
               Definite := not Scalars.Is_Empty (Low.Bounds) and then not Scalars.Is_Empty (High.Bounds)
                 and then Low.Bounds.Upper <= High.Bounds.Lower;
            end if;
         end;
      end if;
      if Result.Position <= Scan.Position then return Invalid_Body (Scan); end if;
      Widen_Into (Context, Result.Facts);
      pragma Assert (Static => Valid_Flow (Context, Result.Facts));
      declare
         Inner : Body_Context := Context;
         Inner_Scan : Body_Scan (Scan.Count + 1);
      begin
         --  Update the copied environment in place. Returning a complete
         --  fixed-size environment from Append adds one large stack temporary
         --  per nested loop, although only this last slot changes.
         Inner.Scalar_Names.Count := Context.Scalar_Names.Count + 1;
         Inner.Scalar_Names.Items (Inner.Scalar_Names.Count) :=
           (First, After, Index_Bounds, False, Index_Bounds, False, 0, 0);
         Inner_Scan.Position := Result.Position;
         Inner_Scan.Target := Result.Target;
         Inner_Scan.Capacity := Result.Capacity;
         Inner_Scan.Assigned := Result.Assigned;
         Inner_Scan.Output := Result.Output;
         Inner_Scan.Facts.Path :=
           (if Scalars.Is_Empty (Index_Bounds) then Paths.Empty_Context else Result.Facts.Path);
         Inner_Scan.Facts.Values := (others => Scalars.Empty);
         for Index in Result.Facts.Values'Range loop
            pragma Loop_Invariant
              (Static => (for all Done in Result.Facts.Values'First .. Index - 1 =>
                Inner_Scan.Facts.Values (Done) = Result.Facts.Values (Done)));
            Inner_Scan.Facts.Values (Index) := Result.Facts.Values (Index);
         end loop;
         --  Expose the copied prefix and fresh immutable index separately.
         pragma Assert (Static =>
           (for all Index in Result.Facts.Values'Range =>
              Inner_Scan.Facts.Values (Index) = Result.Facts.Values (Index)));
         pragma Assert (Static =>
           (for all Index in 1 .. Context.Scalar_Names.Count =>
              Inner.Scalar_Names.Items (Index) = Context.Scalar_Names.Items (Index)));
         pragma Assert (Static =>
           Inner.Declaration_Count = Context.Declaration_Count);
         Inner_Scan.Facts.Values (Inner_Scan.Count) := Index_Bounds;
         pragma Assert (Static =>
           not Inner.Scalar_Names.Items (Inner_Scan.Count).Mutable);
         pragma Assert (Static =>
           Inner_Scan.Count > Inner.Declaration_Count);
         pragma Assert (Static =>
           Included (Inner_Scan.Facts.Values (Inner_Scan.Count),
                     Inner.Scalar_Names.Items (Inner_Scan.Count).Bounds));
         pragma Assert (Static => Valid_Flow (Inner, Inner_Scan.Facts));
         Inner_Scan := Read_Body (Text, Inner, Inner_Scan, End_Only, Catalog, Procedure_Catalog);
         if Inner_Scan.Position <= Scan.Position then return Invalid_Body (Scan); end if;
         Result.Position := Inner_Scan.Position;
         Result.Target := Inner_Scan.Target;
         Result.Capacity := Inner_Scan.Capacity;
         Result.Assigned := Inner_Scan.Assigned;
         Result.Output := Inner_Scan.Output;
         if Scalars.Is_Empty (Index_Bounds) then
            Result.Facts := Scan.Facts;
         elsif Definite then
            Result.Facts.Path := Inner_Scan.Facts.Path;
         else
            Result.Facts.Path := Paths.Join (Scan.Facts.Path, Inner_Scan.Facts.Path);
         end if;
         --  Result keeps widened mutables and the entry outer-index intervals.
      end;
      Result := Body_Token (Text, Context, Result, End_Keyword);
      Result := Body_Token (Text, Context, Result, Loop_Keyword);
      Result := Body_Token (Text, Context, Result, Semicolon);
      if Result.Position <= Scan.Position then return Invalid_Body (Scan); end if;
      return Result;
   end Loop_Body;

   function Conditional_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata) return Body_Scan is
      Result : Body_Scan (Scan.Count) := Body_Token (Text, Context, Scan, If_Keyword);
      Condition : Condition_Result (Scan.Count);
      Yes : Scalar_Flow (Scan.Count);
   begin
      Read_Condition_Into (Text, Context, Result.Position, Result.Facts, Condition);
      Result.Position := Condition.After;
      Result.Facts := Condition.When_True;
      Result := Body_Token (Text, Context, Result, Then_Keyword);
      if Result.Position <= Scan.Position then return Invalid_Body (Scan); end if;
      Result := Read_Body (Text, Context, Result, Arm_Boundary, Catalog, Procedure_Catalog);
      if Result.Position <= Scan.Position then return Invalid_Body (Scan); end if;
      Yes := Result.Facts;
      pragma Assert (Static => Valid_Flow (Context, Yes));
      Result.Facts := Condition.When_False;
      Result := Alternative_Body (Text, Context, Result, Catalog, Procedure_Catalog);
      pragma Assert (Static => Valid_Flow (Context, Result.Facts));
      Lemma_Joined_Flow (Context, Result.Facts, Yes);
      Join_Into (Result.Facts, Yes);
      pragma Assert (Static => Valid_Flow (Context, Result.Facts));
      Result := Body_Token (Text, Context, Result, End_Keyword);
      Result := Body_Token (Text, Context, Result, If_Keyword);
      Result := Body_Token (Text, Context, Result, Semicolon);
      if Result.Position <= Scan.Position then return Invalid_Body (Scan); end if;
      return Result;
   end Conditional_Body;

   function Alternative_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata) return Body_Scan is
      Result : Body_Scan (Scan.Count) := Scan;
      Condition : Condition_Result (Scan.Count);
      Yes : Scalar_Flow (Scan.Count);
   begin
      if Scan.Position = 0 then return Invalid_Body (Scan); end if;
      if Take_Token (Text, Scan.Position, Elsif_Keyword) /= 0 then
         Result := Body_Token (Text, Context, Result, Elsif_Keyword);
         Read_Condition_Into (Text, Context, Result.Position, Result.Facts, Condition);
         Result.Position := Condition.After;
         Result.Facts := Condition.When_True;
         Result := Body_Token (Text, Context, Result, Then_Keyword);
         if Result.Position <= Scan.Position then return Invalid_Body (Scan); end if;
         Result := Read_Body (Text, Context, Result, Arm_Boundary, Catalog, Procedure_Catalog);
         if Result.Position <= Scan.Position then return Invalid_Body (Scan); end if;
         Yes := Result.Facts;
         pragma Assert (Static => Valid_Flow (Context, Yes));
         Result.Facts := Condition.When_False;
         Result := Alternative_Body (Text, Context, Result, Catalog, Procedure_Catalog);
         pragma Assert (Static => Valid_Flow (Context, Result.Facts));
         Lemma_Joined_Flow (Context, Result.Facts, Yes);
         Join_Into (Result.Facts, Yes);
         pragma Assert (Static => Valid_Flow (Context, Result.Facts));
         return Result;
      elsif Take_Token (Text, Scan.Position, Else_Keyword) /= 0 then
         Result := Body_Token (Text, Context, Result, Else_Keyword);
         if Result.Position <= Scan.Position then return Invalid_Body (Scan); end if;
         return Read_Body (Text, Context, Result, End_Only, Catalog, Procedure_Catalog);
      elsif Take_Token (Text, Scan.Position, End_Keyword) /= 0 then
         return Scan;
      else
         return Invalid_Body (Scan);
      end if;
   end Alternative_Body;

   function Hidden_Word (Text : String; State : Parser_State; Word : String) return Boolean is
     (Function_Hides (Text, State.Functions, Word)
      or else (for some Index in 1 .. State.Procedures.Count =>
        Name_Is (Text, State.Procedures.Items (Index).First, State.Procedures.Items (Index).After, Word))
      or else (for some I in 1 .. State.Names.Count =>
        Name_Is (Text, State.Names.Items (I).First, State.Names.Items (I).After, Word))
      or else (for some I in 1 .. State.Scalar_Names.Count =>
        State.Scalar_Names.Items (I).Qualifier_First = 0 and then
        Name_Is (Text, State.Scalar_Names.Items (I).First, State.Scalar_Names.Items (I).After, Word))
      or else (for some I in 1 .. State.Boolean_Names.Count =>
        State.Boolean_Names.Items (I).Qualifier_First = 0 and then
        Name_Is (Text, State.Boolean_Names.Items (I).First, State.Boolean_Names.Items (I).After, Word))
      or else (for some I in 1 .. State.Array_Names.Names.Count =>
        Name_Is (Text, State.Array_Names.Names.Items (I).First, State.Array_Names.Names.Items (I).After, Word))
      or else (for some I in 1 .. State.Array_Names.Names.Types.Count =>
        Name_Is (Text, State.Array_Names.Names.Types.Items (I).First,
                 State.Array_Names.Names.Types.Items (I).After, Word))
      or else (for some I in 1 .. State.Subtype_Names.Count =>
        State.Subtype_Names.Items (I).Qualifier_First = 0 and then
        Name_Is (Text, State.Subtype_Names.Items (I).First, State.Subtype_Names.Items (I).After, Word)))
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State)
         and then Word'First = 1 and then Word'Length in 1 .. Max_Source_Length;
   function Hidden_Outer (Text : String; State : Parser_State) return Hidden_Marks is
     (Integer_Hidden => State.Hiding.Integer_Hidden or Hidden_Word (Text, State, "integer"),
      Boolean_Hidden => State.Hiding.Boolean_Hidden or Hidden_Word (Text, State, "boolean"),
      Character_Hidden => State.Hiding.Character_Hidden or Hidden_Word (Text, State, "character"),
      True_Hidden => State.Hiding.True_Hidden or Hidden_Word (Text, State, "true"),
      False_Hidden => State.Hiding.False_Hidden or Hidden_Word (Text, State, "false"))
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State);
   function Hide_Name
     (Text : String; Hiding : Hidden_Marks; First, After : Literal_Position)
      return Hidden_Marks is
     (Integer_Hidden => Hiding.Integer_Hidden or Name_Is (Text, First, After, "integer"),
      Boolean_Hidden => Hiding.Boolean_Hidden or Name_Is (Text, First, After, "boolean"),
      Character_Hidden => Hiding.Character_Hidden or Name_Is (Text, First, After, "character"),
      True_Hidden => Hiding.True_Hidden or Name_Is (Text, First, After, "true"),
      False_Hidden => Hiding.False_Hidden or Name_Is (Text, First, After, "false"))
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then First > 0 and then After > First and then After <= Text'Last + 1;
   type Function_Type_Result is record
      After : Literal_Position;
      Kind : Functions.Scalar_Kind;
      Bounds : Scalars.Interval;
      Type_Id : Array_Bindings.Type_Count := 0;
   end record;
   function Function_Type_At
     (Text : String; State : Parser_State; Position : Literal_Position) return Function_Type_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_State (Text, State),
       Post => Function_Type_At'Result.After = 0
         or else (Function_Type_At'Result.After in Position + 1 .. Text'Last + 1
           and then not Scalars.Is_Empty (Function_Type_At'Result.Bounds));
   function Function_Type_At
     (Text : String; State : Parser_State; Position : Literal_Position) return Function_Type_Result is
     (declare Integer_Type : constant Scalar_Constraint_Result := Scalar_Type_At (Text, State, Position);
       First : constant Literal_Position := Skip_At (Text, Position);
       After : constant Literal_Position := Take_Token (Text, First, Boolean_Name);
      begin (if Integer_Type.After /= 0 then
        (Integer_Type.After, Functions.Integer_Kind, Integer_Type.Bounds, 0)
       elsif After = 0 or else State.Hiding.Boolean_Hidden
         or else Lookup_Name (Text, State.Names, First, After) /= 0
         or else Scalar_Expressions.Lookup (Text, State.Scalar_Names, First, After) /= 0
         or else Lookup_Boolean (Text, State.Boolean_Names, First, After) /= 0
         or else Lookup_Subtype (Text, State.Subtype_Names, First, After) /= 0
         or else Array_Bindings.Lookup (Text, State.Array_Names.Names, First, After) /= 0
           or else Array_Bindings.Lookup_Type (Text, State.Array_Names.Names.Types, First, After) /= 0
         or else Functions.Lookup (Text, State.Functions, First, After) /= 0
           or else Procedures.Lookup (Text, State.Procedures, First, After) /= 0
         or else Formal_Hides (Text, State, First, After)
       then (0, Functions.Integer_Kind, Scalars.Empty, 0)
       else (After, Functions.Boolean_Kind, Scalars.Full, 0)));
   function Formal_Type_At
     (Text : String; State : Parser_State; Position : Literal_Position) return Function_Type_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_State (Text, State),
       Post => Formal_Type_At'Result.After = 0
         or else (Formal_Type_At'Result.After in Position + 1 .. Text'Last + 1
           and then not Scalars.Is_Empty (Formal_Type_At'Result.Bounds)
           and then Formal_Type_At'Result.Type_Id <= State.Array_Names.Names.Types.Count);
   function Formal_Type_At
     (Text : String; State : Parser_State; Position : Literal_Position) return Function_Type_Result is
     (declare Type_Id : constant Array_Bindings.Type_Count := Array_Type_At (Text, State, Position);
      begin (if Type_Id = 0 then Function_Type_At (Text, State, Position)
       else (Name_After (Text, Skip_At (Text, Position)), Functions.Integer_Kind,
             State.Array_Names.Names.Types.Items (Type_Id).Component_Bounds, Type_Id)));
   type Parameter_Step_Result is record
      State : Parser_State;
      Closed : Boolean;
   end record;
   function Parameter_Step
     (Text : String; State : Parser_State; Arguments : Boolean) return Parameter_Step_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Parameter_Step'Result.State)
         and then (Parameter_Step'Result.State.Position = 0
           or else (Parameter_Step'Result.State.Position > State.Position
             and then Parameter_Step'Result.State.Functions.Count = State.Functions.Count
             and then Parameter_Step'Result.State.Functions.Parameter_Count = State.Functions.Parameter_Count + 1
             and then Parameter_Step'Result.State.First_Parameter = State.First_Parameter
             and then Parameter_Step'Result.State.Pure = State.Pure));
   function Parameter_Step
     (Text : String; State : Parser_State; Arguments : Boolean) return Parameter_Step_Result is
     (declare First : constant Literal_Position := Skip_At (Text, State.Position);
       After : constant Literal_Position := Name_After (Text, First);
       Start : constant Literal_Position := Take_Token (Text, Take_Token (Text, After, Colon), In_Keyword);
       Value : constant Function_Type_Result := Formal_Type_At (Text, State, Start);
      begin (if not New_Name_Allowed (Text, State, First, After, Arguments)
        or else Start = 0 or else Value.After <= State.Position
        or else State.Functions.Parameter_Count = Functions.Max_Formals
        or else Equal_Name (Text, First, After, Skip_At (Text, Start), Value.After)
       then (Invalid_State, False)
       else (declare Next : constant Parser_State :=
         (State with delta Position => Value.After,
          Functions => Functions.Append_Formal (State.Functions, (First, After, Value.Kind, Value.Bounds, Value.Type_Id)),
          Hiding => Hide_Name (Text, State.Hiding, First, After));
        Separator : constant Literal_Position := Take_Token (Text, Value.After, Semicolon);
        Close : constant Literal_Position := Take_Token (Text, Value.After, Right_Parenthesis);
        begin (if Close /= 0 then ((Next with delta Position => Close), True)
         elsif Separator > State.Position then ((Next with delta Position => Separator), False)
         else (Invalid_State, False)))));
   function Parameters_Model
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Parameters_Model'Result)
         and then (Parameters_Model'Result.Position = 0
           or else (Parameters_Model'Result.Position > State.Position
             and then Parameters_Model'Result.Functions.Count = State.Functions.Count
             and then Parameters_Model'Result.Functions.Parameter_Count > State.Functions.Parameter_Count
             and then Parameters_Model'Result.First_Parameter = State.First_Parameter
             and then Parameters_Model'Result.Pure = State.Pure)),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - State.Position);
   function Parameters_Model
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
     (declare Next : constant Parameter_Step_Result := Parameter_Step (Text, State, Arguments);
      begin (if Next.State.Position = 0 then Invalid_State
       elsif Next.Closed then Next.State
       else Parameters_Model (Text, Next.State, Arguments)));
   function Parameters_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => (Runtime => Valid_State (Text, Parameters_At'Result)
         and then (Parameters_At'Result.Position = 0
           or else (Parameters_At'Result.Position > State.Position
             and then Parameters_At'Result.Functions.Count = State.Functions.Count
             and then Parameters_At'Result.Functions.Parameter_Count > State.Functions.Parameter_Count
             and then Parameters_At'Result.First_Parameter = State.First_Parameter
             and then Parameters_At'Result.Pure = State.Pure)),
         Static => Parameters_At'Result = Parameters_Model (Text, State, Arguments));
   function Parameters_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
      Current : Parser_State := State;
   begin
      loop
         pragma Loop_Invariant (Valid_State (Text, Current));
         pragma Loop_Invariant (Current.Position >= State.Position);
         pragma Loop_Invariant (Current.Functions.Count = State.Functions.Count);
         pragma Loop_Invariant (Current.Functions.Parameter_Count >= State.Functions.Parameter_Count);
         pragma Loop_Invariant (Current.First_Parameter = State.First_Parameter);
         pragma Loop_Invariant (Current.Pure = State.Pure);
         pragma Loop_Invariant (Static => Parameters_Model (Text, State, Arguments) =
           Parameters_Model (Text, Current, Arguments));
         pragma Loop_Variant (Increases => Current.Position);
         declare Next : constant Parameter_Step_Result := Parameter_Step (Text, Current, Arguments);
         begin
            if Next.State.Position = 0 then return Invalid_State; end if;
            if Next.Closed then return Next.State; end if;
            Current := Next.State;
         end;
      end loop;
   end Parameters_At;
   function Function_Local_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Function_Local_At'Result)
         and then (Function_Local_At'Result.Position = 0
           or else (Function_Local_At'Result.Position > State.Position
             and then Function_Local_At'Result.Functions = State.Functions
             and then Function_Local_At'Result.Procedures = State.Procedures
             and then Function_Local_At'Result.First_Procedure_Parameter = State.First_Procedure_Parameter
             and then Function_Local_At'Result.First_Parameter = State.First_Parameter
             and then Function_Local_At'Result.Pure = State.Pure));
   function Function_Local_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
     (declare Scalar : constant Parser_State := Scalar_Declaration_At (Text, State, Arguments);
       Flag : constant Parser_State := Boolean_Declaration_At (Text, State, Arguments);
      begin (if Scalar.Position /= 0 then Scalar else Flag));
   function Function_Locals_Model
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Function_Locals_Model'Result)
         and then (Function_Locals_Model'Result.Position = 0
           or else (Function_Locals_Model'Result.Position >= State.Position
             and then Function_Locals_Model'Result.Functions = State.Functions
             and then Function_Locals_Model'Result.Procedures = State.Procedures
             and then Function_Locals_Model'Result.First_Procedure_Parameter = State.First_Procedure_Parameter
             and then Function_Locals_Model'Result.First_Parameter = State.First_Parameter
             and then Function_Locals_Model'Result.Pure = State.Pure)),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - State.Position);
   function Function_Locals_Model
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
     (if State.Position = 0 then Invalid_State
      elsif Take_Token (Text, State.Position, Begin_Keyword) /= 0 then State
      else (declare Next : constant Parser_State := Function_Local_At (Text, State, Arguments);
       begin (if Next.Position = 0 then Invalid_State
              else Function_Locals_Model (Text, Next, Arguments))));
   function Function_Locals
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => (Runtime => Valid_State (Text, Function_Locals'Result)
         and then (Function_Locals'Result.Position = 0
           or else (Function_Locals'Result.Position >= State.Position
             and then Function_Locals'Result.Functions = State.Functions
             and then Function_Locals'Result.Procedures = State.Procedures
             and then Function_Locals'Result.First_Procedure_Parameter = State.First_Procedure_Parameter
             and then Function_Locals'Result.First_Parameter = State.First_Parameter
             and then Function_Locals'Result.Pure = State.Pure)),
         Static => Function_Locals'Result = Function_Locals_Model (Text, State, Arguments));
   function Function_Locals
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
      Current : Parser_State := State;
   begin
      while Current.Position /= 0 loop
         pragma Loop_Invariant (Valid_State (Text, Current));
         pragma Loop_Invariant (Current.Position >= State.Position);
         pragma Loop_Invariant (Current.Functions = State.Functions);
         pragma Loop_Invariant (Current.Procedures = State.Procedures);
         pragma Loop_Invariant (Current.First_Procedure_Parameter = State.First_Procedure_Parameter);
         pragma Loop_Invariant (Current.First_Parameter = State.First_Parameter);
         pragma Loop_Invariant (Current.Pure = State.Pure);
         pragma Loop_Invariant (Static => Function_Locals_Model (Text, State, Arguments) =
           Function_Locals_Model (Text, Current, Arguments));
         pragma Loop_Variant (Increases => Current.Position);
         if Take_Token (Text, Current.Position, Begin_Keyword) /= 0 then return Current; end if;
         Current := Function_Local_At (Text, Current, Arguments);
      end loop;
      return Invalid_State;
   end Function_Locals;
   function Append_Array_Parameter_Model
     (Frame : Parser_State; First, After : Literal_Position;
      Type_Id : Array_Bindings.Type_Count) return Parser_State
     with Ghost => Static, Global => null;
   function Append_Array_Parameter_Model
     (Frame : Parser_State; First, After : Literal_Position;
      Type_Id : Array_Bindings.Type_Count) return Parser_State is
     (if Type_Id = 0 or else Type_Id > Frame.Array_Names.Names.Types.Count
        or else Frame.Array_Names.Names.Count = Array_Bindings.Max_Bindings
        or else not Array_Bindings.Valid_Type (Frame.Array_Names.Names.Types.Items (Type_Id))
        or else (Frame.Array_Names.Names.Count > 0 and then
          Frame.Array_Names.Names.Items (Frame.Array_Names.Names.Count).View_Slot = 0)
      then Invalid_State
      else (declare Item : constant Array_Bindings.Array_Type := Frame.Array_Names.Names.Types.Items (Type_Id);
        Slot : constant Array_Bindings.Binding_Index := Frame.Array_Names.Names.Count + 1;
        Length : constant Array_Bindings.Element_Count := Array_Bindings.Element_Count
          (Scalars.Wide (Item.Bounds.Upper) - Scalars.Wide (Item.Bounds.Lower) + 1);
       begin (Frame with delta Array_Names => (Frame.Array_Names with delta Names =>
         (Frame.Array_Names.Names with delta Count => Slot,
          Items => (Frame.Array_Names.Names.Items with delta Slot =>
            (First, After, Item.Bounds, 0, Length, False, Item.Component_Bounds, False, Type_Id, Slot)))))));

   function Append_Array_Parameter
     (Frame : Parser_State; First, After : Literal_Position;
      Type_Id : Array_Bindings.Type_Count) return Parser_State
     with Global => null,
       Post => (Static => Append_Array_Parameter'Result =
         Append_Array_Parameter_Model (Frame, First, After, Type_Id)
         and then Same_Parser_State (Append_Array_Parameter'Result,
           Append_Array_Parameter_Model (Frame, First, After, Type_Id)));
   function Append_Array_Parameter
     (Frame : Parser_State; First, After : Literal_Position;
      Type_Id : Array_Bindings.Type_Count) return Parser_State is
      Result : constant Parser_State :=
        (if Type_Id = 0 or else Type_Id > Frame.Array_Names.Names.Types.Count
        or else Frame.Array_Names.Names.Count = Array_Bindings.Max_Bindings
        or else not Array_Bindings.Valid_Type (Frame.Array_Names.Names.Types.Items (Type_Id))
        or else (Frame.Array_Names.Names.Count > 0 and then
          Frame.Array_Names.Names.Items (Frame.Array_Names.Names.Count).View_Slot = 0)
      then Invalid_State
      else (declare Item : constant Array_Bindings.Array_Type := Frame.Array_Names.Names.Types.Items (Type_Id);
        Slot : constant Array_Bindings.Binding_Index := Frame.Array_Names.Names.Count + 1;
        Length : constant Array_Bindings.Element_Count := Array_Bindings.Element_Count
          (Scalars.Wide (Item.Bounds.Upper) - Scalars.Wide (Item.Bounds.Lower) + 1);
       begin (Frame with delta Array_Names => (Frame.Array_Names with delta Names =>
         (Frame.Array_Names.Names with delta Count => Slot,
          Items => (Frame.Array_Names.Names.Items with delta Slot =>
            (First, After, Item.Bounds, 0, Length, False, Item.Component_Bounds, False, Type_Id, Slot)))))));
      Model_Result : constant Parser_State :=
        Append_Array_Parameter_Model (Frame, First, After, Type_Id) with Ghost => Static;
   begin
      pragma Assert (Static => Result = Model_Result);
      Lemma_Parser_State_Same (Result, Model_Result);
      return Result;
   end Append_Array_Parameter;

   function Append_Parameter (Frame : Parser_State; Parameter : Functions.Formal) return Parser_State is
     (if Parameter.Type_Id /= 0 then
        Append_Array_Parameter (Frame, Parameter.First, Parameter.After, Parameter.Type_Id)
      elsif Parameter.Kind = Functions.Integer_Kind then
        (if Frame.Scalar_Names.Count = Scalar_Expressions.Max_Bindings then Invalid_State
         else (Frame with delta Scalar_Names => Scalar_Expressions.Append
           (Frame.Scalar_Names, (Parameter.First, Parameter.After, Parameter.Bounds,
                               False, Parameter.Bounds, False, 0, 0))))
      else (if Frame.Boolean_Names.Count = Max_Boolean_Bindings then Invalid_State
       else (Frame with delta Boolean_Names =>
         (Count => Frame.Boolean_Names.Count + 1,
          Items => (Frame.Boolean_Names.Items with delta Frame.Boolean_Names.Count + 1 =>
            (Parameter.First, Parameter.After, False, 0, 0, False, False))))))
     with Global => null;
   subtype Parameter_Cursor is Positive range 1 .. Functions.Max_Formals + 1;
   function Parameter_Frame_Model
     (Frame : Parser_State; Index : Parameter_Cursor) return Parser_State
     with Ghost => Static, Global => null,
       Pre => Index <= Frame.Functions.Parameter_Count + 1,
       Subprogram_Variant => (Decreases => Functions.Max_Formals + 1 - Index);
   function Parameter_Frame_Model
     (Frame : Parser_State; Index : Parameter_Cursor) return Parser_State is
     (if Frame.Position = 0 then Invalid_State
      elsif Index > Frame.Functions.Parameter_Count then Frame
      else (declare Next : constant Parser_State := Append_Parameter (Frame, Frame.Functions.Parameters (Index));
       begin (if Next.Position = 0 then Invalid_State
              else Parameter_Frame_Model (Next, Index + 1))));
   function Parameter_Frame (Text : String; Frame : Parser_State) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Frame) and then Frame.First_Parameter > 0,
       Post => (Runtime => Valid_State (Text, Parameter_Frame'Result)
         and then (Parameter_Frame'Result.Position = 0
           or else (Parameter_Frame'Result.Position = Frame.Position
             and then Parameter_Frame'Result.Functions = Frame.Functions
             and then Parameter_Frame'Result.Scalar_Names.Count >= Frame.Scalar_Names.Count
             and then Parameter_Frame'Result.Boolean_Names.Count >= Frame.Boolean_Names.Count)),
         Static => Parameter_Frame'Result = Parameter_Frame_Model (Frame, Frame.First_Parameter));
   function Parameter_Frame (Text : String; Frame : Parser_State) return Parser_State is
      Result : Parser_State := Frame;
      Index : Parameter_Cursor := Frame.First_Parameter;
   begin
      if Frame.Position = 0 then return Invalid_State; end if;
      while Index <= Frame.Functions.Parameter_Count loop
         pragma Loop_Invariant (Index in Frame.First_Parameter .. Frame.Functions.Parameter_Count + 1);
         pragma Loop_Invariant (Result.Functions = Frame.Functions);
         pragma Loop_Invariant (Result.Position = Frame.Position);
         pragma Loop_Invariant (Result.Scalar_Names.Count >= Frame.Scalar_Names.Count);
         pragma Loop_Invariant (Result.Boolean_Names.Count >= Frame.Boolean_Names.Count);
         pragma Loop_Invariant (Valid_State (Text, Result));
         pragma Loop_Invariant (Static => Parameter_Frame_Model (Frame, Frame.First_Parameter) =
           Parameter_Frame_Model (Result, Index));
         pragma Loop_Variant (Increases => Index);
         Result := Append_Parameter (Result, Frame.Functions.Parameters (Index));
         if Result.Position = 0 then return Invalid_State; end if;
         Index := Index + 1;
      end loop;
      return Result;
   end Parameter_Frame;
   type Procedure_Parameter_Step_Result is record
      State : Parser_State;
      Closed : Boolean;
   end record;
   function Procedure_Parameter_Step
     (Text : String; State : Parser_State; Arguments : Boolean) return Procedure_Parameter_Step_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Procedure_Parameter_Step'Result.State)
         and then (Procedure_Parameter_Step'Result.State.Position = 0
           or else (Procedure_Parameter_Step'Result.State.Position > State.Position
             and then Procedure_Parameter_Step'Result.State.Procedures.Count = State.Procedures.Count
             and then Procedure_Parameter_Step'Result.State.Functions = State.Functions
             and then Procedure_Parameter_Step'Result.State.Procedures.Parameter_Count = State.Procedures.Parameter_Count + 1
             and then Procedure_Parameter_Step'Result.State.First_Procedure_Parameter = State.First_Procedure_Parameter
             and then Procedure_Parameter_Step'Result.State.Pure = State.Pure));
   function Procedure_Parameter_Step
     (Text : String; State : Parser_State; Arguments : Boolean) return Procedure_Parameter_Step_Result is
     (declare First : constant Literal_Position := Skip_At (Text, State.Position);
       After : constant Literal_Position := Name_After (Text, First);
       Colon_End : constant Literal_Position := Take_Token (Text, After, Colon);
       In_End : constant Literal_Position := Take_Token (Text, Colon_End, In_Keyword);
       Out_End : constant Literal_Position := Take_Token
         (Text, (if In_End = 0 then Colon_End else In_End), Out_Keyword);
       Mode : constant Procedures.Parameter_Mode :=
         (if In_End = 0 then Procedures.Output
          elsif Out_End = 0 then Procedures.Input else Procedures.Input_Output);
       Start : constant Literal_Position := (if Out_End /= 0 then Out_End else In_End);
       Value : constant Function_Type_Result := Formal_Type_At (Text, State, Start);
      begin (if not New_Name_Allowed (Text, State, First, After, Arguments)
        or else Start = 0 or else Value.After <= State.Position
        or else (Value.Type_Id /= 0 and then Mode /= Procedures.Input)
        or else State.Procedures.Parameter_Count = Procedures.Max_Formals
        or else Equal_Name (Text, First, After, Skip_At (Text, Start), Value.After)
       then (Invalid_State, False)
       else (declare Next : constant Parser_State :=
         (State with delta Position => Value.After,
          Procedures => Procedures.Append_Formal (State.Procedures, (First, After, Value.Kind, Value.Bounds, Value.Type_Id, Mode)),
          Hiding => Hide_Name (Text, State.Hiding, First, After));
        Separator : constant Literal_Position := Take_Token (Text, Value.After, Semicolon);
        Close : constant Literal_Position := Take_Token (Text, Value.After, Right_Parenthesis);
        begin (if Close /= 0 then ((Next with delta Position => Close), True)
         elsif Separator > State.Position then ((Next with delta Position => Separator), False)
         else (Invalid_State, False)))));
   function Procedure_Parameters_Model
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Procedure_Parameters_Model'Result)
         and then (Procedure_Parameters_Model'Result.Position = 0
           or else (Procedure_Parameters_Model'Result.Position > State.Position
             and then Procedure_Parameters_Model'Result.Procedures.Count = State.Procedures.Count
             and then Procedure_Parameters_Model'Result.Functions = State.Functions
             and then Procedure_Parameters_Model'Result.Procedures.Parameter_Count > State.Procedures.Parameter_Count
             and then Procedure_Parameters_Model'Result.First_Procedure_Parameter = State.First_Procedure_Parameter
             and then Procedure_Parameters_Model'Result.Pure = State.Pure)),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - State.Position);
   function Procedure_Parameters_Model
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
     (declare Next : constant Procedure_Parameter_Step_Result := Procedure_Parameter_Step (Text, State, Arguments);
      begin (if Next.State.Position = 0 then Invalid_State
       elsif Next.Closed then Next.State
       else Procedure_Parameters_Model (Text, Next.State, Arguments)));
   function Procedure_Parameters_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => (Runtime => Valid_State (Text, Procedure_Parameters_At'Result)
         and then (Procedure_Parameters_At'Result.Position = 0
           or else (Procedure_Parameters_At'Result.Position > State.Position
             and then Procedure_Parameters_At'Result.Procedures.Count = State.Procedures.Count
             and then Procedure_Parameters_At'Result.Functions = State.Functions
             and then Procedure_Parameters_At'Result.Procedures.Parameter_Count > State.Procedures.Parameter_Count
             and then Procedure_Parameters_At'Result.First_Procedure_Parameter = State.First_Procedure_Parameter
             and then Procedure_Parameters_At'Result.Pure = State.Pure)),
         Static => Procedure_Parameters_At'Result = Procedure_Parameters_Model (Text, State, Arguments));
   function Procedure_Parameters_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
      Current : Parser_State := State;
   begin
      loop
         pragma Loop_Invariant (Valid_State (Text, Current));
         pragma Loop_Invariant (Current.Position >= State.Position);
         pragma Loop_Invariant (Current.Procedures.Count = State.Procedures.Count);
         pragma Loop_Invariant (Current.Functions = State.Functions);
         pragma Loop_Invariant (Current.Procedures.Parameter_Count >= State.Procedures.Parameter_Count);
         pragma Loop_Invariant (Current.First_Procedure_Parameter = State.First_Procedure_Parameter);
         pragma Loop_Invariant (Current.Pure = State.Pure);
         pragma Loop_Invariant (Static => Procedure_Parameters_Model (Text, State, Arguments) =
           Procedure_Parameters_Model (Text, Current, Arguments));
         pragma Loop_Variant (Increases => Current.Position);
         declare Next : constant Procedure_Parameter_Step_Result := Procedure_Parameter_Step (Text, Current, Arguments);
         begin
            if Next.State.Position = 0 then return Invalid_State; end if;
            if Next.Closed then return Next.State; end if;
            Current := Next.State;
         end;
      end loop;
   end Procedure_Parameters_At;
   function Append_Procedure_Parameter
     (Frame : Parser_State; Parameter : Procedures.Formal) return Parser_State is
     (if Parameter.Type_Id /= 0 then
        (if Parameter.Mode /= Procedures.Input then Invalid_State
         else Append_Array_Parameter (Frame, Parameter.First, Parameter.After, Parameter.Type_Id))
      elsif Parameter.Kind = Functions.Integer_Kind then
        (if Frame.Scalar_Names.Count = Scalar_Expressions.Max_Bindings then Invalid_State
         else (Frame with delta Scalar_Names => Scalar_Expressions.Append
           (Frame.Scalar_Names, (First => Parameter.First, After => Parameter.After,
             Bounds => Parameter.Bounds, Static => False, Declared_Bounds => Parameter.Bounds,
             Mutable => Parameter.Mode /= Procedures.Input,
             Qualifier_First => 0, Qualifier_After => 0))))
      else (if Frame.Boolean_Names.Count = Max_Boolean_Bindings then Invalid_State
       else (Frame with delta Boolean_Names =>
         (Count => Frame.Boolean_Names.Count + 1,
          Items => (Frame.Boolean_Names.Items with delta Frame.Boolean_Names.Count + 1 =>
            (Parameter.First, Parameter.After, Parameter.Mode /= Procedures.Input, 0, 0, False, False))))))
     with Global => null;
   subtype Procedure_Parameter_Cursor is Positive range 1 .. Procedures.Max_Formals + 1;
   function Procedure_Input_Frame_Model
     (Frame : Parser_State; Index : Procedure_Parameter_Cursor) return Parser_State
     with Ghost => Static, Global => null,
       Pre => Index <= Frame.Procedures.Parameter_Count + 1,
       Subprogram_Variant => (Decreases => Procedures.Max_Formals + 1 - Index);
   function Procedure_Input_Frame_Model
     (Frame : Parser_State; Index : Procedure_Parameter_Cursor) return Parser_State is
     (if Frame.Position = 0 then Invalid_State
      elsif Index > Frame.Procedures.Parameter_Count then Frame
      elsif Frame.Procedures.Parameters (Index).Mode = Procedures.Output then
        Procedure_Input_Frame_Model (Frame, Index + 1)
      else (declare Next : constant Parser_State :=
        Append_Procedure_Parameter (Frame, Frame.Procedures.Parameters (Index));
       begin (if Next.Position = 0 then Invalid_State
              else Procedure_Input_Frame_Model (Next, Index + 1))));
   function Procedure_Input_Frame (Text : String; Frame : Parser_State) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Frame) and then Frame.First_Procedure_Parameter > 0,
       Post => (Runtime => Valid_State (Text, Procedure_Input_Frame'Result)
         and then (Procedure_Input_Frame'Result.Position = 0
           or else (Procedure_Input_Frame'Result.Position = Frame.Position
             and then Procedure_Input_Frame'Result.Functions = Frame.Functions
             and then Procedure_Input_Frame'Result.Procedures = Frame.Procedures
             and then Procedure_Input_Frame'Result.First_Procedure_Parameter = Frame.First_Procedure_Parameter
             and then Procedure_Input_Frame'Result.Scalar_Names.Count >= Frame.Scalar_Names.Count
             and then Procedure_Input_Frame'Result.Boolean_Names.Count >= Frame.Boolean_Names.Count)),
         Static => Procedure_Input_Frame'Result =
           Procedure_Input_Frame_Model (Frame, Frame.First_Procedure_Parameter));
   function Procedure_Input_Frame (Text : String; Frame : Parser_State) return Parser_State is
      Result : Parser_State := Frame;
      Index : Procedure_Parameter_Cursor := Frame.First_Procedure_Parameter;
   begin
      if Frame.Position = 0 then return Invalid_State; end if;
      while Index <= Frame.Procedures.Parameter_Count loop
         pragma Loop_Invariant (Index in Frame.First_Procedure_Parameter .. Frame.Procedures.Parameter_Count + 1);
         pragma Loop_Invariant (Result.Functions = Frame.Functions);
         pragma Loop_Invariant (Result.Procedures = Frame.Procedures);
         pragma Loop_Invariant (Result.First_Procedure_Parameter = Frame.First_Procedure_Parameter);
         pragma Loop_Invariant (Result.Position = Frame.Position);
         pragma Loop_Invariant (Result.Scalar_Names.Count >= Frame.Scalar_Names.Count);
         pragma Loop_Invariant (Result.Boolean_Names.Count >= Frame.Boolean_Names.Count);
         pragma Loop_Invariant (Valid_State (Text, Result));
         pragma Loop_Invariant (Static =>
           Procedure_Input_Frame_Model (Frame, Frame.First_Procedure_Parameter) =
             Procedure_Input_Frame_Model (Result, Index));
         pragma Loop_Variant (Increases => Index);
         if Frame.Procedures.Parameters (Index).Mode /= Procedures.Output then
            Result := Append_Procedure_Parameter (Result, Frame.Procedures.Parameters (Index));
            if Result.Position = 0 then return Invalid_State; end if;
         end if;
         Index := Index + 1;
      end loop;
      return Result;
   end Procedure_Input_Frame;

   --  The fixed read frame contains locals and in/in-out parameters only.
   --  Every output is appended after its actual source assignment succeeds.
   function Procedure_Prefix_Step
     (Text : String; Read_Frame, Frame : Parser_State; Parameter : Procedures.Formal;
      Declaration_Count : Scalar_Expressions.Binding_Count)
      return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Read_Frame) and then Valid_State (Text, Frame)
         and then Declaration_Count <= Read_Frame.Scalar_Names.Count
         and then Parameter.First > 0
         and then Valid_Name_State (Text, Parameter.First, Parameter.After)
         and then not Scalars.Is_Empty (Parameter.Bounds),
       Post => Valid_State (Text, Procedure_Prefix_Step'Result)
         and then (Procedure_Prefix_Step'Result.Position = 0
           or else (Procedure_Prefix_Step'Result.Position > Frame.Position
             and then Procedure_Prefix_Step'Result.Functions = Frame.Functions
             and then Procedure_Prefix_Step'Result.Procedures = Frame.Procedures
             and then Procedure_Prefix_Step'Result.First_Procedure_Parameter = Frame.First_Procedure_Parameter
             and then Procedure_Prefix_Step'Result.Scalar_Names.Count >= Frame.Scalar_Names.Count));
   function Procedure_Prefix_Step
     (Text : String; Read_Frame, Frame : Parser_State; Parameter : Procedures.Formal;
      Declaration_Count : Scalar_Expressions.Binding_Count)
      return Parser_State is
      First : constant Literal_Position := Skip_At (Text, Frame.Position);
      After : constant Literal_Position := Name_After (Text, First);
      Context : constant Body_Context :=
        (Context_Of ((Read_Frame, False, False)) with delta Declaration_Count => Declaration_Count);
      Value_After : constant Literal_Position := Actual_After
        (Text, Context, Take_Token (Text, After, Assignment), Initial_Flow (Context),
         (Parameter.First, Parameter.After, Parameter.Kind, Parameter.Bounds, Parameter.Type_Id));
      Following : constant Literal_Position := Take_Token (Text, Value_After, Semicolon);
   begin
      if First = 0 or else After <= First
        or else not Equal_Name (Text, First, After, Parameter.First, Parameter.After)
        or else Value_After = 0 or else Following <= Frame.Position
      then return Invalid_State; end if;
      return Append_Procedure_Parameter ((Frame with delta Position => Following), Parameter);
   end Procedure_Prefix_Step;

   function Procedure_Prefix_Model
     (Text : String; Read_Frame, Frame : Parser_State; Index : Procedure_Parameter_Cursor;
      Declaration_Count : Scalar_Expressions.Binding_Count)
      return Parser_State
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Read_Frame) and then Valid_State (Text, Frame)
         and then Declaration_Count <= Read_Frame.Scalar_Names.Count
         and then Index <= Frame.Procedures.Parameter_Count + 1,
       Post => Valid_State (Text, Procedure_Prefix_Model'Result)
         and then (Procedure_Prefix_Model'Result.Position = 0
           or else (Procedure_Prefix_Model'Result.Position >= Frame.Position
             and then Procedure_Prefix_Model'Result.Functions = Frame.Functions
             and then Procedure_Prefix_Model'Result.Procedures = Frame.Procedures
             and then Procedure_Prefix_Model'Result.Scalar_Names.Count >= Frame.Scalar_Names.Count)),
       Subprogram_Variant => (Decreases => Procedures.Max_Formals + 1 - Index);
   function Procedure_Prefix_Model
     (Text : String; Read_Frame, Frame : Parser_State; Index : Procedure_Parameter_Cursor;
      Declaration_Count : Scalar_Expressions.Binding_Count)
      return Parser_State is
     (if Frame.Position = 0 then Invalid_State
      elsif Index > Frame.Procedures.Parameter_Count then Frame
      elsif Frame.Procedures.Parameters (Index).Mode /= Procedures.Output then
        Procedure_Prefix_Model (Text, Read_Frame, Frame, Index + 1, Declaration_Count)
      else (declare Next : constant Parser_State := Procedure_Prefix_Step
        (Text, Read_Frame, Frame, Frame.Procedures.Parameters (Index), Declaration_Count);
       begin (if Next.Position = 0 then Invalid_State
              else Procedure_Prefix_Model (Text, Read_Frame, Next, Index + 1, Declaration_Count))));
   function Procedure_Prefix
     (Text : String; Frame : Parser_State; Declaration_Count : Scalar_Expressions.Binding_Count) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Frame) and then Frame.First_Procedure_Parameter > 0
         and then Declaration_Count <= Frame.Scalar_Names.Count,
       Post => (Runtime => Valid_State (Text, Procedure_Prefix'Result)
         and then (Procedure_Prefix'Result.Position = 0
           or else (Procedure_Prefix'Result.Position >= Frame.Position
             and then Procedure_Prefix'Result.Functions = Frame.Functions
             and then Procedure_Prefix'Result.Procedures = Frame.Procedures
             and then Procedure_Prefix'Result.Scalar_Names.Count >= Frame.Scalar_Names.Count)),
         Static => Procedure_Prefix'Result =
           Procedure_Prefix_Model (Text, Frame, Frame, Frame.First_Procedure_Parameter, Declaration_Count));
   function Procedure_Prefix
     (Text : String; Frame : Parser_State; Declaration_Count : Scalar_Expressions.Binding_Count) return Parser_State is
      Result : Parser_State := Frame;
      Index : Procedure_Parameter_Cursor := Frame.First_Procedure_Parameter;
   begin
      if Frame.Position = 0 then return Invalid_State; end if;
      while Index <= Frame.Procedures.Parameter_Count loop
         pragma Loop_Invariant (Index in Frame.First_Procedure_Parameter .. Frame.Procedures.Parameter_Count + 1);
         pragma Loop_Invariant (Valid_State (Text, Result));
         pragma Loop_Invariant (Result.Position >= Frame.Position);
         pragma Loop_Invariant (Result.Functions = Frame.Functions);
         pragma Loop_Invariant (Result.Procedures = Frame.Procedures);
         pragma Loop_Invariant (Result.Scalar_Names.Count >= Frame.Scalar_Names.Count);
         pragma Loop_Invariant (Static =>
           Procedure_Prefix_Model (Text, Frame, Frame, Frame.First_Procedure_Parameter, Declaration_Count) =
             Procedure_Prefix_Model (Text, Frame, Result, Index, Declaration_Count));
         pragma Loop_Variant (Increases => Index);
         if Frame.Procedures.Parameters (Index).Mode = Procedures.Output then
            Result := Procedure_Prefix_Step
              (Text, Frame, Result, Frame.Procedures.Parameters (Index), Declaration_Count);
            if Result.Position = 0 then return Invalid_State; end if;
         end if;
         Index := Index + 1;
      end loop;
      return Result;
   end Procedure_Prefix;

   function Function_Return_After
     (Text : String; Context : Body_Context; Scan : Body_Scan;
      Result_Type : Function_Type_Result) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Function_Return_After'Result = 0
         or else Function_Return_After'Result in Scan.Position + 1 .. Text'Last + 1;
   function Function_Return_After
     (Text : String; Context : Body_Context; Scan : Body_Scan;
      Result_Type : Function_Type_Result) return Literal_Position is
      Start : constant Literal_Position := Take_Token (Text, Scan.Position, Return_Keyword);
   begin
      if Start = 0 then return 0; end if;
      return Actual_After (Text, Context, Start, Scan.Facts,
                           (0, 0, Result_Type.Kind, Result_Type.Bounds, 0));
   end Function_Return_After;
   procedure Lemma_Function_Metadata_Append
     (Text : String; Environment : Functions.Metadata; Item : Functions.Signature)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Functions.Valid_Metadata (Text, Environment)
         and then Environment.Count < Functions.Max_Functions
         and then Item.First > 0
         and then Valid_Name_State (Text, Item.First, Item.After)
         and then Item.Count > 0 and then Item.Formal_First > 0
         and then Item.Formal_First <= Environment.Parameter_Count
         and then Item.Count <= Environment.Parameter_Count - Item.Formal_First + 1
         and then not Scalars.Is_Empty (Item.Result_Bounds),
       Post => Functions.Valid_Metadata (Text, Functions.Append (Environment, Item))
   is
   begin
      null;
   end Lemma_Function_Metadata_Append;

   procedure Lemma_Procedure_Metadata_Append
     (Text : String; Environment : Procedures.Metadata; Item : Procedures.Signature)
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Procedures.Valid_Metadata (Text, Environment)
         and then Environment.Count < Procedures.Max_Procedures
         and then Item.First > 0
         and then Valid_Name_State (Text, Item.First, Item.After)
         and then Item.Count > 0 and then Item.Formal_First > 0
         and then Item.Formal_First <= Environment.Parameter_Count
         and then Item.Count <= Environment.Parameter_Count - Item.Formal_First + 1,
       Post => Procedures.Valid_Metadata (Text, Procedures.Append (Environment, Item))
   is
   begin
      null;
   end Lemma_Procedure_Metadata_Append;

   function Function_Body_At
     (Text : String; Outer : Parser_State; Frame : Parser_State;
      First, After : Literal_Position; Result_Type : Function_Type_Result;
      Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Outer) and then Valid_State (Text, Frame)
         and then Outer.Functions.Parameter_Count <= Frame.Functions.Parameter_Count
         and then Frame.First_Parameter > 0
         and then Frame.First_Parameter <= Frame.Functions.Parameter_Count
         and then Frame.Functions.Count < Functions.Max_Functions
         and then Valid_Name_State (Text, First, After) and then First > 0
         and then not Scalars.Is_Empty (Result_Type.Bounds),
       Post => Valid_State (Text, Function_Body_At'Result)
         and then (Function_Body_At'Result.Position = 0
           or else Function_Body_At'Result.Position > Outer.Position);
   function Function_Body_At
     (Text : String; Outer : Parser_State; Frame : Parser_State;
      First, After : Literal_Position; Result_Type : Function_Type_Result;
      Arguments : Boolean) return Parser_State is
      Locals : constant Parser_State := Function_Locals (Text, Frame, Arguments);
   begin
      Lemma_Function_Metadata_Append
        (Text, Frame.Functions,
         (First, After, Frame.First_Parameter,
          Frame.Functions.Parameter_Count - Frame.First_Parameter + 1,
          Result_Type.Kind, Result_Type.Bounds));
      if Locals.Position = 0 then return Invalid_State; end if;
      declare Bound : constant Parser_State := Parameter_Frame (Text, Locals);
      begin
         if Bound.Position = 0 then return Invalid_State; end if;
         declare
            Start : constant Parser_State := (Bound with delta Position => Take_Token (Text, Bound.Position, Begin_Keyword));
            Context : constant Body_Context := (Context_Of ((Start, False, False))
              with delta Declaration_Count => Locals.Scalar_Names.Count);
            Body_Result : constant Body_Scan := Body_Tail
              (Text, Context, Body_Of ((Start, False, False)), Return_Only, Frame.Functions, Procedures.Empty_Metadata);
            Return_End : constant Literal_Position := Function_Return_After (Text, Context, Body_Result, Result_Type);
            End_First : constant Literal_Position := Skip_At (Text,
              Take_Token (Text, Take_Token (Text, Return_End, Semicolon), End_Keyword));
            End_After : constant Literal_Position := Name_After (Text, End_First);
            Following : constant Literal_Position := Take_Token (Text, End_After, Semicolon);
         begin
            if Body_Result.Position = 0 or else Return_End = 0
              or else End_First = 0 or else End_After <= End_First
              or else not Equal_Name (Text, First, After, End_First, End_After)
              or else Following <= Outer.Position
            then return Invalid_State; end if;
            return (Outer with delta Position => Following,
              Functions => Functions.Append (Frame.Functions,
                (First, After, Frame.First_Parameter,
                 Frame.Functions.Parameter_Count - Frame.First_Parameter + 1,
                 Result_Type.Kind, Result_Type.Bounds)),
              Hiding => Hide_Name (Text, Outer.Hiding, First, After),
              Assigned_In_Functions => Outer.Assigned_In_Functions or Body_Result.Assigned,
              Subtype_Names => (Outer.Subtype_Names with delta Hidden_Calls =>
                (for Operation in Names.Operation_Kind =>
                  Outer.Subtype_Names.Hidden_Calls (Operation) or else
                    Name_Is (Text, First, After,
                      (case Operation is
                        when Names.Output_Call => "put_line",
                        when Names.Partial_Output_Call => "put",
                        when Names.Argument_Call => "first_or_default",
                        when Names.Validity_Call => "input_is_valid",
                        when Names.Reject_Call => "reject")))));
         end;
      end;
   end Function_Body_At;
   function Function_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
      Start : constant Literal_Position := Take_Token (Text, State.Position, Function_Keyword);
      First : constant Literal_Position := Skip_At (Text, Start);
      After : constant Literal_Position := Name_After (Text, First);
      Open : constant Literal_Position := Take_Token (Text, After, Left_Parenthesis);
   begin
      if Start = 0 or else Open = 0 or else State.Pure
        or else not New_Name_Allowed (Text, State, First, After, Arguments)
        or else State.Functions.Count = Functions.Max_Functions
        or else State.Functions.Parameter_Count = Functions.Max_Formals
      then return Invalid_State; end if;
      declare
         Initial : constant Parser_State :=
           (Initial_State with delta Position => Open, Pure => True,
            Context_First => State.Context_First, Package_First => State.Package_First,
            Package_After => State.Package_After,
            Array_Names => (Array_Bindings.Empty_Environment with delta Names =>
              (Array_Bindings.Empty_Metadata with delta Types => State.Array_Names.Names.Types)),
            Subtype_Names => State.Subtype_Names, Functions => State.Functions, Procedures => State.Procedures,
            Hiding => Hide_Name (Text, Hidden_Outer (Text, State), First, After),
            First_Parameter => State.Functions.Parameter_Count + 1);
         Header : constant Parser_State := Parameters_At (Text, Initial, Arguments);
      begin
         if Header.Position = 0 then return Invalid_State; end if;
         declare
            Result_Type : constant Function_Type_Result := Function_Type_At
              (Text, Header, Take_Token (Text, Header.Position, Return_Keyword));
            Body_Start : constant Literal_Position := Take_Token (Text, Result_Type.After, Is_Keyword);
         begin
            if Result_Type.After = 0 or else Body_Start = 0 then return Invalid_State; end if;
            return Function_Body_At (Text, State, (Header with delta Position => Body_Start),
                                     First, After, Result_Type, Arguments);
         end;
      end;
   end Function_Declaration_At;

   function Procedure_Body_At
     (Text : String; Outer, Frame : Parser_State;
      First, After : Literal_Position; Arguments : Boolean) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Outer) and then Valid_State (Text, Frame)
         and then Outer.Procedures.Parameter_Count <= Frame.Procedures.Parameter_Count
         and then Frame.First_Procedure_Parameter > 0
         and then Frame.First_Procedure_Parameter <= Frame.Procedures.Parameter_Count
         and then Frame.Procedures.Count < Procedures.Max_Procedures
         and then Valid_Name_State (Text, First, After) and then First > 0,
       Post => Valid_State (Text, Procedure_Body_At'Result)
         and then (Procedure_Body_At'Result.Position = 0
           or else Procedure_Body_At'Result.Position > Outer.Position);
   function Procedure_Body_At
     (Text : String; Outer, Frame : Parser_State;
      First, After : Literal_Position; Arguments : Boolean) return Parser_State is
      Locals : constant Parser_State := Function_Locals (Text, Frame, Arguments);
   begin
      if Locals.Position = 0 then return Invalid_State; end if;
      declare Bound : constant Parser_State := Procedure_Input_Frame (Text, Locals);
      begin
         if Bound.Position = 0 then return Invalid_State; end if;
         declare
            Start : constant Parser_State :=
              (Bound with delta Position => Take_Token (Text, Bound.Position, Begin_Keyword));
            Ready : constant Parser_State :=
              Procedure_Prefix (Text, Start, Locals.Scalar_Names.Count);
         begin
            if Ready.Position = 0 then return Invalid_State; end if;
            declare
               Context : constant Body_Context := (Context_Of ((Ready, False, False))
                 with delta Declaration_Count => Locals.Scalar_Names.Count);
               Initialized : constant Boolean := Ready.Position > Start.Position;
               Scan : constant Body_Scan := Body_Of ((Ready, Initialized, False));
               Body_Result : constant Body_Scan :=
                 (if Initialized then Body_Tail
                    (Text, Context, Scan, End_Only, Frame.Functions, Frame.Procedures)
                  else Read_Body
                    (Text, Context, Scan, End_Only, Frame.Functions, Frame.Procedures));
               End_First : constant Literal_Position := Skip_At (Text,
                 Take_Token (Text, Body_Result.Position, End_Keyword));
               End_After : constant Literal_Position := Name_After (Text, End_First);
               Following : constant Literal_Position := Take_Token (Text, End_After, Semicolon);
            begin
               if Body_Result.Position = 0 or else End_First = 0 or else End_After <= End_First
                 or else not Equal_Name (Text, First, After, End_First, End_After)
                 or else Following <= Outer.Position
               then return Invalid_State; end if;
               Lemma_Procedure_Metadata_Append
                 (Text, Frame.Procedures,
                  (First, After, Frame.First_Procedure_Parameter,
                   Frame.Procedures.Parameter_Count - Frame.First_Procedure_Parameter + 1));
               return (Outer with delta Position => Following,
                 Procedures => Procedures.Append (Frame.Procedures,
                   (First, After, Frame.First_Procedure_Parameter,
                    Frame.Procedures.Parameter_Count - Frame.First_Procedure_Parameter + 1)),
                 Hiding => Hide_Name (Text, Outer.Hiding, First, After),
                 Assigned_In_Functions => Outer.Assigned_In_Functions or Body_Result.Assigned,
                 Subtype_Names => (Outer.Subtype_Names with delta Hidden_Calls =>
                   (for Operation in Names.Operation_Kind =>
                     Outer.Subtype_Names.Hidden_Calls (Operation) or else
                       Name_Is (Text, First, After,
                         (case Operation is
                           when Names.Output_Call => "put_line",
                           when Names.Partial_Output_Call => "put",
                           when Names.Argument_Call => "first_or_default",
                           when Names.Validity_Call => "input_is_valid",
                           when Names.Reject_Call => "reject")))));
            end;
         end;
      end;
   end Procedure_Body_At;
   function Procedure_Declaration_At
     (Text : String; State : Parser_State; Arguments : Boolean) return Parser_State is
      Start : constant Literal_Position := Take_Token (Text, State.Position, Procedure_Keyword);
      First : constant Literal_Position := Skip_At (Text, Start);
      After : constant Literal_Position := Name_After (Text, First);
      Open : constant Literal_Position := Take_Token (Text, After, Left_Parenthesis);
   begin
      if Start = 0 or else Open = 0 or else State.Pure
        or else not New_Name_Allowed (Text, State, First, After, Arguments)
        or else State.Procedures.Count = Procedures.Max_Procedures
        or else State.Procedures.Parameter_Count = Procedures.Max_Formals
      then return Invalid_State; end if;
      declare
         Initial : constant Parser_State :=
           (Initial_State with delta Position => Open, Pure => True,
            Context_First => State.Context_First, Package_First => State.Package_First,
            Package_After => State.Package_After,
            Array_Names => (Array_Bindings.Empty_Environment with delta Names =>
              (Array_Bindings.Empty_Metadata with delta Types => State.Array_Names.Names.Types)),
            Subtype_Names => State.Subtype_Names, Functions => State.Functions,
            Procedures => State.Procedures,
            Hiding => Hide_Name (Text, Hidden_Outer (Text, State), First, After),
            First_Procedure_Parameter => State.Procedures.Parameter_Count + 1);
         Header : constant Parser_State := Procedure_Parameters_At (Text, Initial, Arguments);
      begin
         if Header.Position = 0 then return Invalid_State; end if;
         declare Body_Start : constant Literal_Position := Take_Token (Text, Header.Position, Is_Keyword);
         begin
            if Body_Start = 0 or else
              not (for some Index in Header.First_Procedure_Parameter .. Header.Procedures.Parameter_Count =>
                Header.Procedures.Parameters (Index).Mode /= Procedures.Input)
            then return Invalid_State; end if;
            return Procedure_Body_At (Text, State, (Header with delta Position => Body_Start),
                                      First, After, Arguments);
         end;
      end;
   end Procedure_Declaration_At;

   function Read_Statements
     (Text : String; Scan : Scan_Result; Stop : Token_Kind) return Scan_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Scan.State) and then Stop in Else_Keyword | End_Keyword,
       Post => Valid_State (Text, Read_Statements'Result.State);
   function Read_Statements
     (Text : String; Scan : Scan_Result; Stop : Token_Kind) return Scan_Result is
      Context : constant Body_Context := Context_Of (Scan);
      Result : constant Body_Scan (Scan.State.Scalar_Names.Count) := Read_Body
        (Text, Context, Body_Of (Scan), (if Stop = Else_Keyword then Else_Only else End_Only), Scan.State.Functions, Scan.State.Procedures);
   begin
      return (if Result.Position = 0 or else not Paths.Completed (Result.Facts.Path)
              then Invalid_Scan else Expand_Body (Context, Result, Scan.State));
   end Read_Statements;

   function Scan_Step
     (Text : String; Form : Form_Kind; Token : Token_Kind; Scan : Scan_Result)
      return Scan_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Scan.State),
       Post => Valid_State (Text, Scan_Step'Result.State);
   function Scan_Step
     (Text : String; Form : Form_Kind; Token : Token_Kind; Scan : Scan_Result)
      return Scan_Result is
     (if Token = Statements then Read_Statements
        (Text, Scan, End_Keyword)
      else (declare Next : constant Parser_State := Step (Text, Form, Token, Scan.State);
            begin (Scan with delta State => Next,
              Assigned => Scan.Assigned or Next.Assigned_In_Functions)));

   subtype Token_Index is Positive range 1 .. 101;
   function Scan_Suffix
     (Text : String; Form : Form_Kind; Next_Token : Token_Index;
      Scan : Scan_Result) return Scan_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Scan.State),
       Post => Valid_State (Text, Scan_Suffix'Result.State),
       Subprogram_Variant => (Increases => Next_Token);
   function Scan_Suffix
     (Text : String; Form : Form_Kind; Next_Token : Token_Index;
      Scan : Scan_Result) return Scan_Result is
     (if Scan.State.Position = 0 then Invalid_Scan
      elsif Next_Token > Tokens (Form)'Last then
        (if Trivia_End (Text, Scan.State.Position) = Text'Last + 1
         then Scan else Invalid_Scan)
      else Scan_Suffix (Text, Form, Next_Token + 1,
        Scan_Step (Text, Form, Tokens (Form) (Next_Token), Scan)));

   function Form_Result (Source : String; Form : Form_Kind) return Scan_Result
     with Ghost => Static, Global => null;
   function Form_Result (Source : String; Form : Form_Kind) return Scan_Result is
     (if Source'Length in 1 .. Max_Source_Length
      and then Allowed_Source (Normalized (Source))
      and then Within_Work_Budget (Normalized (Source))
      then Scan_Suffix (Normalized (Source), Form, 1, Initial_Scan)
      else Invalid_Scan);

   function Function_Model (Source : String) return Functions.Metadata is
     (if Form_Result (Source, Direct_Form).State.Position /= 0 then
        Form_Result (Source, Direct_Form).State.Functions
      elsif Form_Result (Source, Argument_Form).State.Position /= 0 then
        Form_Result (Source, Argument_Form).State.Functions
      else Functions.Empty_Metadata);

   function Procedure_Model (Source : String) return Procedures.Metadata is
     (if Form_Result (Source, Direct_Form).State.Position /= 0 then
        Form_Result (Source, Direct_Form).State.Procedures
      elsif Form_Result (Source, Argument_Form).State.Position /= 0 then
        Form_Result (Source, Argument_Form).State.Procedures
      else Procedures.Empty_Metadata);

   function Is_Member (Source : String) return Boolean is
     (for some Form in Form_Kind => Form_Result (Source, Form).State.Position /= 0);
   function Has_Arguments (Source : String) return Boolean is
     (for some Form in Form_Kind =>
        Form_Result (Source, Form).State.Position /= 0 and then Is_Argument_Form (Form));
   function Has_Assignment (Source : String) return Boolean is
     (for some Form in Form_Kind => Form_Result (Source, Form).State.Position /= 0
        and then Form_Result (Source, Form).Assigned);
   function Has_Output (Source : String) return Boolean is
     (for some Form in Form_Kind => Form_Result (Source, Form).State.Position /= 0
        and then Form_Result (Source, Form).Output);

   function Read_Form (Source : String; Form : Form_Kind) return Scan_Result
     with Global => null,
       Post => (Static => Read_Form'Result = Form_Result (Source, Form));
   function Read_Form (Source : String; Form : Form_Kind) return Scan_Result is
   begin
      if Source'Length = 0 or else Source'Length > Max_Source_Length then return Invalid_Scan; end if;
      declare
         Text : constant String := Normalized (Source);
         Scan : Scan_Result := Initial_Scan;
         Next_Token : Token_Index := 1;
      begin
         if not Allowed_Source (Text) then return Invalid_Scan; end if;
         if not Within_Work_Budget (Text) then return Invalid_Scan; end if;
         while Next_Token <= Tokens (Form)'Last loop
            pragma Loop_Invariant (Scan.State.Position > 0 and then Valid_State (Text, Scan.State));
            pragma Loop_Invariant (Static =>
              Scan_Suffix (Text, Form, 1, Initial_Scan)
              = Scan_Suffix (Text, Form, Next_Token, Scan));
            pragma Loop_Variant (Increases => Next_Token);
            Scan := Scan_Step (Text, Form, Tokens (Form) (Next_Token), Scan);
            if Scan.State.Position = 0 then return Invalid_Scan; end if;
            Next_Token := Next_Token + 1;
         end loop;
         return (if Skip_At (Text, Scan.State.Position) > Text'Last then Scan else Invalid_Scan);
      end;
   end Read_Form;

   function Local_Functions (Source : String) return Functions.Metadata is
      Direct : constant Scan_Result := Read_Form (Source, Direct_Form);
   begin
      if Direct.State.Position /= 0 then return Direct.State.Functions; end if;
      declare Argument : constant Scan_Result := Read_Form (Source, Argument_Form);
      begin
         return (if Argument.State.Position /= 0 then Argument.State.Functions
                 else Functions.Empty_Metadata);
      end;
   end Local_Functions;

   function Local_Procedures (Source : String) return Procedures.Metadata is
      Direct : constant Scan_Result := Read_Form (Source, Direct_Form);
   begin
      if Direct.State.Position /= 0 then return Direct.State.Procedures; end if;
      declare Argument : constant Scan_Result := Read_Form (Source, Argument_Form);
      begin
         return (if Argument.State.Position /= 0 then Argument.State.Procedures
                 else Procedures.Empty_Metadata);
      end;
   end Local_Procedures;

   function Accepts (Source : String) return Boolean is
   begin
      for Form in Form_Kind loop
         pragma Loop_Invariant (Static =>
           (for all Previous in Form_Kind'First .. Form =>
             (if Previous /= Form then Form_Result (Source, Previous).State.Position = 0)));
         if Read_Form (Source, Form).State.Position /= 0 then return True; end if;
      end loop;
      return False;
   end Accepts;

   function Uses_Arguments (Source : String) return Boolean is
   begin
      for Form in Form_Kind loop
         pragma Loop_Invariant (Static =>
           (for all Previous in Form_Kind'First .. Form =>
             (if Previous /= Form then Form_Result (Source, Previous).State.Position = 0
               or else not Is_Argument_Form (Previous))));
         if Read_Form (Source, Form).State.Position /= 0 and then Is_Argument_Form (Form)
         then return True; end if;
      end loop;
      return False;
   end Uses_Arguments;

   function Uses_Assignment (Source : String) return Boolean is
   begin
      for Form in Form_Kind loop
         pragma Loop_Invariant (Static =>
           (for all Previous in Form_Kind'First .. Form =>
             (if Previous /= Form then Form_Result (Source, Previous).State.Position = 0
               or else not Form_Result (Source, Previous).Assigned)));
         declare Scan : constant Scan_Result := Read_Form (Source, Form); begin
            if Scan.State.Position /= 0 and then Scan.Assigned then return True; end if;
         end;
      end loop;
      return False;
   end Uses_Assignment;

   function Uses_Output (Source : String) return Boolean is
   begin
      for Form in Form_Kind loop
         pragma Loop_Invariant (Static =>
           (for all Previous in Form_Kind'First .. Form =>
             (if Previous /= Form then Form_Result (Source, Previous).State.Position = 0
               or else not Form_Result (Source, Previous).Output)));
         declare Scan : constant Scan_Result := Read_Form (Source, Form); begin
            if Scan.State.Position /= 0 and then Scan.Output then return True; end if;
         end;
      end loop;
      return False;
   end Uses_Output;

   --  Application parsing keeps byte offsets in the shared pool while every
   --  reader's Text ends at the original compilation unit's own EOF.
   function Package_Word
     (Text : String; Position : Literal_Position; Word : String)
      return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Word'First = 1 and then Word'Length in 1 .. 16,
       Post => Package_Word'Result = 0
         or else Package_Word'Result in Position + 1 .. Text'Last + 1
   is
      First : constant Literal_Position := Skip_At (Text, Position);
      After : constant Literal_Position := Name_After (Text, First);
   begin
      return (if First /= 0 and then After > First
        and then Name_Is (Text, First, After, Word) then After else 0);
   end Package_Word;

   function Spark_Pragma_After
     (Text : String; Position : Literal_Position) return Literal_Position
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Spark_Pragma_After'Result = 0
         or else Spark_Pragma_After'Result in Position + 1 .. Text'Last + 1
   is
   begin
      return Take_Token (Text, Take_Token (Text, Take_Token (Text, Take_Token
       (Text, Take_Token (Text, Take_Token (Text, Position, Pragma_Keyword),
         SPARK_Mode_Name), Left_Parenthesis), On_Name), Right_Parenthesis), Semicolon);
   end Spark_Pragma_After;

   function Package_Name_Allowed
     (Text : String; Name : Packages.Name_Span) return Boolean is
     (Packages.Valid_Name (Text, Name)
      and then not Forbidden_Name (Text, Name.First, Name.After)
      and then not Name_Is (Text, Name.First, Name.After, "main")
      and then not Name_Is (Text, Name.First, Name.After, "ada")
      and then not Name_Is (Text, Name.First, Name.After, "interfaces")
      and then not Name_Is (Text, Name.First, Name.After, "system")
      and then not Name_Is (Text, Name.First, Name.After, "gnat")
      and then not Name_Is (Text, Name.First, Name.After, "silver_arguments")
      and then not Name_Is (Text, Name.First, Name.After, "silver_output_libc")
      and then not Name_Is (Text, Name.First, Name.After, "silver_runtime")
      and then not Name_Is (Text, Name.First, Name.After, "integer")
      and then not Name_Is (Text, Name.First, Name.After, "boolean")
      and then not Name_Is (Text, Name.First, Name.After, "character"))
     with Global => null;

   function Package_Name_Fresh
     (Text : String; Info : Packages.Metadata; Name : Packages.Name_Span)
      return Boolean is
     (Packages.Valid_Name (Text, Name)
      and then not Forbidden_Name (Text, Name.First, Name.After)
      and then not Packages.Same_Name
        (Text, Name, (Info.Name_First, Info.Name_After))
      and then Packages.Lookup_Export (Text, Info, Name) = 0
      and then Packages.Lookup_State (Text, Info, Name) = 0
      and then (for all I in 1 .. Info.Routine_Count =>
        not Packages.Same_Name (Text, Name, Info.Routines (I).Spec_Name)))
     with Global => null;

   type Package_Type_Result is record
      Name : Packages.Name_Span := Packages.No_Name;
      After : Literal_Position := 0;
      Kind : Functions.Scalar_Kind := Functions.Integer_Kind;
      Bounds : Scalars.Interval := Scalars.Empty;
      Identity : Packages.Type_Id := Packages.Integer_Type;
   end record;
   Invalid_Package_Type : constant Package_Type_Result := (others => <>);

   function Package_Type_At
     (Text : String; Frame : Parser_State; Info : Packages.Metadata;
      Position : Literal_Position) return Package_Type_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Frame) and then Position <= Text'Last + 1,
       Post => Package_Type_At'Result.After = 0
         or else (Package_Type_At'Result.After in Position + 1 .. Text'Last + 1
           and then Packages.Valid_Name (Text, Package_Type_At'Result.Name)
           and then not Scalars.Is_Empty (Package_Type_At'Result.Bounds))
   is
      First : constant Literal_Position := Skip_At (Text, Position);
      Last : constant Literal_Position := Name_After (Text, First);
      Value : constant Function_Type_Result := Function_Type_At (Text, Frame, Position);
      Export : constant Packages.Export_Count_Type :=
        Packages.Lookup_Export (Text, Info, (First, Last));
   begin
      if not Packages.Valid_Name (Text, (First, Last)) or else Value.After /= Last then
         return Invalid_Package_Type;
      elsif Value.Kind = Functions.Boolean_Kind then
         return ((First, Last), Last, Value.Kind, Scalars.Full, Packages.Boolean_Type);
      elsif Name_Is (Text, First, Last, "integer") then
         return ((First, Last), Last, Value.Kind, Value.Bounds, Packages.Integer_Type);
      elsif Export /= 0 and then Info.Exports (Export).Kind = Packages.Integer_Subtype then
         return ((First, Last), Last, Value.Kind, Value.Bounds, Export + 1);
      else
         return Invalid_Package_Type;
      end if;
   end Package_Type_At;

   type Static_Boolean_Result is record
      After : Literal_Position := 0;
      Value : Boolean := False;
   end record;
   Invalid_Static_Boolean : constant Static_Boolean_Result := (others => <>);

   function Static_Boolean_At
     (Text : String; Frame : Parser_State; Position : Literal_Position)
      return Static_Boolean_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Frame) and then Position <= Text'Last + 1,
       Post => Static_Boolean_At'Result.After = 0
         or else Static_Boolean_At'Result.After in Position + 1 .. Text'Last + 1,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 4);

   function Static_Boolean_Primary
     (Text : String; Frame : Parser_State; Position : Literal_Position)
      return Static_Boolean_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Frame) and then Position <= Text'Last + 1,
       Post => Static_Boolean_Primary'Result.After = 0
         or else Static_Boolean_Primary'Result.After in Position + 1 .. Text'Last + 1,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 1)
   is
      Open : constant Literal_Position := Take_Token (Text, Position, Left_Parenthesis);
      Reference : constant Scalar_Expressions.Name_Reference :=
        Scalar_Expressions.Read_Reference (Text, Position);
      Found : constant Boolean_Count := Lookup_Boolean
        (Text, Frame.Boolean_Names, Reference.First, Reference.After,
         Reference.Qualifier_First, Reference.Qualifier_After);
      Result : Static_Boolean_Result;
   begin
      if Position = 0 then return Invalid_Static_Boolean; end if;
      if Open /= 0 then
         Result := Static_Boolean_At (Text, Frame, Open);
         Result.After := Take_Token (Text, Result.After, Right_Parenthesis);
         return Result;
      elsif Found /= 0 and then Frame.Boolean_Names.Items (Found).Known then
         return (Reference.After, Frame.Boolean_Names.Items (Found).Value);
      elsif Reference.Qualifier_First = 0 and then Reference.First /= 0
        and then Reference.After > Reference.First
        and then Boolean_Atom_After (Text, Context_Of ((Frame, False, False)), Position) /= 0
      then
         if Name_Is (Text, Reference.First, Reference.After, "true") then
            return (Reference.After, True);
         elsif Name_Is (Text, Reference.First, Reference.After, "false") then
            return (Reference.After, False);
         end if;
      end if;
      return Invalid_Static_Boolean;
   end Static_Boolean_Primary;

   function Static_Boolean_Factor
     (Text : String; Frame : Parser_State; Position : Literal_Position)
      return Static_Boolean_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Frame) and then Position <= Text'Last + 1,
       Post => Static_Boolean_Factor'Result.After = 0
         or else Static_Boolean_Factor'Result.After in Position + 1 .. Text'Last + 1,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 2)
   is
      Negated : constant Literal_Position := Take_Token (Text, Position, Not_Keyword);
      Result : Static_Boolean_Result := Static_Boolean_Primary
        (Text, Frame, (if Negated = 0 then Position else Negated));
   begin
      if Negated /= 0 then Result.Value := not Result.Value; end if;
      return Result;
   end Static_Boolean_Factor;

   function Static_Boolean_Relation
     (Text : String; Frame : Parser_State; Position : Literal_Position)
      return Static_Boolean_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Frame) and then Position <= Text'Last + 1,
       Post => Static_Boolean_Relation'Result.After = 0
         or else Static_Boolean_Relation'Result.After in Position + 1 .. Text'Last + 1,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 3)
   is
      Left : constant Scalar_Expressions.Expression_Result :=
        Scalar_Expressions.Read_Expression (Text, Position, Frame.Scalar_Names, Elaborating => True);
      Compare : constant Comparison_Result := Scalar_Comparison_At (Text, Left.After);
      Right : Scalar_Expressions.Expression_Result;
      Flag_Left, Flag_Right : Static_Boolean_Result;
      Boolean_Compare : Comparison_Result;
   begin
      if Left.After /= 0 and then Compare.After /= 0 then
         Right := Scalar_Expressions.Read_Expression
           (Text, Compare.After, Frame.Scalar_Names, Elaborating => True);
         if Right.After = 0 or else Scalars.Is_Empty (Left.Bounds)
           or else Scalars.Is_Empty (Right.Bounds)
           or else Left.Bounds.Lower /= Left.Bounds.Upper
           or else Right.Bounds.Lower /= Right.Bounds.Upper
         then return Invalid_Static_Boolean; end if;
         return (Right.After, (case Compare.Operator is
           when Paths.Equal => Left.Bounds.Lower = Right.Bounds.Lower,
           when Paths.Unequal => Left.Bounds.Lower /= Right.Bounds.Lower,
           when Paths.Less => Left.Bounds.Lower < Right.Bounds.Lower,
           when Paths.Less_Equal => Left.Bounds.Lower <= Right.Bounds.Lower,
           when Paths.Greater => Left.Bounds.Lower > Right.Bounds.Lower,
           when Paths.Greater_Equal => Left.Bounds.Lower >= Right.Bounds.Lower));
      end if;
      Flag_Left := Static_Boolean_Factor (Text, Frame, Position);
      if Flag_Left.After = 0 then return Invalid_Static_Boolean; end if;
      Boolean_Compare := Scalar_Comparison_At (Text, Flag_Left.After);
      if Boolean_Compare.After = 0 then return Flag_Left; end if;
      if Boolean_Compare.Operator not in Paths.Equal | Paths.Unequal then
         return Invalid_Static_Boolean;
      end if;
      Flag_Right := Static_Boolean_Factor (Text, Frame, Boolean_Compare.After);
      if Flag_Right.After = 0 then return Invalid_Static_Boolean; end if;
      return (Flag_Right.After,
        (Flag_Left.Value = Flag_Right.Value) = (Boolean_Compare.Operator = Paths.Equal));
   end Static_Boolean_Relation;

   function Static_Boolean_At
     (Text : String; Frame : Parser_State; Position : Literal_Position)
      return Static_Boolean_Result
   is
      Result : Static_Boolean_Result := Static_Boolean_Relation (Text, Frame, Position);
      Operator, Selected : Chain_Kind;
      Right : Static_Boolean_Result;
   begin
      if Result.After = 0 then return Invalid_Static_Boolean; end if;
      Selected := Chain_Token (Text, Result.After);
      while Selected /= No_Chain loop
         pragma Loop_Invariant (Result.After in Position + 1 .. Text'Last + 1);
         pragma Loop_Variant (Increases => Result.After);
         Operator := Chain_Token (Text, Result.After);
         if Operator = No_Chain then return Result; end if;
         if Operator /= Selected then return Invalid_Static_Boolean; end if;
         Right := Static_Boolean_Relation (Text, Frame,
           Chain_After (Text, Result.After, Operator));
         if Right.After <= Result.After then return Invalid_Static_Boolean; end if;
         Result.Value := (case Operator is
           when Eager_And | Short_And => Result.Value and Right.Value,
           when Eager_Or | Short_Or => Result.Value or Right.Value,
           when Eager_Xor => Result.Value xor Right.Value,
           when No_Chain => Result.Value);
         Result.After := Right.After;
      end loop;
      return Result;
   end Static_Boolean_At;

   function Outer_Declaration
     (Info : Packages.Metadata; Name : Packages.Name_Span) return Boolean is
     ((for some I in 1 .. Info.Export_Count => Info.Exports (I).Name = Name)
      or else (for some I in 1 .. Info.State_Count => Info.States (I).Name = Name))
     with Global => null;

   --  Removing hidden entries changes frame indices, never declaration identity.
   --  Captures are resolved from the defining spans retained by visible entries.
   function Hide_Outer
     (Text : String; Frame : Parser_State; Info : Packages.Metadata;
      Name : Packages.Name_Span) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Frame) and then Packages.Valid_Name (Text, Name),
       Post => Valid_State (Text, Hide_Outer'Result)
   is
      Result : Parser_State := Frame;
      Scalars_Kept : Scalar_Expressions.Binding_Count := 0;
      Booleans_Kept : Boolean_Count := 0;
      Subtypes_Kept : Subtype_Count := 0;
   begin
      if Forbidden_Name (Text, Name.First, Name.After)
        or else Packages.Same_Name (Text, Name, (Info.Name_First, Info.Name_After))
      then return Invalid_State; end if;
      for I in 1 .. Frame.Scalar_Names.Count loop
         pragma Loop_Invariant (Scalars_Kept < I);
         if Frame.Scalar_Names.Items (I).Qualifier_First = 0 and then Equal_Name
           (Text, Name.First, Name.After, Frame.Scalar_Names.Items (I).First,
            Frame.Scalar_Names.Items (I).After)
         then
            if not Outer_Declaration (Info,
              (Frame.Scalar_Names.Items (I).First, Frame.Scalar_Names.Items (I).After))
            then return Invalid_State; end if;
         else
            Scalars_Kept := Scalars_Kept + 1;
            Result.Scalar_Names.Items (Scalars_Kept) := Frame.Scalar_Names.Items (I);
         end if;
      end loop;
      for I in 1 .. Frame.Boolean_Names.Count loop
         pragma Loop_Invariant (Booleans_Kept < I);
         if Frame.Boolean_Names.Items (I).Qualifier_First = 0 and then Equal_Name
           (Text, Name.First, Name.After, Frame.Boolean_Names.Items (I).First,
            Frame.Boolean_Names.Items (I).After)
         then
            if not Outer_Declaration (Info,
              (Frame.Boolean_Names.Items (I).First, Frame.Boolean_Names.Items (I).After))
            then return Invalid_State; end if;
         else
            Booleans_Kept := Booleans_Kept + 1;
            Result.Boolean_Names.Items (Booleans_Kept) := Frame.Boolean_Names.Items (I);
         end if;
      end loop;
      for I in 1 .. Frame.Subtype_Names.Count loop
         pragma Loop_Invariant (Subtypes_Kept < I);
         if Frame.Subtype_Names.Items (I).Qualifier_First = 0 and then Equal_Name
           (Text, Name.First, Name.After, Frame.Subtype_Names.Items (I).First,
            Frame.Subtype_Names.Items (I).After)
         then
            if not Outer_Declaration (Info,
              (Frame.Subtype_Names.Items (I).First, Frame.Subtype_Names.Items (I).After))
            then return Invalid_State; end if;
         else
            Subtypes_Kept := Subtypes_Kept + 1;
            Result.Subtype_Names.Items (Subtypes_Kept) := Frame.Subtype_Names.Items (I);
         end if;
      end loop;
      Result.Scalar_Names.Count := Scalars_Kept;
      Result.Boolean_Names.Count := Booleans_Kept;
      Result.Subtype_Names.Count := Subtypes_Kept;
      Result.Hiding := Hide_Name (Text, Result.Hiding, Name.First, Name.After);
      if not Valid_State (Text, Result) then return Invalid_State; end if;
      return Result;
   end Hide_Outer;

   type Package_Object_Result is record
      Frame : Parser_State := Invalid_State;
      Name : Packages.Name_Span := Packages.No_Name;
      Mark : Package_Type_Result := Invalid_Package_Type;
      Init_First, Init_After : Literal_Position := 0;
      Initial_Bounds : Scalars.Interval := Scalars.Empty;
      Constant_Object, Boolean_Value : Boolean := False;
   end record;
   Invalid_Package_Object : constant Package_Object_Result := (others => <>);

   function Package_Object_At
     (Text : String; Frame : Parser_State; Info : Packages.Metadata;
      Local : Boolean := False) return Package_Object_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Frame),
       Post => Valid_State (Text, Package_Object_At'Result.Frame)
         and then (Package_Object_At'Result.Frame.Position = 0
           or else Package_Object_At'Result.Frame.Position > Frame.Position)
   is
      First : constant Literal_Position := Skip_At (Text, Frame.Position);
      Last : constant Literal_Position := Name_After (Text, First);
      Colon_End : constant Literal_Position := Take_Token (Text, Last, Colon);
      Constant_End : constant Literal_Position := Take_Token (Text, Colon_End, Constant_Keyword);
      Result : Package_Object_Result;
      Constraint : Scalar_Constraint_Result;
      Value : Scalar_Expressions.Expression_Result;
      Flag : Static_Boolean_Result;
      After : Literal_Position;
   begin
      if not Packages.Valid_Name (Text, (First, Last)) or else Colon_End = 0 then
         return Invalid_Package_Object;
      end if;
      Result.Name := (First, Last);
      if Local then
         Result.Frame := Hide_Outer (Text, Frame, Info, Result.Name);
      elsif Package_Name_Fresh (Text, Info, Result.Name)
        and then New_Name_Allowed (Text, Frame, First, Last, False)
      then
         Result.Frame := (Frame with delta Hiding => Hide_Name (Text, Frame.Hiding, First, Last));
      else
         return Invalid_Package_Object;
      end if;
      if Result.Frame.Position = 0 then return Invalid_Package_Object; end if;
      Result.Constant_Object := Constant_End /= 0;
      Result.Mark := Package_Type_At (Text, Result.Frame, Info,
        (if Constant_End = 0 then Colon_End else Constant_End));
      if Result.Mark.After = 0 then return Invalid_Package_Object; end if;
      Constraint := (Result.Mark.After, Result.Mark.Bounds);
      if Result.Mark.Kind = Functions.Integer_Kind then
         Constraint := Scalar_Constraint_At
           (Text, Result.Mark.After, Result.Frame.Scalar_Names, Result.Mark.Bounds);
      end if;
      Result.Mark.Bounds := Constraint.Bounds;
      Result.Init_First := Skip_At (Text, Take_Token (Text, Constraint.After, Assignment));
      if Result.Init_First = 0 then return Invalid_Package_Object; end if;
      if Result.Mark.Kind = Functions.Integer_Kind then
         Value := Scalar_Expressions.Read_Expression
           (Text, Result.Init_First, Result.Frame.Scalar_Names, First, Last, Elaborating => True);
         if Value.After = 0 or else Scalars.Is_Empty (Value.Bounds)
           or else not Included (Value.Bounds, Constraint.Bounds)
           or else (not Local and then Value.Bounds.Lower /= Value.Bounds.Upper)
           or else Result.Frame.Scalar_Names.Count = Scalar_Expressions.Max_Bindings
         then return Invalid_Package_Object; end if;
         Result.Init_After := Value.After;
         Result.Initial_Bounds := Value.Bounds;
         Result.Frame.Scalar_Names := Scalar_Expressions.Append
           (Result.Frame.Scalar_Names,
            (First, Last, Value.Bounds, Constant_End /= 0 and then Value.Static,
             Constraint.Bounds, Constant_End = 0, 0, 0));
      else
         After := Boolean_Initializer_After (Text, Result.Frame, Result.Init_First, First, Last);
         if After = 0 or else Result.Frame.Boolean_Names.Count = Max_Boolean_Bindings then
            return Invalid_Package_Object;
         end if;
         if not Local then
            Flag := Static_Boolean_At (Text, Result.Frame, Result.Init_First);
            if Flag.After /= After then return Invalid_Package_Object; end if;
            Result.Boolean_Value := Flag.Value;
         end if;
         Result.Init_After := After;
         Result.Initial_Bounds := Scalars.Singleton (if Result.Boolean_Value then 1 else 0);
         Result.Frame.Boolean_Names.Count := Result.Frame.Boolean_Names.Count + 1;
         Result.Frame.Boolean_Names.Items (Result.Frame.Boolean_Names.Count) :=
           (First, Last, Constant_End = 0, 0, 0, not Local, Result.Boolean_Value);
      end if;
      Result.Frame.Position := Take_Token (Text, Result.Init_After, Semicolon);
      if Result.Frame.Position <= Frame.Position then return Invalid_Package_Object; end if;
      return Result;
   end Package_Object_At;

   procedure Append_Package_Formal
     (Frame : in out Parser_State; Name : Packages.Name_Span;
      Mark : Package_Type_Result; Mode : Procedures.Parameter_Mode)
     with Global => null,
       Pre => Name.First > 0 and then Name.After > Name.First
   is
   begin
      if Mark.Kind = Functions.Integer_Kind then
         if Frame.Scalar_Names.Count = Scalar_Expressions.Max_Bindings then
            Frame.Position := 0;
            return;
         end if;
         Frame.Scalar_Names := Scalar_Expressions.Append
           (Frame.Scalar_Names, (Name.First, Name.After, Mark.Bounds, False,
             Mark.Bounds, Mode /= Procedures.Input, 0, 0));
      elsif Mark.Kind = Functions.Boolean_Kind then
         if Frame.Boolean_Names.Count = Max_Boolean_Bindings then
            Frame.Position := 0;
            return;
         end if;
         Frame.Boolean_Names.Count := Frame.Boolean_Names.Count + 1;
         Frame.Boolean_Names.Items (Frame.Boolean_Names.Count) :=
           (Name.First, Name.After, Mode /= Procedures.Input, 0, 0, False, False);
      else
         Frame.Position := 0;
      end if;
   end Append_Package_Formal;

   --  One unified completion index covers both function and procedure bodies.
   --  Each body formal retains the original specification formal's identity.
   procedure Package_Signature_At
     (Text : String; Outer : Parser_State; Info : in out Packages.Metadata;
      Completing : Boolean; Header : out Parser_State)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Outer),
       Post => Valid_State (Text, Header)
         and then (Header.Position = 0 or else Header.Position > Outer.Position)
   is
      Original : constant Literal_Position := Skip_At (Text, Outer.Position);
      Function_End : constant Literal_Position := Take_Token (Text, Outer.Position, Function_Keyword);
      Procedure_End : constant Literal_Position := Take_Token (Text, Outer.Position, Procedure_Keyword);
      Name_First : constant Literal_Position := Skip_At
        (Text, (if Function_End /= 0 then Function_End else Procedure_End));
      Name_After : constant Literal_Position := Silver_Output_Profile.Name_After (Text, Name_First);
      Item : Packages.Routine;
      Routine_Id : Packages.Routine_Count_Type;
      Formal_Count : Packages.Formal_Count_Type := 0;
      Formal_Start : Packages.Formal_Count_Type := 0;
      Open, First, Last, Next, Mode_End : Literal_Position;
      Mode : Procedures.Parameter_Mode;
      Mark : Package_Type_Result;
      Parameter : Packages.Formal;
      Slot : Packages.Formal_Count_Type;
      Before : Literal_Position;
   begin
      Header := Invalid_State;
      if Original = 0 or else (Function_End = 0 and then Procedure_End = 0)
        or else Name_First = 0 or else Name_After <= Name_First
      then return; end if;
      if Completing then
         if Info.Completed >= Info.Routine_Count then return; end if;
         Routine_Id := Info.Completed + 1;
         Item := Info.Routines (Routine_Id);
         if Item.Count > 0 and then
           (Item.Formal_First = 0 or else Item.Formal_First > Info.Parameter_Count
            or else Item.Count > Info.Parameter_Count - Item.Formal_First + 1)
         then return; end if;
         if not Packages.Same_Name (Text, Item.Spec_Name, (Name_First, Name_After))
           or else (Item.Kind = Packages.Function_Routine) /= (Function_End /= 0)
         then return; end if;
         Formal_Start := Item.Formal_First;
         Item.Body_Name := (Name_First, Name_After);
         Item.Body_First := Original;
      else
         if Info.Routine_Count = Packages.Max_Routines
           or else not Package_Name_Fresh (Text, Info, (Name_First, Name_After))
         then return; end if;
         Routine_Id := Info.Routine_Count + 1;
         Item := (others => <>);
         Item.Kind := (if Function_End /= 0 then Packages.Function_Routine else Packages.Procedure_Routine);
         Item.Spec_Name := (Name_First, Name_After);
         Item.Spec_First := Original;
      end if;
      Header := (Outer with delta Position => Name_After, Pure => True,
        Hiding => Hide_Name (Text, Outer.Hiding, Name_First, Name_After));
      Open := Take_Token (Text, Header.Position, Left_Parenthesis);
      if Open /= 0 then
         Header.Position := Open;
         loop
            pragma Loop_Variant (Increases => Header.Position);
            Before := Header.Position;
            First := Skip_At (Text, Header.Position);
            Last := Silver_Output_Profile.Name_After (Text, First);
            if not Packages.Valid_Name (Text, (First, Last)) then Header := Invalid_State; return; end if;
            if Completing then
               if Formal_Count >= Item.Count then Header := Invalid_State; return; end if;
               Slot := Formal_Start + Formal_Count;
            else
               if Info.Parameter_Count = Packages.Max_Formals then Header := Invalid_State; return; end if;
               Slot := Info.Parameter_Count + 1;
               if Formal_Count = 0 then Formal_Start := Slot; end if;
            end if;
            if Formal_Count > 0 and then
              (for some I in Formal_Start .. Formal_Start + Formal_Count - 1 =>
                Packages.Same_Name (Text, (First, Last),
                  (if Completing then Info.Parameters (I).Body_Name else Info.Parameters (I).Spec_Name)))
            then Header := Invalid_State; return; end if;
            Header := Hide_Outer (Text, Header, Info, (First, Last));
            if Header.Position = 0 then return; end if;
            Next := Take_Token (Text, Last, Colon);
            Mode_End := Take_Token (Text, Next, In_Keyword);
            if Mode_End /= 0 then
               Next := Take_Token (Text, Mode_End, Out_Keyword);
               Mode := (if Next /= 0 then Procedures.Input_Output else Procedures.Input);
               if Next = 0 then Next := Mode_End; end if;
            else
               Next := Take_Token (Text, Next, Out_Keyword);
               Mode := Procedures.Output;
            end if;
            if Next = 0 or else (Item.Kind = Packages.Function_Routine and then Mode /= Procedures.Input) then
               Header := Invalid_State; return;
            end if;
            Mark := Package_Type_At (Text, Header, Info, Next);
            if Mark.After = 0 then Header := Invalid_State; return; end if;
            if Completing then
               Parameter := Info.Parameters (Slot);
               if not Packages.Same_Name (Text, Parameter.Spec_Name, (First, Last))
                 or else Parameter.Mode /= Mode or else Parameter.Kind /= Mark.Kind
                 or else Parameter.Type_Identity /= Mark.Identity
                 or else Parameter.Bounds /= Mark.Bounds
               then Header := Invalid_State; return; end if;
               Parameter.Body_Name := (First, Last);
               Parameter.Body_Type_Name := Mark.Name;
            else
               Parameter := (Spec_Name => (First, Last), Spec_Type_Name => Mark.Name,
                 Kind => Mark.Kind, Bounds => Mark.Bounds, Type_Identity => Mark.Identity,
                 Mode => Mode, others => <>);
               Info.Parameter_Count := Slot;
            end if;
            Info.Parameters (Slot) := Parameter;
            Formal_Count := Formal_Count + 1;
            Header.Position := Mark.After;
            --  Header resolution sees every formal, including out formals.
            Append_Package_Formal (Header, (First, Last), Mark, Mode);
            if Header.Position = 0 then return; end if;
            Next := Take_Token (Text, Header.Position, Right_Parenthesis);
            if Next /= 0 then Header.Position := Next; exit; end if;
            Header.Position := Take_Token (Text, Header.Position, Semicolon);
            if Header.Position <= Before then Header := Invalid_State; return; end if;
         end loop;
      end if;
      if Completing and then Formal_Count /= Item.Count then Header := Invalid_State; return; end if;
      if not Completing then
         Item.Count := Formal_Count;
         Item.Formal_First := Formal_Start;
      end if;
      if Item.Kind = Packages.Function_Routine then
         Mark := Package_Type_At (Text, Header, Info,
           Take_Token (Text, Header.Position, Return_Keyword));
         if Mark.After = 0 then Header := Invalid_State; return; end if;
         if Completing then
            if Item.Result_Kind /= Mark.Kind or else Item.Result_Type_Identity /= Mark.Identity
              or else Item.Result_Bounds /= Mark.Bounds
            then Header := Invalid_State; return; end if;
            Item.Body_Result_Name := Mark.Name;
         else
            Item.Result_Kind := Mark.Kind;
            Item.Result_Bounds := Mark.Bounds;
            Item.Result_Type_Identity := Mark.Identity;
            Item.Spec_Result_Name := Mark.Name;
         end if;
         Header.Position := Mark.After;
      end if;
      Header.Position := Take_Token
        (Text, Header.Position, (if Completing then Is_Keyword else Semicolon));
      if Header.Position <= Outer.Position or else not Valid_State (Text, Header) then
         Header := Invalid_State; return;
      end if;
      if not Completing then
         Item.Spec_After := Header.Position;
         Info.Routine_Count := Routine_Id;
      end if;
      Info.Routines (Routine_Id) := Item;
   end Package_Signature_At;

   procedure Package_Spec_At
     (Text : String; Info : in out Packages.Metadata; Exports : out Parser_State)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length,
       Post => Valid_State (Text, Exports)
   is
      First : constant Literal_Position := Skip_At (Text, Package_Word (Text, 1, "package"));
      Last : constant Literal_Position := Name_After (Text, First);
      Next : Parser_State;
      Object : Package_Object_Result;
      Export : Packages.Export_Declaration;
      End_First, End_Last, Following : Literal_Position;
      Before : Literal_Position;
   begin
      Exports := Invalid_State;
      if not Package_Name_Allowed (Text, (First, Last)) then return; end if;
      Info.Name_First := First;
      Info.Name_After := Last;
      Exports := (Initial_State with delta
        Position => Spark_Pragma_After (Text, Take_Token (Text, Last, Is_Keyword)),
        Package_First => First, Package_After => Last);
      if Exports.Position = 0 then return; end if;
      loop
         pragma Loop_Variant (Increases => Exports.Position);
         Before := Exports.Position;
         exit when Take_Token (Text, Exports.Position, End_Keyword) /= 0;
         if Take_Token (Text, Exports.Position, Function_Keyword) /= 0
           or else Take_Token (Text, Exports.Position, Procedure_Keyword) /= 0
         then
            Package_Signature_At (Text, Exports, Info, False, Next);
            if Next.Position = 0 or else Info.Routine_Count = 0 then Exports := Invalid_State; return; end if;
            Exports.Position := Next.Position;
            Exports.Hiding := Hide_Name (Text, Exports.Hiding,
              Info.Routines (Info.Routine_Count).Spec_Name.First,
              Info.Routines (Info.Routine_Count).Spec_Name.After);
         else
            if Info.Export_Count = Packages.Max_Exports then Exports := Invalid_State; return; end if;
            if Take_Token (Text, Exports.Position, Subtype_Keyword) /= 0 then
               Next := Subtype_Declaration_At (Text, Exports, False);
               if Next.Position = 0 then Exports := Invalid_State; return; end if;
               declare Item : constant Subtype_Binding := Next.Subtype_Names.Items (Next.Subtype_Names.Count);
               begin
                  if not Package_Name_Fresh (Text, Info, (Item.First, Item.After)) then
                     Exports := Invalid_State; return;
                  end if;
                  Export := (Name => (Item.First, Item.After), Kind => Packages.Integer_Subtype,
                    Bounds => Item.Bounds, Type_Identity => Info.Export_Count + 2, others => <>);
               end;
            else
               Object := Package_Object_At (Text, Exports, Info);
               if Object.Frame.Position = 0 or else not Object.Constant_Object then
                  Exports := Invalid_State; return;
               end if;
               Next := Object.Frame;
               Export := (Name => Object.Name,
                 Kind => (if Object.Mark.Kind = Functions.Integer_Kind
                   then Packages.Integer_Constant else Packages.Boolean_Constant),
                 Bounds => (if Object.Mark.Kind = Functions.Integer_Kind
                   then Object.Initial_Bounds else Scalars.Full),
                 Type_Name => Object.Mark.Name, Type_Identity => Object.Mark.Identity,
                 Initializer_First => Object.Init_First, Initializer_After => Object.Init_After,
                 Boolean_Value => Object.Boolean_Value);
            end if;
            Info.Export_Count := Info.Export_Count + 1;
            Info.Exports (Info.Export_Count) := Export;
            Exports := Next;
         end if;
         if Exports.Position <= Before or else not Valid_State (Text, Exports) then
            Exports := Invalid_State; return;
         end if;
      end loop;
      End_First := Skip_At (Text, Take_Token (Text, Exports.Position, End_Keyword));
      End_Last := Name_After (Text, End_First);
      Following := Take_Token (Text, End_Last, Semicolon);
      --  Without Elaborate_Body, a specification containing only these scalar
      --  constants/subtypes does not permit the mandatory package body.
      if Info.Routine_Count = 0
        or else not Packages.Same_Name (Text, (First, Last), (End_First, End_Last))
        or else Following = 0 or else Skip_At (Text, Following) /= Text'Last + 1
      then Exports := Invalid_State;
      else Exports.Position := Following;
      end if;
   end Package_Spec_At;

   type Application_Scan (Count : Scalar_Expressions.Binding_Count) is record
      Scan : Body_Scan (Count);
      Allow_Procedure_Calls : Boolean := True;
      Reads, Writes : Packages.State_Set := Packages.Empty_State_Set;
   end record;
   function Application_Of (Scan : Body_Scan) return Application_Scan is
     (Count => Scan.Count, Scan => Scan, others => <>);
   function Invalid_Application (Value : Application_Scan) return Application_Scan is
     (Value with delta Scan => Invalid_Body (Value.Scan));

   function Visible_State
     (Text : String; Context : Body_Context; Info : Packages.Metadata;
      Index : Packages.State_Index) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context),
       Post => (if Visible_State'Result then
         Index <= Info.State_Count and then Packages.Valid_Name (Text, Info.States (Index).Name))
   is
      Name : constant Packages.Name_Span := Info.States (Index).Name;
      Scalar : Scalar_Expressions.Binding_Count;
      Flag : Boolean_Count;
   begin
      if Index > Info.State_Count or else not Packages.Valid_Name (Text, Name) then return False; end if;
      Scalar := Scalar_Expressions.Lookup (Text, Context.Scalar_Names, Name.First, Name.After);
      if Info.States (Index).Kind = Functions.Integer_Kind then
         return Scalar /= 0 and then Context.Scalar_Names.Items (Scalar).First = Name.First
           and then Context.Scalar_Names.Items (Scalar).After = Name.After;
      end if;
      if Scalar /= 0 then return False; end if;
      Flag := Lookup_Boolean (Text, Context.Boolean_Names, Name.First, Name.After);
      return Flag /= 0 and then Context.Boolean_Names.Items (Flag).First = Name.First
        and then Context.Boolean_Names.Items (Flag).After = Name.After;
   end Visible_State;

   function State_Target
     (Text : String; Context : Body_Context; Info : Packages.Metadata;
      Position : Literal_Position) return Packages.State_Id
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Position <= Text'Last + 1,
       Post => State_Target'Result <= Info.State_Count
   is
      First : constant Literal_Position := Skip_At (Text, Position);
      Last : constant Literal_Position := Name_After (Text, First);
      Found : constant Packages.State_Id := Packages.Lookup_State (Text, Info, (First, Last));
   begin
      return (if Found /= 0 and then Visible_State (Text, Context, Info, Found) then Found else 0);
   end State_Target;

   function State_Reads
     (Text : String; Context : Body_Context; Info : Packages.Metadata;
      First, After : Literal_Position) return Packages.State_Set
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context)
         and then First <= Text'Last + 1 and then After <= Text'Last + 1,
       Post => Packages.Within (State_Reads'Result, Info.State_Count)
   is
      Result : Packages.State_Set := Packages.Empty_State_Set;
   begin
      if First = 0 or else After <= First then return Result; end if;
      for I in 1 .. Info.State_Count loop
         pragma Loop_Invariant
           (for all S in Packages.State_Index =>
             (if S > Info.State_Count then not Result (S)));
         if Visible_State (Text, Context, Info, I) then
            Result (I) := not Actual_Name_Free
              (Text, First, After, Info.States (I).Name.First, Info.States (I).Name.After);
         end if;
      end loop;
      return Result;
   end State_Reads;

   function Package_Callee
     (Text : String; Context : Body_Context; Info : Packages.Metadata;
      Position : Literal_Position; Kind : Packages.Routine_Kind)
      return Packages.Routine_Count_Type
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Position <= Text'Last + 1,
       Post => Package_Callee'Result <= Info.Routine_Count
   is
      Reference : constant Scalar_Expressions.Name_Reference :=
        Scalar_Expressions.Read_Reference (Text, Position);
      Callee : Packages.Routine_Count_Type;
   begin
      if Info.Completed > Info.Routine_Count or else Reference.After = 0 then return 0; end if;
      if Context.Pure then
         if Reference.Qualifier_First /= 0
           or else Scalar_Expressions.Lookup (Text, Context.Scalar_Names, Reference.First, Reference.After) /= 0
           or else Lookup_Boolean (Text, Context.Boolean_Names, Reference.First, Reference.After) /= 0
         then return 0; end if;
      elsif not Packages.Same_Name (Text,
        (Reference.Qualifier_First, Reference.Qualifier_After), (Info.Name_First, Info.Name_After))
      then return 0;
      end if;
      Callee := Packages.Lookup_Routine (Text, Info, (Reference.First, Reference.After));
      return (if Callee /= 0 and then Info.Routines (Callee).Kind = Kind then Callee else 0);
   end Package_Callee;

   type Package_Actual is record
      First, After : Literal_Position := 0;
      Target : Procedure_Actual_Result := Invalid_Procedure_Actual;
      Reads : Packages.State_Set := Packages.Empty_State_Set;
      Written_State : Packages.State_Id := 0;
   end record;
   type Package_Actual_Array is array (Packages.Formal_Index) of Package_Actual;
   type Package_Seen_Array is array (Packages.Formal_Index) of Boolean;
   type Application_Call (Count : Scalar_Expressions.Binding_Count) is record
      Value : Call_Result := Invalid_Call;
      Result : Application_Scan (Count);
   end record;

   function Package_Call_At
     (Text : String; Context : Body_Context; Input : Application_Scan;
      Info : Packages.Metadata; Position : Literal_Position;
      Kind : Packages.Routine_Kind) return Application_Call
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Input.Scan)
         and then Position <= Text'Last + 1,
       Post => Package_Call_At'Result.Count = Input.Count
         and then Package_Call_At'Result.Result.Allow_Procedure_Calls = Input.Allow_Procedure_Calls
         and then Valid_Body (Text, Context, Package_Call_At'Result.Result.Scan)
         and then (Package_Call_At'Result.Value.After = 0
           or else Package_Call_At'Result.Value.After in Position + 1 .. Text'Last + 1)
   is
      Callee : constant Packages.Routine_Count_Type := Package_Callee (Text, Context, Info, Position, Kind);
      Failure : constant Application_Call (Input.Count) :=
        (Input.Count, Invalid_Call, Invalid_Application (Input));
      Reference : constant Scalar_Expressions.Name_Reference :=
        Scalar_Expressions.Read_Reference (Text, Position);
      Result : Application_Call (Input.Count) := (Input.Count, Invalid_Call, Input);
      Actuals : Package_Actual_Array := (others => (others => <>));
      Call_Writes : Packages.State_Set := Packages.Empty_State_Set;
      Seen : Package_Seen_Array := (others => False);
      Item : Packages.Routine;
      Cursor_At, First, Last, Arrow_End, Following : Literal_Position;
      Named : Boolean := False;
      Slot : Packages.Formal_Count_Type;
      Parameter : Packages.Formal;
      Legacy_Parameter : Procedures.Formal;
      Scalar : Scalar_Expressions.Binding_Count;
   begin
      if Callee = 0 then return Failure; end if;
      Item := Info.Routines (Callee);
      Call_Writes := Item.May_Write;
      if Item.Count > 0 and then
        (Item.Formal_First = 0 or else Item.Formal_First > Info.Parameter_Count
         or else Item.Count > Info.Parameter_Count - Item.Formal_First + 1)
      then return Failure; end if;
      Cursor_At := Reference.After;
      if Item.Count > 0 then
         Cursor_At := Take_Token (Text, Cursor_At, Left_Parenthesis);
         if Cursor_At = 0 then return Failure; end if;
         for Ordinal in 1 .. Item.Count loop
            First := Skip_At (Text, Cursor_At);
            Last := Name_After (Text, First);
            Arrow_End := Take_Token (Text, Last, Arrow);
            Slot := 0;
            if Arrow_End /= 0 then
               Named := True;
               for I in Item.Formal_First .. Item.Formal_First + Item.Count - 1 loop
                  if Packages.Same_Name (Text, (First, Last), Info.Parameters (I).Spec_Name) then Slot := I; end if;
               end loop;
               Cursor_At := Arrow_End;
            elsif Named then
               return Failure;
            else
               Slot := Item.Formal_First + Ordinal - 1;
            end if;
            if Slot = 0 or else Seen (Slot) then return Failure; end if;
            Seen (Slot) := True;
            Parameter := Info.Parameters (Slot);
            Actuals (Slot).First := Cursor_At;
            if Parameter.Mode = Procedures.Input then
               Following := Actual_After (Text, Context, Cursor_At, Input.Scan.Facts,
                 (Parameter.Spec_Name.First, Parameter.Spec_Name.After, Parameter.Kind, Parameter.Bounds, 0));
            else
               Legacy_Parameter := (Parameter.Spec_Name.First, Parameter.Spec_Name.After,
                 Parameter.Kind, Parameter.Bounds, 0, Parameter.Mode);
               Actuals (Slot).Target := Procedure_Target_Actual
                 (Text, Context, Cursor_At, Input.Scan.Facts, Legacy_Parameter);
               Following := Actuals (Slot).Target.After;
               Actuals (Slot).Written_State := State_Target (Text, Context, Info, Cursor_At);
            end if;
            if Following <= Cursor_At then return Failure; end if;
            Actuals (Slot).After := Following;
            if Parameter.Mode /= Procedures.Output then
               Actuals (Slot).Reads := State_Reads (Text, Context, Info, Cursor_At, Following);
            end if;
            Result.Result.Reads := Packages.Union (Result.Result.Reads, Actuals (Slot).Reads);
            if Actuals (Slot).Written_State /= 0 then
               Call_Writes (Actuals (Slot).Written_State) := True;
            end if;
            Cursor_At := Take_Token (Text, Following,
              (if Ordinal = Item.Count then Right_Parenthesis else Comma));
            if Cursor_At = 0 then return Failure; end if;
         end loop;
      end if;
      --  Every explicit writable payload is disjoint from all other explicit
      --  payloads and from the callee's implicit state reads and writes.
      if Item.Count > 0 then
         for I in Item.Formal_First .. Item.Formal_First + Item.Count - 1 loop
            for S in 1 .. Info.State_Count loop
               if Item.May_Write (S) and then Actuals (I).Reads (S) then return Failure; end if;
            end loop;
            if Info.Parameters (I).Mode /= Procedures.Input then
               if Actuals (I).Written_State /= 0 and then
                 (Item.May_Read (Actuals (I).Written_State)
                  or else Item.May_Write (Actuals (I).Written_State))
               then return Failure; end if;
               for J in Item.Formal_First .. Item.Formal_First + Item.Count - 1 loop
                  if I /= J and then not Actual_Name_Free (Text, Actuals (J).First,
                    Actuals (J).After, Actuals (I).Target.First, Actuals (I).Target.After)
                  then return Failure; end if;
               end loop;
               Scalar := Actuals (I).Target.Scalar;
               if Scalar /= 0 then Result.Result.Scan.Facts.Values (Scalar) := Info.Parameters (I).Bounds; end if;
               Result.Result.Scan.Assigned := True;
            end if;
         end loop;
      end if;
      Result.Result.Reads := Packages.Union (Result.Result.Reads, Item.May_Read);
      Result.Result.Writes := Packages.Union (Result.Result.Writes, Call_Writes);
      for S in 1 .. Info.State_Count loop
         if Call_Writes (S) and then Visible_State (Text, Context, Info, S)
           and then Info.States (S).Kind = Functions.Integer_Kind
         then
            Scalar := Scalar_Expressions.Lookup (Text, Context.Scalar_Names,
              Info.States (S).Name.First, Info.States (S).Name.After);
            if Scalar /= 0 then
               Result.Result.Scan.Facts.Values (Scalar) := Context.Scalar_Names.Items (Scalar).Declared_Bounds;
            end if;
         end if;
      end loop;
      Result.Result.Scan.Position := Cursor_At;
      if Kind = Packages.Procedure_Routine then Result.Result.Scan.Assigned := True; end if;
      Result.Value := (Cursor_At, Item.Result_Kind, Item.Result_Bounds);
      if Cursor_At <= Position or else not Valid_Body (Text, Context, Result.Result.Scan) then return Failure; end if;
      return Result;
   end Package_Call_At;

   function Application_Basic
     (Text : String; Context : Body_Context; Input : Application_Scan;
      Info : Packages.Metadata; Catalog : Functions.Metadata;
      Procedure_Catalog : Procedures.Metadata) return Application_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Input.Scan)
         and then Functions.Valid_Metadata (Text, Catalog)
         and then Procedures.Valid_Metadata (Text, Procedure_Catalog),
       Post => Application_Basic'Result.Count = Input.Count
         and then Application_Basic'Result.Allow_Procedure_Calls = Input.Allow_Procedure_Calls
         and then Valid_Body (Text, Context, Application_Basic'Result.Scan)
         and then (Application_Basic'Result.Scan.Position = 0
           or else Application_Basic'Result.Scan.Position > Input.Scan.Position)
   is
      Result : Application_Scan (Input.Count) := Input;
      First : constant Literal_Position := Skip_At (Text, Input.Scan.Position);
      Last : constant Literal_Position := Name_After (Text, First);
      Value_First : constant Literal_Position := Take_Token (Text, Last, Assignment);
      Scalar : constant Scalar_Expressions.Binding_Count := Scalar_Target (Text, Context, Input.Scan.Position);
      Flag : constant Boolean_Count := Boolean_Target (Text, Context, Input.Scan.Position);
      State : constant Packages.State_Id := State_Target (Text, Context, Info, Input.Scan.Position);
      Called : Application_Call (Input.Count);
   begin
      if Input.Scan.Position = 0 then return Invalid_Application (Input); end if;
      if Value_First /= 0 and then (Scalar /= 0 or else Flag /= 0) then
         Called := Package_Call_At (Text, Context, Input, Info, Value_First, Packages.Function_Routine);
         if Called.Value.After /= 0 then
            Result := Called.Result;
            Result.Scan := Call_Assignment_Result (Context,
              (Result.Scan with delta Position => Input.Scan.Position), Scalar, Flag, Called.Value);
            Result.Scan := Body_Token (Text, Context, Result.Scan, Semicolon);
         else
            Result.Scan := Basic_Body (Text, Context, Input.Scan, Catalog, Procedure_Catalog);
            Result.Reads := Packages.Union (Result.Reads,
              State_Reads (Text, Context, Info, Value_First, Result.Scan.Position));
         end if;
         if State /= 0 then Result.Writes (State) := True; end if;
      elsif Input.Allow_Procedure_Calls and then
        Package_Callee (Text, Context, Info, Input.Scan.Position, Packages.Procedure_Routine) /= 0 then
         Called := Package_Call_At
           (Text, Context, Input, Info, Input.Scan.Position, Packages.Procedure_Routine);
         Result := Called.Result;
         Result.Scan := Body_Token (Text, Context, Result.Scan, Semicolon);
      else
         Result.Scan := Basic_Body (Text, Context, Input.Scan, Catalog, Procedure_Catalog);
      end if;
      if Result.Scan.Position <= Input.Scan.Position then return Invalid_Application (Input); end if;
      return Result;
   end Application_Basic;

   function Application_Statement
     (Text : String; Context : Body_Context; Input : Application_Scan;
      Info : Packages.Metadata; Catalog : Functions.Metadata;
      Procedure_Catalog : Procedures.Metadata) return Application_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Input.Scan)
         and then Functions.Valid_Metadata (Text, Catalog)
         and then Procedures.Valid_Metadata (Text, Procedure_Catalog),
       Post => Application_Statement'Result.Count = Input.Count
         and then Application_Statement'Result.Allow_Procedure_Calls = Input.Allow_Procedure_Calls
         and then Valid_Body (Text, Context, Application_Statement'Result.Scan)
         and then (Application_Statement'Result.Scan.Position = 0
           or else Application_Statement'Result.Scan.Position > Input.Scan.Position),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Input.Scan.Position, Decreases => 1);

   function Application_Tail
     (Text : String; Context : Body_Context; Input : Application_Scan;
      Info : Packages.Metadata; Stop : Body_Stop; Require_One : Boolean;
      Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata)
      return Application_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Input.Scan)
         and then Functions.Valid_Metadata (Text, Catalog)
         and then Procedures.Valid_Metadata (Text, Procedure_Catalog),
       Post => Application_Tail'Result.Count = Input.Count
         and then Application_Tail'Result.Allow_Procedure_Calls = Input.Allow_Procedure_Calls
         and then Valid_Body (Text, Context, Application_Tail'Result.Scan)
         and then (Application_Tail'Result.Scan.Position = 0
           or else Application_Tail'Result.Scan.Position >= Input.Scan.Position),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Input.Scan.Position, Decreases => 2)
   is
      Result : Application_Scan (Input.Count) := Input;
      Before : Literal_Position;
      Seen : Boolean := False;
   begin
      while Result.Scan.Position /= 0 and then not At_Body_Stop (Text, Result.Scan.Position, Stop) loop
         pragma Loop_Invariant (Valid_Body (Text, Context, Result.Scan));
         pragma Loop_Invariant (Result.Scan.Position >= Input.Scan.Position);
         pragma Loop_Invariant (Result.Allow_Procedure_Calls = Input.Allow_Procedure_Calls);
         pragma Loop_Variant (Increases => Result.Scan.Position);
         Before := Result.Scan.Position;
         Result := Application_Statement (Text, Context, Result, Info, Catalog, Procedure_Catalog);
         if Result.Scan.Position <= Before then return Invalid_Application (Result); end if;
         Seen := True;
      end loop;
      if Result.Scan.Position = 0 or else (Require_One and then not Seen) then
         return Invalid_Application (Result);
      end if;
      return Result;
   end Application_Tail;

   function Application_Statement
     (Text : String; Context : Body_Context; Input : Application_Scan;
      Info : Packages.Metadata; Catalog : Functions.Metadata;
      Procedure_Catalog : Procedures.Metadata) return Application_Scan
   is
      Result : Application_Scan (Input.Count) := Input;
      Condition : Condition_Result (Input.Count);
      Yes : Scalar_Flow (Input.Count) := Input.Scan.Facts;
      Have_Yes : Boolean := False;
      First, Last, Start : Literal_Position;
      Low, High : Scalar_Expressions.Expression_Result;
      Bounds : Scalars.Interval;
      Definite : Boolean;
   begin
      if Input.Scan.Position = 0 then return Invalid_Application (Input); end if;
      if Take_Token (Text, Input.Scan.Position, If_Keyword) /= 0 then
         Result.Scan.Position := Take_Token (Text, Result.Scan.Position, If_Keyword);
         loop
            pragma Loop_Invariant (Valid_Body (Text, Context, Result.Scan));
            pragma Loop_Invariant (Valid_Flow (Context, Yes));
            pragma Loop_Invariant (Result.Allow_Procedure_Calls = Input.Allow_Procedure_Calls);
            pragma Loop_Invariant (Result.Scan.Position > Input.Scan.Position);
            pragma Loop_Variant (Increases => Result.Scan.Position);
            Start := Result.Scan.Position;
            Read_Condition_Into (Text, Context, Start, Result.Scan.Facts, Condition);
            if Condition.After = 0 then return Invalid_Application (Input); end if;
            Result.Reads := Packages.Union (Result.Reads,
              State_Reads (Text, Context, Info, Start, Condition.After));
            Result.Scan.Position := Take_Token (Text, Condition.After, Then_Keyword);
            Result.Scan.Facts := Condition.When_True;
            if Result.Scan.Position <= Start then return Invalid_Application (Input); end if;
            Result := Application_Tail
              (Text, Context, Result, Info, Arm_Boundary, True, Catalog, Procedure_Catalog);
            if Result.Scan.Position = 0 then return Invalid_Application (Input); end if;
            if Have_Yes then
               Lemma_Joined_Flow (Context, Yes, Result.Scan.Facts);
               Join_Into (Yes, Result.Scan.Facts);
            else
               Yes := Result.Scan.Facts;
               Have_Yes := True;
            end if;
            Result.Scan.Facts := Condition.When_False;
            exit when Take_Token (Text, Result.Scan.Position, Elsif_Keyword) = 0;
            Result.Scan.Position := Take_Token (Text, Result.Scan.Position, Elsif_Keyword);
            if Result.Scan.Position <= Start then return Invalid_Application (Input); end if;
         end loop;
         if Take_Token (Text, Result.Scan.Position, Else_Keyword) /= 0 then
            Result.Scan.Position := Take_Token (Text, Result.Scan.Position, Else_Keyword);
            Result := Application_Tail
              (Text, Context, Result, Info, End_Only, True, Catalog, Procedure_Catalog);
         end if;
         if Result.Scan.Position = 0 then return Invalid_Application (Input); end if;
         Lemma_Joined_Flow (Context, Result.Scan.Facts, Yes);
         Join_Into (Result.Scan.Facts, Yes);
         Result.Scan := Body_Token (Text, Context, Result.Scan, End_Keyword);
         Result.Scan := Body_Token (Text, Context, Result.Scan, If_Keyword);
         Result.Scan := Body_Token (Text, Context, Result.Scan, Semicolon);
      elsif Take_Token (Text, Input.Scan.Position, For_Keyword) /= 0 then
         Result.Scan.Position := Take_Token (Text, Input.Scan.Position, For_Keyword);
         First := Skip_At (Text, Result.Scan.Position);
         Last := Name_After (Text, First);
         if First = 0 or else Last <= First
           or else (Forbidden_Name (Text, First, Last) and then not Name_Is (Text, First, Last, "string"))
           or else (Context.Dynamic_First /= 0 and then Name_Is (Text, First, Last, "silver_arguments"))
           or else Packages.Same_Name (Text, (First, Last), (Info.Name_First, Info.Name_After))
           or else Context.Scalar_Names.Count = Scalar_Expressions.Max_Bindings
         then return Invalid_Application (Input); end if;
         if Take_Token (Text, Last, Of_Keyword) /= 0 then
            if Context.Pure then return Invalid_Application (Input); end if;
            Result.Scan.Position := Take_Token (Text, Last, Of_Keyword);
            if Take_Token (Text, Result.Scan.Position, Reverse_Keyword) /= 0 then
               Result.Scan.Position := Take_Token (Text, Result.Scan.Position, Reverse_Keyword);
            end if;
            declare
               Array_First : constant Literal_Position := Skip_At (Text, Result.Scan.Position);
               Array_Last : constant Literal_Position := Name_After (Text, Array_First);
               Target : constant Array_Bindings.Binding_Count := Array_Target (Text, Context, Result.Scan.Position);
            begin
               if Array_First = 0 or else Array_Last <= Array_First
                 or else Equal_Name (Text, First, Last, Array_First, Array_Last)
                 or else Target = 0 or else Context.Array_Names.Items (Target).Mutable
                 or else Context.Array_Names.Items (Target).Boolean_Elements
               then return Invalid_Application (Input); end if;
               Result.Scan.Position := Take_Token (Text, Array_Last, Loop_Keyword);
               Bounds := Context.Array_Names.Items (Target).Component_Bounds;
               Definite := True;
            end;
         else
            Start := Take_Token (Text, Last, In_Keyword);
            if Take_Token (Text, Start, Reverse_Keyword) /= 0 then Start := Take_Token (Text, Start, Reverse_Keyword); end if;
            declare Shape : constant Scalar_Expressions.Expression_Result :=
              Scalar_Expressions.Read_Array_Attribute
                (Text, Start, Context.Scalar_Names, Context.Array_Names, First, Last, Range_Query => True);
            begin
               if Shape.After /= 0 then
                  Result.Scan.Position := Take_Token (Text, Shape.After, Loop_Keyword);
                  Bounds := Shape.Bounds;
                  Definite := True;
               else
                  Low := Read_Counted_Bound (Text, Context, Start, Input.Scan.Facts, First, Last);
                  High := Read_Counted_Bound (Text, Context,
                    Take_Token (Text, Low.After, Range_Delimiter), Input.Scan.Facts, First, Last);
                  Result.Scan.Position := Take_Token (Text, High.After, Loop_Keyword);
                  Bounds := (if Scalars.Is_Empty (Low.Bounds) or else Scalars.Is_Empty (High.Bounds)
                    then Scalars.Empty else Scalars.Normalize ((Low.Bounds.Lower, High.Bounds.Upper)));
                  Definite := not Scalars.Is_Empty (Low.Bounds) and then not Scalars.Is_Empty (High.Bounds)
                    and then Low.Bounds.Upper <= High.Bounds.Lower;
               end if;
            end;
            Result.Reads := Packages.Union (Result.Reads,
              State_Reads (Text, (Context with delta Mask_First => First, Mask_After => Last),
                Info, Start, Result.Scan.Position));
         end if;
         if Result.Scan.Position <= Input.Scan.Position then return Invalid_Application (Input); end if;
         Widen_Into (Context, Result.Scan.Facts);
         declare
            Inner : Body_Context := Context;
            Inside : Application_Scan (Input.Count + 1);
         begin
            Inner.Scalar_Names.Count := Inner.Scalar_Names.Count + 1;
            Inner.Scalar_Names.Items (Inner.Scalar_Names.Count) :=
              (First, Last, Bounds, False, Bounds, False, 0, 0);
            Inside.Scan.Position := Result.Scan.Position;
            Inside.Scan.Target := Result.Scan.Target;
            Inside.Scan.Capacity := Result.Scan.Capacity;
            Inside.Scan.Assigned := Result.Scan.Assigned;
            Inside.Scan.Output := Result.Scan.Output;
            Inside.Allow_Procedure_Calls := Result.Allow_Procedure_Calls;
            Inside.Reads := Result.Reads;
            Inside.Writes := Result.Writes;
            Inside.Scan.Facts.Path := (if Scalars.Is_Empty (Bounds) then Paths.Empty_Context else Result.Scan.Facts.Path);
            Inside.Scan.Facts.Values := (others => Scalars.Empty);
            for I in Result.Scan.Facts.Values'Range loop
               pragma Loop_Invariant
                 (for all Done in Result.Scan.Facts.Values'First .. I - 1 =>
                   Inside.Scan.Facts.Values (Done) = Result.Scan.Facts.Values (Done));
               Inside.Scan.Facts.Values (I) := Result.Scan.Facts.Values (I);
            end loop;
            Inside.Scan.Facts.Values (Inside.Count) := Bounds;
            Inside := Application_Tail (Text, Inner, Inside, Info, End_Only, True, Catalog, Procedure_Catalog);
            if Inside.Scan.Position = 0 then return Invalid_Application (Input); end if;
            Result.Scan.Position := Inside.Scan.Position;
            Result.Scan.Target := Inside.Scan.Target;
            Result.Scan.Capacity := Inside.Scan.Capacity;
            Result.Scan.Assigned := Inside.Scan.Assigned;
            Result.Scan.Output := Inside.Scan.Output;
            --  Syntactic effects survive even a statically empty loop.
            Result.Reads := Inside.Reads;
            Result.Writes := Inside.Writes;
            if Scalars.Is_Empty (Bounds) then Result.Scan.Facts := Input.Scan.Facts;
            elsif Definite then Result.Scan.Facts.Path := Inside.Scan.Facts.Path;
            else Result.Scan.Facts.Path := Paths.Join (Input.Scan.Facts.Path, Inside.Scan.Facts.Path);
            end if;
         end;
         Result.Scan := Body_Token (Text, Context, Result.Scan, End_Keyword);
         Result.Scan := Body_Token (Text, Context, Result.Scan, Loop_Keyword);
         Result.Scan := Body_Token (Text, Context, Result.Scan, Semicolon);
      else
         return Application_Basic (Text, Context, Input, Info, Catalog, Procedure_Catalog);
      end if;
      if Result.Scan.Position <= Input.Scan.Position or else not Valid_Body (Text, Context, Result.Scan) then
         return Invalid_Application (Input);
      end if;
      return Result;
   end Application_Statement;

   function Routine_Frame
     (Text : String; Globals : Parser_State; Info : Packages.Metadata;
      Routine : Packages.Routine_Index; Position : Literal_Position)
      return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Globals) and then Position <= Text'Last + 1,
       Post => Valid_State (Text, Routine_Frame'Result)
   is
      Result : Parser_State := (Globals with delta Position => Position, Pure => True,
        Scalar_Names => Scalar_Expressions.Body_Environment (Globals.Scalar_Names));
      Item : constant Packages.Routine := Info.Routines (Routine);
      Parameter : Packages.Formal;
      Mark : Package_Type_Result;
   begin
      for I in 1 .. Result.Boolean_Names.Count loop
         if Result.Boolean_Names.Items (I).Mutable then Result.Boolean_Names.Items (I).Known := False; end if;
      end loop;
      if Item.Count > 0 then
         if Item.Formal_First = 0 or else Item.Formal_First > Info.Parameter_Count
           or else Item.Count > Info.Parameter_Count - Item.Formal_First + 1
         then return Invalid_State; end if;
         --  Even an uninitialized out formal hides a same-spelled global.
         for I in Item.Formal_First .. Item.Formal_First + Item.Count - 1 loop
            Parameter := Info.Parameters (I);
            if not Packages.Valid_Name (Text, Parameter.Body_Name) then return Invalid_State; end if;
            Result := Hide_Outer (Text, Result, Info, Parameter.Body_Name);
            if Result.Position = 0 then return Invalid_State; end if;
         end loop;
         for I in Item.Formal_First .. Item.Formal_First + Item.Count - 1 loop
            Parameter := Info.Parameters (I);
            if Parameter.Mode /= Procedures.Output then
               Mark := (Name => Parameter.Body_Type_Name, After => Parameter.Body_Type_Name.After,
                 Kind => Parameter.Kind, Bounds => Parameter.Bounds, Identity => Parameter.Type_Identity);
               Append_Package_Formal (Result, Parameter.Body_Name, Mark, Parameter.Mode);
               if Result.Position = 0 then return Invalid_State; end if;
            end if;
         end loop;
      end if;
      if not Valid_State (Text, Result) then return Invalid_State; end if;
      return Result;
   end Routine_Frame;

   procedure Package_Completion_At
     (Text : String; Globals : in out Parser_State; Info : in out Packages.Metadata)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Globals),
       Post => Valid_State (Text, Globals)
   is
      Original : constant Literal_Position := Globals.Position;
      Header, Frame : Parser_State;
      Item : Packages.Routine;
      Object : Package_Object_Result;
      Reads : Packages.State_Set := Packages.Empty_State_Set;
      Formal : Packages.Formal;
      Mark : Package_Type_Result;
      Index : Packages.Routine_Count_Type;
      First, Last, Value_First, Value_After, Following, Before : Literal_Position;
      Initialized : Boolean := False;
   begin
      if Info.Completed >= Info.Routine_Count then Globals := Invalid_State; return; end if;
      Index := Info.Completed + 1;
      Package_Signature_At (Text, Globals, Info, True, Header);
      if Header.Position = 0 then Globals := Invalid_State; return; end if;
      Item := Info.Routines (Index);
      if Item.Count > 0 and then
        (Item.Formal_First = 0 or else Item.Formal_First > Info.Parameter_Count
         or else Item.Count > Info.Parameter_Count - Item.Formal_First + 1)
      then Globals := Invalid_State; return; end if;
      Frame := Routine_Frame (Text, Globals, Info, Index, Header.Position);
      if Frame.Position = 0 then Globals := Invalid_State; return; end if;
      while Take_Token (Text, Frame.Position, Begin_Keyword) = 0 loop
         pragma Loop_Variant (Increases => Frame.Position);
         Before := Frame.Position;
         First := Skip_At (Text, Frame.Position);
         Last := Name_After (Text, First);
         if Item.Count > 0 and then
           (for some I in Item.Formal_First .. Item.Formal_First + Item.Count - 1 =>
             Packages.Same_Name (Text, (First, Last), Info.Parameters (I).Body_Name))
         then Globals := Invalid_State; return; end if;
         Object := Package_Object_At (Text, Frame, Info, Local => True);
         if Object.Frame.Position <= Before then Globals := Invalid_State; return; end if;
         Reads := Packages.Union (Reads, State_Reads
           (Text, Context_Of ((Object.Frame, False, False)), Info, Object.Init_First, Object.Init_After));
         Frame := Object.Frame;
      end loop;
      Frame.Position := Take_Token (Text, Frame.Position, Begin_Keyword);
      if Item.Count > 0 then
         for I in Item.Formal_First .. Item.Formal_First + Item.Count - 1 loop
            Formal := Info.Parameters (I);
            if Formal.Mode = Procedures.Output then
               if not Packages.Valid_Name (Text, Formal.Body_Name) then Globals := Invalid_State; return; end if;
               First := Skip_At (Text, Frame.Position);
               Last := Name_After (Text, First);
               if not Packages.Same_Name (Text, (First, Last), Formal.Body_Name) then
                  Globals := Invalid_State; return;
               end if;
               Value_First := Take_Token (Text, Last, Assignment);
               declare Context : constant Body_Context :=
                 (Context_Of ((Frame, False, False)) with delta Declaration_Count => 0);
               begin
                  Value_After := Actual_After (Text, Context, Value_First, Initial_Flow (Context),
                    (Formal.Body_Name.First, Formal.Body_Name.After, Formal.Kind, Formal.Bounds, 0));
                  Reads := Packages.Union (Reads, State_Reads (Text, Context, Info, Value_First, Value_After));
               end;
               Following := Take_Token (Text, Value_After, Semicolon);
               if Following <= Frame.Position then Globals := Invalid_State; return; end if;
               Frame.Position := Following;
               Initialized := True;
            end if;
         end loop;
         --  All prefix RHSs use the same frame without any output formal.
         --  Only the completed prefix introduces the writable outputs.
         for I in Item.Formal_First .. Item.Formal_First + Item.Count - 1 loop
            Formal := Info.Parameters (I);
            if Formal.Mode = Procedures.Output then
               if not Packages.Valid_Name (Text, Formal.Body_Name) then Globals := Invalid_State; return; end if;
               Mark := (Formal.Body_Type_Name, Formal.Body_Type_Name.After,
                 Formal.Kind, Formal.Bounds, Formal.Type_Identity);
               Append_Package_Formal (Frame, Formal.Body_Name, Mark, Formal.Mode);
               if Frame.Position = 0 then Globals := Invalid_State; return; end if;
            end if;
         end loop;
      end if;
      declare
         Context : constant Body_Context :=
           (Context_Of ((Frame, Initialized, False)) with delta Declaration_Count => 0);
         Input : Application_Scan := Application_Of (Body_Of ((Frame, Initialized, False)));
         Result : Application_Scan (Input.Count);
      begin
         Input.Allow_Procedure_Calls := Item.Kind = Packages.Procedure_Routine;
         Input.Reads := Reads;
         Result := Application_Tail (Text, Context, Input, Info,
           (if Item.Kind = Packages.Function_Routine then Return_Only else End_Only),
           Item.Kind = Packages.Procedure_Routine and then not Initialized,
           Functions.Empty_Metadata, Procedures.Empty_Metadata);
         if Result.Scan.Position = 0 then Globals := Invalid_State; return; end if;
         if Item.Kind = Packages.Function_Routine then
            Value_First := Take_Token (Text, Result.Scan.Position, Return_Keyword);
            Value_After := Function_Return_After (Text, Context, Result.Scan,
              (0, Item.Result_Kind, Item.Result_Bounds, 0));
            Result.Reads := Packages.Union (Result.Reads,
              State_Reads (Text, Context, Info, Value_First, Value_After));
            Result.Scan.Position := Take_Token (Text, Value_After, Semicolon);
            if Result.Scan.Position = 0 or else Result.Writes /= Packages.Empty_State_Set then
               Globals := Invalid_State; return;
            end if;
         end if;
         First := Skip_At (Text, Take_Token (Text, Result.Scan.Position, End_Keyword));
         Last := Name_After (Text, First);
         Following := Take_Token (Text, Last, Semicolon);
         if Following <= Original or else not Packages.Same_Name (Text, (First, Last), Item.Body_Name) then
            Globals := Invalid_State; return;
         end if;
         Item.Body_After := Following;
         Item.May_Read := Result.Reads;
         Item.May_Write := Result.Writes;
         Item.Assigned := Result.Scan.Assigned;
         Info.Routines (Index) := Item;
         Info.Completed := Index;
         Info.Assigned := Info.Assigned or Item.Assigned;
         Globals.Position := Following;
      end;
   end Package_Completion_At;

   procedure Package_Body_At
     (Text : String; Exports : Parser_State; Info : in out Packages.Metadata;
      Accepted : out Boolean)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Exports)
         and then Info.Units (Units.Package_Body).First <= Text'Last + 1
   is
      First : constant Literal_Position := Skip_At (Text,
        Package_Word (Text, Package_Word (Text, Info.Units (Units.Package_Body).First, "package"), "body"));
      Last : constant Literal_Position := Name_After (Text, First);
      Globals : Parser_State := Exports;
      Object : Package_Object_Result;
      End_First, End_Last, Following, Before : Literal_Position;
   begin
      Accepted := False;
      if not Packages.Same_Name (Text, (First, Last), (Info.Name_First, Info.Name_After)) then return; end if;
      Info.Body_Name_First := First;
      Info.Body_Name_After := Last;
      Globals.Position := Spark_Pragma_After (Text, Take_Token (Text, Last, Is_Keyword));
      if Globals.Position = 0 then return; end if;
      while Take_Token (Text, Globals.Position, Function_Keyword) = 0
        and then Take_Token (Text, Globals.Position, Procedure_Keyword) = 0
        and then Take_Token (Text, Globals.Position, End_Keyword) = 0
      loop
         pragma Loop_Variant (Increases => Globals.Position);
         if Info.State_Count = Packages.Max_States then return; end if;
         Before := Globals.Position;
         Object := Package_Object_At (Text, Globals, Info);
         if Object.Frame.Position <= Before or else Object.Constant_Object then return; end if;
         Info.State_Count := Info.State_Count + 1;
         Info.States (Info.State_Count) :=
           (Name => Object.Name, Kind => Object.Mark.Kind,
            Type_Name => Object.Mark.Name, Type_Identity => Object.Mark.Identity,
            Declared_Bounds => Object.Mark.Bounds, Initial_Bounds => Object.Initial_Bounds,
            Initializer_First => Object.Init_First, Initializer_After => Object.Init_After,
            Boolean_Initial => Object.Boolean_Value);
         Globals := Object.Frame;
      end loop;
      while Info.Completed < Info.Routine_Count loop
         pragma Loop_Variant (Increases => Info.Completed);
         Before := Globals.Position;
         Package_Completion_At (Text, Globals, Info);
         if Globals.Position <= Before then return; end if;
      end loop;
      End_First := Skip_At (Text, Take_Token (Text, Globals.Position, End_Keyword));
      End_Last := Name_After (Text, End_First);
      Following := Take_Token (Text, End_Last, Semicolon);
      Accepted := Packages.Same_Name (Text, (End_First, End_Last), (Info.Name_First, Info.Name_After))
        and then Following /= 0 and then Skip_At (Text, Following) = Text'Last + 1;
   end Package_Body_At;

   function Imported_Frame
     (Text : String; Exports : Parser_State; Info : Packages.Metadata;
      Position : Literal_Position) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Exports) and then Position <= Text'Last + 1
         and then Valid_Name_State (Text, Info.Name_First, Info.Name_After)
         and then Info.Units (Units.Main_Body).First <= Text'Last + 1,
       Post => Valid_State (Text, Imported_Frame'Result)
   is
      Result : Parser_State := (Exports with delta Position => Position,
        Context_First => Info.Units (Units.Main_Body).First,
        Package_First => Info.Name_First, Package_After => Info.Name_After,
        Pure => False, Hiding => No_Hidden_Marks);
   begin
      for I in 1 .. Result.Scalar_Names.Count loop
         Result.Scalar_Names.Items (I).Qualifier_First := Info.Name_First;
         Result.Scalar_Names.Items (I).Qualifier_After := Info.Name_After;
      end loop;
      for I in 1 .. Result.Boolean_Names.Count loop
         Result.Boolean_Names.Items (I).Qualifier_First := Info.Name_First;
         Result.Boolean_Names.Items (I).Qualifier_After := Info.Name_After;
      end loop;
      for I in 1 .. Result.Subtype_Names.Count loop
         Result.Subtype_Names.Items (I).Qualifier_First := Info.Name_First;
         Result.Subtype_Names.Items (I).Qualifier_After := Info.Name_After;
      end loop;
      Result.Subtype_Names.Hidden_Calls := (others => False);
      Result.Subtype_Names.True_Hidden := False;
      Result.Subtype_Names.False_Hidden := False;
      if not Valid_State (Text, Result) then return Invalid_State; end if;
      return Result;
   end Imported_Frame;

   function Same_Package_Spelling
     (Text : String; Info : Packages.Metadata; Word : String) return Boolean
     with Global => null
   is
   begin
      if not Packages.Valid_Name (Text, (Info.Name_First, Info.Name_After))
        or else Word'Length /= Info.Name_After - Info.Name_First
      then return False; end if;
      for I in Word'Range loop
         if Lowercase (Word (I)) /= Lowercase (Text (Info.Name_First + (I - Word'First))) then return False; end if;
      end loop;
      return True;
   end Same_Package_Spelling;

   function Package_Main_At
     (Sources : Units.Bundle; Exports : Parser_State; Info : Packages.Metadata)
      return Analysis_Result
     with Global => null,
       Pre => Units.Valid (Sources)
         and then Valid_State (Sources.Pool (1 .. Sources.Used), Exports)
         and then Packages.Complete_Metadata (Sources.Pool (1 .. Sources.Used), Info)
   is
      Text : constant String := Sources.Pool (1 .. Sources.Used);
      Imported : constant String := Imported_Package (Units.Unit_Source (Sources, Units.Main_Body));
      Context_Clauses : constant Names.Context_Result := Names.Read_Context
        (Text, Sources.Units (Units.Main_Body).First, Info.Name_First, Info.Name_After);
      Frame : Parser_State;
      Start, Following : Literal_Position;
   begin
      if not Same_Package_Spelling (Text, Info, Imported) or else Context_Clauses.After = 0 then return Invalid_Analysis; end if;
      Start := Spark_Pragma_After (Text, Take_Token (Text, Take_Token (Text,
        Take_Token (Text, Context_Clauses.After, Procedure_Keyword), Main_Name), Is_Keyword));
      if Start = 0 then return Invalid_Analysis; end if;
      Frame := Imported_Frame (Text, Exports, Info, Start);
      if Context_Clauses.Arguments_With then Frame := Argument_At (Text, Frame); end if;
      if Frame.Position = 0 then return Invalid_Analysis; end if;
      Frame := Read_Declarations (Text, Frame, Context_Clauses.Arguments_With);
      Frame.Position := Take_Token (Text, Frame.Position, Begin_Keyword);
      if Frame.Position = 0 then return Invalid_Analysis; end if;
      declare
         Context : constant Body_Context := Context_Of ((Frame, Frame.Assigned_In_Functions, False));
         Result : constant Application_Scan := Application_Tail
           (Text, Context, Application_Of (Body_Of ((Frame, Frame.Assigned_In_Functions, False))),
            Info, End_Only, True, Frame.Functions, Frame.Procedures);
      begin
         Following := Take_Token (Text, Take_Token
           (Text, Take_Token (Text, Result.Scan.Position, End_Keyword), Main_Name), Semicolon);
         if Following = 0 or else Skip_At (Text, Following) /= Text'Last + 1
           or else not Paths.Completed (Result.Scan.Facts.Path)
         then return Invalid_Analysis; end if;
         return (Accepted => True, Package_Info => Info,
           Main_Functions => Frame.Functions, Main_Procedures => Frame.Procedures,
           Uses_Arguments => Context_Clauses.Arguments_With,
           Uses_Assignment => Result.Scan.Assigned, Uses_Output => Result.Scan.Output);
      end;
   end Package_Main_At;

   procedure Charge_Unit
     (Text : String; Remaining : in out Concatenation_Count; Accepted : out Boolean)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
   is
      Position : Cursor := 1;
      First, After_Name, After_Character : Literal_Position;
      Number : Silver_Scalar_Literals.Literal_Result;
      Quoted : Value_Result;
      Charge : Boolean;
   begin
      Accepted := False;
      loop
         pragma Loop_Invariant (Position <= Text'Last + 1);
         pragma Loop_Variant (Increases => Position);
         First := Skip_At (Text, Position);
         if First = 0 then return; end if;
         if First > Text'Last then Accepted := True; return; end if;
         After_Character := Character_Literal_After (Text, First);
         After_Name := Name_After (Text, First);
         Number := Silver_Scalar_Literals.Read_Integer (Text, First);
         Charge := False;
         if After_Character /= 0 then Position := After_Character;
         elsif Text (First) = Character'Val (34) then
            Quoted := Literal_At (Text, First);
            if Quoted.After = 0 then return; end if;
            Position := Quoted.After;
         elsif After_Name /= 0 then
            Charge := Name_Is (Text, First, After_Name, "mod") or else Name_Is (Text, First, After_Name, "rem");
            Position := After_Name;
         elsif Number.After /= 0 then Position := Number.After;
         elsif Text (First) = '/' and then First < Text'Last and then Text (First + 1) = '=' then Position := First + 2;
         else
            Charge := Text (First) in '&' | '+' | '-' | '*' | '/';
            Position := First + 1;
         end if;
         if Charge then
            if Remaining = 0 then return; end if;
            Remaining := Remaining - 1;
         end if;
      end loop;
   end Charge_Unit;

   function Analyze_Application (Sources : Units.Bundle) return Analysis_Result
     with Global => null,
       Post => (if Analyze_Application'Result.Accepted then
         Units.Valid (Sources)
         and then Analyze_Application'Result.Package_Info.Units = Sources.Units
         and then Packages.Complete_Metadata
           (Sources.Pool (1 .. Sources.Used), Analyze_Application'Result.Package_Info)
         and then Functions.Valid_Metadata
           (Sources.Pool (1 .. Sources.Used), Analyze_Application'Result.Main_Functions)
         and then Procedures.Valid_Metadata
           (Sources.Pool (1 .. Sources.Used), Analyze_Application'Result.Main_Procedures))
   is
      Info : Packages.Metadata := Packages.Empty_Metadata;
      Exports : Parser_State;
      Remaining : Concatenation_Count := Max_Concatenations;
      Accepted : Boolean;
      Result : Analysis_Result;
   begin
      if not Units.Valid (Sources) or else not Allowed_Source (Sources.Pool (1 .. Sources.Used)) then return Invalid_Analysis; end if;
      for Unit in Units.Unit_Kind loop
         Charge_Unit (Normalized (Units.Unit_Source (Sources, Unit)), Remaining, Accepted);
         if not Accepted then return Invalid_Analysis; end if;
      end loop;
      Info.Units := Sources.Units;
      Package_Spec_At (Units.Prefix (Sources, Units.Package_Specification), Info, Exports);
      if Exports.Position = 0 or else not Valid_State (Units.Prefix (Sources, Units.Package_Body), Exports) then return Invalid_Analysis; end if;
      Package_Body_At (Units.Prefix (Sources, Units.Package_Body), Exports, Info, Accepted);
      if not Accepted or else not Packages.Complete_Metadata (Sources.Pool (1 .. Sources.Used), Info)
        or else not Valid_State (Sources.Pool (1 .. Sources.Used), Exports)
      then return Invalid_Analysis; end if;
      Result := Package_Main_At (Sources, Exports, Info);
      if not Result.Accepted or else Result.Package_Info.Units /= Sources.Units
        or else not Packages.Complete_Metadata (Sources.Pool (1 .. Sources.Used), Result.Package_Info)
        or else not Functions.Valid_Metadata (Sources.Pool (1 .. Sources.Used), Result.Main_Functions)
        or else not Procedures.Valid_Metadata (Sources.Pool (1 .. Sources.Used), Result.Main_Procedures)
      then return Invalid_Analysis; end if;
      return Result;
   end Analyze_Application;

   function Analyze_Model (Sources : Units.Bundle) return Analysis_Result is
     (Analyze_Application (Sources));
   function Analyze (Sources : Units.Bundle) return Analysis_Result is
     (Analyze_Application (Sources));
   function Is_Application_Member (Sources : Units.Bundle) return Boolean is
     (Analyze_Model (Sources).Accepted);
   function Accepts_Application (Sources : Units.Bundle) return Boolean is
     (Analyze (Sources).Accepted);

   function Imported_Package (Main_Source : String) return String is
   begin
      if Main_Source'Length = 0 or else Main_Source'Length > Max_Source_Length
      then return ""; end if;
      declare
         Text : constant String := Normalized (Main_Source);
         Position : Literal_Position := 1;
         Candidate : Silver_Package_Bindings.Name_Span :=
           Silver_Package_Bindings.No_Name;
      begin
         loop
            pragma Loop_Invariant (Position in 1 .. Text'Last + 1);
            pragma Loop_Invariant (Candidate.First = 0
              or else Silver_Package_Bindings.Valid_Name (Text, Candidate));
            pragma Loop_Variant (Increases => Position);
            declare
               First : constant Literal_Position := Skip_At (Text, Position);
               After : constant Literal_Position := Name_After (Text, First);
               With_Clause : constant Boolean :=
                 First > 0 and then After > First
                 and then Name_Is (Text, First, After, "with");
               Use_Clause : constant Boolean :=
                 First > 0 and then After > First
                 and then Name_Is (Text, First, After, "use");
            begin
               exit when not With_Clause and then not Use_Clause;
               Position := After;
               loop
                  pragma Loop_Invariant (Position in After .. Text'Last + 1);
                  pragma Loop_Invariant (Candidate.First = 0
                    or else Silver_Package_Bindings.Valid_Name (Text, Candidate));
                  pragma Loop_Variant (Increases => Position);
                  declare
                     Name_First : constant Literal_Position := Skip_At (Text, Position);
                     Name_After : constant Literal_Position :=
                       Silver_Output_Profile.Name_After (Text, Name_First);
                     Name : constant Silver_Package_Bindings.Name_Span :=
                       (Name_First, Name_After);
                     Comma_After : constant Literal_Position :=
                       Take_Token (Text, Name_After, Comma);
                     Semicolon_After : constant Literal_Position :=
                       Take_Token (Text, Name_After, Semicolon);
                  begin
                     if not Silver_Package_Bindings.Valid_Name (Text, Name)
                       or else (Comma_After = 0 and then Semicolon_After = 0)
                     then return ""; end if;
                     if With_Clause
                       and then not Name_Is (Text, Name_First, Name_After, "silver_io")
                       and then not Name_Is (Text, Name_First, Name_After, "silver_arguments")
                     then
                        if Candidate.First /= 0
                          and then not Silver_Package_Bindings.Same_Name
                            (Text, Candidate, Name)
                        then return ""; end if;
                        Candidate := Name;
                     end if;
                     if Semicolon_After /= 0 then
                        Position := Semicolon_After;
                        exit;
                     end if;
                     Position := Comma_After;
                  end;
               end loop;
            end;
         end loop;
         if Candidate.First = 0 then return ""; end if;
         declare
            Result : constant String (1 .. Candidate.After - Candidate.First) :=
              Text (Candidate.First .. Candidate.After - 1);
         begin
            return Result;
         end;
      end;
   end Imported_Package;
end Silver_Output_Profile;
