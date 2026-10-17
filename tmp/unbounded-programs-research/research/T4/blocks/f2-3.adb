with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P3:Integer range 0..9:=1;
Q3:Integer range 0..5:=2;
K3:constant Integer:=P3;
T3:String:="ab";
U3:String:=T3;
begin
P3:=(9-P3);
Q3:=K3;
T3:=U3;
Silver_IO.Put_Line(Integer'Image(P3));
U3:=T3;
Q3:=(5-Q3);
P3:=Q3;
T3:="cd";
Q3:=K3;
P3:=K3;
Silver_IO.Put_Line(T3&U3);
end Main;
