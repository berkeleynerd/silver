with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P74:Integer range 0..9:=1;
Q74:Integer range 0..5:=2;
K74:constant Integer:=P74;
T74:String:="ab";
U74:String:=T74;
begin
P74:=(9-P74);
Q74:=K74;
T74:=U74;
Silver_IO.Put_Line(Integer'Image(P74));
U74:=T74;
Q74:=(5-Q74);
P74:=Q74;
T74:="cd";
Q74:=K74;
P74:=K74;
Silver_IO.Put_Line(T74&U74);
end Main;
