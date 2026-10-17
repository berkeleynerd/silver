with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P48:Integer range 0..9:=1;
Q48:Integer range 0..5:=2;
K48:constant Integer:=P48;
T48:String:="ab";
U48:String:=T48;
begin
P48:=(9-P48);
Q48:=K48;
T48:=U48;
Silver_IO.Put_Line(Integer'Image(P48));
U48:=T48;
Q48:=(5-Q48);
P48:=Q48;
T48:="cd";
Q48:=K48;
P48:=K48;
Silver_IO.Put_Line(T48&U48);
end Main;
