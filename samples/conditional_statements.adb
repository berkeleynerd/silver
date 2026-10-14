with Silver_IO;
with Silver_Arguments;
procedure Main is
   pragma SPARK_Mode (On);
   Input : constant String := Silver_Arguments.First_Or_Default ("guest");
   Status : String := "ready";
   Saved : constant String := Status;
begin
   if Silver_Arguments.Input_Is_Valid then
      if Input = "verbose" then
         if Status = "ready" then
            Status := "extra";
         end if;
      elsif Input = "" then
         Status := "empty";
      else
         if Input = "quiet" then
            Status := "quiet";
         else
            Status := "ready";
         end if;
      end if;
      if Status = "extra" then
         Silver_IO.Put_Line ("Details enabled");
      end if;
      Silver_IO.Put_Line ("Initial: " & Saved & "; current: " & Status);
      Silver_IO.Put_Line (Input);
   else
      Silver_Arguments.Reject;
   end if;
end Main;
