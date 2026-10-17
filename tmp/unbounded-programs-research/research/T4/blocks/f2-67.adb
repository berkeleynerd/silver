with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P67:Integer range 0..9:=1;
Q67:Integer range 0..5:=2;
K67:constant Integer:=P67;
T67:String:="ab";
U67:String:=T67;
begin
P67:=(9-P67);
Q67:=K67;
T67:=U67;
Silver_IO.Put_Line(Integer'Image(P67));
U67:=T67;
Q67:=(5-Q67);
P67:=Q67;
T67:="cd";
Q67:=K67;
P67:=K67;
Silver_IO.Put_Line(T67&U67);
end Main;
