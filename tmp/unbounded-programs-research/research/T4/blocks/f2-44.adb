with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P44:Integer range 0..9:=1;
Q44:Integer range 0..5:=2;
K44:constant Integer:=P44;
T44:String:="ab";
U44:String:=T44;
begin
P44:=(9-P44);
Q44:=K44;
T44:=U44;
Silver_IO.Put_Line(Integer'Image(P44));
U44:=T44;
Q44:=(5-Q44);
P44:=Q44;
T44:="cd";
Q44:=K44;
P44:=K44;
Silver_IO.Put_Line(T44&U44);
end Main;
