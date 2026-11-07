with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Element is Integer range -9 .. 9;
   First : constant array (1 .. 4) of Element := (-3, 0, 5, 5);
   Second : constant array (1 .. 3) of Element := (8, -1, 2);
   Combined : array (1 .. 7) of Element := (0, 0, 0, 0, 0, 0, 0);
begin
   for I in 1 .. 4 loop
      Combined (I) := First (I);
   end loop;
   for I in 1 .. 3 loop
      Combined ((4 + I)) := Second (I);
   end loop;
   Silver_IO.Put ("First:[");
   for I in 1 .. 4 loop
      if I > 1 then
         Silver_IO.Put (",");
      end if;
      Silver_IO.Put (Integer'Image (First (I)));
   end loop;
   Silver_IO.Put_Line ("]");
   Silver_IO.Put ("Second:[");
   for I in 1 .. 3 loop
      if I > 1 then
         Silver_IO.Put (",");
      end if;
      Silver_IO.Put (Integer'Image (Second (I)));
   end loop;
   Silver_IO.Put_Line ("]");
   Silver_IO.Put ("Combined:[");
   for I in 1 .. 7 loop
      if I > 1 then
         Silver_IO.Put (",");
      end if;
      Silver_IO.Put (Integer'Image (Combined (I)));
   end loop;
   Silver_IO.Put_Line ("]");
end Main;
