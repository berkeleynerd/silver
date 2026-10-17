with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P39:Integer range 0..9:=1;
Q39:Integer range 0..5:=2;
K39:constant Integer:=P39;
T39:String:="ab";
U39:String:=T39;
begin
P39:=(9-P39);
Q39:=K39;
T39:=U39;
Silver_IO.Put_Line(Integer'Image(P39));
U39:=T39;
Q39:=(5-Q39);
P39:=Q39;
T39:="cd";
Q39:=K39;
P39:=K39;
Silver_IO.Put_Line(T39&U39);
end Main;
