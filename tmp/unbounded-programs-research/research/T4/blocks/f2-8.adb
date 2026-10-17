with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P8:Integer range 0..9:=1;
Q8:Integer range 0..5:=2;
K8:constant Integer:=P8;
T8:String:="ab";
U8:String:=T8;
begin
P8:=(9-P8);
Q8:=K8;
T8:=U8;
Silver_IO.Put_Line(Integer'Image(P8));
U8:=T8;
Q8:=(5-Q8);
P8:=Q8;
T8:="cd";
Q8:=K8;
P8:=K8;
Silver_IO.Put_Line(T8&U8);
end Main;
