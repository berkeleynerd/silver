with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
begin
   Silver_IO.Put_Line ("      +---+---+---+");
   Silver_IO.Put_Line ("     / W / W / W /|");
   Silver_IO.Put_Line ("    +---+---+---+ |");
   Silver_IO.Put_Line ("   / W / W / W /|R|");
   Silver_IO.Put_Line ("  +---+---+---+ | +");
   Silver_IO.Put_Line (" / W / W / W /|R|/|");
   Silver_IO.Put_Line ("+---+---+---+ | + |");
   Silver_IO.Put_Line ("|   |   |   |R|/|R|");
   Silver_IO.Put_Line ("| G | G | G | + | +");
   Silver_IO.Put_Line ("|   |   |   |/|R|/|");
   Silver_IO.Put_Line ("+---+---+---+ | + |");
   Silver_IO.Put_Line ("|   |   |   |R|/|R|");
   Silver_IO.Put_Line ("| G | G | G | + | +");
   Silver_IO.Put_Line ("|   |   |   |/|R|/");
   Silver_IO.Put_Line ("+---+---+---+ | +");
   Silver_IO.Put_Line ("|   |   |   |R|/");
   Silver_IO.Put_Line ("| G | G | G | +");
   Silver_IO.Put_Line ("|   |   |   |/");
   Silver_IO.Put_Line ("+---+---+---+");
end Main;
