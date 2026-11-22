pragma SPARK_Mode (On);
package body Bounded_Probe is
   protected body Counter is
      procedure Release is
      begin
         Ready := True;
      end Release;

      entry Await_Release when Ready is
      begin
         Ready := False;
         if Value < 100 then
            Value := Value + 1;
         end if;
      end Await_Release;

      function Read return Integer is
      begin
         return Value;
      end Read;
   end Counter;

   task body Worker is
   begin
      loop
         Counter.Await_Release;
      end loop;
   end Worker;
end Bounded_Probe;
