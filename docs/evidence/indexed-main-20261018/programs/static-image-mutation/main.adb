with -- contextSilver_IO;
procedure -- noteMain is
   pragma SPARK_Mode (On);
   N : Integer range 0 .. 9 := 0;
   S : String := Integer'Image (N);
begin
   for I in 1 .. 2 loop
      N := I;
      S := Integer'Image (N);
      Silver_IO.Put_Line (S);
   end loop;
end Main;
