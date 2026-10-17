with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P2:Integer range 0..9:=1;
Q2:Integer range 0..5:=2;
K2:constant Integer:=P2;
T2:String:="ab";
U2:String:=T2;
begin
P2:=(9-P2);
Q2:=K2;
T2:=U2;
Silver_IO.Put_Line(Integer'Image(P2));
U2:=T2;
Q2:=(5-Q2);
P2:=Q2;
T2:="cd";
Q2:=K2;
P2:=K2;
Silver_IO.Put_Line(T2&U2);
end Main;
