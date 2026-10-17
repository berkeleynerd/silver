with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P41:Integer range 0..9:=1;
Q41:Integer range 0..5:=2;
K41:constant Integer:=P41;
T41:String:="ab";
U41:String:=T41;
begin
P41:=(9-P41);
Q41:=K41;
T41:=U41;
Silver_IO.Put_Line(Integer'Image(P41));
U41:=T41;
Q41:=(5-Q41);
P41:=Q41;
T41:="cd";
Q41:=K41;
P41:=K41;
Silver_IO.Put_Line(T41&U41);
end Main;
