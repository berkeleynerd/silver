with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P91:Integer range 0..9:=1;
Q91:Integer range 0..5:=2;
K91:constant Integer:=P91;
T91:String:="ab";
U91:String:=T91;
begin
P91:=(9-P91);
Q91:=K91;
T91:=U91;
Silver_IO.Put_Line(Integer'Image(P91));
U91:=T91;
Q91:=(5-Q91);
P91:=Q91;
T91:="cd";
Q91:=K91;
P91:=K91;
Silver_IO.Put_Line(T91&U91);
end Main;
