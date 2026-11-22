pragma SPARK_Mode (On);
with Ada.Real_Time;
package body Bounded_Probe is
   use type Ada.Real_Time.Time;
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
      Next : Ada.Real_Time.Time := Ada.Real_Time.Clock;
      Period : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (10);
   begin
      loop
         Counter.Increment;
         Next := Next + Period;
         delay until Next;
      end loop;
   end Worker;
end Bounded_Probe;
