with Silver_IO, Silver_Arguments;
procedure Main is
 pragma SPARK_Mode (On);
 D : constant String := Silver_Arguments.First_Or_Default ("x");
begin
 if Silver_Arguments.Input_Is_Valid then
 Silver_IO.Put_Line (D);
 else
 Silver_Arguments.Reject;
 end if;
end Main;
