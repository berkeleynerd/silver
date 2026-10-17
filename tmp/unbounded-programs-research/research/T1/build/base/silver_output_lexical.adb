with Silver_Profile;

package body Silver_Output_Lexical
  with SPARK_Mode => On
is
   use Silver_Profile;

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

   function Read_Capacity (Text : String; Position : Cursor) return Decimal_Result
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
         elsif Text (Position) = '[' and then Position + 2 <= Text'Last
           and then Text (Position + 1) = Character'Val (34)
           and then Is_Identifier_Character (Text (Position + 2))
         then
            return;
         elsif Text (Position) in ' ' .. '~' then
            Position := Position + 1;
            Length := Length + 1;
         else
            return;
         end if;
      end loop;
   end Match_Sized_Literal;

   procedure Skip_Comment (Text : String; Position : in out Cursor)
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

   procedure Match_Literal
     (Text : String; Position : in out Cursor; Matched : out Boolean)
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
         elsif Text (Position) = '[' and then Position + 2 <= Text'Last
           and then Text (Position + 1) = Character'Val (34)
           and then Is_Identifier_Character (Text (Position + 2))
         then
            return;
         elsif Text (Position) in ' ' .. '~' then
            Position := Position + 1;
         else
            return;
         end if;
      end loop;
   end Match_Literal;

   procedure Match_Identifier
     (Text : String; Position : in out Cursor; Matched : out Boolean)
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
end Silver_Output_Lexical;
