with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P10:Integer range 0..9:=1;
Q10:Integer range 0..5:=2;
K10:constant Integer:=P10;
T10:String:="ab";
U10:String:=T10;
begin
P10:=(9-P10);
Q10:=K10;
T10:=U10;
Silver_IO.Put_Line(Integer'Image(P10));
U10:=T10;
Q10:=(5-Q10);
P10:=Q10;
T10:="cd";
Q10:=K10;
P10:=K10;
Silver_IO.Put_Line(T10&U10);
end Main;
