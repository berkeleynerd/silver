with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P25:Integer range 0..9:=1;
Q25:Integer range 0..5:=2;
K25:constant Integer:=P25;
T25:String:="ab";
U25:String:=T25;
begin
P25:=(9-P25);
Q25:=K25;
T25:=U25;
Silver_IO.Put_Line(Integer'Image(P25));
U25:=T25;
Q25:=(5-Q25);
P25:=Q25;
T25:="cd";
Q25:=K25;
P25:=K25;
Silver_IO.Put_Line(T25&U25);
end Main;
