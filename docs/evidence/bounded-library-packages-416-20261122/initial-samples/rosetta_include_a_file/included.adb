package body Included is
   pragma SPARK_Mode (On);
   function Twice (Value : in Digit) return Integer is
   begin
      return (Value + Value);
   end Twice;
end Included;
