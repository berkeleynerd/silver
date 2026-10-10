with Silver_Profile;

package Silver_Output_Profile
  with SPARK_Mode => On
is
   Max_Source_Length : constant Positive := 4_096;
   Comment_Introducer : constant String (1 .. 2) := "--";

   type Token_Kind is
     (With_Keyword, IO_Name, Procedure_Keyword, Main_Name, Is_Keyword,
      Pragma_Keyword, SPARK_Mode_Name, On_Name, Begin_Keyword, Put_Line_Name,
      End_Keyword, Left_Parenthesis, Right_Parenthesis, Semicolon, Dot,
      String_Literal, Colon, Constant_Keyword, String_Name, Assignment,
      Declaration_Name, Reference_Name, Arguments_Name, First_Or_Default_Name,
      If_Keyword, Input_Is_Valid_Name, Then_Keyword, Else_Keyword, Reject_Name,
      Ampersand, And_Keyword, Apostrophe, Length_Name, Less_Equal, Capacity_Literal);

   function Is_Word_Token (Token : Token_Kind) return Boolean
     with Global => null,
          Post => Is_Word_Token'Result = (Token_Kind'Pos (Token) in 0 .. 10
            or else Token in Constant_Keyword | String_Name | Arguments_Name
              | First_Or_Default_Name | If_Keyword | Input_Is_Valid_Name
              | Then_Keyword | Else_Keyword | Reject_Name | And_Keyword | Length_Name);

   type Token_Sequence is array (Positive range <>) of Token_Kind;
   Required_Tokens : constant Token_Sequence :=
     (With_Keyword, IO_Name, Semicolon,
      Procedure_Keyword, Main_Name, Is_Keyword,
      Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis, On_Name,
      Right_Parenthesis, Semicolon, Begin_Keyword,
      IO_Name, Dot, Put_Line_Name, Left_Parenthesis, String_Literal,
      Right_Parenthesis, Semicolon, End_Keyword, Main_Name, Semicolon);

   Named_Required_Tokens : constant Token_Sequence :=
     (With_Keyword, IO_Name, Semicolon,
      Procedure_Keyword, Main_Name, Is_Keyword,
      Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis, On_Name,
      Right_Parenthesis, Semicolon, Declaration_Name, Colon,
      Constant_Keyword, String_Name, Assignment, String_Literal, Semicolon,
      Begin_Keyword, IO_Name, Dot, Put_Line_Name, Left_Parenthesis,
      Reference_Name, Right_Parenthesis, Semicolon, End_Keyword, Main_Name,
      Semicolon);

   Argument_Required_Tokens : constant Token_Sequence :=
     (With_Keyword, IO_Name, Semicolon, With_Keyword, Arguments_Name,
      Semicolon, Procedure_Keyword, Main_Name, Is_Keyword,
      Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis, On_Name,
      Right_Parenthesis, Semicolon, Declaration_Name, Colon,
      Constant_Keyword, String_Name, Assignment, Arguments_Name, Dot,
      First_Or_Default_Name, Left_Parenthesis, String_Literal,
      Right_Parenthesis, Semicolon, Begin_Keyword, If_Keyword,
      Arguments_Name, Dot, Input_Is_Valid_Name, Then_Keyword, IO_Name,
      Dot, Put_Line_Name, Left_Parenthesis, Reference_Name,
      Right_Parenthesis, Semicolon, Else_Keyword, Arguments_Name, Dot,
      Reject_Name, Semicolon, End_Keyword, If_Keyword, Semicolon,
      End_Keyword, Main_Name, Semicolon);

   Concatenation_Required_Tokens : constant Token_Sequence :=
     (With_Keyword, IO_Name, Semicolon,
      Procedure_Keyword, Main_Name, Is_Keyword,
      Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis, On_Name,
      Right_Parenthesis, Semicolon, Declaration_Name, Colon,
      Constant_Keyword, String_Name, Assignment, String_Literal, Semicolon,
      Begin_Keyword, IO_Name, Dot, Put_Line_Name, Left_Parenthesis,
      String_Literal, Ampersand, Reference_Name, Ampersand, String_Literal,
      Right_Parenthesis, Semicolon, End_Keyword, Main_Name, Semicolon);

   Assignment_Required_Tokens : constant Token_Sequence :=
     (With_Keyword, IO_Name, Semicolon,
      Procedure_Keyword, Main_Name, Is_Keyword,
      Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis, On_Name,
      Right_Parenthesis, Semicolon, Declaration_Name, Colon,
      String_Name, Assignment, String_Literal, Semicolon,
      Begin_Keyword, Reference_Name, Assignment, String_Literal, Semicolon,
      IO_Name, Dot, Put_Line_Name, Left_Parenthesis, Reference_Name,
      Right_Parenthesis, Semicolon, End_Keyword, Main_Name, Semicolon);

   Guarded_Required_Tokens : constant Token_Sequence :=
     (With_Keyword, IO_Name, Semicolon, With_Keyword, Arguments_Name,
      Semicolon, Procedure_Keyword, Main_Name, Is_Keyword,
      Pragma_Keyword, SPARK_Mode_Name, Left_Parenthesis, On_Name,
      Right_Parenthesis, Semicolon, Declaration_Name, Colon,
      Constant_Keyword, String_Name, Assignment, Arguments_Name, Dot,
      First_Or_Default_Name, Left_Parenthesis, String_Literal,
      Right_Parenthesis, Semicolon, Begin_Keyword, If_Keyword,
      Arguments_Name, Dot, Input_Is_Valid_Name, And_Keyword, Then_Keyword,
      Reference_Name, Apostrophe, Length_Name, Less_Equal, Capacity_Literal,
      Then_Keyword, IO_Name, Dot, Put_Line_Name, Left_Parenthesis,
      String_Literal, Ampersand, Reference_Name, Ampersand, String_Literal,
      Right_Parenthesis, Semicolon, Else_Keyword, Arguments_Name, Dot,
      Reject_Name, Semicolon, End_Keyword, If_Keyword, Semicolon,
      End_Keyword, Main_Name, Semicolon);

   function Spelling (Token : Token_Kind) return String
     with Global => null,
          Post => Spelling'Result'First = 1
            and then Spelling'Result'Length in 1 .. 16;

   --  The independent ghost grammar admits direct literal output, named
   --  literal constants, guarded command-line initialization and output,
   --  literal-backed concatenation, and command-line concatenation behind
   --  the fixed validity and residual-capacity guard, and one equal-length
   --  literal assignment to a literal-initialized String variable.
   --  Its string contents are printable ASCII; doubled quotes encode one
   --  quote, and comments/trivia apply only outside the literal.
   function Is_Member (Source : String) return Boolean
     with Ghost => Static, Global => null;

   function Is_Guarded_Member (Source : String) return Boolean
     with Ghost => Static, Global => null;

   function Accepts_Guarded (Source : String) return Boolean
     with Global => null,
          Post => (Static => Accepts_Guarded'Result = Is_Guarded_Member (Source));

   function Is_Assignment_Member (Source : String) return Boolean
     with Ghost => Static, Global => null;

   function Accepts_Assignment (Source : String) return Boolean
     with Global => null,
          Post => (Static => Accepts_Assignment'Result = Is_Assignment_Member (Source));

   function Accepts (Source : String) return Boolean
     with Global => null,
          Post => (Static => Accepts'Result = Is_Member (Source));
end Silver_Output_Profile;
