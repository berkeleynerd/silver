with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P24:Integer range 0..9:=1;
Q24:Integer range 0..5:=2;
K24:constant Integer:=P24;
T24:String:="ab";
U24:String:=T24;
begin
P24:=(9-P24);
Q24:=K24;
T24:=U24;
Silver_IO.Put_Line(Integer'Image(P24));
U24:=T24;
Q24:=(5-Q24);
P24:=Q24;
T24:="cd";
Q24:=K24;
P24:=K24;
Silver_IO.Put_Line(T24&U24);
end Main;
