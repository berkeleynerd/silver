with Silver_IO, Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Choice : constant String := Silver_Arguments.First_Or_Default ("two");
   Chained : String := "?";
   Nested : String := "?";
begin
   if Silver_Arguments.Input_Is_Valid then
      -- An elsif can be replaced by an if nested inside else.
      if Choice = "one" then
         Chained := "1";
      elsif Choice = "two" then
         Chained := "2";
      else
         Chained := "?";
      end if;
      if Choice = "one" then
         Nested := "1";
      else
         if Choice = "two" then
            Nested := "2";
         else
            Nested := "?";
         end if;
      end if;
      Silver_IO.Put_Line ("elsif: " & Chained);
      Silver_IO.Put_Line ("nested if: " & Nested);
   else
      Silver_Arguments.Reject;
   end if;
end Main;
