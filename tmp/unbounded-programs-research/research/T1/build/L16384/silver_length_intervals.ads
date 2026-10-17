with Silver_Path_Facts;

package Silver_Length_Intervals with SPARK_Mode => On is
   package Paths renames Silver_Path_Facts;

   --  Both endpoints retain their contributions when an operand has no value.
   --  In particular, an empty Image must not erase the other String operands.
   type Summary is record
      Minimum_Length, Static_Length : Paths.Length_Value;
      Dynamic_Count : Paths.Operand_Count;
      Empty_Value : Boolean := False;
   end record;
   Empty_Summary : constant Summary := (0, 0, 0, True);

   function Is_Empty (Value : Summary) return Boolean is (Value.Empty_Value);
   function Lower (Value : Summary) return Paths.Summary is
     (Value.Minimum_Length, Value.Dynamic_Count);
   function Upper (Value : Summary) return Paths.Summary is
     (Value.Static_Length, Value.Dynamic_Count);

   function Fits (Facts : Paths.Context; Value : Summary) return Boolean
     with Global => null;

   --  Assignment is directional: Right is the target. Empty values waive
   --  runtime equality, but their retained contribution must fit a fixed target.
   function Same_Length (Facts : Paths.Context; Left, Right : Summary) return Boolean
     with Global => null;

   function Refine_Equal (Facts : Paths.Context; Left, Right : Summary)
      return Paths.Context
     with Global => null;
end Silver_Length_Intervals;
