with Silver_Profile;

package body Silver_Output_Profile
  with SPARK_Mode => On
is
   use Silver_Profile;

   subtype Cursor is Positive range 1 .. Max_Source_Length + 1;

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
         when Declaration_Name | Reference_Name => "_",
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
         when Capacity_Literal => "0");

   function Normalized (Source : String) return String
     with
       Global => null,
       Pre => Source'Length <= Max_Source_Length,
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

   --  The following ghost functions are the functional grammar model.
   --  Their decreasing variants establish that membership is decidable.
   function Comment_End (Text : String; Position : Cursor) return Cursor
     with
       Ghost => Static,
       Global => null,
       Pre => Text'First = 1
         and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Comment_End'Result in Position .. Text'Last + 1,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position);

   function Comment_End (Text : String; Position : Cursor) return Cursor is
     (if Position > Text'Last
        or else Is_Comment_End (Text (Position))
      then Position
      else Comment_End (Text, Position + 1));

   function Trivia_End (Text : String; Position : Cursor) return Cursor
     with
       Ghost => Static,
       Global => null,
       Pre => Text'First = 1
         and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Trivia_End'Result in Position .. Text'Last + 1,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position);

   function Trivia_End (Text : String; Position : Cursor) return Cursor is
     (if Position > Text'Last then Position
      elsif Is_Whitespace (Text (Position))
      then Trivia_End (Text, Position + 1)
      elsif Text (Position) = Comment_Introducer (1)
        and then Position < Text'Last
        and then Text (Position + 1) = Comment_Introducer (2)
      then Trivia_End (Text, Comment_End (Text, Position + 2))
      else Position);

   function Token_At
     (Text : String; Position : Cursor; Word : String; Is_Word : Boolean)
      return Boolean
     with
       Ghost => Static,
       Global => null,
       Pre => Text'First = 1
         and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Word'First = 1
         and then Word'Length in 1 .. 16;

   function Token_At
     (Text : String; Position : Cursor; Word : String; Is_Word : Boolean)
      return Boolean
   is
     (Word'Length <= (Text'Last - Position) + 1
      and then
        (for all Index in Word'Range =>
           Lowercase (Text ((Position + Index) - 1)) = Word (Index))
      and then
        (not Is_Word
         or else Position + Word'Length > Text'Last
         or else not Is_Identifier_Character (Text (Position + Word'Length))));

   subtype Literal_Position is Natural range 0 .. Max_Source_Length + 1;

   --  Position is the first byte after the opening quote. Zero means no
   --  well-formed closing quote; success is the position after its close.
   function Literal_End (Text : String; Position : Cursor) return Literal_Position
     with Ghost => Static, Global => null,
       Pre => Text'First = 1
         and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Literal_End'Result = 0
         or else Literal_End'Result in Position + 1 .. Text'Last + 1,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position);

   function Literal_End (Text : String; Position : Cursor) return Literal_Position is
     (if Position > Text'Last then 0
      elsif Text (Position) = Character'Val (34) then
        (if Position < Text'Last
           and then Text (Position + 1) = Character'Val (34)
         then Literal_End (Text, Position + 2)
         else Position + 1)
      elsif Text (Position) in ' ' .. '~'
      then Literal_End (Text, Position + 1)
      else 0);

   subtype Token_Index is Positive range 1 .. Required_Tokens'Last + 1;

   function Suffix_Matches
     (Text : String; Position : Cursor; Next_Token : Token_Index)
      return Boolean
     with
       Ghost => Static,
       Global => null,
       Pre => Text'First = 1
         and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Subprogram_Variant => (Increases => Next_Token);

   function Suffix_Matches
     (Text : String; Position : Cursor; Next_Token : Token_Index)
      return Boolean
   is
     (if Next_Token > Required_Tokens'Last
      then Trivia_End (Text, Position) = Text'Last + 1
      elsif Required_Tokens (Next_Token) = String_Literal then
        Trivia_End (Text, Position) <= Text'Last
        and then Text (Trivia_End (Text, Position)) = Character'Val (34)
        and then Literal_End (Text, Trivia_End (Text, Position) + 1) /= 0
        and then Suffix_Matches
          (Text, Literal_End (Text, Trivia_End (Text, Position) + 1),
           Next_Token + 1)
      else
        Token_At
          (Text, Trivia_End (Text, Position),
           Spelling (Required_Tokens (Next_Token)),
           Is_Word_Token (Required_Tokens (Next_Token)))
        and then Suffix_Matches
          (Text,
           Trivia_End (Text, Position)
             + Spelling (Required_Tokens (Next_Token))'Length,
           Next_Token + 1));

   function Is_Letter (Item : Character) return Boolean is
     (Item in 'A' .. 'Z' | 'a' .. 'z');

   function Identifier_Tail
     (Text : String; Position : Cursor; Previous_Underscore : Boolean)
      return Literal_Position
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Identifier_Tail'Result = 0
         or else Identifier_Tail'Result in Position .. Text'Last + 1,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position);

   function Identifier_Tail
     (Text : String; Position : Cursor; Previous_Underscore : Boolean)
      return Literal_Position
   is
     (if Position > Text'Last or else not Is_Identifier_Character (Text (Position))
      then (if Previous_Underscore then 0 else Position)
      elsif Text (Position) = '_' and then Previous_Underscore then 0
      else Identifier_Tail (Text, Position + 1, Text (Position) = '_'));

   function Identifier_End (Text : String; Position : Cursor) return Literal_Position
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Identifier_End'Result = 0
         or else Identifier_End'Result in Position + 1 .. Text'Last + 1;

   function Identifier_End (Text : String; Position : Cursor) return Literal_Position is
     (if Position > Text'Last or else not Is_Letter (Text (Position)) then 0
      else Identifier_Tail (Text, Position + 1, False));

   function Name_Is
     (Text : String; First, After : Cursor; Word : String) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then First < After and then After <= Text'Last + 1
         and then Word'First = 1 and then Word'Length in 1 .. Max_Source_Length;

   function Name_Is
     (Text : String; First, After : Cursor; Word : String) return Boolean
   is
     (After - First = Word'Length
      and then (for all Offset in 0 .. Word'Length - 1 =>
        Lowercase (Text (First + Offset)) = Word (1 + Offset)));

   function Equal_Name
     (Text : String; Left_First, Left_After, Right_First, Right_After : Cursor)
      return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Left_First < Left_After and then Left_After <= Text'Last + 1
         and then Right_First < Right_After and then Right_After <= Text'Last + 1;

   function Equal_Name
     (Text : String; Left_First, Left_After, Right_First, Right_After : Cursor)
      return Boolean
   is
     (Left_After - Left_First = Right_After - Right_First
      and then (for all Offset in 0 .. (Left_After - Left_First) - 1 =>
        Lowercase (Text (Left_First + Offset)) = Lowercase (Text (Right_First + Offset))));

   type Forbidden_Kind is
     (Forbidden_abort,
      Forbidden_abs,
      Forbidden_abstract,
      Forbidden_accept,
      Forbidden_access,
      Forbidden_aliased,
      Forbidden_all,
      Forbidden_and,
      Forbidden_array,
      Forbidden_at,
      Forbidden_begin,
      Forbidden_body,
      Forbidden_case,
      Forbidden_constant,
      Forbidden_declare,
      Forbidden_delay,
      Forbidden_delta,
      Forbidden_digits,
      Forbidden_do,
      Forbidden_else,
      Forbidden_elsif,
      Forbidden_end,
      Forbidden_entry,
      Forbidden_exception,
      Forbidden_exit,
      Forbidden_for,
      Forbidden_function,
      Forbidden_generic,
      Forbidden_goto,
      Forbidden_if,
      Forbidden_in,
      Forbidden_interface,
      Forbidden_is,
      Forbidden_limited,
      Forbidden_loop,
      Forbidden_mod,
      Forbidden_new,
      Forbidden_not,
      Forbidden_null,
      Forbidden_of,
      Forbidden_or,
      Forbidden_others,
      Forbidden_out,
      Forbidden_overriding,
      Forbidden_package,
      Forbidden_parallel,
      Forbidden_pragma,
      Forbidden_private,
      Forbidden_procedure,
      Forbidden_protected,
      Forbidden_raise,
      Forbidden_range,
      Forbidden_record,
      Forbidden_rem,
      Forbidden_renames,
      Forbidden_requeue,
      Forbidden_return,
      Forbidden_reverse,
      Forbidden_select,
      Forbidden_separate,
      Forbidden_some,
      Forbidden_subtype,
      Forbidden_synchronized,
      Forbidden_tagged,
      Forbidden_task,
      Forbidden_terminate,
      Forbidden_then,
      Forbidden_type,
      Forbidden_until,
      Forbidden_use,
      Forbidden_when,
      Forbidden_while,
      Forbidden_with,
      Forbidden_xor,
      Forbidden_string,
      Forbidden_silver_io);

   function Forbidden_Spelling (Word : Forbidden_Kind) return String
     with Global => null,
       Post => Forbidden_Spelling'Result'First = 1
         and then Forbidden_Spelling'Result'Length in 1 .. 12;

   function Forbidden_Spelling (Word : Forbidden_Kind) return String is
   begin
      case Word is
         when Forbidden_abort => return "abort";
         when Forbidden_abs => return "abs";
         when Forbidden_abstract => return "abstract";
         when Forbidden_accept => return "accept";
         when Forbidden_access => return "access";
         when Forbidden_aliased => return "aliased";
         when Forbidden_all => return "all";
         when Forbidden_and => return "and";
         when Forbidden_array => return "array";
         when Forbidden_at => return "at";
         when Forbidden_begin => return "begin";
         when Forbidden_body => return "body";
         when Forbidden_case => return "case";
         when Forbidden_constant => return "constant";
         when Forbidden_declare => return "declare";
         when Forbidden_delay => return "delay";
         when Forbidden_delta => return "delta";
         when Forbidden_digits => return "digits";
         when Forbidden_do => return "do";
         when Forbidden_else => return "else";
         when Forbidden_elsif => return "elsif";
         when Forbidden_end => return "end";
         when Forbidden_entry => return "entry";
         when Forbidden_exception => return "exception";
         when Forbidden_exit => return "exit";
         when Forbidden_for => return "for";
         when Forbidden_function => return "function";
         when Forbidden_generic => return "generic";
         when Forbidden_goto => return "goto";
         when Forbidden_if => return "if";
         when Forbidden_in => return "in";
         when Forbidden_interface => return "interface";
         when Forbidden_is => return "is";
         when Forbidden_limited => return "limited";
         when Forbidden_loop => return "loop";
         when Forbidden_mod => return "mod";
         when Forbidden_new => return "new";
         when Forbidden_not => return "not";
         when Forbidden_null => return "null";
         when Forbidden_of => return "of";
         when Forbidden_or => return "or";
         when Forbidden_others => return "others";
         when Forbidden_out => return "out";
         when Forbidden_overriding => return "overriding";
         when Forbidden_package => return "package";
         when Forbidden_parallel => return "parallel";
         when Forbidden_pragma => return "pragma";
         when Forbidden_private => return "private";
         when Forbidden_procedure => return "procedure";
         when Forbidden_protected => return "protected";
         when Forbidden_raise => return "raise";
         when Forbidden_range => return "range";
         when Forbidden_record => return "record";
         when Forbidden_rem => return "rem";
         when Forbidden_renames => return "renames";
         when Forbidden_requeue => return "requeue";
         when Forbidden_return => return "return";
         when Forbidden_reverse => return "reverse";
         when Forbidden_select => return "select";
         when Forbidden_separate => return "separate";
         when Forbidden_some => return "some";
         when Forbidden_subtype => return "subtype";
         when Forbidden_synchronized => return "synchronized";
         when Forbidden_tagged => return "tagged";
         when Forbidden_task => return "task";
         when Forbidden_terminate => return "terminate";
         when Forbidden_then => return "then";
         when Forbidden_type => return "type";
         when Forbidden_until => return "until";
         when Forbidden_use => return "use";
         when Forbidden_when => return "when";
         when Forbidden_while => return "while";
         when Forbidden_with => return "with";
         when Forbidden_xor => return "xor";
         when Forbidden_string => return "string";
         when Forbidden_silver_io => return "silver_io";
      end case;
   end Forbidden_Spelling;

   function Forbidden_Name (Text : String; First, After : Cursor) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then First < After and then After <= Text'Last + 1;

   function Forbidden_Name (Text : String; First, After : Cursor) return Boolean is
     (for some Word in Forbidden_Kind =>
        Name_Is (Text, First, After, Forbidden_Spelling (Word)));

   function Forbidden_Argument_Name
     (Text : String; First, After : Cursor) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then First < After and then After <= Text'Last + 1;

   function Forbidden_Argument_Name
     (Text : String; First, After : Cursor) return Boolean is
     (Forbidden_Name (Text, First, After)
      or else Name_Is (Text, First, After, "silver_arguments"));

   subtype Named_Token_Index is Positive range 1 .. Named_Required_Tokens'Last + 1;

   function Valid_Name_State (Text : String; First, After : Literal_Position) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;

   function Valid_Name_State (Text : String; First, After : Literal_Position) return Boolean is
     ((First = 0 and then After = 0)
      or else (First > 0 and then First < After and then After <= Text'Last + 1));

   function Named_Suffix_Matches
     (Text : String; Position : Cursor; Next_Token : Named_Token_Index;
      Declared_First, Declared_After : Literal_Position) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Valid_Name_State (Text, Declared_First, Declared_After),
       Subprogram_Variant => (Increases => Next_Token);

   function Named_Suffix_Matches
     (Text : String; Position : Cursor; Next_Token : Named_Token_Index;
      Declared_First, Declared_After : Literal_Position) return Boolean
   is
     (if Next_Token > Named_Required_Tokens'Last then
        Trivia_End (Text, Position) = Text'Last + 1
      elsif Named_Required_Tokens (Next_Token) = Declaration_Name then
        Identifier_End (Text, Trivia_End (Text, Position)) /= 0
        and then not Forbidden_Name
          (Text, Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
        and then Named_Suffix_Matches
          (Text, Identifier_End (Text, Trivia_End (Text, Position)), Next_Token + 1,
           Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
      elsif Named_Required_Tokens (Next_Token) = Reference_Name then
        Declared_First > 0
        and then Identifier_End (Text, Trivia_End (Text, Position)) /= 0
        and then Equal_Name
          (Text, Declared_First, Declared_After,
           Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
        and then Named_Suffix_Matches
          (Text, Identifier_End (Text, Trivia_End (Text, Position)), Next_Token + 1,
           Declared_First, Declared_After)
      elsif Named_Required_Tokens (Next_Token) = String_Literal then
        Trivia_End (Text, Position) <= Text'Last
        and then Text (Trivia_End (Text, Position)) = Character'Val (34)
        and then Literal_End (Text, Trivia_End (Text, Position) + 1) /= 0
        and then Named_Suffix_Matches
          (Text, Literal_End (Text, Trivia_End (Text, Position) + 1), Next_Token + 1,
           Declared_First, Declared_After)
      else
        Token_At (Text, Trivia_End (Text, Position),
          Spelling (Named_Required_Tokens (Next_Token)),
          Is_Word_Token (Named_Required_Tokens (Next_Token)))
        and then Named_Suffix_Matches
          (Text, Trivia_End (Text, Position) + Spelling (Named_Required_Tokens (Next_Token))'Length,
           Next_Token + 1, Declared_First, Declared_After));

   subtype Argument_Token_Index is Positive range 1 .. Argument_Required_Tokens'Last + 1;

   function Argument_Suffix_Matches
     (Text : String; Position : Cursor; Next_Token : Argument_Token_Index;
      Declared_First, Declared_After : Literal_Position) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Valid_Name_State (Text, Declared_First, Declared_After),
       Subprogram_Variant => (Increases => Next_Token);

   function Argument_Suffix_Matches
     (Text : String; Position : Cursor; Next_Token : Argument_Token_Index;
      Declared_First, Declared_After : Literal_Position) return Boolean
   is
     (if Next_Token > Argument_Required_Tokens'Last then
        Trivia_End (Text, Position) = Text'Last + 1
      elsif Argument_Required_Tokens (Next_Token) = Declaration_Name then
        Identifier_End (Text, Trivia_End (Text, Position)) /= 0
        and then not Forbidden_Argument_Name
          (Text, Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
        and then Argument_Suffix_Matches
          (Text, Identifier_End (Text, Trivia_End (Text, Position)), Next_Token + 1,
           Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
      elsif Argument_Required_Tokens (Next_Token) = Reference_Name then
        Declared_First > 0
        and then Identifier_End (Text, Trivia_End (Text, Position)) /= 0
        and then Equal_Name
          (Text, Declared_First, Declared_After,
           Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
        and then Argument_Suffix_Matches
          (Text, Identifier_End (Text, Trivia_End (Text, Position)), Next_Token + 1,
           Declared_First, Declared_After)
      elsif Argument_Required_Tokens (Next_Token) = String_Literal then
        Trivia_End (Text, Position) <= Text'Last
        and then Text (Trivia_End (Text, Position)) = Character'Val (34)
        and then Literal_End (Text, Trivia_End (Text, Position) + 1) /= 0
        and then Argument_Suffix_Matches
          (Text, Literal_End (Text, Trivia_End (Text, Position) + 1), Next_Token + 1,
           Declared_First, Declared_After)
      else
        Token_At (Text, Trivia_End (Text, Position),
          Spelling (Argument_Required_Tokens (Next_Token)),
          Is_Word_Token (Argument_Required_Tokens (Next_Token)))
        and then Argument_Suffix_Matches
          (Text, Trivia_End (Text, Position) + Spelling (Argument_Required_Tokens (Next_Token))'Length,
           Next_Token + 1, Declared_First, Declared_After));

   subtype Concatenation_Token_Index is
     Positive range 1 .. Concatenation_Required_Tokens'Last + 1;

   function Concatenation_Suffix_Matches
     (Text : String; Position : Cursor; Next_Token : Concatenation_Token_Index;
      Declared_First, Declared_After : Literal_Position) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Valid_Name_State (Text, Declared_First, Declared_After),
       Subprogram_Variant => (Increases => Next_Token);

   function Concatenation_Suffix_Matches
     (Text : String; Position : Cursor; Next_Token : Concatenation_Token_Index;
      Declared_First, Declared_After : Literal_Position) return Boolean
   is
     (if Next_Token > Concatenation_Required_Tokens'Last then
        Trivia_End (Text, Position) = Text'Last + 1
      elsif Concatenation_Required_Tokens (Next_Token) = Declaration_Name then
        Identifier_End (Text, Trivia_End (Text, Position)) /= 0
        and then not Forbidden_Name
          (Text, Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
        and then Concatenation_Suffix_Matches
          (Text, Identifier_End (Text, Trivia_End (Text, Position)), Next_Token + 1,
           Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
      elsif Concatenation_Required_Tokens (Next_Token) = Reference_Name then
        Declared_First > 0
        and then Identifier_End (Text, Trivia_End (Text, Position)) /= 0
        and then Equal_Name
          (Text, Declared_First, Declared_After,
           Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
        and then Concatenation_Suffix_Matches
          (Text, Identifier_End (Text, Trivia_End (Text, Position)), Next_Token + 1,
           Declared_First, Declared_After)
      elsif Concatenation_Required_Tokens (Next_Token) = String_Literal then
        Trivia_End (Text, Position) <= Text'Last
        and then Text (Trivia_End (Text, Position)) = Character'Val (34)
        and then Literal_End (Text, Trivia_End (Text, Position) + 1) /= 0
        and then Concatenation_Suffix_Matches
          (Text, Literal_End (Text, Trivia_End (Text, Position) + 1), Next_Token + 1,
           Declared_First, Declared_After)
      else
        Token_At (Text, Trivia_End (Text, Position),
          Spelling (Concatenation_Required_Tokens (Next_Token)),
          Is_Word_Token (Concatenation_Required_Tokens (Next_Token)))
        and then Concatenation_Suffix_Matches
          (Text, Trivia_End (Text, Position) + Spelling (Concatenation_Required_Tokens (Next_Token))'Length,
           Next_Token + 1, Declared_First, Declared_After));

   subtype Capacity_Value is Natural range 0 .. Max_Source_Length;
   type Decimal_Result is record
      After : Literal_Position;
      Value : Capacity_Value;
   end record;
   Invalid_Decimal : constant Decimal_Result := (After => 0, Value => 0);

   function Decimal_Tail
     (Text : String; Position : Cursor; Value : Capacity_Value)
      return Decimal_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Decimal_Tail'Result.After = 0
         or else Decimal_Tail'Result.After in Position .. Text'Last + 1,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position);

   function Decimal_Tail
     (Text : String; Position : Cursor; Value : Capacity_Value)
      return Decimal_Result is
     (if Position > Text'Last then (After => Position, Value => Value)
      elsif Text (Position) not in '0' .. '9' then
        (if Is_Identifier_Character (Text (Position)) then Invalid_Decimal
         else (After => Position, Value => Value))
      elsif Value > (Max_Source_Length -
        (Character'Pos (Text (Position)) - Character'Pos ('0'))) / 10
      then Invalid_Decimal
      else Decimal_Tail (Text, Position + 1,
        10 * Value + (Character'Pos (Text (Position)) - Character'Pos ('0'))));

   function Decimal_At (Text : String; Position : Cursor) return Decimal_Result
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Decimal_At'Result.After = 0
         or else Decimal_At'Result.After in Position + 1 .. Text'Last + 1;

   function Decimal_At (Text : String; Position : Cursor) return Decimal_Result is
     (if Position > Text'Last or else Text (Position) not in '0' .. '9'
      then Invalid_Decimal
      elsif Text (Position) = '0' then
        (if Position < Text'Last
           and then Is_Identifier_Character (Text (Position + 1))
         then Invalid_Decimal else (After => Position + 1, Value => 0))
      else Decimal_Tail (Text, Position + 1,
        Character'Pos (Text (Position)) - Character'Pos ('0')));

   function Literal_Length (Text : String; Position : Cursor) return Capacity_Value
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => Literal_Length'Result <= (Text'Last + 1) - Position,
       Subprogram_Variant => (Decreases => (Text'Last + 1) - Position);

   function Literal_Length (Text : String; Position : Cursor) return Capacity_Value is
     (if Position > Text'Last then 0
      elsif Text (Position) = Character'Val (34) then
        (if Position < Text'Last and then Text (Position + 1) = Character'Val (34)
         then 1 + Literal_Length (Text, Position + 2) else 0)
      elsif Text (Position) in ' ' .. '~'
      then 1 + Literal_Length (Text, Position + 1)
      else 0);

   function Read_Capacity (Text : String; Position : Cursor) return Decimal_Result
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Static => Read_Capacity'Result = Decimal_At (Text, Position))
   is
      Next : Cursor := Position;
      Value : Capacity_Value;
   begin
      if Next > Text'Last or else Text (Next) not in '0' .. '9' then
         return Invalid_Decimal;
      end if;
      if Text (Next) = '0' then
         if Next < Text'Last and then Is_Identifier_Character (Text (Next + 1)) then
            return Invalid_Decimal;
         end if;
         return (After => Next + 1, Value => 0);
      end if;
      Value := Character'Pos (Text (Next)) - Character'Pos ('0');
      Next := Next + 1;
      while Next <= Text'Last loop
         pragma Loop_Invariant (Next in Position + 1 .. Text'Last + 1);
         pragma Loop_Invariant (Static =>
           Decimal_At (Text, Position) = Decimal_Tail (Text, Next, Value));
         pragma Loop_Variant (Increases => Next);
         if Text (Next) not in '0' .. '9' then
            if Is_Identifier_Character (Text (Next)) then
               return Invalid_Decimal;
            end if;
            return (After => Next, Value => Value);
         end if;
         declare
            Digit : constant Natural := Character'Pos (Text (Next)) - Character'Pos ('0');
         begin
            if Value > (Max_Source_Length - Digit) / 10 then
               return Invalid_Decimal;
            end if;
            Value := 10 * Value + Digit;
         end;
         Next := Next + 1;
      end loop;
      return (After => Next, Value => Value);
   end Read_Capacity;

   procedure Match_Sized_Literal
     (Text : String; Position : in out Cursor; Matched : out Boolean;
      Length : out Capacity_Value)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Static => Position <= Text'Last + 1
         and then Matched =
           (Position'Old <= Text'Last
            and then Text (Position'Old) = Character'Val (34)
            and then Literal_End (Text, Position'Old + 1) /= 0)
         and then (if Matched then
           Position = Literal_End (Text, Position'Old + 1)
           and then Length = Literal_Length (Text, Position'Old + 1)))
   is
      Start : constant Cursor := Position;
   begin
      Matched := False;
      Length := 0;
      if Position > Text'Last or else Text (Position) /= Character'Val (34) then
         return;
      end if;
      Position := Position + 1;
      while Position <= Text'Last loop
         pragma Loop_Invariant (Position in Start + 1 .. Text'Last + 1);
         pragma Loop_Invariant (Length <= (Position - Start) - 1);
         pragma Loop_Invariant (Static =>
           Literal_End (Text, Start + 1) = Literal_End (Text, Position));
         pragma Loop_Invariant (Static =>
           Length + Literal_Length (Text, Position) = Literal_Length (Text, Start + 1));
         pragma Loop_Variant (Increases => Position);
         if Text (Position) = Character'Val (34) then
            if Position < Text'Last and then Text (Position + 1) = Character'Val (34) then
               Position := Position + 2;
               Length := Length + 1;
            else
               Position := Position + 1;
               Matched := True;
               return;
            end if;
         elsif Text (Position) in ' ' .. '~' then
            Position := Position + 1;
            Length := Length + 1;
         else
            return;
         end if;
      end loop;
   end Match_Sized_Literal;

   subtype Assignment_Token_Index is
     Positive range 1 .. Assignment_Required_Tokens'Last + 1;

   function Assignment_Suffix_Matches
     (Text : String; Position : Cursor; Next_Token : Assignment_Token_Index;
      Declared_First, Declared_After : Literal_Position;
      Initial_Length : Capacity_Value) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Valid_Name_State (Text, Declared_First, Declared_After),
       Subprogram_Variant => (Increases => Next_Token);

   function Assignment_Suffix_Matches
     (Text : String; Position : Cursor; Next_Token : Assignment_Token_Index;
      Declared_First, Declared_After : Literal_Position;
      Initial_Length : Capacity_Value) return Boolean
   is
     (if Next_Token > Assignment_Required_Tokens'Last then
        Trivia_End (Text, Position) = Text'Last + 1
      elsif Assignment_Required_Tokens (Next_Token) = Declaration_Name then
        Identifier_End (Text, Trivia_End (Text, Position)) /= 0
        and then not Forbidden_Name
          (Text, Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
        and then Assignment_Suffix_Matches
          (Text, Identifier_End (Text, Trivia_End (Text, Position)), Next_Token + 1,
           Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)),
           Initial_Length)
      elsif Assignment_Required_Tokens (Next_Token) = Reference_Name then
        Declared_First > 0
        and then Identifier_End (Text, Trivia_End (Text, Position)) /= 0
        and then Equal_Name
          (Text, Declared_First, Declared_After,
           Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
        and then Assignment_Suffix_Matches
          (Text, Identifier_End (Text, Trivia_End (Text, Position)), Next_Token + 1,
           Declared_First, Declared_After, Initial_Length)
      elsif Assignment_Required_Tokens (Next_Token) = String_Literal then
        Trivia_End (Text, Position) <= Text'Last
        and then Text (Trivia_End (Text, Position)) = Character'Val (34)
        and then Literal_End (Text, Trivia_End (Text, Position) + 1) /= 0
        and then (if Next_Token > 17 then
          Literal_Length (Text, Trivia_End (Text, Position) + 1) = Initial_Length)
        and then Assignment_Suffix_Matches
          (Text, Literal_End (Text, Trivia_End (Text, Position) + 1), Next_Token + 1,
           Declared_First, Declared_After,
           (if Next_Token = 17 then
              Literal_Length (Text, Trivia_End (Text, Position) + 1)
            else Initial_Length))
      else
        Token_At (Text, Trivia_End (Text, Position),
          Spelling (Assignment_Required_Tokens (Next_Token)),
          Is_Word_Token (Assignment_Required_Tokens (Next_Token)))
        and then Assignment_Suffix_Matches
          (Text, Trivia_End (Text, Position) + Spelling (Assignment_Required_Tokens (Next_Token))'Length,
           Next_Token + 1, Declared_First, Declared_After, Initial_Length));

   subtype Guarded_Token_Index is
     Positive range 1 .. Guarded_Required_Tokens'Last + 1;

   function Guarded_Suffix_Matches
     (Text : String; Position : Cursor; Next_Token : Guarded_Token_Index;
      Declared_First, Declared_After : Literal_Position;
      Capacity, Decoration_Length : Capacity_Value) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Valid_Name_State (Text, Declared_First, Declared_After),
       Subprogram_Variant => (Increases => Next_Token);

   function Guarded_Suffix_Matches
     (Text : String; Position : Cursor; Next_Token : Guarded_Token_Index;
      Declared_First, Declared_After : Literal_Position;
      Capacity, Decoration_Length : Capacity_Value) return Boolean
   is
     (if Next_Token > Guarded_Required_Tokens'Last then
        Trivia_End (Text, Position) = Text'Last + 1
        and then Capacity + Decoration_Length = Max_Source_Length
      elsif Guarded_Required_Tokens (Next_Token) = Declaration_Name then
        Identifier_End (Text, Trivia_End (Text, Position)) /= 0
        and then not Forbidden_Argument_Name
          (Text, Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
        and then Guarded_Suffix_Matches
          (Text, Identifier_End (Text, Trivia_End (Text, Position)), Next_Token + 1,
           Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)),
           Capacity, Decoration_Length)
      elsif Guarded_Required_Tokens (Next_Token) = Reference_Name then
        Declared_First > 0
        and then Identifier_End (Text, Trivia_End (Text, Position)) /= 0
        and then Equal_Name
          (Text, Declared_First, Declared_After,
           Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
        and then Guarded_Suffix_Matches
          (Text, Identifier_End (Text, Trivia_End (Text, Position)), Next_Token + 1,
           Declared_First, Declared_After, Capacity, Decoration_Length)
      elsif Guarded_Required_Tokens (Next_Token) = Capacity_Literal then
        Decimal_At (Text, Trivia_End (Text, Position)).After /= 0
        and then Guarded_Suffix_Matches
          (Text, Decimal_At (Text, Trivia_End (Text, Position)).After, Next_Token + 1,
           Declared_First, Declared_After,
           Decimal_At (Text, Trivia_End (Text, Position)).Value, Decoration_Length)
      elsif Guarded_Required_Tokens (Next_Token) = String_Literal then
        Trivia_End (Text, Position) <= Text'Last
        and then Text (Trivia_End (Text, Position)) = Character'Val (34)
        and then Literal_End (Text, Trivia_End (Text, Position) + 1) /= 0
        and then (if Next_Token > 39 then
          Decoration_Length + Literal_Length (Text, Trivia_End (Text, Position) + 1)
            <= Max_Source_Length)
        and then Guarded_Suffix_Matches
          (Text, Literal_End (Text, Trivia_End (Text, Position) + 1), Next_Token + 1,
           Declared_First, Declared_After, Capacity,
           (if Next_Token > 39 then
              Decoration_Length + Literal_Length (Text, Trivia_End (Text, Position) + 1)
            else Decoration_Length))
      else
        Token_At (Text, Trivia_End (Text, Position),
          Spelling (Guarded_Required_Tokens (Next_Token)),
          Is_Word_Token (Guarded_Required_Tokens (Next_Token)))
        and then Guarded_Suffix_Matches
          (Text, Trivia_End (Text, Position) + Spelling (Guarded_Required_Tokens (Next_Token))'Length,
           Next_Token + 1, Declared_First, Declared_After, Capacity, Decoration_Length));

   function Is_Guarded_Member (Source : String) return Boolean is
     (Source'Length in 1 .. Max_Source_Length
      and then Allowed_Source (Normalized (Source))
      and then Guarded_Suffix_Matches (Normalized (Source), 1, 1, 0, 0, 0, 0));

   function Is_Assignment_Member (Source : String) return Boolean is
     (Source'Length in 1 .. Max_Source_Length
      and then Allowed_Source (Normalized (Source))
      and then Assignment_Suffix_Matches (Normalized (Source), 1, 1, 0, 0, 0));

   function Is_Member (Source : String) return Boolean is
     (Source'Length in 1 .. Max_Source_Length
      and then Allowed_Source (Normalized (Source))
      and then (Suffix_Matches (Normalized (Source), 1, 1)
        or else Named_Suffix_Matches (Normalized (Source), 1, 1, 0, 0)
        or else Argument_Suffix_Matches (Normalized (Source), 1, 1, 0, 0)
        or else Concatenation_Suffix_Matches (Normalized (Source), 1, 1, 0, 0)
        or else Guarded_Suffix_Matches (Normalized (Source), 1, 1, 0, 0, 0, 0)
        or else Assignment_Suffix_Matches (Normalized (Source), 1, 1, 0, 0, 0)));

   function Is_Literal_Member (Source : String) return Boolean
     with Ghost => Static, Global => null;

   function Is_Literal_Member (Source : String) return Boolean is
     (Source'Length in 1 .. Max_Source_Length
      and then Allowed_Source (Normalized (Source))
      and then Suffix_Matches (Normalized (Source), 1, 1));

   procedure Skip_Comment (Text : String; Position : in out Cursor)
     with
       Global => null,
       Pre => Text'First = 1
         and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Static => Position in Position'Old .. Text'Last + 1
         and then Position = Comment_End (Text, Position'Old))
   is
      Initial_Position : constant Cursor := Position;
   begin
      while Position <= Text'Last
        and then not Is_Comment_End (Text (Position))
      loop
         pragma Loop_Invariant
           (Position in Initial_Position .. Text'Last + 1);
         pragma Loop_Invariant
           (Static => Comment_End (Text, Initial_Position) = Comment_End (Text, Position));
         pragma Loop_Variant (Increases => Position);
         Position := Position + 1;
      end loop;
   end Skip_Comment;

   procedure Skip_Trivia (Text : String; Position : in out Cursor)
     with
       Global => null,
       Pre => Text'First = 1
         and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Static => Position in Position'Old .. Text'Last + 1
         and then Position = Trivia_End (Text, Position'Old))
   is
      Initial_Position : constant Cursor := Position;
   begin
      while Position <= Text'Last loop
         pragma Loop_Invariant
           (Position in Initial_Position .. Text'Last + 1);
         pragma Loop_Invariant
           (Static => Trivia_End (Text, Initial_Position) = Trivia_End (Text, Position));
         pragma Loop_Variant (Increases => Position);

         if Is_Whitespace (Text (Position)) then
            Position := Position + 1;
         elsif Text (Position) = Comment_Introducer (1)
           and then Position < Text'Last
           and then Text (Position + 1) = Comment_Introducer (2)
         then
            Position := Position + 2;
            Skip_Comment (Text, Position);
         else
            return;
         end if;
      end loop;
   end Skip_Trivia;

   procedure Match_Token
     (Text : String; Position : in out Cursor; Token : Token_Kind;
      Matched : out Boolean)
     with
       Global => null,
       Pre => Text'First = 1
         and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Static => Position <= Text'Last + 1
         and then Matched = Token_At
           (Text, Position'Old, Spelling (Token),
            Is_Word_Token (Token))
         and then
           (if Matched then Position = Position'Old + Spelling (Token)'Length
            else Position = Position'Old))
   is
      Word : constant String := Spelling (Token);
   begin
      Matched := False;
      if Word'Length > (Text'Last - Position) + 1 then
         return;
      end if;

      for Index in Word'Range loop
         pragma Loop_Invariant
           (for all Previous in Word'First .. Index - 1 =>
              Lowercase (Text ((Position + Previous) - 1)) = Word (Previous));
         if Lowercase (Text ((Position + Index) - 1)) /= Word (Index) then
            return;
         end if;
      end loop;

      if Is_Word_Token (Token)
        and then Position + Word'Length <= Text'Last
        and then Is_Identifier_Character (Text (Position + Word'Length))
      then
         return;
      end if;

      Position := Position + Word'Length;
      Matched := True;
   end Match_Token;

   procedure Match_Literal
     (Text : String; Position : in out Cursor; Matched : out Boolean)
     with Global => null,
       Pre => Text'First = 1
         and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Static => Position <= Text'Last + 1
         and then Matched =
           (Position'Old <= Text'Last
            and then Text (Position'Old) = Character'Val (34)
            and then Literal_End (Text, Position'Old + 1) /= 0)
         and then (if Matched then
           Position = Literal_End (Text, Position'Old + 1)))
   is
      Start : constant Cursor := Position;
   begin
      Matched := False;
      if Position > Text'Last or else Text (Position) /= Character'Val (34) then
         return;
      end if;
      Position := Position + 1;
      while Position <= Text'Last loop
         pragma Loop_Invariant (Position in Start + 1 .. Text'Last + 1);
         pragma Loop_Invariant (Static =>
           Literal_End (Text, Start + 1) = Literal_End (Text, Position));
         pragma Loop_Variant (Increases => Position);
         if Text (Position) = Character'Val (34) then
            if Position < Text'Last
              and then Text (Position + 1) = Character'Val (34)
            then
               Position := Position + 2;
            else
               Position := Position + 1;
               Matched := True;
               return;
            end if;
         elsif Text (Position) in ' ' .. '~' then
            Position := Position + 1;
         else
            return;
         end if;
      end loop;
   end Match_Literal;

   function Accepts_Literal (Source : String) return Boolean
     with Global => null,
       Post => (Static => Accepts_Literal'Result = Is_Literal_Member (Source));

   function Accepts_Literal (Source : String) return Boolean is
   begin
      if Source'Length = 0 or else Source'Length > Max_Source_Length then
         return False;
      end if;

      declare
         Text : constant String := Normalized (Source);
         Position : Cursor := 1;
         Next_Token : Token_Index := 1;
         Matched : Boolean;
      begin
         --  Validate comments as well as tokens: an otherwise ignored comment
         --  must not introduce characters outside the profile's ASCII rules.
         if not Allowed_Source (Text) then
            return False;
         end if;

         while Next_Token <= Required_Tokens'Last loop
            pragma Loop_Invariant (Position <= Text'Last + 1);
            pragma Loop_Invariant
              (Static => Suffix_Matches (Text, 1, 1)
               = Suffix_Matches (Text, Position, Next_Token));
            pragma Loop_Variant (Increases => Next_Token);

            Skip_Trivia (Text, Position);
            if Required_Tokens (Next_Token) = String_Literal then
               Match_Literal (Text, Position, Matched);
            else
               Match_Token
                 (Text, Position, Required_Tokens (Next_Token), Matched);
            end if;
            if not Matched then
               return False;
            end if;
            Next_Token := Next_Token + 1;
         end loop;

         Skip_Trivia (Text, Position);
         return Position > Text'Last;
      end;
   end Accepts_Literal;
   procedure Match_Identifier
     (Text : String; Position : in out Cursor; Matched : out Boolean)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Static => Position <= Text'Last + 1
         and then Matched = (Identifier_End (Text, Position'Old) /= 0)
         and then (if Matched then Position = Identifier_End (Text, Position'Old)))
   is
      Start : constant Cursor := Position;
      Previous_Underscore : Boolean := False;
   begin
      Matched := False;
      if Position > Text'Last or else not Is_Letter (Text (Position)) then
         return;
      end if;
      Position := Position + 1;
      while Position <= Text'Last and then Is_Identifier_Character (Text (Position)) loop
         pragma Loop_Invariant (Position in Start + 1 .. Text'Last + 1);
         pragma Loop_Invariant (Static =>
           Identifier_Tail (Text, Start + 1, False)
             = Identifier_Tail (Text, Position, Previous_Underscore));
         pragma Loop_Variant (Increases => Position);
         if Text (Position) = '_' and then Previous_Underscore then
            return;
         end if;
         Previous_Underscore := Text (Position) = '_';
         Position := Position + 1;
      end loop;
      if not Previous_Underscore then
         Matched := True;
      end if;
   end Match_Identifier;

   function Accepts_Named (Source : String) return Boolean
     with Global => null,
       Post => (Static => Accepts_Named'Result =
         (Source'Length in 1 .. Max_Source_Length
          and then Allowed_Source (Normalized (Source))
          and then Named_Suffix_Matches (Normalized (Source), 1, 1, 0, 0)));

   function Accepts_Named (Source : String) return Boolean is
   begin
      if Source'Length = 0 or else Source'Length > Max_Source_Length then
         return False;
      end if;
      declare
         Text : constant String := Normalized (Source);
         Position : Cursor := 1;
         Next_Token : Named_Token_Index := 1;
         Declared_First, Declared_After : Literal_Position := 0;
         Matched : Boolean;
      begin
         if not Allowed_Source (Text) then
            return False;
         end if;
         while Next_Token <= Named_Required_Tokens'Last loop
            pragma Loop_Invariant (Position <= Text'Last + 1);
            pragma Loop_Invariant (Valid_Name_State (Text, Declared_First, Declared_After));
            pragma Loop_Invariant (Static =>
              Named_Suffix_Matches (Text, 1, 1, 0, 0)
                = Named_Suffix_Matches (Text, Position, Next_Token, Declared_First, Declared_After));
            pragma Loop_Variant (Increases => Next_Token);
            Skip_Trivia (Text, Position);
            declare
               Start : constant Cursor := Position;
            begin
               if Named_Required_Tokens (Next_Token) = Declaration_Name then
                  Match_Identifier (Text, Position, Matched);
                  if not Matched then return False; end if;
                  if Forbidden_Name (Text, Start, Position) then return False; end if;
                  Declared_First := Start;
                  Declared_After := Position;
               elsif Named_Required_Tokens (Next_Token) = Reference_Name then
                  Match_Identifier (Text, Position, Matched);
                  if not Matched or else Declared_First = 0 then return False; end if;
                  if not Equal_Name (Text, Declared_First, Declared_After, Start, Position) then
                     return False;
                  end if;
               elsif Named_Required_Tokens (Next_Token) = String_Literal then
                  Match_Literal (Text, Position, Matched);
               else
                  Match_Token (Text, Position, Named_Required_Tokens (Next_Token), Matched);
               end if;
            end;
            if not Matched then return False; end if;
            Next_Token := Next_Token + 1;
         end loop;
         Skip_Trivia (Text, Position);
         return Position > Text'Last;
      end;
   end Accepts_Named;

   function Accepts_Arguments (Source : String) return Boolean
     with Global => null,
       Post => (Static => Accepts_Arguments'Result =
         (Source'Length in 1 .. Max_Source_Length
          and then Allowed_Source (Normalized (Source))
          and then Argument_Suffix_Matches (Normalized (Source), 1, 1, 0, 0)));

   function Accepts_Arguments (Source : String) return Boolean is
   begin
      if Source'Length = 0 or else Source'Length > Max_Source_Length then
         return False;
      end if;
      declare
         Text : constant String := Normalized (Source);
         Position : Cursor := 1;
         Next_Token : Argument_Token_Index := 1;
         Declared_First, Declared_After : Literal_Position := 0;
         Matched : Boolean;
      begin
         if not Allowed_Source (Text) then
            return False;
         end if;
         while Next_Token <= Argument_Required_Tokens'Last loop
            pragma Loop_Invariant (Position <= Text'Last + 1);
            pragma Loop_Invariant (Valid_Name_State (Text, Declared_First, Declared_After));
            pragma Loop_Invariant (Static =>
              Argument_Suffix_Matches (Text, 1, 1, 0, 0)
                = Argument_Suffix_Matches (Text, Position, Next_Token, Declared_First, Declared_After));
            pragma Loop_Variant (Increases => Next_Token);
            Skip_Trivia (Text, Position);
            declare
               Start : constant Cursor := Position;
            begin
               if Argument_Required_Tokens (Next_Token) = Declaration_Name then
                  Match_Identifier (Text, Position, Matched);
                  if not Matched then return False; end if;
                  if Forbidden_Argument_Name (Text, Start, Position) then return False; end if;
                  Declared_First := Start;
                  Declared_After := Position;
               elsif Argument_Required_Tokens (Next_Token) = Reference_Name then
                  Match_Identifier (Text, Position, Matched);
                  if not Matched or else Declared_First = 0 then return False; end if;
                  if not Equal_Name (Text, Declared_First, Declared_After, Start, Position) then
                     return False;
                  end if;
               elsif Argument_Required_Tokens (Next_Token) = String_Literal then
                  Match_Literal (Text, Position, Matched);
               else
                  Match_Token (Text, Position, Argument_Required_Tokens (Next_Token), Matched);
               end if;
            end;
            if not Matched then return False; end if;
            Next_Token := Next_Token + 1;
         end loop;
         Skip_Trivia (Text, Position);
         return Position > Text'Last;
      end;
   end Accepts_Arguments;

   function Accepts_Concatenation (Source : String) return Boolean
     with Global => null,
       Post => (Static => Accepts_Concatenation'Result =
         (Source'Length in 1 .. Max_Source_Length
          and then Allowed_Source (Normalized (Source))
          and then Concatenation_Suffix_Matches (Normalized (Source), 1, 1, 0, 0)));

   function Accepts_Concatenation (Source : String) return Boolean is
   begin
      if Source'Length = 0 or else Source'Length > Max_Source_Length then
         return False;
      end if;
      declare
         Text : constant String := Normalized (Source);
         Position : Cursor := 1;
         Next_Token : Concatenation_Token_Index := 1;
         Declared_First, Declared_After : Literal_Position := 0;
         Matched : Boolean;
      begin
         if not Allowed_Source (Text) then
            return False;
         end if;
         while Next_Token <= Concatenation_Required_Tokens'Last loop
            pragma Loop_Invariant (Position <= Text'Last + 1);
            pragma Loop_Invariant (Valid_Name_State (Text, Declared_First, Declared_After));
            pragma Loop_Invariant (Static =>
              Concatenation_Suffix_Matches (Text, 1, 1, 0, 0)
                = Concatenation_Suffix_Matches (Text, Position, Next_Token, Declared_First, Declared_After));
            pragma Loop_Variant (Increases => Next_Token);
            Skip_Trivia (Text, Position);
            declare
               Start : constant Cursor := Position;
            begin
               if Concatenation_Required_Tokens (Next_Token) = Declaration_Name then
                  Match_Identifier (Text, Position, Matched);
                  if not Matched then return False; end if;
                  if Forbidden_Name (Text, Start, Position) then return False; end if;
                  Declared_First := Start;
                  Declared_After := Position;
               elsif Concatenation_Required_Tokens (Next_Token) = Reference_Name then
                  Match_Identifier (Text, Position, Matched);
                  if not Matched or else Declared_First = 0 then return False; end if;
                  if not Equal_Name (Text, Declared_First, Declared_After, Start, Position) then
                     return False;
                  end if;
               elsif Concatenation_Required_Tokens (Next_Token) = String_Literal then
                  Match_Literal (Text, Position, Matched);
               else
                  Match_Token (Text, Position, Concatenation_Required_Tokens (Next_Token), Matched);
               end if;
            end;
            if not Matched then return False; end if;
            Next_Token := Next_Token + 1;
         end loop;
         Skip_Trivia (Text, Position);
         return Position > Text'Last;
      end;
   end Accepts_Concatenation;

   function Accepts_Assignment (Source : String) return Boolean is
   begin
      if Source'Length = 0 or else Source'Length > Max_Source_Length then
         return False;
      end if;
      declare
         Text : constant String := Normalized (Source);
         Position : Cursor := 1;
         Next_Token : Assignment_Token_Index := 1;
         Declared_First, Declared_After : Literal_Position := 0;
         Matched : Boolean;
         Initial_Length : Capacity_Value := 0;
         Length : Capacity_Value;
      begin
         if not Allowed_Source (Text) then
            return False;
         end if;
         while Next_Token <= Assignment_Required_Tokens'Last loop
            pragma Loop_Invariant (Position <= Text'Last + 1);
            pragma Loop_Invariant (Valid_Name_State (Text, Declared_First, Declared_After));
            pragma Loop_Invariant (Static =>
              Assignment_Suffix_Matches (Text, 1, 1, 0, 0, 0)
                = Assignment_Suffix_Matches (Text, Position, Next_Token, Declared_First, Declared_After, Initial_Length));
            pragma Loop_Variant (Increases => Next_Token);
            Skip_Trivia (Text, Position);
            declare
               Start : constant Cursor := Position;
            begin
               if Assignment_Required_Tokens (Next_Token) = Declaration_Name then
                  Match_Identifier (Text, Position, Matched);
                  if not Matched then return False; end if;
                  if Forbidden_Name (Text, Start, Position) then return False; end if;
                  Declared_First := Start;
                  Declared_After := Position;
               elsif Assignment_Required_Tokens (Next_Token) = Reference_Name then
                  Match_Identifier (Text, Position, Matched);
                  if not Matched or else Declared_First = 0 then return False; end if;
                  if not Equal_Name (Text, Declared_First, Declared_After, Start, Position) then
                     return False;
                  end if;
               elsif Assignment_Required_Tokens (Next_Token) = String_Literal then
                  Match_Sized_Literal (Text, Position, Matched, Length);
                  if not Matched then return False; end if;
                  if Next_Token > 17 and then Length /= Initial_Length then
                     return False;
                  end if;
                  if Next_Token = 17 then
                     Initial_Length := Length;
                  end if;
               else
                  Match_Token (Text, Position, Assignment_Required_Tokens (Next_Token), Matched);
               end if;
            end;
            if not Matched then return False; end if;
            Next_Token := Next_Token + 1;
         end loop;
         Skip_Trivia (Text, Position);
         return Position > Text'Last;
      end;
   end Accepts_Assignment;

   function Accepts_Guarded (Source : String) return Boolean is
   begin
      if Source'Length = 0 or else Source'Length > Max_Source_Length then
         return False;
      end if;
      declare
         Text : constant String := Normalized (Source);
         Position : Cursor := 1;
         Next_Token : Guarded_Token_Index := 1;
         Declared_First, Declared_After : Literal_Position := 0;
         Matched : Boolean;
         Capacity, Decoration_Length : Capacity_Value := 0;
         Length : Capacity_Value;
      begin
         if not Allowed_Source (Text) then
            return False;
         end if;
         while Next_Token <= Guarded_Required_Tokens'Last loop
            pragma Loop_Invariant (Position <= Text'Last + 1);
            pragma Loop_Invariant (Valid_Name_State (Text, Declared_First, Declared_After));
            pragma Loop_Invariant (Static =>
              Guarded_Suffix_Matches (Text, 1, 1, 0, 0, 0, 0)
                = Guarded_Suffix_Matches (Text, Position, Next_Token, Declared_First, Declared_After, Capacity, Decoration_Length));
            pragma Loop_Variant (Increases => Next_Token);
            Skip_Trivia (Text, Position);
            declare
               Start : constant Cursor := Position;
            begin
               if Guarded_Required_Tokens (Next_Token) = Declaration_Name then
                  Match_Identifier (Text, Position, Matched);
                  if not Matched then return False; end if;
                  if Forbidden_Argument_Name (Text, Start, Position) then return False; end if;
                  Declared_First := Start;
                  Declared_After := Position;
               elsif Guarded_Required_Tokens (Next_Token) = Reference_Name then
                  Match_Identifier (Text, Position, Matched);
                  if not Matched or else Declared_First = 0 then return False; end if;
                  if not Equal_Name (Text, Declared_First, Declared_After, Start, Position) then
                     return False;
                  end if;
               elsif Guarded_Required_Tokens (Next_Token) = Capacity_Literal then
                  declare
                     Parsed : constant Decimal_Result := Read_Capacity (Text, Position);
                  begin
                     if Parsed.After = 0 then return False; end if;
                     Position := Parsed.After;
                     Capacity := Parsed.Value;
                     Matched := True;
                  end;
               elsif Guarded_Required_Tokens (Next_Token) = String_Literal then
                  Match_Sized_Literal (Text, Position, Matched, Length);
                  if not Matched then return False; end if;
                  if Next_Token > 39 then
                     if Decoration_Length + Length > Max_Source_Length then
                        return False;
                     end if;
                     Decoration_Length := Decoration_Length + Length;
                  end if;
               else
                  Match_Token (Text, Position, Guarded_Required_Tokens (Next_Token), Matched);
               end if;
            end;
            if not Matched then return False; end if;
            Next_Token := Next_Token + 1;
         end loop;
         Skip_Trivia (Text, Position);
         return Position > Text'Last and then Capacity + Decoration_Length = Max_Source_Length;
      end;
   end Accepts_Guarded;

   function Accepts (Source : String) return Boolean is
   begin
      return Accepts_Literal (Source) or else Accepts_Named (Source)
        or else Accepts_Arguments (Source) or else Accepts_Concatenation (Source)
        or else Accepts_Guarded (Source) or else Accepts_Assignment (Source);
   end Accepts;
end Silver_Output_Profile;
