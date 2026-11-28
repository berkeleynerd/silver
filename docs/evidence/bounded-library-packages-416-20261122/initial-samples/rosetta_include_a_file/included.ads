package Included is
   pragma SPARK_Mode (On);
   subtype Digit is Integer range 0 .. 9;
   function Twice (Value : in Digit) return Integer;
end Included;
