with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
begin
   for I in 1 .. 5 loop
      for J in 1 .. I loop
         Silver_IO.Put ("*");
      end loop;
      Silver_IO.Put_Line ("");
   end loop;
end Main;
