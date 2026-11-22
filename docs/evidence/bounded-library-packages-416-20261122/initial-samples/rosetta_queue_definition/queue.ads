package Queue is
   pragma SPARK_Mode (On);
   subtype Element is Integer range 0 .. 99;
   procedure Push (Value : in Element; Added : out Boolean);
   procedure Pop (Value : out Element; Present : out Boolean);
   function Empty return Boolean;
end Queue;
