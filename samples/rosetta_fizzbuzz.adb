with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
begin
   for Number in 1 .. 100 loop
      if (Number mod 15) = 0 then
         Silver_IO.Put_Line ("FizzBuzz");
      elsif (Number mod 3) = 0 then
         Silver_IO.Put_Line ("Fizz");
      elsif (Number mod 5) = 0 then
         Silver_IO.Put_Line ("Buzz");
      else
         Silver_IO.Put_Line (Integer'Image (Number));
      end if;
   end loop;
end Main;
