with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P38:Integer range 0..9:=1;
Q38:Integer range 0..5:=2;
K38:constant Integer:=P38;
T38:String:="ab";
U38:String:=T38;
begin
P38:=(9-P38);
Q38:=K38;
T38:=U38;
Silver_IO.Put_Line(Integer'Image(P38));
U38:=T38;
Q38:=(5-Q38);
P38:=Q38;
T38:="cd";
Q38:=K38;
P38:=K38;
Silver_IO.Put_Line(T38&U38);
end Main;
