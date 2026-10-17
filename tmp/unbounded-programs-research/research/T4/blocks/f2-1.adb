with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P1:Integer range 0..9:=1;
Q1:Integer range 0..5:=2;
K1:constant Integer:=P1;
T1:String:="ab";
U1:String:=T1;
begin
P1:=(9-P1);
Q1:=K1;
T1:=U1;
Silver_IO.Put_Line(Integer'Image(P1));
U1:=T1;
Q1:=(5-Q1);
P1:=Q1;
T1:="cd";
Q1:=K1;
P1:=K1;
Silver_IO.Put_Line(T1&U1);
end Main;
