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
         when Capacity_Literal => "0",
         when Equal => "=");

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


   subtype Named_Token_Index is Positive range 1 .. Named_Required_Tokens'Last + 1;


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

   subtype Branching_Token_Index is Positive range 1 .. Branching_Required_Tokens'Last + 1;

   function Branching_Suffix_Matches
     (Text : String; Position : Cursor; Next_Token : Branching_Token_Index;
      Declared_First, Declared_After : Literal_Position) return Boolean
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Position <= Text'Last + 1
         and then Valid_Name_State (Text, Declared_First, Declared_After),
       Subprogram_Variant => (Increases => Next_Token);

   function Branching_Suffix_Matches
     (Text : String; Position : Cursor; Next_Token : Branching_Token_Index;
      Declared_First, Declared_After : Literal_Position) return Boolean
   is
     (if Next_Token > Branching_Required_Tokens'Last then
        Trivia_End (Text, Position) = Text'Last + 1
      elsif Branching_Required_Tokens (Next_Token) = Declaration_Name then
        Identifier_End (Text, Trivia_End (Text, Position)) /= 0
        and then not Forbidden_Argument_Name
          (Text, Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
        and then Branching_Suffix_Matches
          (Text, Identifier_End (Text, Trivia_End (Text, Position)), Next_Token + 1,
           Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
      elsif Branching_Required_Tokens (Next_Token) = Reference_Name then
        Declared_First > 0
        and then Identifier_End (Text, Trivia_End (Text, Position)) /= 0
        and then Equal_Name
          (Text, Declared_First, Declared_After,
           Trivia_End (Text, Position), Identifier_End (Text, Trivia_End (Text, Position)))
        and then Branching_Suffix_Matches
          (Text, Identifier_End (Text, Trivia_End (Text, Position)), Next_Token + 1,
           Declared_First, Declared_After)
      elsif Branching_Required_Tokens (Next_Token) = String_Literal then
        Trivia_End (Text, Position) <= Text'Last
        and then Text (Trivia_End (Text, Position)) = Character'Val (34)
        and then Literal_End (Text, Trivia_End (Text, Position) + 1) /= 0
        and then Branching_Suffix_Matches
          (Text, Literal_End (Text, Trivia_End (Text, Position) + 1), Next_Token + 1,
           Declared_First, Declared_After)
      else
        Token_At (Text, Trivia_End (Text, Position),
          Spelling (Branching_Required_Tokens (Next_Token)),
          Is_Word_Token (Branching_Required_Tokens (Next_Token)))
        and then Branching_Suffix_Matches
          (Text, Trivia_End (Text, Position) + Spelling (Branching_Required_Tokens (Next_Token))'Length,
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
        or else Assignment_Suffix_Matches (Normalized (Source), 1, 1, 0, 0, 0)
        or else Branching_Suffix_Matches (Normalized (Source), 1, 1, 0, 0)));

   function Is_Literal_Member (Source : String) return Boolean
     with Ghost => Static, Global => null;

   function Is_Literal_Member (Source : String) return Boolean is
     (Source'Length in 1 .. Max_Source_Length
      and then Allowed_Source (Normalized (Source))
      and then Suffix_Matches (Normalized (Source), 1, 1));


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

   function Accepts_Branching (Source : String) return Boolean
     with Global => null,
       Post => (Static => Accepts_Branching'Result =
         (Source'Length in 1 .. Max_Source_Length
          and then Allowed_Source (Normalized (Source))
          and then Branching_Suffix_Matches (Normalized (Source), 1, 1, 0, 0)));

   function Accepts_Branching (Source : String) return Boolean is
   begin
      if Source'Length = 0 or else Source'Length > Max_Source_Length then
         return False;
      end if;
      declare
         Text : constant String := Normalized (Source);
         Position : Cursor := 1;
         Next_Token : Branching_Token_Index := 1;
         Declared_First, Declared_After : Literal_Position := 0;
         Matched : Boolean;
      begin
         if not Allowed_Source (Text) then
            return False;
         end if;
         while Next_Token <= Branching_Required_Tokens'Last loop
            pragma Loop_Invariant (Position <= Text'Last + 1);
            pragma Loop_Invariant (Valid_Name_State (Text, Declared_First, Declared_After));
            pragma Loop_Invariant (Static =>
              Branching_Suffix_Matches (Text, 1, 1, 0, 0)
                = Branching_Suffix_Matches (Text, Position, Next_Token, Declared_First, Declared_After));
            pragma Loop_Variant (Increases => Next_Token);
            Skip_Trivia (Text, Position);
            declare
               Start : constant Cursor := Position;
            begin
               if Branching_Required_Tokens (Next_Token) = Declaration_Name then
                  Match_Identifier (Text, Position, Matched);
                  if not Matched then return False; end if;
                  if Forbidden_Argument_Name (Text, Start, Position) then return False; end if;
                  Declared_First := Start;
                  Declared_After := Position;
               elsif Branching_Required_Tokens (Next_Token) = Reference_Name then
                  Match_Identifier (Text, Position, Matched);
                  if not Matched or else Declared_First = 0 then return False; end if;
                  if not Equal_Name (Text, Declared_First, Declared_After, Start, Position) then
                     return False;
                  end if;
               elsif Branching_Required_Tokens (Next_Token) = String_Literal then
                  Match_Literal (Text, Position, Matched);
               else
                  Match_Token (Text, Position, Branching_Required_Tokens (Next_Token), Matched);
               end if;
            end;
            if not Matched then return False; end if;
            Next_Token := Next_Token + 1;
         end loop;
         Skip_Trivia (Text, Position);
         return Position > Text'Last;
      end;
   end Accepts_Branching;

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
        or else Accepts_Guarded (Source) or else Accepts_Assignment (Source)
        or else Accepts_Branching (Source);
   end Accepts;
end Silver_Output_Profile;
