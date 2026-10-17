with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P23:Integer range 0..9:=1;
Q23:Integer range 0..5:=2;
K23:constant Integer:=P23;
T23:String:="ab";
U23:String:=T23;
begin
P23:=(9-P23);
Q23:=K23;
T23:=U23;
Silver_IO.Put_Line(Integer'Image(P23));
U23:=T23;
Q23:=(5-Q23);
P23:=Q23;
T23:="cd";
Q23:=K23;
P23:=K23;
Silver_IO.Put_Line(T23&U23);
end Main;
