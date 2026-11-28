pragma SPARK_Mode (On);
with Hidden_State;
with Visible_State;
procedure Main is
begin
   Hidden_State.Increment;
   Visible_State.Increment;
end Main;
