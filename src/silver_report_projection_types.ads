--  Shared finite state for the executable projection and its ghost model.
package Silver_Report_Projection_Types with SPARK_Mode => On is
   Max_Depth : constant Positive := 64;
   subtype Depth_Range is Natural range 0 .. Max_Depth;
   type Container_Kind is (Object_Container, Array_Container);
   type Position_Kind is
     (First_Key, Next_Key, Colon, Object_Value, Object_Separator,
      First_Item, Next_Item, Array_Separator);
   type Role_Kind is (Ordinary, Root_Object, Check_List, Check_Record);
   type Key_Kind is (Other_Key, Flow_Key, Proof_Key, Tree_Key);
   type Frame is record
      Container : Container_Kind := Object_Container;
      Position : Position_Kind := First_Key;
      Role : Role_Kind := Ordinary;
      Key : Key_Kind := Other_Key;
      Keep : Boolean := True;
   end record;
   type Frames is array (Positive range 1 .. Max_Depth) of Frame;
   type Lexical_Mode is
     (Between_Tokens, In_String, After_Escape, Unicode_Escape,
      In_Number, In_Literal);
   type Number_Position is
     (After_Minus, After_Zero, Integer_Digits, After_Dot, Fraction_Digits,
      After_Exponent, After_Exponent_Sign, Exponent_Digits);
   type Literal_Kind is (True_Literal, False_Literal, Null_Literal);
   subtype Key_Length is Natural range 0 .. 11;
   type State is record
      Stack : Frames;
      Depth : Depth_Range := 0;
      Mode : Lexical_Mode := Between_Tokens;
      Number : Number_Position := Integer_Digits;
      Literal : Literal_Kind := True_Literal;
      Literal_Position : Positive range 1 .. 5 := 1;
      Unicode_Left : Natural range 0 .. 4 := 0;
      String_Is_Key : Boolean := False;
      Name : String (1 .. 10) := (others => ' ');
      Name_Length : Key_Length := 0;
      Name_Escaped : Boolean := False;
      Token_Keep : Boolean := True;
      Started, Finished, Failed : Boolean := False;
   end record;
   Initial_State : constant State := (others => <>);
   subtype Emission_Length is Natural range 0 .. 2;
   subtype Emission_Bytes is String (1 .. 2);
   type Transition is record
      Following : State;
      Bytes : Emission_Bytes := (others => ' ');
      Length : Emission_Length := 0;
   end record;

end Silver_Report_Projection_Types;
