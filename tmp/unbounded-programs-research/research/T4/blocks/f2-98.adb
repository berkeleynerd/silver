with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P98:Integer range 0..9:=1;
Q98:Integer range 0..5:=2;
K98:constant Integer:=P98;
T98:String:="ab";
U98:String:=T98;
begin
P98:=(9-P98);
Q98:=K98;
T98:=U98;
Silver_IO.Put_Line(Integer'Image(P98));
U98:=T98;
Q98:=(5-Q98);
P98:=Q98;
T98:="cd";
Q98:=K98;
P98:=K98;
Silver_IO.Put_Line(T98&U98);
end Main;
