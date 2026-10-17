with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P27:Integer range 0..9:=1;
Q27:Integer range 0..5:=2;
K27:constant Integer:=P27;
T27:String:="ab";
U27:String:=T27;
begin
P27:=(9-P27);
Q27:=K27;
T27:=U27;
Silver_IO.Put_Line(Integer'Image(P27));
U27:=T27;
Q27:=(5-Q27);
P27:=Q27;
T27:="cd";
Q27:=K27;
P27:=K27;
Silver_IO.Put_Line(T27&U27);
end Main;
