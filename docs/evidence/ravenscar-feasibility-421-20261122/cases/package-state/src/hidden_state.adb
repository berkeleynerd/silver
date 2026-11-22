pragma SPARK_Mode (On);
package body Hidden_State is
   Value : Integer range 0 .. 100 := 0;
   procedure Increment is
   begin
      if Value < 100 then
         Value := Value + 1;
      end if;
   end Increment;

   function Read return Integer is
   begin
      return Value;
   end Read;
end Hidden_State;
