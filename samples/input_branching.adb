with Silver_IO;
with Silver_Arguments;

procedure Main is
   pragma SPARK_Mode (On);

   Mode : constant String :=
     Silver_Arguments.First_Or_Default ("brief");
begin
   if Silver_Arguments.Input_Is_Valid then
      if Mode = "verbose" then
         Silver_IO.Put_Line ("Silver is ready. Input validation succeeded.");
      else
         Silver_IO.Put_Line ("Ready.");
      end if;
   else
      Silver_Arguments.Reject;
   end if;
end Main;
