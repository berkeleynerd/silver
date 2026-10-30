with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Element is Integer range 1 .. 9;
   First_List : constant array (1 .. 8) of Element := (2, 5, 1, 3, 8, 9, 4, 6);
   Second_List : constant array (1 .. 7) of Element := (3, 5, 6, 2, 9, 8, 4);
   Third_List : constant array (1 .. 5) of Element := (1, 3, 7, 6, 9);
   In_Second : Boolean := False;
   In_Third : Boolean := False;
   Printed : Boolean := False;
begin
   Silver_IO.Put ("[");
   for Item of First_List loop
      In_Second := False;
      In_Third := False;
      for Other of Second_List loop
         if Item = Other then
            In_Second := True;
         end if;
      end loop;
      for Other of Third_List loop
         if Item = Other then
            In_Third := True;
         end if;
      end loop;
      if In_Second and In_Third then
         if Printed then
            Silver_IO.Put (",");
         end if;
         Silver_IO.Put (Integer'Image (Item));
         Printed := True;
      end if;
   end loop;
   Silver_IO.Put_Line ("]");
end Main;
