with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P37:Integer range 0..9:=1;
Q37:Integer range 0..5:=2;
K37:constant Integer:=P37;
T37:String:="ab";
U37:String:=T37;
begin
P37:=(9-P37);
Q37:=K37;
T37:=U37;
Silver_IO.Put_Line(Integer'Image(P37));
U37:=T37;
Q37:=(5-Q37);
P37:=Q37;
T37:="cd";
Q37:=K37;
P37:=K37;
Silver_IO.Put_Line(T37&U37);
end Main;
