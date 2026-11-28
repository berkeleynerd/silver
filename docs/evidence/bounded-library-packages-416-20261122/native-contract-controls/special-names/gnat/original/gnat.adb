package body GNAT is
   pragma SPARK_Mode (On);
   Value : Count := 0;
   procedure Reset is
   begin
      Value := 0;
   end Reset;
   procedure Increment is
   begin
      if Value < 9 then
         Value := (Value + 1);
      end if;
   end Increment;
   function Read return Count is
   begin
      return Value;
   end Read;
end GNAT;
