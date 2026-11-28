pragma SPARK_Mode (On);
with Bounded_Probe;
procedure Main is
begin
   Bounded_Probe.Counter.Release;
   Bounded_Probe.Counter.Await_Release;
end Main;
