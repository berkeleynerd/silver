with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Input : constant String := Silver_Arguments.First_Or_Default ("guest");
   Label : String := "draft";
   Saved : constant String := Label;
   Mirror : String := Label;
begin
   if Silver_Arguments.Input_Is_Valid and then Input'Length <= 4088 then
      Silver_IO.Put_Line ("Hello, " & Input & "!");
      if Input = "verbose" then
         Label := "extra";
         Mirror := Label;
         Silver_IO.Put_Line ("Details: " & Mirror);
      else
         Label := "ready";
         null;
      end if;
      Mirror := Label;
      Label := Label;
      Silver_IO.Put_Line ("Before: " & Saved & "; current: " & Mirror);
      if Mirror = "extra" then
         Silver_IO.Put_Line ("Mode: details");
         null;
      else
         Silver_IO.Put_Line ("Mode: brief");
      end if;
   else
      Silver_Arguments.Reject;
   end if;
end Main;
