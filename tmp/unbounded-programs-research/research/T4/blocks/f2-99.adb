with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P99:Integer range 0..9:=1;
Q99:Integer range 0..5:=2;
K99:constant Integer:=P99;
T99:String:="ab";
U99:String:=T99;
begin
P99:=(9-P99);
Q99:=K99;
T99:=U99;
Silver_IO.Put_Line(Integer'Image(P99));
U99:=T99;
Q99:=(5-Q99);
P99:=Q99;
T99:="cd";
Q99:=K99;
P99:=K99;
Silver_IO.Put_Line(T99&U99);
end Main;
