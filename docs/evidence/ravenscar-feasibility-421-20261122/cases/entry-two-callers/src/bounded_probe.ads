pragma SPARK_Mode (On);
package Bounded_Probe is
   protected Counter is
      procedure Release;
      entry Await_Release;
      function Read return Integer;
   private
      Value : Integer range 0 .. 100 := 0;
      Ready : Boolean := False;
   end Counter;

   task Worker;
end Bounded_Probe;
