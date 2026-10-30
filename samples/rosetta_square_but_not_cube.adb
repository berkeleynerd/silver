with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Square : Integer range 1 .. 1600 := 1;
   Count : Integer range 0 .. 30 := 0;
   Cube : Boolean := False;
begin
   for Root in 1 .. 40 loop
      Square := (Root * Root);
      Cube := False;
      for Trial in 1 .. 13 loop
         if ((Trial * Trial) * Trial) = Square then
            Cube := True;
         end if;
      end loop;
      if not Cube and then Count < 30 then
         Count := (Count + 1);
         Silver_IO.Put (Integer'Image (Square));
      end if;
   end loop;
   Silver_IO.Put_Line ("");
end Main;
