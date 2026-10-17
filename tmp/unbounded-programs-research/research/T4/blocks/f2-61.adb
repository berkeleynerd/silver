with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P61:Integer range 0..9:=1;
Q61:Integer range 0..5:=2;
K61:constant Integer:=P61;
T61:String:="ab";
U61:String:=T61;
begin
P61:=(9-P61);
Q61:=K61;
T61:=U61;
Silver_IO.Put_Line(Integer'Image(P61));
U61:=T61;
Q61:=(5-Q61);
P61:=Q61;
T61:="cd";
Q61:=K61;
P61:=K61;
Silver_IO.Put_Line(T61&U61);
end Main;
