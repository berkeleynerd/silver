pragma SPARK_Mode (On);
package Visible_State is
   Value : Integer range 0 .. 100 := 0;
   procedure Reset;
   procedure Increment;
   function Read return Integer;
end Visible_State;
