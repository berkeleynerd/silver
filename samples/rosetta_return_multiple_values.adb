with Silver_IO;

procedure Main is
   pragma SPARK_Mode (On);

   subtype Small is Integer range -100 .. 100;

   procedure Sum_And_Diff
     (Left : in Small;
      Right : in Small;
      Sum : out Integer;
      Difference : out Integer)
   is
   begin
      Sum := (Left + Right);
      Difference := (Left - Right);
   end Sum_And_Diff;

   Sum : Integer := 0;
   Difference : Integer := 0;
begin
   Sum_And_Diff (5, 3, Sum, Difference);
   Silver_IO.Put_Line ("Sum:" & Integer'Image (Sum));
   Silver_IO.Put_Line ("Difference:" & Integer'Image (Difference));

   Sum_And_Diff (-100, 100, Sum, Difference);
   Silver_IO.Put_Line ("Sum:" & Integer'Image (Sum));
   Silver_IO.Put_Line ("Difference:" & Integer'Image (Difference));

   Sum_And_Diff (100, 100, Sum, Difference);
   Silver_IO.Put_Line ("Sum:" & Integer'Image (Sum));
   Silver_IO.Put_Line ("Difference:" & Integer'Image (Difference));
end Main;
