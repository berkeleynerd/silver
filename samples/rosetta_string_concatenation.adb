with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Original : String := "Hello";
   Joined : String := Original & " world!";
begin
   Silver_IO.Put_Line (Original);
   Silver_IO.Put_Line (Joined);
end Main;
