with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P72:Integer range 0..9:=1;
Q72:Integer range 0..5:=2;
K72:constant Integer:=P72;
T72:String:="ab";
U72:String:=T72;
begin
P72:=(9-P72);
Q72:=K72;
T72:=U72;
Silver_IO.Put_Line(Integer'Image(P72));
U72:=T72;
Q72:=(5-Q72);
P72:=Q72;
T72:="cd";
Q72:=K72;
P72:=K72;
Silver_IO.Put_Line(T72&U72);
end Main;
