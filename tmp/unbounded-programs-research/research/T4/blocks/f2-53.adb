with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P53:Integer range 0..9:=1;
Q53:Integer range 0..5:=2;
K53:constant Integer:=P53;
T53:String:="ab";
U53:String:=T53;
begin
P53:=(9-P53);
Q53:=K53;
T53:=U53;
Silver_IO.Put_Line(Integer'Image(P53));
U53:=T53;
Q53:=(5-Q53);
P53:=Q53;
T53:="cd";
Q53:=K53;
P53:=K53;
Silver_IO.Put_Line(T53&U53);
end Main;
