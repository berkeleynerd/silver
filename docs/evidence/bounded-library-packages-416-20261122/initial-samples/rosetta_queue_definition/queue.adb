package body Queue is
   pragma SPARK_Mode (On);
   First : Element := 0;
   Second : Element := 0;
   Count : Integer range 0 .. 2 := 0;
   procedure Push (Value : in Element; Added : out Boolean) is
   begin
      Added := False;
      if Count = 0 then
         First := Value;
         Count := 1;
         Added := True;
      elsif Count = 1 then
         Second := Value;
         Count := 2;
         Added := True;
      end if;
   end Push;
   procedure Pop (Value : out Element; Present : out Boolean) is
   begin
      Value := 0;
      Present := False;
      if Count = 1 then
         Value := First;
         Count := 0;
         Present := True;
      elsif Count = 2 then
         Value := First;
         First := Second;
         Count := 1;
         Present := True;
      end if;
   end Pop;
   function Empty return Boolean is
   begin
      return Count = 0;
   end Empty;
end Queue;
