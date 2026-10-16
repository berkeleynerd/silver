with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;

--  Streaming projection of proof-tree metadata; all other bytes are retained.
--  The state has the existing report nesting ceiling, but no raw byte counter.
package Silver_Report_Projection with SPARK_Mode => On is
   use type Silver_Report_Projection_Types.Lexical_Mode;
   use type Silver_Report_Projection_Types.Transition;
   subtype State is Silver_Report_Projection_Types.State;
   subtype Transition is Silver_Report_Projection_Types.Transition;
   Initial_State : constant State := Silver_Report_Projection_Types.Initial_State;

   function Advance (Before : State; Item : Character) return Transition
     with Global => null,
       Post => (Static => Advance'Result =
         Silver_Report_Projection_Model.Advance_Spec (Before, Item));
   function Complete (Current : State) return Boolean is
     (not Current.Failed and then Current.Depth = 0
      and then ((Current.Mode = Silver_Report_Projection_Types.Between_Tokens
                 and then Current.Finished)
        or else (Current.Mode = Silver_Report_Projection_Types.In_Number
          and then Current.Number in Silver_Report_Projection_Types.After_Zero
            | Silver_Report_Projection_Types.Integer_Digits
            | Silver_Report_Projection_Types.Fraction_Digits
            | Silver_Report_Projection_Types.Exponent_Digits)))
     with Global => null;
end Silver_Report_Projection;
