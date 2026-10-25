with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
begin
   Silver_IO.Put_Line ("Single delimiters: & ' ( ) * + , - . : ; < = >");
   Silver_IO.Put_Line ("Compound delimiters: => .. := /= >= <=");
   Silver_IO.Put_Line ("Double quotes delimit String literals; double a quote inside one.");
   Silver_IO.Put_Line ("She said ""Hello"".");
   Silver_IO.Put_Line ("Backslash is literal: \; -- inside a String is literal too.");
end Main;
