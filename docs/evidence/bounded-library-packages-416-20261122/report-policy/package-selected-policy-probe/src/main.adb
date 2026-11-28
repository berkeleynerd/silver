with Audit_State;
procedure Main is
   pragma SPARK_Mode (On);
   Value : Audit_State.Small := 0;
begin
   Audit_State.Reset;
   Audit_State.Reset;
   Audit_State.Depend (Value, 1);
   Audit_State.Produce (Value, 1);
end Main;
