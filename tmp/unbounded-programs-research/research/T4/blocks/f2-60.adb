with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P60:Integer range 0..9:=1;
Q60:Integer range 0..5:=2;
K60:constant Integer:=P60;
T60:String:="ab";
U60:String:=T60;
begin
P60:=(9-P60);
Q60:=K60;
T60:=U60;
Silver_IO.Put_Line(Integer'Image(P60));
U60:=T60;
Q60:=(5-Q60);
P60:=Q60;
T60:="cd";
Q60:=K60;
P60:=K60;
Silver_IO.Put_Line(T60&U60);
end Main;
