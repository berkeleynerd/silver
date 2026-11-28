pragma SPARK_Mode (On);
package body Visible_State is
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
end Visible_State;
