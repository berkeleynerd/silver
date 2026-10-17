with Ada.Command_Line; with Ada.Text_IO;
procedure Arg is
   A : constant String := Ada.Command_Line.Argument (1);
   B : constant String := A & A & A & A & A & A & A & A;  --  8x on secondary stack/heap
begin
   Ada.Text_IO.Put_Line (Natural'Image (A'Length) & Natural'Image (B'Length));
end Arg;
