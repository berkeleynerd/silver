--  Ordered initialized bindings and fixed object lengths share the existing
--  lexical domain and staged body shapes. Copies capture their initializer's
--  origin immediately; body assignments never change object bounds.
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
        | Input_Is_Valid_Name | Then_Keyword | Else_Keyword | Reject_Name
        | And_Keyword | Length_Name);

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
         when Reject_Name => "reject",
         when Ampersand => "&",
         when And_Keyword => "and",
         when Apostrophe => "'",
         when Length_Name => "length",
         when Less_Equal => "<=",
         when Capacity_Literal => "0",
         when Equal => "=",
         when Argument_Declaration | Declarations | Assignment_Target
            | Target_Reference | Dynamic_Reference | Assignment_Value
            | Output_Expression => "_");

   function Tokens (Form : Form_Kind) return Token_Sequence is
     (case Form is
      when Direct_Form =>
         (With_Keyword, IO_Name, Semicolon, Procedure_Keyword,
          Main_Name, Is_Keyword, Pragma_Keyword, SPARK_Mode_Name,
          Left_Parenthesis, On_Name, Right_Parenthesis, Semicolon,
          Declarations, Begin_Keyword, IO_Name, Dot,
          Put_Line_Name, Left_Parenthesis, Output_Expression, Right_Parenthesis,
          Semicolon, End_Keyword, Main_Name, Semicolon),
      when Assignment_Form =>
         (With_Keyword, IO_Name, Semicolon, Procedure_Keyword,
          Main_Name, Is_Keyword, Pragma_Keyword, SPARK_Mode_Name,
          Left_Parenthesis, On_Name, Right_Parenthesis, Semicolon,
          Declarations, Begin_Keyword, Assignment_Target, Assignment,
          Assignment_Value, Semicolon, IO_Name, Dot,
          Put_Line_Name, Left_Parenthesis, Output_Expression, Right_Parenthesis,
          Semicolon, End_Keyword, Main_Name, Semicolon),
      when Argument_Form =>
         (With_Keyword, IO_Name, Semicolon, With_Keyword,
          Arguments_Name, Semicolon, Procedure_Keyword, Main_Name,
          Is_Keyword, Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis,
          On_Name, Right_Parenthesis, Semicolon, Argument_Declaration,
          Declarations, Begin_Keyword, If_Keyword, Arguments_Name,
          Dot, Input_Is_Valid_Name, Then_Keyword, IO_Name,
          Dot, Put_Line_Name, Left_Parenthesis, Output_Expression,
          Right_Parenthesis, Semicolon, Else_Keyword, Arguments_Name,
          Dot, Reject_Name, Semicolon, End_Keyword,
          If_Keyword, Semicolon, End_Keyword, Main_Name,
          Semicolon),
      when Guarded_Argument_Form =>
         (With_Keyword, IO_Name, Semicolon, With_Keyword,
          Arguments_Name, Semicolon, Procedure_Keyword, Main_Name,
          Is_Keyword, Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis,
          On_Name, Right_Parenthesis, Semicolon, Argument_Declaration,
          Declarations, Begin_Keyword, If_Keyword, Arguments_Name,
          Dot, Input_Is_Valid_Name, And_Keyword, Then_Keyword,
          Dynamic_Reference, Apostrophe, Length_Name, Less_Equal,
          Capacity_Literal, Then_Keyword, IO_Name, Dot,
          Put_Line_Name, Left_Parenthesis, Output_Expression, Right_Parenthesis,
          Semicolon, Else_Keyword, Arguments_Name, Dot,
          Reject_Name, Semicolon, End_Keyword, If_Keyword,
          Semicolon, End_Keyword, Main_Name, Semicolon),
      when Branching_Form =>
         (With_Keyword, IO_Name, Semicolon, With_Keyword,
          Arguments_Name, Semicolon, Procedure_Keyword, Main_Name,
          Is_Keyword, Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis,
          On_Name, Right_Parenthesis, Semicolon, Argument_Declaration,
          Declarations, Begin_Keyword, If_Keyword, Arguments_Name,
          Dot, Input_Is_Valid_Name, Then_Keyword, If_Keyword,
          Dynamic_Reference, Equal, String_Literal, Then_Keyword,
          IO_Name, Dot, Put_Line_Name, Left_Parenthesis,
          Output_Expression, Right_Parenthesis, Semicolon, Else_Keyword,
          IO_Name, Dot, Put_Line_Name, Left_Parenthesis,
          Output_Expression, Right_Parenthesis, Semicolon, End_Keyword,
          If_Keyword, Semicolon, Else_Keyword, Arguments_Name,
          Dot, Reject_Name, Semicolon, End_Keyword,
          If_Keyword, Semicolon, End_Keyword, Main_Name,
          Semicolon),
      when Guarded_Branching_Form =>
         (With_Keyword, IO_Name, Semicolon, With_Keyword,
          Arguments_Name, Semicolon, Procedure_Keyword, Main_Name,
          Is_Keyword, Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis,
          On_Name, Right_Parenthesis, Semicolon, Argument_Declaration,
          Declarations, Begin_Keyword, If_Keyword, Arguments_Name,
          Dot, Input_Is_Valid_Name, And_Keyword, Then_Keyword,
          Dynamic_Reference, Apostrophe, Length_Name, Less_Equal,
          Capacity_Literal, Then_Keyword, If_Keyword, Dynamic_Reference,
          Equal, String_Literal, Then_Keyword, IO_Name,
          Dot, Put_Line_Name, Left_Parenthesis, Output_Expression,
          Right_Parenthesis, Semicolon, Else_Keyword, IO_Name,
          Dot, Put_Line_Name, Left_Parenthesis, Output_Expression,
          Right_Parenthesis, Semicolon, End_Keyword, If_Keyword,
          Semicolon, Else_Keyword, Arguments_Name, Dot,
          Reject_Name, Semicolon, End_Keyword, If_Keyword,
          Semicolon, End_Keyword, Main_Name, Semicolon),
      when Result_Form =>
         (With_Keyword, IO_Name, Semicolon, With_Keyword,
          Arguments_Name, Semicolon, Procedure_Keyword, Main_Name,
          Is_Keyword, Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis,
          On_Name, Right_Parenthesis, Semicolon, Argument_Declaration,
          Declarations, Begin_Keyword, If_Keyword, Arguments_Name,
          Dot, Input_Is_Valid_Name, Then_Keyword, If_Keyword,
          Dynamic_Reference, Equal, String_Literal, Then_Keyword,
          Assignment_Target, Assignment, Assignment_Value, Semicolon,
          Else_Keyword, Target_Reference, Assignment, Assignment_Value,
          Semicolon, End_Keyword, If_Keyword, Semicolon,
          IO_Name, Dot, Put_Line_Name, Left_Parenthesis,
          Output_Expression, Right_Parenthesis, Semicolon, Else_Keyword,
          Arguments_Name, Dot, Reject_Name, Semicolon,
          End_Keyword, If_Keyword, Semicolon, End_Keyword,
          Main_Name, Semicolon),
      when Guarded_Result_Form =>
         (With_Keyword, IO_Name, Semicolon, With_Keyword,
          Arguments_Name, Semicolon, Procedure_Keyword, Main_Name,
          Is_Keyword, Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis,
          On_Name, Right_Parenthesis, Semicolon, Argument_Declaration,
          Declarations, Begin_Keyword, If_Keyword, Arguments_Name,
          Dot, Input_Is_Valid_Name, And_Keyword, Then_Keyword,
          Dynamic_Reference, Apostrophe, Length_Name, Less_Equal,
          Capacity_Literal, Then_Keyword, If_Keyword, Dynamic_Reference,
          Equal, String_Literal, Then_Keyword, Assignment_Target,
          Assignment, Assignment_Value, Semicolon, Else_Keyword,
          Target_Reference, Assignment, Assignment_Value, Semicolon,
          End_Keyword, If_Keyword, Semicolon, IO_Name,
          Dot, Put_Line_Name, Left_Parenthesis, Output_Expression,
          Right_Parenthesis, Semicolon, Else_Keyword, Arguments_Name,
          Dot, Reject_Name, Semicolon, End_Keyword,
          If_Keyword, Semicolon, End_Keyword, Main_Name,
          Semicolon));

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
              Value : constant Value_Result := Value_At
                (Text, Take_Token (Text, Type_After, Assignment), State.Names);
              Following : constant Literal_Position := Take_Token (Text, Value.After, Semicolon);
      begin
        (if not New_Name_Allowed (Text, State, First, After, Arguments)
           or else Following = 0 or else State.Names.Count = Max_Bindings
         then Invalid_State
         else Add_Binding (State, First, After, Value, Constant_After = 0, Following)));

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

   subtype Operand_Count is Natural range 0 .. Max_Expression_Operands;
   type Expression_Result is record
      After : Literal_Position;
      Static_Length : Capacity_Value;
      Dynamic_Seen : Boolean;
   end record;
   Invalid_Expression : constant Expression_Result :=
     (After => 0, Static_Length => 0, Dynamic_Seen => False);

   function Operand_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment)
      return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Names (Text, Names),
       Post => Operand_At'Result.After = 0
         or else Operand_At'Result.After in Position + 1 .. Text'Last + 1;
   function Operand_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment)
      return Expression_Result is
     (declare Value : constant Value_Result := Value_At (Text, Position, Names);
      begin (After => Value.After, Static_Length => Value.Static_Length,
             Dynamic_Seen => Value.Dynamic_Seen));

   function Expression_Tail
     (Text : String; Position : Literal_Position; Names : Binding_Environment;
      Length : Capacity_Value; Dynamic_Seen : Boolean; Remaining : Operand_Count)
      return Expression_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Names (Text, Names),
       Post => Expression_Tail'Result.After = 0
         or else Expression_Tail'Result.After in Position + 1 .. Text'Last + 1,
       Subprogram_Variant => (Decreases => Remaining);
   function Expression_Tail
     (Text : String; Position : Literal_Position; Names : Binding_Environment;
      Length : Capacity_Value; Dynamic_Seen : Boolean; Remaining : Operand_Count)
      return Expression_Result is
     (declare Atom : constant Expression_Result := Operand_At (Text, Position, Names);
              Following : constant Literal_Position := Take_Token (Text, Atom.After, Ampersand);
      begin
        (if Remaining = 0 or else Atom.After = 0
           or else Atom.Static_Length > Max_Source_Length - Length
           or else (Dynamic_Seen and then Atom.Dynamic_Seen)
         then Invalid_Expression
         elsif Following /= 0 then
           Expression_Tail (Text, Following, Names, Length + Atom.Static_Length,
             Dynamic_Seen or else Atom.Dynamic_Seen, Remaining - 1)
         else (After => Atom.After, Static_Length => Length + Atom.Static_Length,
               Dynamic_Seen => Dynamic_Seen or else Atom.Dynamic_Seen)));

   function Expression_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment)
      return Expression_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1 and then Valid_Names (Text, Names),
       Post => (Static => (Expression_At'Result.After = 0
         or else Expression_At'Result.After in Position + 1 .. Text'Last + 1)
         and then ( Expression_At'Result =
           Expression_Tail (Text, Position, Names, 0, False, Max_Expression_Operands)));
   function Expression_At
     (Text : String; Position : Literal_Position; Names : Binding_Environment)
      return Expression_Result is
      Next : Literal_Position := Position;
      Length : Capacity_Value := 0;
      Dynamic_Seen : Boolean := False;
      Remaining : Operand_Count := Max_Expression_Operands;
      Atom : Expression_Result;
      Following : Literal_Position;
   begin
      loop
         pragma Loop_Invariant (Next in Position .. Text'Last + 1);
         pragma Loop_Invariant (Static =>
           Expression_Tail (Text, Position, Names, 0, False, Max_Expression_Operands)
           = Expression_Tail (Text, Next, Names, Length, Dynamic_Seen, Remaining));
         pragma Loop_Variant (Decreases => Remaining);
         Atom := Operand_At (Text, Next, Names);
         if Remaining = 0 or else Atom.After = 0
           or else Atom.Static_Length > Max_Source_Length - Length
           or else (Dynamic_Seen and then Atom.Dynamic_Seen)
         then return Invalid_Expression; end if;
         Following := Take_Token (Text, Atom.After, Ampersand);
         Length := Length + Atom.Static_Length;
         Dynamic_Seen := Dynamic_Seen or else Atom.Dynamic_Seen;
         if Following = 0 then
            return (After => Atom.After, Static_Length => Length, Dynamic_Seen => Dynamic_Seen);
         end if;
         Next := Following;
         Remaining := Remaining - 1;
      end loop;
   end Expression_At;

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
     (declare Value : constant Value_Result := Value_At (Text, State.Position, State.Names);
      begin
        (if Value.After = 0 or else State.Target = 0
           or else Value.Static_Length /= State.Names.Items (State.Target).Static_Length
           or else Value.Dynamic_Seen /= State.Names.Items (State.Target).Dynamic
         then Invalid_State else (State with delta Position => Value.After)));

   function Output_At (Text : String; State : Parser_State) return Parser_State
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Post => Valid_State (Text, Output_At'Result);
   function Output_At (Text : String; State : Parser_State) return Parser_State is
     (declare Value : constant Expression_Result := Expression_At (Text, State.Position, State.Names);
      begin
        (if Value.After = 0 or else
           (Value.Dynamic_Seen and then Value.Static_Length > Max_Source_Length - State.Capacity)
         then Invalid_State else (State with delta Position => Value.After)));

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
      elsif Token = Capacity_Literal then Capacity_At (Text, State)
      elsif Token = String_Literal then
        (State with delta Position => Literal_At (Text, Skip_At (Text, State.Position)).After)
      else (State with delta Position => Take_Token (Text, State.Position, Token)));

   subtype Token_Index is Positive range 1 .. 101;
   function Suffix_Matches
     (Text : String; Form : Form_Kind; Next_Token : Token_Index;
      State : Parser_State) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_State (Text, State),
       Subprogram_Variant => (Increases => Next_Token);
   function Suffix_Matches
     (Text : String; Form : Form_Kind; Next_Token : Token_Index;
      State : Parser_State) return Boolean is
     (if State.Position = 0 then False
      elsif Next_Token > Tokens (Form)'Last then
        Trivia_End (Text, State.Position) = Text'Last + 1
      else Suffix_Matches (Text, Form, Next_Token + 1,
        Step (Text, Form, Tokens (Form) (Next_Token), State)));

   function Form_Member (Source : String; Form : Form_Kind) return Boolean
     with Ghost => Static, Global => null;
   function Form_Member (Source : String; Form : Form_Kind) return Boolean is
     (Source'Length in 1 .. Max_Source_Length
      and then Allowed_Source (Normalized (Source))
      and then Suffix_Matches (Normalized (Source), Form, 1, Initial_State));
   function Is_Member (Source : String) return Boolean is
     (for some Form in Form_Kind => Form_Member (Source, Form));
   function Has_Arguments (Source : String) return Boolean is
     (for some Form in Form_Kind =>
        Form_Member (Source, Form) and then Is_Argument_Form (Form)
        and then (for all Previous in Form_Kind'First .. Form =>
          (if Previous /= Form then not Form_Member (Source, Previous))));
   function Has_Assignment (Source : String) return Boolean is
     (for some Form in Form_Kind =>
        Form_Member (Source, Form) and then Is_Assignment_Form (Form)
        and then (for all Previous in Form_Kind'First .. Form =>
          (if Previous /= Form then not Form_Member (Source, Previous))));

   function Accepts_Form (Source : String; Form : Form_Kind) return Boolean
     with Global => null,
       Post => (Static => Accepts_Form'Result = Form_Member (Source, Form));
   function Accepts_Form (Source : String; Form : Form_Kind) return Boolean is
   begin
      if Source'Length = 0 or else Source'Length > Max_Source_Length then return False; end if;
      declare
         Text : constant String := Normalized (Source);
         State : Parser_State := Initial_State;
         Next_Token : Token_Index := 1;
      begin
         if not Allowed_Source (Text) then return False; end if;
         while Next_Token <= Tokens (Form)'Last loop
            pragma Loop_Invariant (State.Position > 0 and then Valid_State (Text, State));
            pragma Loop_Invariant (Static =>
              Suffix_Matches (Text, Form, 1, Initial_State)
              = Suffix_Matches (Text, Form, Next_Token, State));
            pragma Loop_Variant (Increases => Next_Token);
            State := Step (Text, Form, Tokens (Form) (Next_Token), State);
            if State.Position = 0 then return False; end if;
            Next_Token := Next_Token + 1;
         end loop;
         return Skip_At (Text, State.Position) > Text'Last;
      end;
   end Accepts_Form;

   function Accepts (Source : String) return Boolean is
   begin
      for Form in Form_Kind loop
         pragma Loop_Invariant (Static =>
           (for all Previous in Form_Kind'First .. Form =>
             (if Previous /= Form then not Form_Member (Source, Previous))));
         if Accepts_Form (Source, Form) then return True; end if;
      end loop;
      return False;
   end Accepts;

   function Uses_Arguments (Source : String) return Boolean is
   begin
      for Form in Form_Kind loop
         pragma Loop_Invariant (Static =>
           (for all Previous in Form_Kind'First .. Form =>
             (if Previous /= Form then not Form_Member (Source, Previous))));
         if Accepts_Form (Source, Form) then return Is_Argument_Form (Form); end if;
      end loop;
      return False;
   end Uses_Arguments;

   function Uses_Assignment (Source : String) return Boolean is
   begin
      for Form in Form_Kind loop
         pragma Loop_Invariant (Static =>
           (for all Previous in Form_Kind'First .. Form =>
             (if Previous /= Form then not Form_Member (Source, Previous))));
         if Accepts_Form (Source, Form) then return Is_Assignment_Form (Form); end if;
      end loop;
      return False;
   end Uses_Assignment;
end Silver_Output_Profile;
