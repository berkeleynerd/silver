with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P59:Integer range 0..9:=1;
Q59:Integer range 0..5:=2;
K59:constant Integer:=P59;
T59:String:="ab";
U59:String:=T59;
begin
P59:=(9-P59);
Q59:=K59;
T59:=U59;
Silver_IO.Put_Line(Integer'Image(P59));
U59:=T59;
Q59:=(5-Q59);
P59:=Q59;
T59:="cd";
Q59:=K59;
P59:=K59;
Silver_IO.Put_Line(T59&U59);
end Main;
