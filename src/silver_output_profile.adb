with Silver_Profile;

package body Silver_Output_Profile
  with SPARK_Mode => On
is
   use Silver_Profile;

   subtype Cursor is Positive range 1 .. Max_Source_Length + 1;

   function Is_Word_Token (Token : Token_Kind) return Boolean is
     (Token in With_Keyword .. End_Keyword);

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
         when String_Literal => """");

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
         and then Word'Length in 1 .. 10;

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

   function Is_Member (Source : String) return Boolean is
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

   function Accepts (Source : String) return Boolean is
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
   end Accepts;
end Silver_Output_Profile;
