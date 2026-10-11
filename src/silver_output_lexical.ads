with Silver_Profile;

package Silver_Output_Lexical
  with SPARK_Mode => On
is
   use Silver_Profile;

   subtype Cursor is Positive range 1 .. Max_Source_Length + 1;

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

   function Valid_Name_State (Text : String; First, After : Literal_Position) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;

   function Valid_Name_State (Text : String; First, After : Literal_Position) return Boolean is
     ((First = 0 and then After = 0)
      or else (First > 0 and then First < After and then After <= Text'Last + 1));

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
       Post => (Static => Read_Capacity'Result = Decimal_At (Text, Position));

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
           and then Length = Literal_Length (Text, Position'Old + 1)));

   procedure Skip_Comment (Text : String; Position : in out Cursor)
     with
       Global => null,
       Pre => Text'First = 1
         and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Static => Position in Position'Old .. Text'Last + 1
         and then Position = Comment_End (Text, Position'Old));

   procedure Skip_Trivia (Text : String; Position : in out Cursor)
     with
       Global => null,
       Pre => Text'First = 1
         and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Static => Position in Position'Old .. Text'Last + 1
         and then Position = Trivia_End (Text, Position'Old));

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
           Position = Literal_End (Text, Position'Old + 1)));

   procedure Match_Identifier
     (Text : String; Position : in out Cursor; Matched : out Boolean)
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1,
       Post => (Static => Position <= Text'Last + 1
         and then Matched = (Identifier_End (Text, Position'Old) /= 0)
         and then (if Matched then Position = Identifier_End (Text, Position'Old)));
end Silver_Output_Lexical;
