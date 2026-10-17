with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P89:Integer range 0..9:=1;
Q89:Integer range 0..5:=2;
K89:constant Integer:=P89;
T89:String:="ab";
U89:String:=T89;
begin
P89:=(9-P89);
Q89:=K89;
T89:=U89;
Silver_IO.Put_Line(Integer'Image(P89));
U89:=T89;
Q89:=(5-Q89);
P89:=Q89;
T89:="cd";
Q89:=K89;
P89:=K89;
Silver_IO.Put_Line(T89&U89);
end Main;
