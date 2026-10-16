package body Silver_Report_Projection_Parents with SPARK_Mode => On is
   procedure Same_Transitive (Left, Middle, Right : State; Base : Depth_Range) is
   begin
      null;
   end Same_Transitive;

   procedure Whole_Transitive (Left, Middle, Right : State; Base : Depth_Range) is
   begin
      null;
   end Whole_Transitive;

   procedure Whole_Head
     (Raw : Bytes.Sequence; First, Last : Big_Natural; Left : State; Base : Depth_Range)
   is
   begin
      null;
   end Whole_Head;

   procedure Lift_Whole
     (Raw : Bytes.Sequence; First, Last : Big_Natural;
      Left, Middle : State; Base : Depth_Range)
   is
   begin
      if First <= Last then
         Lift_Whole (Raw, First, Last - 1, Left, Middle, Base);
         Whole_Transitive (Left, Middle, Model.Scan_State (Raw, Last - 1), Base);
      end if;
   end Lift_Whole;

   procedure Inside_Container (S : State; Item : Character; Base : Depth_Range) is
   begin
      null;
   end Inside_Container;

   procedure Inside_Token (S : State; Item : Character) is
   begin
      null;
   end Inside_Token;

   procedure Start_Value (S : State; Item : Character) is
   begin
      null;
   end Start_Value;
end Silver_Report_Projection_Parents;
