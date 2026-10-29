with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Element is Integer range 1 .. 10;
   Values : constant array (1 .. 10) of Element := (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
   Sum : Integer range 0 .. 2147483647 := 0;
   Product : Integer range 1 .. 2147483647 := 1;
begin
   for Item of Values loop
      if Sum <= 2147483637 then
         Sum := (Sum + Item);
      else
         Silver_IO.Put_Line ("sum exceeds Integer range");
      end if;
      if Product <= 214748364 then
         Product := (Product * Item);
      else
         Silver_IO.Put_Line ("product exceeds Integer range");
      end if;
   end loop;
   Silver_IO.Put_Line (Integer'Image (Sum));
   Silver_IO.Put_Line (Integer'Image (Product));
end Main;
