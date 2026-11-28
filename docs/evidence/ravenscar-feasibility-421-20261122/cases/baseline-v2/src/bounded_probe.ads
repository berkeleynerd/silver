pragma SPARK_Mode (On);
package Bounded_Probe is
   protected Counter is
      procedure Increment;
      function Read return Integer;
   private
      Value : Integer range 0 .. 100 := 0;
   end Counter;

   task Worker;
end Bounded_Probe;
