with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Text : String := "abracadabra";
   Current : Character := ' ';
   A_Count : Integer range 0 .. 5 := 0;
   B_Count : Integer range 0 .. 2 := 0;
   R_Count : Integer range 0 .. 2 := 0;
begin
   for Index in 1 .. 11 loop
      Current := Text (Index);
      if Current = 'a' then
         if A_Count < 5 then
            A_Count := (A_Count + 1);
         end if;
         if A_Count = 1 then
            Text (Index) := 'A';
         elsif A_Count = 2 then
            Text (Index) := 'B';
         elsif A_Count = 4 then
            Text (Index) := 'C';
         elsif A_Count = 5 then
            Text (Index) := 'D';
         end if;
      elsif Current = 'b' then
         if B_Count < 2 then
            B_Count := (B_Count + 1);
         end if;
         if B_Count = 1 then
            Text (Index) := 'E';
         end if;
      elsif Current = 'r' then
         if R_Count < 2 then
            R_Count := (R_Count + 1);
         end if;
         if R_Count = 2 then
            Text (Index) := 'F';
         end if;
      end if;
   end loop;
   Silver_IO.Put_Line (Text);
end Main;
