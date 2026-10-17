with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P29:Integer range 0..9:=1;
Q29:Integer range 0..5:=2;
K29:constant Integer:=P29;
T29:String:="ab";
U29:String:=T29;
begin
P29:=(9-P29);
Q29:=K29;
T29:=U29;
Silver_IO.Put_Line(Integer'Image(P29));
U29:=T29;
Q29:=(5-Q29);
P29:=Q29;
T29:="cd";
Q29:=K29;
P29:=K29;
Silver_IO.Put_Line(T29&U29);
end Main;
