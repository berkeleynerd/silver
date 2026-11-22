pragma SPARK_Mode (On);
package Hidden_State is
   procedure Reset;
   procedure Increment;
   function Read return Integer;
end Hidden_State;
