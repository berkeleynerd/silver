with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P34:Integer range 0..9:=1;
Q34:Integer range 0..5:=2;
K34:constant Integer:=P34;
T34:String:="ab";
U34:String:=T34;
begin
P34:=(9-P34);
Q34:=K34;
T34:=U34;
Silver_IO.Put_Line(Integer'Image(P34));
U34:=T34;
Q34:=(5-Q34);
P34:=Q34;
T34:="cd";
Q34:=K34;
P34:=K34;
Silver_IO.Put_Line(T34&U34);
end Main;
