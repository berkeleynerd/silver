with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P63:Integer range 0..9:=1;
Q63:Integer range 0..5:=2;
K63:constant Integer:=P63;
T63:String:="ab";
U63:String:=T63;
begin
P63:=(9-P63);
Q63:=K63;
T63:=U63;
Silver_IO.Put_Line(Integer'Image(P63));
U63:=T63;
Q63:=(5-Q63);
P63:=Q63;
T63:="cd";
Q63:=K63;
P63:=K63;
Silver_IO.Put_Line(T63&U63);
end Main;
