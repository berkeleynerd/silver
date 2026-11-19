with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
begin
   for N in reverse 1 .. 99 loop
      Silver_IO.Put_Line (Integer'Image (N) & " bottles of beer on the wall");
      Silver_IO.Put_Line (Integer'Image (N) & " bottles of beer");
      Silver_IO.Put_Line ("Take one down, pass it around");
      Silver_IO.Put_Line (Integer'Image ((N - 1)) & " bottles of beer on the wall");
      Silver_IO.Put_Line ("");
   end loop;
end Main;
