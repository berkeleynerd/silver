with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P5:Integer range 0..9:=1;
Q5:Integer range 0..5:=2;
K5:constant Integer:=P5;
T5:String:="ab";
U5:String:=T5;
begin
P5:=(9-P5);
Q5:=K5;
T5:=U5;
Silver_IO.Put_Line(Integer'Image(P5));
U5:=T5;
Q5:=(5-Q5);
P5:=Q5;
T5:="cd";
Q5:=K5;
P5:=K5;
Silver_IO.Put_Line(T5&U5);
end Main;
