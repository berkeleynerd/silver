with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P19:Integer range 0..9:=1;
Q19:Integer range 0..5:=2;
K19:constant Integer:=P19;
T19:String:="ab";
U19:String:=T19;
begin
P19:=(9-P19);
Q19:=K19;
T19:=U19;
Silver_IO.Put_Line(Integer'Image(P19));
U19:=T19;
Q19:=(5-Q19);
P19:=Q19;
T19:="cd";
Q19:=K19;
P19:=K19;
Silver_IO.Put_Line(T19&U19);
end Main;
