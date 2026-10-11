--  Program shells and flat expressions share one parser. Stable byte, name,
--  literal and decimal primitives stay in Silver_Output_Lexical.
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
         when String_Literal | Static_Initializer | Static_Assignment => """",
         when Colon => ":",
         when Constant_Keyword => "constant",
         when String_Name => "string",
         when Assignment => ":=",
         when Declaration_Name | Reference_Name | Dynamic_Declaration
            | Dynamic_Reference | Output_Expression => "_",
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
         when Equal => "=");

   function Tokens (Form : Form_Kind) return Token_Sequence is
     (case Form is
      when Direct_Form =>
         (With_Keyword, IO_Name, Semicolon, Procedure_Keyword, Main_Name, Is_Keyword,
          Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis, On_Name,
          Right_Parenthesis, Semicolon, Begin_Keyword, IO_Name, Dot, Put_Line_Name,
          Left_Parenthesis, Output_Expression, Right_Parenthesis, Semicolon,
          End_Keyword, Main_Name, Semicolon),
      when Static_Form =>
         (With_Keyword, IO_Name, Semicolon, Procedure_Keyword, Main_Name, Is_Keyword,
          Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis, On_Name,
          Right_Parenthesis, Semicolon, Declaration_Name, Colon, Constant_Keyword,
          String_Name, Assignment, Static_Initializer, Semicolon, Begin_Keyword,
          IO_Name, Dot, Put_Line_Name, Left_Parenthesis, Output_Expression,
          Right_Parenthesis, Semicolon, End_Keyword, Main_Name, Semicolon),
      when Assignment_Form =>
         (With_Keyword, IO_Name, Semicolon, Procedure_Keyword, Main_Name, Is_Keyword,
          Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis, On_Name,
          Right_Parenthesis, Semicolon, Declaration_Name, Colon, String_Name,
          Assignment, Static_Initializer, Semicolon, Begin_Keyword, Reference_Name,
          Assignment, Static_Assignment, Semicolon, IO_Name, Dot, Put_Line_Name,
          Left_Parenthesis, Output_Expression, Right_Parenthesis, Semicolon,
          End_Keyword, Main_Name, Semicolon),
      when Argument_Form =>
         (With_Keyword, IO_Name, Semicolon, With_Keyword, Arguments_Name, Semicolon,
          Procedure_Keyword, Main_Name, Is_Keyword, Pragma_Keyword, SPARK_Mode_Name,
          Left_Parenthesis, On_Name, Right_Parenthesis, Semicolon, Dynamic_Declaration,
          Colon, Constant_Keyword, String_Name, Assignment, Arguments_Name, Dot,
          First_Or_Default_Name, Left_Parenthesis, String_Literal, Right_Parenthesis,
          Semicolon, Begin_Keyword, If_Keyword, Arguments_Name, Dot,
          Input_Is_Valid_Name, Then_Keyword, IO_Name, Dot, Put_Line_Name,
          Left_Parenthesis, Output_Expression, Right_Parenthesis, Semicolon,
          Else_Keyword, Arguments_Name, Dot, Reject_Name, Semicolon, End_Keyword,
          If_Keyword, Semicolon, End_Keyword, Main_Name, Semicolon),
      when Guarded_Argument_Form =>
         (With_Keyword, IO_Name, Semicolon, With_Keyword, Arguments_Name, Semicolon,
          Procedure_Keyword, Main_Name, Is_Keyword, Pragma_Keyword, SPARK_Mode_Name,
          Left_Parenthesis, On_Name, Right_Parenthesis, Semicolon, Dynamic_Declaration,
          Colon, Constant_Keyword, String_Name, Assignment, Arguments_Name, Dot,
          First_Or_Default_Name, Left_Parenthesis, String_Literal, Right_Parenthesis,
          Semicolon, Begin_Keyword, If_Keyword, Arguments_Name, Dot,
          Input_Is_Valid_Name, And_Keyword, Then_Keyword, Dynamic_Reference,
          Apostrophe, Length_Name, Less_Equal, Capacity_Literal, Then_Keyword, IO_Name,
          Dot, Put_Line_Name, Left_Parenthesis, Output_Expression, Right_Parenthesis,
          Semicolon, Else_Keyword, Arguments_Name, Dot, Reject_Name, Semicolon,
          End_Keyword, If_Keyword, Semicolon, End_Keyword, Main_Name, Semicolon),
      when Branching_Form =>
         (With_Keyword, IO_Name, Semicolon, With_Keyword, Arguments_Name, Semicolon,
          Procedure_Keyword, Main_Name, Is_Keyword, Pragma_Keyword, SPARK_Mode_Name,
          Left_Parenthesis, On_Name, Right_Parenthesis, Semicolon, Dynamic_Declaration,
          Colon, Constant_Keyword, String_Name, Assignment, Arguments_Name, Dot,
          First_Or_Default_Name, Left_Parenthesis, String_Literal, Right_Parenthesis,
          Semicolon, Begin_Keyword, If_Keyword, Arguments_Name, Dot,
          Input_Is_Valid_Name, Then_Keyword, If_Keyword, Dynamic_Reference, Equal,
          String_Literal, Then_Keyword, IO_Name, Dot, Put_Line_Name, Left_Parenthesis,
          Output_Expression, Right_Parenthesis, Semicolon, Else_Keyword, IO_Name, Dot,
          Put_Line_Name, Left_Parenthesis, Output_Expression, Right_Parenthesis,
          Semicolon, End_Keyword, If_Keyword, Semicolon, Else_Keyword, Arguments_Name,
          Dot, Reject_Name, Semicolon, End_Keyword, If_Keyword, Semicolon, End_Keyword,
          Main_Name, Semicolon),
      when Guarded_Branching_Form =>
         (With_Keyword, IO_Name, Semicolon, With_Keyword, Arguments_Name, Semicolon,
          Procedure_Keyword, Main_Name, Is_Keyword, Pragma_Keyword, SPARK_Mode_Name,
          Left_Parenthesis, On_Name, Right_Parenthesis, Semicolon, Dynamic_Declaration,
          Colon, Constant_Keyword, String_Name, Assignment, Arguments_Name, Dot,
          First_Or_Default_Name, Left_Parenthesis, String_Literal, Right_Parenthesis,
          Semicolon, Begin_Keyword, If_Keyword, Arguments_Name, Dot,
          Input_Is_Valid_Name, And_Keyword, Then_Keyword, Dynamic_Reference,
          Apostrophe, Length_Name, Less_Equal, Capacity_Literal, Then_Keyword,
          If_Keyword, Dynamic_Reference, Equal, String_Literal, Then_Keyword, IO_Name,
          Dot, Put_Line_Name, Left_Parenthesis, Output_Expression, Right_Parenthesis,
          Semicolon, Else_Keyword, IO_Name, Dot, Put_Line_Name, Left_Parenthesis,
          Output_Expression, Right_Parenthesis, Semicolon, End_Keyword, If_Keyword,
          Semicolon, Else_Keyword, Arguments_Name, Dot, Reject_Name, Semicolon,
          End_Keyword, If_Keyword, Semicolon, End_Keyword, Main_Name, Semicolon),
      when Result_Form =>
         (With_Keyword, IO_Name, Semicolon, With_Keyword, Arguments_Name, Semicolon,
          Procedure_Keyword, Main_Name, Is_Keyword, Pragma_Keyword, SPARK_Mode_Name,
          Left_Parenthesis, On_Name, Right_Parenthesis, Semicolon, Dynamic_Declaration,
          Colon, Constant_Keyword, String_Name, Assignment, Arguments_Name, Dot,
          First_Or_Default_Name, Left_Parenthesis, String_Literal, Right_Parenthesis,
          Semicolon, Declaration_Name, Colon, String_Name, Assignment,
          Static_Initializer, Semicolon, Begin_Keyword, If_Keyword, Arguments_Name,
          Dot, Input_Is_Valid_Name, Then_Keyword, If_Keyword, Dynamic_Reference, Equal,
          String_Literal, Then_Keyword, Reference_Name, Assignment, Static_Assignment,
          Semicolon, Else_Keyword, Reference_Name, Assignment, Static_Assignment,
          Semicolon, End_Keyword, If_Keyword, Semicolon, IO_Name, Dot, Put_Line_Name,
          Left_Parenthesis, Output_Expression, Right_Parenthesis, Semicolon,
          Else_Keyword, Arguments_Name, Dot, Reject_Name, Semicolon, End_Keyword,
          If_Keyword, Semicolon, End_Keyword, Main_Name, Semicolon),
      when Guarded_Result_Form =>
         (With_Keyword, IO_Name, Semicolon, With_Keyword, Arguments_Name, Semicolon,
          Procedure_Keyword, Main_Name, Is_Keyword, Pragma_Keyword, SPARK_Mode_Name,
          Left_Parenthesis, On_Name, Right_Parenthesis, Semicolon, Dynamic_Declaration,
          Colon, Constant_Keyword, String_Name, Assignment, Arguments_Name, Dot,
          First_Or_Default_Name, Left_Parenthesis, String_Literal, Right_Parenthesis,
          Semicolon, Declaration_Name, Colon, String_Name, Assignment,
          Static_Initializer, Semicolon, Begin_Keyword, If_Keyword, Arguments_Name,
          Dot, Input_Is_Valid_Name, And_Keyword, Then_Keyword, Dynamic_Reference,
          Apostrophe, Length_Name, Less_Equal, Capacity_Literal, Then_Keyword,
          If_Keyword, Dynamic_Reference, Equal, String_Literal, Then_Keyword,
          Reference_Name, Assignment, Static_Assignment, Semicolon, Else_Keyword,
          Reference_Name, Assignment, Static_Assignment, Semicolon, End_Keyword,
          If_Keyword, Semicolon, IO_Name, Dot, Put_Line_Name, Left_Parenthesis,
          Output_Expression, Right_Parenthesis, Semicolon, Else_Keyword,
          Arguments_Name, Dot, Reject_Name, Semicolon, End_Keyword, If_Keyword,
          Semicolon, End_Keyword, Main_Name, Semicolon));

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

   subtype Operand_Count is Natural range 0 .. Max_Expression_Operands;

   type Expression_Result is record
      After : Literal_Position;
      Static_Length : Capacity_Value;
      Dynamic_Seen : Boolean;
      Static_Seen : Boolean;
   end record;
   Invalid_Expression : constant Expression_Result :=
     (After => 0, Static_Length => 0, Dynamic_Seen => False, Static_Seen => False);

   function Operand_At
     (Text : String; Position : Cursor;
      Static_First, Static_After : Literal_Position;
      Static_Length : Capacity_Value;
      Dynamic_First, Dynamic_After : Literal_Position) return Expression_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Valid_Name_State (Text, Static_First, Static_After)
         and then Valid_Name_State (Text, Dynamic_First, Dynamic_After),
       Post => Operand_At'Result.After = 0
         or else Operand_At'Result.After in Position + 1 .. Text'Last + 1;

   function Operand_At
     (Text : String; Position : Cursor;
      Static_First, Static_After : Literal_Position;
      Static_Length : Capacity_Value;
      Dynamic_First, Dynamic_After : Literal_Position) return Expression_Result
   is
     (if Position <= Text'Last and then Text (Position) = Character'Val (34)
        and then Literal_End (Text, Position + 1) /= 0 then
        (After => Literal_End (Text, Position + 1),
         Static_Length => Literal_Length (Text, Position + 1),
         Dynamic_Seen => False, Static_Seen => False)
      elsif Identifier_End (Text, Position) /= 0 and then Static_First > 0
        and then Equal_Name (Text, Static_First, Static_After,
          Position, Identifier_End (Text, Position)) then
        (After => Identifier_End (Text, Position), Static_Length => Static_Length,
         Dynamic_Seen => False, Static_Seen => True)
      elsif Identifier_End (Text, Position) /= 0 and then Dynamic_First > 0
        and then Equal_Name (Text, Dynamic_First, Dynamic_After,
          Position, Identifier_End (Text, Position)) then
        (After => Identifier_End (Text, Position), Static_Length => 0,
         Dynamic_Seen => True, Static_Seen => False)
      else Invalid_Expression);

   function Expression_Tail
     (Text : String; Position : Cursor;
      Static_First, Static_After : Literal_Position;
      Static_Length : Capacity_Value;
      Dynamic_First, Dynamic_After : Literal_Position;
      Length : Capacity_Value; Dynamic_Seen, Static_Seen : Boolean;
      Remaining : Operand_Count) return Expression_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Valid_Name_State (Text, Static_First, Static_After)
         and then Valid_Name_State (Text, Dynamic_First, Dynamic_After),
       Post => Expression_Tail'Result.After = 0
         or else Expression_Tail'Result.After in Position + 1 .. Text'Last + 1,
       Subprogram_Variant => (Decreases => Remaining);

   function Expression_Tail
     (Text : String; Position : Cursor;
      Static_First, Static_After : Literal_Position;
      Static_Length : Capacity_Value;
      Dynamic_First, Dynamic_After : Literal_Position;
      Length : Capacity_Value; Dynamic_Seen, Static_Seen : Boolean;
      Remaining : Operand_Count) return Expression_Result
   is
     (if Remaining = 0 then Invalid_Expression
      elsif Operand_At
          (Text, Trivia_End (Text, Position), Static_First, Static_After,
           Static_Length, Dynamic_First, Dynamic_After).After = 0
        or else Operand_At
          (Text, Trivia_End (Text, Position), Static_First, Static_After,
           Static_Length, Dynamic_First, Dynamic_After).Static_Length > Max_Source_Length - Length
        or else (Dynamic_Seen and then Operand_At
          (Text, Trivia_End (Text, Position), Static_First, Static_After,
           Static_Length, Dynamic_First, Dynamic_After).Dynamic_Seen)
      then Invalid_Expression
      elsif Trivia_End (Text, Operand_At
          (Text, Trivia_End (Text, Position), Static_First, Static_After,
           Static_Length, Dynamic_First, Dynamic_After).After) <= Text'Last
        and then Text (Trivia_End (Text, Operand_At
          (Text, Trivia_End (Text, Position), Static_First, Static_After,
           Static_Length, Dynamic_First, Dynamic_After).After)) = '&'
      then Expression_Tail (Text, Trivia_End (Text, Operand_At
          (Text, Trivia_End (Text, Position), Static_First, Static_After,
           Static_Length, Dynamic_First, Dynamic_After).After) + 1,
        Static_First, Static_After, Static_Length, Dynamic_First, Dynamic_After,
        Length + Operand_At
          (Text, Trivia_End (Text, Position), Static_First, Static_After,
           Static_Length, Dynamic_First, Dynamic_After).Static_Length,
        Dynamic_Seen or else Operand_At
          (Text, Trivia_End (Text, Position), Static_First, Static_After,
           Static_Length, Dynamic_First, Dynamic_After).Dynamic_Seen,
        Static_Seen or else Operand_At
          (Text, Trivia_End (Text, Position), Static_First, Static_After,
           Static_Length, Dynamic_First, Dynamic_After).Static_Seen, Remaining - 1)
      else (After => Operand_At
          (Text, Trivia_End (Text, Position), Static_First, Static_After,
           Static_Length, Dynamic_First, Dynamic_After).After,
        Static_Length => Length + Operand_At
          (Text, Trivia_End (Text, Position), Static_First, Static_After,
           Static_Length, Dynamic_First, Dynamic_After).Static_Length,
        Dynamic_Seen => Dynamic_Seen or else Operand_At
          (Text, Trivia_End (Text, Position), Static_First, Static_After,
           Static_Length, Dynamic_First, Dynamic_After).Dynamic_Seen,
        Static_Seen => Static_Seen or else Operand_At
          (Text, Trivia_End (Text, Position), Static_First, Static_After,
           Static_Length, Dynamic_First, Dynamic_After).Static_Seen));

   function Expression_At
     (Text : String; Position : Cursor;
      Static_First, Static_After : Literal_Position;
      Static_Length : Capacity_Value;
      Dynamic_First, Dynamic_After : Literal_Position) return Expression_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Valid_Name_State (Text, Static_First, Static_After)
         and then Valid_Name_State (Text, Dynamic_First, Dynamic_After),
       Post => Expression_At'Result.After = 0
         or else Expression_At'Result.After in Position + 1 .. Text'Last + 1;

   function Expression_At
     (Text : String; Position : Cursor;
      Static_First, Static_After : Literal_Position;
      Static_Length : Capacity_Value;
      Dynamic_First, Dynamic_After : Literal_Position) return Expression_Result
   is
     (Expression_Tail (Text, Position, Static_First, Static_After, Static_Length, Dynamic_First,
          Dynamic_After, 0, False, False, Max_Expression_Operands));

   type Parser_State is record
      Position : Literal_Position;
      Static_First, Static_After : Literal_Position;
      Dynamic_First, Dynamic_After : Literal_Position;
      Static_Length : Capacity_Value;
      Capacity : Capacity_Value;
   end record;
   Initial_State : constant Parser_State :=
     (Position => 1, Static_First => 0, Static_After => 0,
      Dynamic_First => 0, Dynamic_After => 0, Static_Length => 0,
      Capacity => Max_Source_Length);
   Invalid_State : constant Parser_State :=
     (Position => 0, Static_First => 0, Static_After => 0,
      Dynamic_First => 0, Dynamic_After => 0, Static_Length => 0, Capacity => 0);

   function Valid_State (Text : String; State : Parser_State) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_State (Text : String; State : Parser_State) return Boolean is
     (State.Position <= Text'Last + 1
      and then Valid_Name_State (Text, State.Static_First, State.Static_After)
      and then Valid_Name_State (Text, State.Dynamic_First, State.Dynamic_After));

   function Step
     (Text : String; Form : Form_Kind; Token : Token_Kind; State : Parser_State)
      return Parser_State
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then State.Position > 0 and then Valid_State (Text, State),
       Post => Valid_State (Text, Step'Result);

   function Step
     (Text : String; Form : Form_Kind; Token : Token_Kind; State : Parser_State)
      return Parser_State
   is
     (if Token = Declaration_Name then
        (if Identifier_End (Text, Trivia_End (Text, State.Position)) /= 0
           and then not Forbidden_Name (Text, Trivia_End (Text, State.Position), Identifier_End (Text,
          Trivia_End (Text, State.Position)))
           and then (State.Dynamic_First = 0
             or else (not Forbidden_Argument_Name (Text, Trivia_End (Text, State.Position),
          Identifier_End (Text, Trivia_End (Text, State.Position)))
               and then not Equal_Name (Text, State.Dynamic_First, State.Dynamic_After,
                 Trivia_End (Text, State.Position), Identifier_End (Text, Trivia_End (Text,
          State.Position)))))
         then (State with delta Position => Identifier_End (Text, Trivia_End (Text, State.Position)),
           Static_First => Trivia_End (Text, State.Position), Static_After => Identifier_End (Text,
          Trivia_End (Text, State.Position)))
         else Invalid_State)
      elsif Token = Dynamic_Declaration then
        (if Identifier_End (Text, Trivia_End (Text, State.Position)) /= 0
           and then not Forbidden_Argument_Name (Text, Trivia_End (Text, State.Position),
          Identifier_End (Text, Trivia_End (Text, State.Position)))
         then (State with delta Position => Identifier_End (Text, Trivia_End (Text, State.Position)),
           Dynamic_First => Trivia_End (Text, State.Position), Dynamic_After => Identifier_End (Text,
          Trivia_End (Text, State.Position)))
         else Invalid_State)
      elsif Token = Reference_Name then
        (if Identifier_End (Text, Trivia_End (Text, State.Position)) /= 0 and then State.Static_First > 0
           and then Equal_Name (Text, State.Static_First, State.Static_After, Trivia_End (Text,
          State.Position), Identifier_End (Text, Trivia_End (Text, State.Position)))
         then (State with delta Position => Identifier_End (Text, Trivia_End (Text,
          State.Position))) else Invalid_State)
      elsif Token = Dynamic_Reference then
        (if Identifier_End (Text, Trivia_End (Text, State.Position)) /= 0 and then State.Dynamic_First > 0
           and then Equal_Name (Text, State.Dynamic_First, State.Dynamic_After, Trivia_End (Text,
          State.Position), Identifier_End (Text, Trivia_End (Text, State.Position)))
         then (State with delta Position => Identifier_End (Text, Trivia_End (Text,
          State.Position))) else Invalid_State)
      elsif Token in String_Literal | Static_Initializer | Static_Assignment then
        (if Trivia_End (Text, State.Position) <= Text'Last
           and then Text (Trivia_End (Text, State.Position)) = Character'Val (34)
           and then Literal_End (Text, Trivia_End (Text, State.Position) + 1) /= 0
           and then (Token /= Static_Assignment or else Literal_Length (Text, Trivia_End (Text,
          State.Position) + 1) = State.Static_Length)
         then (State with delta Position => Literal_End (Text, Trivia_End (Text, State.Position) + 1),
           Static_Length => (if Token = Static_Initializer then Literal_Length (Text, Trivia_End (Text,
          State.Position) + 1) else State.Static_Length))
         else Invalid_State)
      elsif Token = Capacity_Literal then
        (if Decimal_At (Text, Trivia_End (Text, State.Position)).After /= 0
         then (State with delta Position => Decimal_At (Text, Trivia_End (Text, State.Position)).After,
          Capacity => Decimal_At (Text, Trivia_End (Text, State.Position)).Value)
         else Invalid_State)
      elsif Token = Output_Expression then
        (if Expression_At
          (Text, State.Position, State.Static_First, State.Static_After,
           State.Static_Length, State.Dynamic_First, State.Dynamic_After).After /= 0
           and then (not Expression_At
          (Text, State.Position, State.Static_First, State.Static_After,
           State.Static_Length, State.Dynamic_First, State.Dynamic_After).Dynamic_Seen
             or else Expression_At
          (Text, State.Position, State.Static_First, State.Static_After,
           State.Static_Length, State.Dynamic_First,
          State.Dynamic_After).Static_Length <= Max_Source_Length - State.Capacity)
           and then (not Is_Assignment_Form (Form) or else Expression_At
          (Text, State.Position, State.Static_First, State.Static_After,
           State.Static_Length, State.Dynamic_First, State.Dynamic_After).Static_Seen)
         then (State with delta Position => Expression_At
          (Text, State.Position, State.Static_First, State.Static_After,
           State.Static_Length, State.Dynamic_First, State.Dynamic_After).After) else Invalid_State)
      elsif Token_At (Text, Trivia_End (Text, State.Position), Spelling (Token), Is_Word_Token (Token))
      then (State with delta Position => Trivia_End (Text, State.Position) + Spelling (Token)'Length)
      else Invalid_State);

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
      State : Parser_State) return Boolean
   is
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
     (for some Form in Argument_Form .. Guarded_Result_Form => Form_Member (Source, Form));
   function Has_Assignment (Source : String) return Boolean is
     (Form_Member (Source, Assignment_Form)
      or else Form_Member (Source, Result_Form)
      or else Form_Member (Source, Guarded_Result_Form));

   procedure Read_Operand
     (Text : String; Position : Cursor;
      Static_First, Static_After : Literal_Position;
      Static_Length : Capacity_Value;
      Dynamic_First, Dynamic_After : Literal_Position;
      Result : out Expression_Result)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Valid_Name_State (Text, Static_First, Static_After)
         and then Valid_Name_State (Text, Dynamic_First, Dynamic_After),
       Post => (Static => Result = Operand_At (Text, Position,
         Static_First, Static_After, Static_Length, Dynamic_First, Dynamic_After))
   is
      After : Cursor := Position;
      Matched : Boolean;
      Length : Capacity_Value;
   begin
      Result := Invalid_Expression;
      if Position <= Text'Last and then Text (Position) = Character'Val (34) then
         Match_Sized_Literal (Text, After, Matched, Length);
         if Matched then
            Result := (After => After, Static_Length => Length,
              Dynamic_Seen => False, Static_Seen => False);
         end if;
      else
         Match_Identifier (Text, After, Matched);
         if not Matched then return; end if;
         if Static_First > 0 and then Equal_Name
           (Text, Static_First, Static_After, Position, After)
         then
            Result := (After => After, Static_Length => Static_Length,
              Dynamic_Seen => False, Static_Seen => True);
         elsif Dynamic_First > 0 and then Equal_Name
           (Text, Dynamic_First, Dynamic_After, Position, After)
         then
            Result := (After => After, Static_Length => 0,
              Dynamic_Seen => True, Static_Seen => False);
         end if;
      end if;
   end Read_Operand;

   procedure Match_Expression
     (Text : String; Position : Cursor;
      Static_First, Static_After : Literal_Position;
      Static_Length : Capacity_Value;
      Dynamic_First, Dynamic_After : Literal_Position;
      Result : out Expression_Result)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Valid_Name_State (Text, Static_First, Static_After)
         and then Valid_Name_State (Text, Dynamic_First, Dynamic_After),
       Post => (Static => Result = Expression_At (Text, Position,
         Static_First, Static_After, Static_Length, Dynamic_First, Dynamic_After))
   is
      Next : Cursor := Position;
      Length : Capacity_Value := 0;
      Dynamic_Seen, Static_Seen : Boolean := False;
      Remaining : Operand_Count := Max_Expression_Operands;
      Atom : Expression_Result;
      Following : Cursor;
   begin
      Result := Invalid_Expression;
      loop
         pragma Loop_Invariant (Next <= Text'Last + 1);
         pragma Loop_Invariant (Static =>
           Expression_At (Text, Position, Static_First, Static_After,
             Static_Length, Dynamic_First, Dynamic_After)
           = Expression_Tail (Text, Next, Static_First, Static_After,
             Static_Length, Dynamic_First, Dynamic_After,
             Length, Dynamic_Seen, Static_Seen, Remaining));
         pragma Loop_Variant (Decreases => Remaining);
         if Remaining = 0 then return; end if;
         declare
            Start : Cursor := Next;
         begin
            Skip_Trivia (Text, Start);
            Read_Operand (Text, Start, Static_First, Static_After,
              Static_Length, Dynamic_First, Dynamic_After, Atom);
         end;
         if Atom.After = 0
           or else Atom.Static_Length > Max_Source_Length - Length
           or else (Dynamic_Seen and then Atom.Dynamic_Seen)
         then
            return;
         end if;
         Following := Atom.After;
         Skip_Trivia (Text, Following);
         Length := Length + Atom.Static_Length;
         Dynamic_Seen := Dynamic_Seen or else Atom.Dynamic_Seen;
         Static_Seen := Static_Seen or else Atom.Static_Seen;
         if Following <= Text'Last and then Text (Following) = '&' then
            Next := Following + 1;
            Remaining := Remaining - 1;
         else
            Result := (After => Atom.After, Static_Length => Length,
              Dynamic_Seen => Dynamic_Seen, Static_Seen => Static_Seen);
            return;
         end if;
      end loop;
   end Match_Expression;

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

   procedure Match_Step
     (Text : String; Form : Form_Kind; Token : Token_Kind;
      State : in out Parser_State)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then State.Position > 0 and then Valid_State (Text, State),
       Post => (Static => Valid_State (Text, State)
         and then State = Step (Text, Form, Token, State'Old))
   is
      Next : Cursor := State.Position;
      Start : Cursor;
      Matched : Boolean;
      Length : Capacity_Value;
      Parsed : Expression_Result;
      Decimal : Decimal_Result;
   begin
      Skip_Trivia (Text, Next);
      Start := Next;
      if Token = Declaration_Name then
         Match_Identifier (Text, Next, Matched);
         if not Matched or else Forbidden_Name (Text, Start, Next)
           or else (State.Dynamic_First > 0
             and then (Forbidden_Argument_Name (Text, Start, Next)
               or else Equal_Name (Text, State.Dynamic_First, State.Dynamic_After, Start, Next)))
         then State := Invalid_State; return; end if;
         State.Position := Next;
         State.Static_First := Start;
         State.Static_After := Next;
      elsif Token = Dynamic_Declaration then
         Match_Identifier (Text, Next, Matched);
         if not Matched or else Forbidden_Argument_Name (Text, Start, Next) then
            State := Invalid_State; return;
         end if;
         State.Position := Next;
         State.Dynamic_First := Start;
         State.Dynamic_After := Next;
      elsif Token = Reference_Name then
         Match_Identifier (Text, Next, Matched);
         if not Matched or else State.Static_First = 0
           or else not Equal_Name (Text, State.Static_First, State.Static_After, Start, Next)
         then State := Invalid_State; return; end if;
         State.Position := Next;
      elsif Token = Dynamic_Reference then
         Match_Identifier (Text, Next, Matched);
         if not Matched or else State.Dynamic_First = 0
           or else not Equal_Name (Text, State.Dynamic_First, State.Dynamic_After, Start, Next)
         then State := Invalid_State; return; end if;
         State.Position := Next;
      elsif Token in String_Literal | Static_Initializer | Static_Assignment then
         Match_Sized_Literal (Text, Next, Matched, Length);
         if not Matched or else
           (Token = Static_Assignment and then Length /= State.Static_Length)
         then State := Invalid_State; return; end if;
         State.Position := Next;
         if Token = Static_Initializer then State.Static_Length := Length; end if;
      elsif Token = Capacity_Literal then
         Decimal := Read_Capacity (Text, Next);
         if Decimal.After = 0 then State := Invalid_State; return; end if;
         State.Position := Decimal.After;
         State.Capacity := Decimal.Value;
      elsif Token = Output_Expression then
         Match_Expression (Text, State.Position, State.Static_First, State.Static_After,
           State.Static_Length, State.Dynamic_First, State.Dynamic_After, Parsed);
         if Parsed.After = 0
           or else (Parsed.Dynamic_Seen
             and then Parsed.Static_Length > Max_Source_Length - State.Capacity)
           or else (Is_Assignment_Form (Form) and then not Parsed.Static_Seen)
         then State := Invalid_State; return; end if;
         State.Position := Parsed.After;
      else
         Match_Token (Text, Next, Token, Matched);
         if not Matched then State := Invalid_State; return; end if;
         State.Position := Next;
      end if;
   end Match_Step;

   function Accepts_Form (Source : String; Form : Form_Kind) return Boolean
     with Global => null,
       Post => (Static => Accepts_Form'Result = Form_Member (Source, Form));
   function Accepts_Form (Source : String; Form : Form_Kind) return Boolean is
   begin
      if Source'Length = 0 or else Source'Length > Max_Source_Length then
         return False;
      end if;
      declare
         Text : constant String := Normalized (Source);
         State : Parser_State := Initial_State;
         Next_Token : Token_Index := 1;
         Following : Cursor;
      begin
         if not Allowed_Source (Text) then return False; end if;
         while Next_Token <= Tokens (Form)'Last loop
            pragma Loop_Invariant (State.Position > 0 and then Valid_State (Text, State));
            pragma Loop_Invariant (Static =>
              Suffix_Matches (Text, Form, 1, Initial_State)
              = Suffix_Matches (Text, Form, Next_Token, State));
            pragma Loop_Variant (Increases => Next_Token);
            Match_Step (Text, Form, Tokens (Form) (Next_Token), State);
            if State.Position = 0 then return False; end if;
            Next_Token := Next_Token + 1;
         end loop;
         Following := State.Position;
         Skip_Trivia (Text, Following);
         return Following > Text'Last;
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
      for Form in Argument_Form .. Guarded_Result_Form loop
         pragma Loop_Invariant (Static =>
           (for all Previous in Argument_Form .. Form =>
             (if Previous /= Form then not Form_Member (Source, Previous))));
         if Accepts_Form (Source, Form) then return True; end if;
      end loop;
      return False;
   end Uses_Arguments;

   function Uses_Assignment (Source : String) return Boolean is
   begin
      return Accepts_Form (Source, Assignment_Form)
        or else Accepts_Form (Source, Result_Form)
        or else Accepts_Form (Source, Guarded_Result_Form);
   end Uses_Assignment;
end Silver_Output_Profile;
