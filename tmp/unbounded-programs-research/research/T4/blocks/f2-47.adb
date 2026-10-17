with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P47:Integer range 0..9:=1;
Q47:Integer range 0..5:=2;
K47:constant Integer:=P47;
T47:String:="ab";
U47:String:=T47;
begin
P47:=(9-P47);
Q47:=K47;
T47:=U47;
Silver_IO.Put_Line(Integer'Image(P47));
U47:=T47;
Q47:=(5-Q47);
P47:=Q47;
T47:="cd";
Q47:=K47;
P47:=K47;
Silver_IO.Put_Line(T47&U47);
end Main;
