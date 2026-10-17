package Silver_Profile
  with SPARK_Mode => On
is
   Max_Source_Length : constant Positive := 65536;
   Comment_Introducer : constant String (1 .. 2) := "--";

   --  These predicates are shared by recognition and catalogue export.
   function Is_Whitespace (Item : Character) return Boolean
     with Global => null,
          Post => Is_Whitespace'Result =
            (Character'Pos (Item) = 32 or else Character'Pos (Item) = 9
             or else Character'Pos (Item) = 10 or else Character'Pos (Item) = 13);
   function Is_Allowed_Character (Item : Character) return Boolean
     with Global => null,
          Post => Is_Allowed_Character'Result =
            (Character'Pos (Item) in 32 .. 126
             or else Character'Pos (Item) = 9
             or else Character'Pos (Item) = 10
             or else Character'Pos (Item) = 13);
   function Is_Identifier_Character (Item : Character) return Boolean
     with Global => null,
          Post => Is_Identifier_Character'Result =
            (Character'Pos (Item) in 65 .. 90
             or else Character'Pos (Item) in 97 .. 122
             or else Character'Pos (Item) in 48 .. 57
             or else Character'Pos (Item) = 95);
   function Is_Comment_End (Item : Character) return Boolean
     with Global => null,
          Post => Is_Comment_End'Result =
            (Character'Pos (Item) = 10 or else Character'Pos (Item) = 13);
   function Lowercase (Item : Character) return Character
     with Global => null,
          Post => Character'Pos (Lowercase'Result) =
            (if Character'Pos (Item) in 65 .. 90
             then Character'Pos (Item) + 32 else Character'Pos (Item));

   type Token_Kind is
     (Procedure_Keyword,
      Main_Name,
      Is_Keyword,
      Pragma_Keyword,
      SPARK_Mode_Name,
      On_Name,
      Begin_Keyword,
      Null_Keyword,
      End_Keyword,
      Left_Parenthesis,
      Right_Parenthesis,
      Semicolon);

   function Is_Word_Token (Token : Token_Kind) return Boolean
     with Global => null,
          Post => Is_Word_Token'Result = (Token_Kind'Pos (Token) in 0 .. 8);

   type Token_Sequence is array (Positive range <>) of Token_Kind;

   --  This sequence is the complete syntactic catalogue for the initial
   --  profile. Recognition and catalogue export both use this constant.
   Required_Tokens : constant Token_Sequence :=
     (Procedure_Keyword,
      Main_Name,
      Is_Keyword,
      Pragma_Keyword,
      SPARK_Mode_Name,
      Left_Parenthesis,
      On_Name,
      Right_Parenthesis,
      Semicolon,
      Begin_Keyword,
      Null_Keyword,
      Semicolon,
      End_Keyword,
      Main_Name,
      Semicolon);

   function Spelling (Token : Token_Kind) return String
     with Global => null,
          Post => Spelling'Result'First = 1
            and then Spelling'Result'Length in 1 .. 10;

   --  Independent membership specification. Its definition composes maximal
   --  trivia spans and exact token spans; it does not call Accepts.
   function Is_Member (Source : String) return Boolean
     with Ghost,
          Global => null;

   --  Membership is independent of any compiler or prover invocation.
   --  Source is ASCII, with case-insensitive names, printable comments, and
   --  space, horizontal tab, CR, or LF as whitespace. Arbitrary String
   --  bounds are supported. The source length limit includes comments.
   function Accepts (Source : String) return Boolean
     with Global => null,
          Post => Accepts'Result = Is_Member (Source);
end Silver_Profile;
