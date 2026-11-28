pragma SPARK_Mode (On);
package body Bounded_Probe is
   protected body Counter is
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
   end Counter;

   task body Worker is
   begin
      loop
         Counter.Increment;
      end loop;
   end Worker;
end Bounded_Probe;
