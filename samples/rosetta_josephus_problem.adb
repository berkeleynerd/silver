with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   -- Solve the task's incident with 41 prisoners, counting every third.
   -- The recurrence uses the task's zero-based prisoner numbering.
   N : constant Integer := 41;
   K : constant Integer := 3;
   Survivor : Integer range 0 .. 40 := 0;
begin
   for I in 2 .. N loop
      Survivor := ((Survivor + K) mod I);
   end loop;
   Silver_IO.Put_Line ("Survivor (0-based):" & Integer'Image (Survivor));
end Main;
