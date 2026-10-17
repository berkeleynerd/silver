with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P86:Integer range 0..9:=1;
Q86:Integer range 0..5:=2;
K86:constant Integer:=P86;
T86:String:="ab";
U86:String:=T86;
begin
P86:=(9-P86);
Q86:=K86;
T86:=U86;
Silver_IO.Put_Line(Integer'Image(P86));
U86:=T86;
Q86:=(5-Q86);
P86:=Q86;
T86:="cd";
Q86:=K86;
P86:=K86;
Silver_IO.Put_Line(T86&U86);
end Main;
