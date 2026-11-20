with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Source : constant String := "ha";
   Buffer : String := "                    ";
   Count : Integer range 0 .. 10 := 5;
   Len : Integer range 0 .. 20 := 0;
begin
   for I in 1 .. Count loop
      for J in 1 .. 2 loop
         Buffer ((((I - 1) * 2) + J)) := Source (J);
      end loop;
   end loop;
   Len := (Count * 2);
   Silver_IO.Put_Line (Buffer (1 .. Len));
end Main;
