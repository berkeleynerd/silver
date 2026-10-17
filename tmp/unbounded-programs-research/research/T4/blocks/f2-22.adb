with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P22:Integer range 0..9:=1;
Q22:Integer range 0..5:=2;
K22:constant Integer:=P22;
T22:String:="ab";
U22:String:=T22;
begin
P22:=(9-P22);
Q22:=K22;
T22:=U22;
Silver_IO.Put_Line(Integer'Image(P22));
U22:=T22;
Q22:=(5-Q22);
P22:=Q22;
T22:="cd";
Q22:=K22;
P22:=K22;
Silver_IO.Put_Line(T22&U22);
end Main;
