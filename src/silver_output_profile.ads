with Silver_Profile;

package Silver_Output_Profile
  with SPARK_Mode => On
is
   Max_Source_Length : constant Positive := 4_096;
   Max_Expression_Operands : constant Positive := 16;
   --  Redistribute the retained two-output shell's 2 * (16 - 1) operator
   --  allowance across all expression positions without increasing total work.
   Max_Concatenations : constant Positive := 30;
   --  A single-name declaration needs at least twelve bytes (A:String:=B;).
   --  This storage bound cannot constrain a source within the source limit.
   Max_Bindings : constant Positive := Max_Source_Length / 12;
   Comment_Introducer : constant String (1 .. 2) := "--";

   type Token_Kind is
     (With_Keyword, IO_Name, Procedure_Keyword, Main_Name, Is_Keyword,
      Pragma_Keyword, SPARK_Mode_Name, On_Name, Begin_Keyword, Put_Line_Name,
      End_Keyword, Left_Parenthesis, Right_Parenthesis, Semicolon, Dot,
      String_Literal, Colon, Constant_Keyword, String_Name, Assignment,
      Arguments_Name, First_Or_Default_Name, If_Keyword, Input_Is_Valid_Name,
      Then_Keyword, Else_Keyword, Reject_Name, Ampersand, And_Keyword,
      Apostrophe, Length_Name, Less_Equal, Capacity_Literal, Equal,
      Argument_Declaration, Declarations, Assignment_Target, Target_Reference,
      Dynamic_Reference, Assignment_Value, Output_Expression, Comparison_Expression);

   function Is_Word_Token (Token : Token_Kind) return Boolean
     with Global => null,
       Post => Is_Word_Token'Result = (Token_Kind'Pos (Token) in 0 .. 10
         or else Token in Constant_Keyword | String_Name | Arguments_Name
           | First_Or_Default_Name | If_Keyword | Input_Is_Valid_Name
           | Then_Keyword | Else_Keyword | Reject_Name | And_Keyword | Length_Name);

   type Token_Sequence is array (Positive range <>) of Token_Kind;
   --  Declarations share eight body/capacity shapes, rather than adding
   --  another complete-program form for each declaration count.
   type Form_Kind is
     (Direct_Form, Assignment_Form, Argument_Form, Guarded_Argument_Form,
      Branching_Form, Guarded_Branching_Form, Result_Form, Guarded_Result_Form);
   function Tokens (Form : Form_Kind) return Token_Sequence
     with Global => null,
       Post => Tokens'Result'First = 1
         and then Tokens'Result'Length in 1 .. 100;
   function Is_Argument_Form (Form : Form_Kind) return Boolean is
     (Form in Argument_Form .. Guarded_Result_Form);
   function Is_Assignment_Form (Form : Form_Kind) return Boolean is
     (Form in Assignment_Form | Result_Form | Guarded_Result_Form);
   function Spelling (Token : Token_Kind) return String
     with Global => null,
       Post => Spelling'Result'First = 1
         and then Spelling'Result'Length in 1 .. 16;

   function Is_Member (Source : String) return Boolean
     with Ghost => Static, Global => null;
   function Has_Arguments (Source : String) return Boolean
     with Ghost => Static, Global => null;
   function Uses_Arguments (Source : String) return Boolean
     with Global => null,
       Post => (Static => Uses_Arguments'Result = Has_Arguments (Source));
   function Has_Assignment (Source : String) return Boolean
     with Ghost => Static, Global => null;
   function Uses_Assignment (Source : String) return Boolean
     with Global => null,
       Post => (Static => Uses_Assignment'Result = Has_Assignment (Source));
   function Accepts (Source : String) return Boolean
     with Global => null,
       Post => (Static => Accepts'Result = Is_Member (Source));
end Silver_Output_Profile;
