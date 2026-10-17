with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P0:Integer range 0..9:=1;
Q0:Integer range 0..5:=2;
K0:constant Integer:=P0;
T0:String:="ab";
U0:String:=T0;
begin
P0:=(9-P0);
Q0:=K0;
T0:=U0;
Silver_IO.Put_Line(Integer'Image(P0));
U0:=T0;
Q0:=(5-Q0);
P0:=Q0;
T0:="cd";
Q0:=K0;
P0:=K0;
Silver_IO.Put_Line(T0&U0);
end Main;
