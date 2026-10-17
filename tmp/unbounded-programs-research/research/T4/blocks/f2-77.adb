with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P77:Integer range 0..9:=1;
Q77:Integer range 0..5:=2;
K77:constant Integer:=P77;
T77:String:="ab";
U77:String:=T77;
begin
P77:=(9-P77);
Q77:=K77;
T77:=U77;
Silver_IO.Put_Line(Integer'Image(P77));
U77:=T77;
Q77:=(5-Q77);
P77:=Q77;
T77:="cd";
Q77:=K77;
P77:=K77;
Silver_IO.Put_Line(T77&U77);
end Main;
