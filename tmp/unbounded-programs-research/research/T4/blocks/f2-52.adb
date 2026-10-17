with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P52:Integer range 0..9:=1;
Q52:Integer range 0..5:=2;
K52:constant Integer:=P52;
T52:String:="ab";
U52:String:=T52;
begin
P52:=(9-P52);
Q52:=K52;
T52:=U52;
Silver_IO.Put_Line(Integer'Image(P52));
U52:=T52;
Q52:=(5-Q52);
P52:=Q52;
T52:="cd";
Q52:=K52;
P52:=K52;
Silver_IO.Put_Line(T52&U52);
end Main;
