with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P94:Integer range 0..9:=1;
Q94:Integer range 0..5:=2;
K94:constant Integer:=P94;
T94:String:="ab";
U94:String:=T94;
begin
P94:=(9-P94);
Q94:=K94;
T94:=U94;
Silver_IO.Put_Line(Integer'Image(P94));
U94:=T94;
Q94:=(5-Q94);
P94:=Q94;
T94:="cd";
Q94:=K94;
P94:=K94;
Silver_IO.Put_Line(T94&U94);
end Main;
