with Silver_IO; use Silver_IO;
with Silver_IO;
procedure Main is
 pragma SPARK_Mode (On);
 K : constant Integer := 2;
 N : Integer range 0 .. 10 := 1;
 S : String := "ab";
 T : constant String := S;
begin
 for I in 1 .. 2 loop
  if (N <= 9 and then S = "ab") or else not (S /= T) then
   N := (K * I);
   S := "cd";
   Put (Item => Integer'Image ((I + K)));
  elsif N = 10 then
   Put_Line (S & T);
  else
   null;
  end if;
  for J in reverse 1 .. I loop
   Put_Line (Integer'Image ((-J)));
  end loop;
 end loop;
end Main;
