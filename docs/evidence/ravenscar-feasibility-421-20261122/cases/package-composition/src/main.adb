pragma SPARK_Mode (On);
with Hidden_State;
with Visible_State;
with Package_Client;
procedure Main is
begin
   Hidden_State.Reset;
   Package_Client.Step;
   if Package_Client.Read < 100 then
      Visible_State.Reset;
   end if;
   Visible_State.Increment;
end Main;
