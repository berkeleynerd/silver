with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P93:Integer range 0..9:=1;
Q93:Integer range 0..5:=2;
K93:constant Integer:=P93;
T93:String:="ab";
U93:String:=T93;
begin
P93:=(9-P93);
Q93:=K93;
T93:=U93;
Silver_IO.Put_Line(Integer'Image(P93));
U93:=T93;
Q93:=(5-Q93);
P93:=Q93;
T93:="cd";
Q93:=K93;
P93:=K93;
Silver_IO.Put_Line(T93&U93);
end Main;
