with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P6:Integer range 0..9:=1;
Q6:Integer range 0..5:=2;
K6:constant Integer:=P6;
T6:String:="ab";
U6:String:=T6;
begin
P6:=(9-P6);
Q6:=K6;
T6:=U6;
Silver_IO.Put_Line(Integer'Image(P6));
U6:=T6;
Q6:=(5-Q6);
P6:=Q6;
T6:="cd";
Q6:=K6;
P6:=K6;
Silver_IO.Put_Line(T6&U6);
end Main;
