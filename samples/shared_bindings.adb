with Silver_IO;

procedure Main is
   pragma SPARK_Mode (On);
   Original : String := "draft";
   Saved : constant String := Original;
   Working : String := Saved;
   Approved : constant String := "ready";
   Prefix : constant String := "Before: ";
begin
   Original := Approved;
   Silver_IO.Put_Line
     (Prefix & Saved & "; copied: " & Working & "; current: " & Original);
end Main;
