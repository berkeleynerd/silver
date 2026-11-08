with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Input_Value is Integer range 0 .. 1000;

   function Sum_Multiples (N : in Input_Value) return Integer is
      Upper : Integer range 0 .. 999 := 0;
      Threes : Integer range 0 .. 333 := 0;
      Fives : Integer range 0 .. 199 := 0;
      Fifteens : Integer range 0 .. 66 := 0;
      Total : Integer := 0;
   begin
      if N = 0 then
         Total := 0;
      else
         Upper := (N - 1);
         Threes := (Upper / 3);
         Fives := (Upper / 5);
         Fifteens := (Upper / 15);
         -- Inclusion-exclusion counts each positive multiple of 15 once.
         Total := (((3 * (Threes * (Threes + 1))) / 2) +
                   ((5 * (Fives * (Fives + 1))) / 2));
         Total := (Total - ((15 * (Fifteens * (Fifteens + 1))) / 2));
      end if;
      return Total;
   end Sum_Multiples;

   Inputs : constant array (1 .. 11) of Input_Value :=
      (0, 1, 3, 4, 5, 6, 10, 15, 16, 999, 1000);
   Total : Integer := 0;
begin
   for N of Inputs loop
      Total := Sum_Multiples (N);
      Silver_IO.Put_Line
         ("sum_multiples(" & Integer'Image (N) & ") =" & Integer'Image (Total));
   end loop;
end Main;
