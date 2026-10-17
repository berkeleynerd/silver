with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P96:Integer range 0..9:=1;
Q96:Integer range 0..5:=2;
K96:constant Integer:=P96;
T96:String:="ab";
U96:String:=T96;
begin
P96:=(9-P96);
Q96:=K96;
T96:=U96;
Silver_IO.Put_Line(Integer'Image(P96));
U96:=T96;
Q96:=(5-Q96);
P96:=Q96;
T96:="cd";
Q96:=K96;
P96:=K96;
Silver_IO.Put_Line(T96&U96);
end Main;
