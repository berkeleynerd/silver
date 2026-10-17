with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P40:Integer range 0..9:=1;
Q40:Integer range 0..5:=2;
K40:constant Integer:=P40;
T40:String:="ab";
U40:String:=T40;
begin
P40:=(9-P40);
Q40:=K40;
T40:=U40;
Silver_IO.Put_Line(Integer'Image(P40));
U40:=T40;
Q40:=(5-Q40);
P40:=Q40;
T40:="cd";
Q40:=K40;
P40:=K40;
Silver_IO.Put_Line(T40&U40);
end Main;
