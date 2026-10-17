with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P65:Integer range 0..9:=1;
Q65:Integer range 0..5:=2;
K65:constant Integer:=P65;
T65:String:="ab";
U65:String:=T65;
begin
P65:=(9-P65);
Q65:=K65;
T65:=U65;
Silver_IO.Put_Line(Integer'Image(P65));
U65:=T65;
Q65:=(5-Q65);
P65:=Q65;
T65:="cd";
Q65:=K65;
P65:=K65;
Silver_IO.Put_Line(T65&U65);
end Main;
