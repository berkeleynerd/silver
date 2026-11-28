pragma SPARK_Mode (On);
with Hidden_State;
package body Package_Client is
   procedure Step is
   begin
      if Hidden_State.Read < 100 then
         Hidden_State.Increment;
      else
         Hidden_State.Reset;
      end if;
   end Step;

   function Read return Integer is
   begin
      return Hidden_State.Read;
   end Read;
end Package_Client;
