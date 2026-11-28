package Standard is
   pragma SPARK_Mode (On);
   subtype Count is Integer range 0 .. 9;
   procedure Reset;
   procedure Increment;
   function Read return Count;
end Standard;
