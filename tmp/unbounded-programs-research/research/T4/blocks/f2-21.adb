with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P21:Integer range 0..9:=1;
Q21:Integer range 0..5:=2;
K21:constant Integer:=P21;
T21:String:="ab";
U21:String:=T21;
begin
P21:=(9-P21);
Q21:=K21;
T21:=U21;
Silver_IO.Put_Line(Integer'Image(P21));
U21:=T21;
Q21:=(5-Q21);
P21:=Q21;
T21:="cd";
Q21:=K21;
P21:=K21;
Silver_IO.Put_Line(T21&U21);
end Main;
