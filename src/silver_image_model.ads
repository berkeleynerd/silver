--  Streaming validation of the pinned GNAT typed-JSON Image declarations.
--  The original byte stream is never rewritten by this package.
package Silver_Image_Model with SPARK_Mode => On is
   type Byte_Count is range 0 .. 2 ** 63 - 1;
   subtype Original_Node_Id is Natural range 0 .. 1_073_741_823;
   First_Inserted_Id : constant := 1_073_741_824;

   type Plan_Kind is (Invalid_Model, Unchanged, Refine);
   type Plan is record
      Kind : Plan_Kind := Invalid_Model;
      Bytes : Byte_Count := 0;
      --  Zero-based number of original bytes preceding the closing bracket.
      Declarations_Offset : Byte_Count := 0;
      Includes_Offset : Byte_Count := 0;
      Greatest_Id : Original_Node_Id := 0;
   end record;

   type State is private;
   Initial_State : constant State;

   procedure Consume (Current : in out State; Item : Character)
     with Global => null;

   function Finish (Current : State) return Plan
     with Global => null,
       Post => (if Finish'Result.Kind = Refine then
         Finish'Result.Declarations_Offset < Finish'Result.Includes_Offset
         and then Finish'Result.Includes_Offset < Finish'Result.Bytes);

   type Insertion_Kind is (Declarations_Insertion, Includes_Insertion);
   function Insertion_Length (Kind : Insertion_Kind) return Positive
     with Global => null;
   function Insertion_Byte
     (Kind : Insertion_Kind; Position : Positive) return Character
     with Global => null, Pre => Position <= Insertion_Length (Kind);

private
   type Lexical_Mode is (Between_Tokens, In_String, After_Escape,
                         In_Unicode, In_Number, In_Literal);
   type Root_Phase is (Before_Root, Root_Key, Root_Colon, Root_List,
                       First_Theory, Next_Theory, Theory_Separator,
                       Root_End, After_Root);
   type Theory_Kind is (Other_Theory, Integer_Theory, String_Theory, Image_Theory);
   subtype Selected_Theory is Theory_Kind range Integer_Theory .. Image_Theory;
   type Seen_Array is array (Selected_Theory) of Boolean;
   type Match_Array is array (Selected_Theory) of Natural;
   type Live_Array is array (Selected_Theory) of Boolean;
   type State is record
      Failed : Boolean := False;
      Bytes : Byte_Count := 0;
      Depth : Byte_Count := 0;
      Mode : Lexical_Mode := Between_Tokens;
      Phase : Root_Phase := Before_Root;
      Seen : Seen_Array := (others => False);
      Matched : Match_Array := (others => 0);
      Live : Live_Array := (others => False);
      In_Theory : Boolean := False;
      Theory : Theory_Kind := Other_Theory;
      Field : Natural range 0 .. 8 := 0;
      Candidate_Declarations : Byte_Count := 0;
      Candidate_Includes : Byte_Count := 0;
      Declarations_Offset : Byte_Count := 0;
      Includes_Offset : Byte_Count := 0;
      Greatest_Id : Original_Node_Id := 0;
      Previous_Array_Start : Boolean := False;
      Node_Id_Pending : Boolean := False;
      Number_Is_Id : Boolean := False;
      Number_Value : Original_Node_Id := 0;
      Number_Digits : Boolean := False;
      String_Is_Tag : Boolean := False;
      String_Is_Key : Boolean := False;
      String_Is_Name : Boolean := False;
      String_Is_Theory_Tag : Boolean := False;
      String_Length : Natural range 0 .. 22 := 0;
      String_Prefix : String (1 .. 21) := (others => ' ');
      Unicode_Left : Natural range 0 .. 4 := 0;
      Unicode_Value : Natural range 0 .. 65_535 := 0;
   end record;
   Initial_State : constant State := (others => <>);
end Silver_Image_Model;
