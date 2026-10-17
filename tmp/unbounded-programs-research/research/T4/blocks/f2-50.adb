with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P50:Integer range 0..9:=1;
Q50:Integer range 0..5:=2;
K50:constant Integer:=P50;
T50:String:="ab";
U50:String:=T50;
begin
P50:=(9-P50);
Q50:=K50;
T50:=U50;
Silver_IO.Put_Line(Integer'Image(P50));
U50:=T50;
Q50:=(5-Q50);
P50:=Q50;
T50:="cd";
Q50:=K50;
P50:=K50;
Silver_IO.Put_Line(T50&U50);
end Main;
