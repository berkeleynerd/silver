with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P75:Integer range 0..9:=1;
Q75:Integer range 0..5:=2;
K75:constant Integer:=P75;
T75:String:="ab";
U75:String:=T75;
begin
P75:=(9-P75);
Q75:=K75;
T75:=U75;
Silver_IO.Put_Line(Integer'Image(P75));
U75:=T75;
Q75:=(5-Q75);
P75:=Q75;
T75:="cd";
Q75:=K75;
P75:=K75;
Silver_IO.Put_Line(T75&U75);
end Main;
