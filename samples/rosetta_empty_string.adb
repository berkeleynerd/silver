with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Input : constant String := Silver_Arguments.First_Or_Default ("");
   Empty : String := "";
   Nonempty : String := "Silver";
begin
   Empty := "";
   if Silver_Arguments.Input_Is_Valid then
      if Empty = "" then
         Silver_IO.Put_Line ("empty variable: empty");
      end if;
      if Nonempty /= "" then
         Silver_IO.Put_Line ("nonempty variable: not empty");
      end if;
      if Input'Length = 0 then
         Silver_IO.Put_Line ("argument: empty");
      else
         Silver_IO.Put_Line ("argument: not empty");
      end if;
   else
      Silver_Arguments.Reject;
   end if;
end Main;
