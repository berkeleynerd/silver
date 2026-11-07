with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Element is Integer range -100 .. 100;
   Values : array (1 .. 10) of Element :=
      (-5, 0, 12, -5, 7, 100, -100, 12, 0, 3);
   Temporary : Element := 0;
   Changed : Boolean := True;
begin
   Silver_IO.Put ("Before:[");
   for I in 1 .. 10 loop
      if I > 1 then
         Silver_IO.Put (",");
      end if;
      Silver_IO.Put (Integer'Image (Values (I)));
   end loop;
   Silver_IO.Put_Line ("]");
   for Pass in 1 .. 9 loop
      if Changed then
         Changed := False;
         for I in 1 .. (10 - Pass) loop
            if Values (I) > Values ((I + 1)) then
               Temporary := Values (I);
               Values (I) := Values ((I + 1));
               Values ((I + 1)) := Temporary;
               Changed := True;
            end if;
         end loop;
      end if;
   end loop;
   Silver_IO.Put ("After:[");
   for I in 1 .. 10 loop
      if I > 1 then
         Silver_IO.Put (",");
      end if;
      Silver_IO.Put (Integer'Image (Values (I)));
   end loop;
   Silver_IO.Put_Line ("]");
end Main;
