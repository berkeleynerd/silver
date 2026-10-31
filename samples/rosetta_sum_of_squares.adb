with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Element is Integer range 0 .. 9;
   Values : constant array (1 .. 6) of Element := (3, 1, 4, 1, 5, 9);
   Count : Integer range 0 .. 6 := 0;
   Sum : Integer range 0 .. 2147483647 := 0;
begin
   -- Count = 0 represents an empty vector in the fixed-capacity storage.
   for I in 1 .. Count loop
      if Sum <= 2147483566 then
         Sum := (Sum + (Values (I) * Values (I)));
      else
         Silver_IO.Put_Line ("sum exceeds Integer range");
      end if;
   end loop;
   Silver_IO.Put_Line (Integer'Image (Sum));

   Sum := 0;
   for Item of Values loop
      if Sum <= 2147483566 then
         Sum := (Sum + (Item * Item));
      else
         Silver_IO.Put_Line ("sum exceeds Integer range");
      end if;
   end loop;
   Silver_IO.Put_Line (Integer'Image (Sum));
end Main;
