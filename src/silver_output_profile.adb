--  Shared declarations and finite statements use the same bounded expressions.
--  Declarations precede guards; assignments preserve fixed object bounds, so
--  statement sequencing and branch joins preserve all binding length shapes.
with Silver_Profile;
with Silver_Output_Lexical;

package body Silver_Output_Profile
  with SPARK_Mode => On
is
   use Silver_Profile;
   use Silver_Output_Lexical;

   function Is_Word_Token (Token : Token_Kind) return Boolean is
     (Token in With_Keyword .. End_Keyword | Constant_Keyword | String_Name
        | Arguments_Name | First_Or_Default_Name | If_Keyword
        | Input_Is_Valid_Name | Then_Keyword | Else_Keyword | Elsif_Keyword | Reject_Name
        | And_Keyword | Length_Name | Null_Keyword);

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
         when Apostrophe => "'",
         when Length_Name => "length",
         when Less_Equal => "<=",
         when Capacity_Literal => "0",
         when Equal => "=",
         when Null_Keyword => "null",
         when Argument_Declaration | Declarations | Assignment_Target
            | Target_Reference | Dynamic_Reference | Assignment_Value
            | Output_Expression | Comparison_Expression | Statements => "_");

   function Tokens (Form : Form_Kind) return Token_Sequence is
     (case Form is
      when Direct_Form =>
         (With_Keyword, IO_Name, Semicolon, Procedure_Keyword,
          Main_Name, Is_Keyword, Pragma_Keyword, SPARK_Mode_Name,
          Left_Parenthesis, On_Name, Right_Parenthesis, Semicolon,
          Declarations, Begin_Keyword, Statements, End_Keyword, Main_Name, Semicolon),
      when Argument_Form =>
         (With_Keyword, IO_Name, Semicolon, With_Keyword,
          Arguments_Name, Semicolon, Procedure_Keyword, Main_Name,
          Is_Keyword, Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis,
          On_Name, Right_Parenthesis, Semicolon, Argument_Declaration,
          Declarations, Begin_Keyword, If_Keyword, Arguments_Name,
          Dot, Input_Is_Valid_Name, Then_Keyword, Statements, Else_Keyword,
          Arguments_Name, Dot, Reject_Name, Semicolon, End_Keyword,
          If_Keyword, Semicolon, End_Keyword, Main_Name, Semicolon),
      when Guarded_Argument_Form =>
         (With_Keyword, IO_Name, Semicolon, With_Keyword,
          Arguments_Name, Semicolon, Procedure_Keyword, Main_Name,
          Is_Keyword, Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis,
          On_Name, Right_Parenthesis, Semicolon, Argument_Declaration,
          Declarations, Begin_Keyword, If_Keyword, Arguments_Name,
          Dot, Input_Is_Valid_Name, And_Keyword, Then_Keyword,
          Dynamic_Reference, Apostrophe, Length_Name, Less_Equal,
          Capacity_Literal, Then_Keyword, Statements, Else_Keyword,
          Arguments_Name, Dot, Reject_Name, Semicolon, End_Keyword,
          If_Keyword, Semicolon, End_Keyword, Main_Name, Semicolon));

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
      Dynamic, Mutable : Boolean;
   end record;
   Empty_Binding : constant Binding_Info :=
     (First => 0, After => 0, Value_First => 0, Static_Length => 0,
      Dynamic => False, Mutable => False);
   type Binding_Array is array (Binding_Index) of Binding_Info;
   type Binding_Environment is record
      Count : Binding_Count;
      Items : Binding_Array;
   end record;
   Empty_Environment : constant Binding_Environment :=
     (Count => 0, Items => (others => Empty_Binding));

   function Valid_Names (Text : String; Names : Binding_Environment) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_Names (Text : String; Names : Binding_Environment) return Boolean is
     (for all I in 1 .. Names.Count =>
        Names.Items (I).First > 0
        and then Valid_Name_State (Text, Names.Items (I).First, Names.Items (I).After)
        and then Names.Items (I).Value_First <= Text'Last + 1);

   type Parser_State is record
      Position : Literal_Position;
      Names : Binding_Environment;
      Dynamic_First, Dynamic_After : Literal_Position;
      Target : Binding_Count;
      Capacity : Capacity_Value;
   end record;
   Initial_State : constant Parser_State :=
     (Position => 1, Names => Empty_Environment, Dynamic_First => 0,
      Dynamic_After => 0, Target => 0, Capacity => Max_Source_Length);
   Invalid_State : constant Parser_State :=
     (Position => 0, Names => Empty_Environment, Dynamic_First => 0,
      Dynamic_After => 0, Target => 0, Capacity => 0);

   function Valid_State (Text : String; State : Parser_State) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_State (Text : String; State : Parser_State) return Boolean is
     (State.Position <= Text'Last + 1
      and then Valid_Names (Text, State.Names)
      and then Valid_Name_State (Text, State.Dynamic_First, State.Dynamic_After)
      and then State.Target <= State.Names.Count);

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
           (for all Previous in Word'First .. Index - 1 =>
             Lowercase (Text ((Position + Previous) - 1)) = Word (Previous));
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

   type Value_Result is record
      After, Value_First : Literal_Position;
      Static_Length : Capacity_Value;
      Dynamic_Seen : Boolean;
      Reference : Binding_Count;
   end record;
   Invalid_Value : constant Value_Result :=
     (After => 0, Value_First => 0, Static_Length => 0, Dynamic_Seen => False, Reference => 0);
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
                  Static_Length => Literal_Length (Text, Position + 1),
                  Dynamic_Seen => False, Reference => 0)
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
      return (After => Next, Value_First => Position + 1, Static_Length => Length,
              Dynamic_Seen => False, Reference => 0);
   end Literal_At;

   subtype Concatenation_Count is Natural range 0 .. Max_Concatenations;

   --  This independent lexical budget counts actual operators, not ampersands
   --  inside literal bytes or comments. Body parsing still establishes syntax.
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
      begin
        (if First = 0 then False
         elsif First > Text'Last then True
         elsif Text (First) = Character'Val (34) then
           Quoted.After /= 0 and then Work_Tail (Text, Quoted.After, Remaining)
         elsif Text (First) = Character'Val (38) then
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
         begin
            if First = 0 then return False; end if;
            if First > Text'Last then return True; end if;
            if Text (First) = Character'Val (34) then
               if Quoted.After = 0 then return False; end if;
               Position := Quoted.After;
            elsif Text (First) = Character'Val (38) then
               if Remaining = 0 then return False; end if;
               Position := First + 1;
               Remaining := Remaining - 1;
            else
               Position := First + 1;
            end if;
         end;
      end loop;
   end Within_Work_Budget;

   function Value_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment)
      return Value_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Names (Text, Names),
       Post => Value_At'Result.Value_First <= Text'Last + 1
         and then Value_At'Result.Reference <= Names.Count
         and then (Value_At'Result.After = 0
           or else Value_At'Result.After in Position + 1 .. Text'Last + 1);
   function Value_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment)
      return Value_Result is
     (declare First : constant Literal_Position := Skip_At (Text, Position);
              Quoted : constant Value_Result := Literal_At (Text, First);
              After : constant Literal_Position := Name_After (Text, First);
              Index : constant Binding_Count := Lookup_Name (Text, Names, First, After);
      begin
        (if Quoted.After /= 0 then Quoted
         elsif Index /= 0 then
           (After => After, Value_First => Names.Items (Index).Value_First,
            Static_Length => Names.Items (Index).Static_Length,
            Dynamic_Seen => Names.Items (Index).Dynamic, Reference => Index)
         else Invalid_Value));

   subtype Operand_Count is Natural range 0 .. Max_Expression_Operands;
   type Expression_Result is record
      After : Literal_Position;
      Static_Length : Capacity_Value;
      Dynamic_Count : Operand_Count;
      Named_Seen : Boolean;
   end record;
   Invalid_Expression : constant Expression_Result :=
     (After => 0, Static_Length => 0, Dynamic_Count => 0, Named_Seen => False);

   --  Parentheses need no stored syntax tree: grouping affects neither affine
   --  lengths nor concatenation order. The depth and operand expectation enforce
   --  the ordinary recursive grammar, while the loop remains source-bounded.
   type Expression_State is record
      Position : Literal_Position;
      Static_Length : Capacity_Value;
      Dynamic_Count, Operands : Operand_Count;
      Depth : Literal_Position;
      Named_Seen, Need_Operand, Complete : Boolean;
   end record;
   Invalid_Expression_State : constant Expression_State :=
     (Position => 0, Static_Length => 0, Dynamic_Count => 0,
      Operands => 0, Depth => 0, Named_Seen => False,
      Need_Operand => True, Complete => False);

   function Valid_Expression_State
     (Text : String; State : Expression_State) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_Expression_State
     (Text : String; State : Expression_State) return Boolean is
     (State.Position <= Text'Last + 1
      and then State.Dynamic_Count <= State.Operands
      and then (State.Position = 0 or else State.Depth < State.Position));

   function Expression_Step
     (Text : String; Names : Binding_Environment; State : Expression_State)
      return Expression_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Names (Text, Names)
         and then Valid_Expression_State (Text, State),
       Post => Valid_Expression_State (Text, Expression_Step'Result)
         and then (Expression_Step'Result.Position = 0
           or else Expression_Step'Result.Complete
           or else Expression_Step'Result.Position > State.Position);
   function Expression_Step
     (Text : String; Names : Binding_Environment; State : Expression_State)
      return Expression_State is
     (declare Open_After : constant Literal_Position :=
                Take_Token (Text, State.Position, Left_Parenthesis);
              Atom : constant Value_Result := Value_At (Text, State.Position, Names);
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
            elsif State.Operands = Max_Expression_Operands or else Atom.After = 0
              or else Atom.Static_Length > Max_Source_Length - State.Static_Length
            then Invalid_Expression_State
            else (State with delta Position => Atom.After,
              Static_Length => State.Static_Length + Atom.Static_Length,
              Dynamic_Count => State.Dynamic_Count + (if Atom.Dynamic_Seen then 1 else 0),
              Operands => State.Operands + 1,
              Named_Seen => State.Named_Seen or else Atom.Reference /= 0,
              Need_Operand => False))
         elsif Join_After /= 0 then
           (State with delta Position => Join_After, Need_Operand => True)
         elsif Close_After /= 0 and then State.Depth /= 0 then
           (State with delta Position => Close_After, Depth => State.Depth - 1)
         elsif State.Depth = 0 then (State with delta Complete => True)
         else Invalid_Expression_State));

   function Expression_Tail
     (Text : String; Names : Binding_Environment; State : Expression_State)
      return Expression_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Names (Text, Names)
         and then Valid_Expression_State (Text, State),
       Post => Expression_Tail'Result.After = 0
         or else Expression_Tail'Result.After in State.Position .. Text'Last + 1,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - State.Position);
   function Expression_Tail
     (Text : String; Names : Binding_Environment; State : Expression_State)
      return Expression_Result is
     (if State.Position = 0 then Invalid_Expression
      elsif State.Complete then
        (After => State.Position, Static_Length => State.Static_Length,
         Dynamic_Count => State.Dynamic_Count, Named_Seen => State.Named_Seen)
      else
        (declare Next : constant Expression_State := Expression_Step (Text, Names, State);
         begin
           (if Next.Position = 0 then Invalid_Expression
            elsif Next.Complete then
              (After => Next.Position, Static_Length => Next.Static_Length,
               Dynamic_Count => Next.Dynamic_Count, Named_Seen => Next.Named_Seen)
            else Expression_Tail (Text, Names, Next))));

   function Expression_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment)
      return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Names (Text, Names),
       Post => (Static => (Expression_At'Result.After = 0
         or else Expression_At'Result.After in Position + 1 .. Text'Last + 1)
         and then (Expression_At'Result = Expression_Tail (Text, Names,
           (Position => Position, Static_Length => 0, Dynamic_Count => 0,
            Operands => 0, Depth => 0, Named_Seen => False,
            Need_Operand => True, Complete => False))));
   function Expression_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment)
      return Expression_Result is
      State : Expression_State :=
        (Position => Position, Static_Length => 0, Dynamic_Count => 0,
         Operands => 0, Depth => 0, Named_Seen => False,
         Need_Operand => True, Complete => False);
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
             (Position => Position, Static_Length => 0, Dynamic_Count => 0,
              Operands => 0, Depth => 0, Named_Seen => False,
            Need_Operand => True, Complete => False))
             = Expression_Tail (Text, Names, State));
         pragma Loop_Variant (Increases => State.Position);
         State := Expression_Step (Text, Names, State);
      end loop;
      if State.Position = 0 then return Invalid_Expression; end if;
      return (After => State.Position, Static_Length => State.Static_Length,
              Dynamic_Count => State.Dynamic_Count, Named_Seen => State.Named_Seen);
   end Expression_At;

   function Fits (Value : Expression_Result; Capacity : Capacity_Value) return Boolean
     with Global => null;
   function Fits (Value : Expression_Result; Capacity : Capacity_Value) return Boolean is
     (Value.After /= 0
      and then Value.Static_Length + Value.Dynamic_Count * Capacity <= Max_Source_Length);

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
      and then (not Arguments or else not Forbidden_Argument_Name (Text, First, After))
      and then Lookup_Name (Text, State.Names, First, After) = 0);

   function Add_Binding
     (State : Parser_State; First, After : Literal_Position;
      Value : Value_Result; Mutable : Boolean; Following : Literal_Position)
      return Parser_State
     with Global => null,
       Pre => State.Names.Count < Max_Bindings;
   function Add_Binding
     (State : Parser_State; First, After : Literal_Position;
      Value : Value_Result; Mutable : Boolean; Following : Literal_Position)
      return Parser_State is
     (State with delta Position => Following,
        Names => (Count => State.Names.Count + 1,
          Items => (State.Names.Items with delta State.Names.Count + 1 =>
            (First => First, After => After, Value_First => Value.Value_First,
             Static_Length => Value.Static_Length, Dynamic => Value.Dynamic_Seen,
             Mutable => Mutable))));

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
     (declare First : constant Literal_Position := Skip_At (Text, State.Position);
              After : constant Literal_Position := Name_After (Text, First);
              Colon_After : constant Literal_Position := Take_Token (Text, After, Colon);
              Constant_After : constant Literal_Position := Take_Token (Text, Colon_After, Constant_Keyword);
              Type_After : constant Literal_Position := Take_Token (Text,
                (if Constant_After /= 0 then Constant_After else Colon_After), String_Name);
              Value : constant Expression_Result := Expression_At
                (Text, Take_Token (Text, Type_After, Assignment), State.Names);
              Following : constant Literal_Position := Take_Token (Text, Value.After, Semicolon);
      begin
        (if not New_Name_Allowed (Text, State, First, After, Arguments)
           or else Following = 0 or else State.Names.Count = Max_Bindings
           or else not Fits (Value, Max_Source_Length)
         then Invalid_State
         else Add_Binding (State, First, After,
           (After => Value.After, Value_First => 0, Static_Length => Value.Static_Length,
            Dynamic_Seen => Value.Dynamic_Count = 1, Reference => 0),
           Constant_After = 0, Following)));

   function Argument_At (Text : String; State : Parser_State) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Argument_At'Result);
   function Argument_At (Text : String; State : Parser_State) return Parser_State is
     (declare First : constant Literal_Position := Skip_At (Text, State.Position);
              After : constant Literal_Position := Name_After (Text, First);
              Prefix : constant Literal_Position := Take_Token (Text,
                Take_Token (Text, Take_Token (Text, Take_Token (Text,
                  Take_Token (Text, Take_Token (Text, Take_Token (Text,
                    Take_Token (Text, After, Colon), Constant_Keyword), String_Name),
                  Assignment), Arguments_Name), Dot), First_Or_Default_Name), Left_Parenthesis);
              Default_Value : constant Value_Result := Literal_At (Text, Skip_At (Text, Prefix));
              Following : constant Literal_Position := Take_Token (Text,
                Take_Token (Text, Default_Value.After, Right_Parenthesis), Semicolon);
      begin
        (if not New_Name_Allowed (Text, State, First, After, True)
           or else Following = 0 or else State.Names.Count /= 0
         then Invalid_State
         else (Add_Binding (State, First, After,
           (After => Following, Value_First => 0, Static_Length => 0,
            Dynamic_Seen => True, Reference => 0), False, Following)
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
        (if Index = 0 or else not State.Names.Items (Index).Mutable
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
     (declare Value : constant Expression_Result := Expression_At (Text, State.Position, State.Names);
      begin
        (if not Fits (Value, State.Capacity) or else State.Target = 0
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
     (declare Value : constant Expression_Result := Expression_At (Text, State.Position, State.Names);
      begin
        (if not Fits (Value, State.Capacity)
         then Invalid_State else (State with delta Position => Value.After)));

   function Comparison_At (Text : String; State : Parser_State) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Comparison_At'Result);
   function Comparison_At (Text : String; State : Parser_State) return Parser_State is
     (declare Left : constant Expression_Result := Expression_At (Text, State.Position, State.Names);
              Right : constant Expression_Result := Expression_At
                (Text, Take_Token (Text, Left.After, Equal), State.Names);
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
   --  execution. Source-bounded statement traversal uses recursive frames containing only
   --  cursors and flags, sharing the immutable declaration context.
   type Scan_Result is record
      State : Parser_State;
      Assigned, Output : Boolean;
   end record;
   Initial_Scan : constant Scan_Result :=
     (State => Initial_State, Assigned => False, Output => False);
   Invalid_Scan : constant Scan_Result :=
     (State => Invalid_State, Assigned => False, Output => False);

   function Scan_Token
     (Text : String; Scan : Scan_Result; Token : Token_Kind) return Scan_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Scan.State),
       Post => Valid_State (Text, Scan_Token'Result.State);
   function Scan_Token
     (Text : String; Scan : Scan_Result; Token : Token_Kind) return Scan_Result is
     (Scan with delta State => Step (Text, Direct_Form, Token, Scan.State));

   function Basic_Statement_At (Text : String; Scan : Scan_Result) return Scan_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Scan.State),
       Post => Valid_State (Text, Basic_Statement_At'Result.State)
         and then (Basic_Statement_At'Result.State.Position = 0
           or else Basic_Statement_At'Result.State.Position > Scan.State.Position);
   function Basic_Statement_At (Text : String; Scan : Scan_Result) return Scan_Result is
      Result : Scan_Result := Scan;
   begin
      if Scan.State.Position = 0 then return Invalid_Scan; end if;
      if Take_Token (Text, Scan.State.Position, Null_Keyword) /= 0 then
         Result := Scan_Token (Text, Result, Null_Keyword);
         Result := Scan_Token (Text, Result, Semicolon);
      elsif Take_Token (Text, Scan.State.Position, IO_Name) /= 0 then
         Result := Scan_Token (Text, Result, IO_Name);
         Result := Scan_Token (Text, Result, Dot);
         Result := Scan_Token (Text, Result, Put_Line_Name);
         Result := Scan_Token (Text, Result, Left_Parenthesis);
         Result := Scan_Token (Text, Result, Output_Expression);
         Result := Scan_Token (Text, Result, Right_Parenthesis);
         Result := Scan_Token (Text, Result, Semicolon);
         Result.Output := True;
      else
         Result := Scan_Token (Text, Result, Assignment_Target);
         Result := Scan_Token (Text, Result, Assignment);
         Result := Scan_Token (Text, Result, Assignment_Value);
         Result := Scan_Token (Text, Result, Semicolon);
         Result.Assigned := True;
      end if;
      if Result.State.Position <= Scan.State.Position then return Invalid_Scan; end if;
      return Result;
   end Basic_Statement_At;

   function Basic_Tail
     (Text : String; Scan : Scan_Result; Stop : Token_Kind) return Scan_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Scan.State),
       Post => Valid_State (Text, Basic_Tail'Result.State),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.State.Position);
   function Basic_Tail
     (Text : String; Scan : Scan_Result; Stop : Token_Kind) return Scan_Result is
     (if Scan.State.Position = 0 then Invalid_Scan
      elsif Take_Token (Text, Scan.State.Position, Stop) /= 0 then Scan
      elsif Basic_Statement_At (Text, Scan).State.Position = 0 then Invalid_Scan
      else Basic_Tail (Text, Basic_Statement_At (Text, Scan), Stop));

   function Read_Basic_Statements
     (Text : String; Scan : Scan_Result; Stop : Token_Kind) return Scan_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Scan.State),
       Post => (Static => Valid_State (Text, Read_Basic_Statements'Result.State)
         and then Read_Basic_Statements'Result =
           Basic_Tail (Text, Basic_Statement_At (Text, Scan), Stop));
   function Read_Basic_Statements
     (Text : String; Scan : Scan_Result; Stop : Token_Kind) return Scan_Result is
      Result : Scan_Result := Basic_Statement_At (Text, Scan);
   begin
      while Result.State.Position /= 0 loop
         pragma Loop_Invariant (Valid_State (Text, Result.State));
         pragma Loop_Invariant (Static =>
           Basic_Tail (Text, Basic_Statement_At (Text, Scan), Stop) =
             Basic_Tail (Text, Result, Stop));
         pragma Loop_Variant (Increases => Result.State.Position);
         if Take_Token (Text, Result.State.Position, Stop) /= 0 then return Result; end if;
         Result := Basic_Statement_At (Text, Result);
      end loop;
      return Invalid_Scan;
   end Read_Basic_Statements;

   --  Recursive conditional frames hold only cursors and flags. The common
   --  declaration environment stays immutable and is passed separately.
   type Body_Context is record
      Names : Binding_Environment;
      Dynamic_First, Dynamic_After : Literal_Position;
   end record;
   type Body_Scan is record
      Position : Literal_Position;
      Target : Binding_Count;
      Capacity : Capacity_Value;
      Assigned, Output : Boolean;
   end record;
   Invalid_Body : constant Body_Scan :=
     (Position => 0, Target => 0, Capacity => 0, Assigned => False, Output => False);
   type Body_Stop is (End_Only, Else_Only, Arm_Boundary);

   function Context_Of (Scan : Scan_Result) return Body_Context is
     (Names => Scan.State.Names, Dynamic_First => Scan.State.Dynamic_First,
      Dynamic_After => Scan.State.Dynamic_After);
   function Body_Of (Scan : Scan_Result) return Body_Scan is
     (Position => Scan.State.Position, Target => Scan.State.Target,
      Capacity => Scan.State.Capacity, Assigned => Scan.Assigned, Output => Scan.Output);
   function Expand_Body (Context : Body_Context; Scan : Body_Scan) return Scan_Result is
     (State => (Position => Scan.Position, Names => Context.Names,
       Dynamic_First => Context.Dynamic_First, Dynamic_After => Context.Dynamic_After,
       Target => Scan.Target, Capacity => Scan.Capacity),
      Assigned => Scan.Assigned, Output => Scan.Output);
   function Compact_Body (Context : Body_Context; Scan : Scan_Result) return Body_Scan is
     (if Scan.State.Position = 0 or else Scan.State.Target > Context.Names.Count
      then Invalid_Body else Body_Of (Scan));

   function Valid_Context (Text : String; Context : Body_Context) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_Context (Text : String; Context : Body_Context) return Boolean is
     (Valid_Names (Text, Context.Names)
      and then Valid_Name_State (Text, Context.Dynamic_First, Context.Dynamic_After));
   function Valid_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Boolean is
     (Scan.Position <= Text'Last + 1 and then Scan.Target <= Context.Names.Count);

   function Body_Token
     (Text : String; Context : Body_Context; Scan : Body_Scan; Token : Token_Kind)
      return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Body_Token'Result)
         and then (Body_Token'Result.Position = 0
           or else Body_Token'Result.Position > Scan.Position);
   function Body_Token
     (Text : String; Context : Body_Context; Scan : Body_Scan; Token : Token_Kind)
      return Body_Scan is
      Result : constant Body_Scan := Compact_Body
        (Context, Scan_Token (Text, Expand_Body (Context, Scan), Token));
   begin
      if Result.Position <= Scan.Position then return Invalid_Body; end if;
      return Result;
   end Body_Token;

   function Basic_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Basic_Body'Result)
         and then (Basic_Body'Result.Position = 0
           or else Basic_Body'Result.Position > Scan.Position);
   function Basic_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan is
     (Compact_Body (Context, Basic_Statement_At (Text, Expand_Body (Context, Scan))));

   function At_Body_Stop (Text : String; Position : Literal_Position; Stop : Body_Stop)
      return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1;
   function At_Body_Stop (Text : String; Position : Literal_Position; Stop : Body_Stop)
      return Boolean is
     (case Stop is
        when End_Only => Take_Token (Text, Position, End_Keyword) /= 0,
        when Else_Only => Take_Token (Text, Position, Else_Keyword) /= 0,
        when Arm_Boundary => Take_Token (Text, Position, Elsif_Keyword) /= 0
          or else Take_Token (Text, Position, Else_Keyword) /= 0
          or else Take_Token (Text, Position, End_Keyword) /= 0);

   function Statement_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Statement_Body'Result)
         and then (Statement_Body'Result.Position = 0
           or else Statement_Body'Result.Position > Scan.Position),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 2);
   function Conditional_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Conditional_Body'Result)
         and then (Conditional_Body'Result.Position = 0
           or else Conditional_Body'Result.Position > Scan.Position),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 1);
   function Alternative_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Alternative_Body'Result)
         and then (Alternative_Body'Result.Position = 0
           or else Alternative_Body'Result.Position >= Scan.Position),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 1);

   function Body_Tail
     (Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop)
      return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => Valid_Body (Text, Context, Body_Tail'Result)
         and then (Body_Tail'Result.Position = 0
           or else Body_Tail'Result.Position >= Scan.Position),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 3);
   function Body_Tail
     (Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop)
      return Body_Scan is
      Result : Body_Scan := Scan;
   begin
      if Result.Position = 0 then return Invalid_Body; end if;
      if At_Body_Stop (Text, Result.Position, Stop) then return Result; end if;
      Result := Statement_Body (Text, Context, Result);
      if Result.Position <= Scan.Position then return Invalid_Body; end if;
      return Body_Tail (Text, Context, Result, Stop);
   end Body_Tail;

   function Read_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop)
      return Body_Scan
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan),
       Post => (Runtime => Valid_Body (Text, Context, Read_Body'Result)
         and then (Read_Body'Result.Position = 0
           or else Read_Body'Result.Position > Scan.Position),
         Static => Read_Body'Result =
           (if Statement_Body (Text, Context, Scan).Position = 0 then Invalid_Body
            else Body_Tail (Text, Context, Statement_Body (Text, Context, Scan), Stop))),
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Scan.Position, Decreases => 3);
   function Read_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan; Stop : Body_Stop)
      return Body_Scan is
      Result : constant Body_Scan := Statement_Body (Text, Context, Scan);
   begin
      if Result.Position = 0 then return Invalid_Body; end if;
      return Body_Tail (Text, Context, Result, Stop);
   end Read_Body;

   function Statement_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan is
     (if Scan.Position = 0 then Invalid_Body
      elsif Take_Token (Text, Scan.Position, If_Keyword) /= 0
      then Conditional_Body (Text, Context, Scan) else Basic_Body (Text, Context, Scan));

   function Conditional_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan is
      Result : Body_Scan := Body_Token (Text, Context, Scan, If_Keyword);
   begin
      Result := Body_Token (Text, Context, Result, Comparison_Expression);
      Result := Body_Token (Text, Context, Result, Then_Keyword);
      if Result.Position <= Scan.Position then return Invalid_Body; end if;
      Result := Read_Body (Text, Context, Result, Arm_Boundary);
      if Result.Position <= Scan.Position then return Invalid_Body; end if;
      Result := Alternative_Body (Text, Context, Result);
      Result := Body_Token (Text, Context, Result, End_Keyword);
      Result := Body_Token (Text, Context, Result, If_Keyword);
      Result := Body_Token (Text, Context, Result, Semicolon);
      if Result.Position <= Scan.Position then return Invalid_Body; end if;
      return Result;
   end Conditional_Body;

   function Alternative_Body
     (Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan is
      Result : Body_Scan := Scan;
   begin
      if Scan.Position = 0 then return Invalid_Body; end if;
      if Take_Token (Text, Scan.Position, Elsif_Keyword) /= 0 then
         Result := Body_Token (Text, Context, Result, Elsif_Keyword);
         Result := Body_Token (Text, Context, Result, Comparison_Expression);
         Result := Body_Token (Text, Context, Result, Then_Keyword);
         if Result.Position <= Scan.Position then return Invalid_Body; end if;
         Result := Read_Body (Text, Context, Result, Arm_Boundary);
         if Result.Position <= Scan.Position then return Invalid_Body; end if;
         return Alternative_Body (Text, Context, Result);
      elsif Take_Token (Text, Scan.Position, Else_Keyword) /= 0 then
         Result := Body_Token (Text, Context, Result, Else_Keyword);
         if Result.Position <= Scan.Position then return Invalid_Body; end if;
         return Read_Body (Text, Context, Result, End_Only);
      elsif Take_Token (Text, Scan.Position, End_Keyword) /= 0 then
         return Scan;
      else
         return Invalid_Body;
      end if;
   end Alternative_Body;

   function Read_Statements
     (Text : String; Scan : Scan_Result; Stop : Token_Kind) return Scan_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, Scan.State) and then Stop in Else_Keyword | End_Keyword,
       Post => Valid_State (Text, Read_Statements'Result.State);
   function Read_Statements
     (Text : String; Scan : Scan_Result; Stop : Token_Kind) return Scan_Result is
      Context : constant Body_Context := Context_Of (Scan);
      Result : constant Body_Scan := Read_Body
        (Text, Context, Body_Of (Scan), (if Stop = Else_Keyword then Else_Only else End_Only));
   begin
      return (if Result.Position = 0 then Invalid_Scan else Expand_Body (Context, Result));
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
        (Text, Scan, (if Is_Argument_Form (Form) then Else_Keyword else End_Keyword))
      else (Scan with delta State => Step (Text, Form, Token, Scan.State)));

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
end Silver_Output_Profile;
