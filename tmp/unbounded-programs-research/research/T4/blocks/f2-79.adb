with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P79:Integer range 0..9:=1;
Q79:Integer range 0..5:=2;
K79:constant Integer:=P79;
T79:String:="ab";
U79:String:=T79;
begin
P79:=(9-P79);
Q79:=K79;
T79:=U79;
Silver_IO.Put_Line(Integer'Image(P79));
U79:=T79;
Q79:=(5-Q79);
P79:=Q79;
T79:="cd";
Q79:=K79;
P79:=K79;
Silver_IO.Put_Line(T79&U79);
end Main;
