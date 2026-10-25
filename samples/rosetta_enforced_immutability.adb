with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Answer : constant Integer := 42;
   Name : constant String := "Silver";
   Copy : Integer := Answer;
begin
   Silver_IO.Put_Line (Name & " keeps" & Integer'Image (Answer));
   -- These commented writes explain the restriction; they are not tests.
   -- Answer := 43;    rejected before proof: a constant is not a target
   -- Name := "Other"; rejected for the same reason
   Copy := 43;
   Silver_IO.Put_Line ("Copy is now" & Integer'Image (Copy) & "; Answer is still" & Integer'Image (Answer));
   for I in 1 .. 1 loop
      -- I := 2;       rejected: a loop index is immutable
      Silver_IO.Put_Line ("Loop index" & Integer'Image (I) & " is immutable too.");
   end loop;
end Main;
