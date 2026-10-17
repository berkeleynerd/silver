with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P9:Integer range 0..9:=1;
Q9:Integer range 0..5:=2;
K9:constant Integer:=P9;
T9:String:="ab";
U9:String:=T9;
begin
P9:=(9-P9);
Q9:=K9;
T9:=U9;
Silver_IO.Put_Line(Integer'Image(P9));
U9:=T9;
Q9:=(5-Q9);
P9:=Q9;
T9:="cd";
Q9:=K9;
P9:=K9;
Silver_IO.Put_Line(T9&U9);
end Main;
