with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   A : String := "abc";
begin
   if A = A & "x" then
      A := "toolong";
   end if;
   Silver_IO.Put_Line (A);
end Main;
