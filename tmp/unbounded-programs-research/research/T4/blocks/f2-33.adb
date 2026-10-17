with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P33:Integer range 0..9:=1;
Q33:Integer range 0..5:=2;
K33:constant Integer:=P33;
T33:String:="ab";
U33:String:=T33;
begin
P33:=(9-P33);
Q33:=K33;
T33:=U33;
Silver_IO.Put_Line(Integer'Image(P33));
U33:=T33;
Q33:=(5-Q33);
P33:=Q33;
T33:="cd";
Q33:=K33;
P33:=K33;
Silver_IO.Put_Line(T33&U33);
end Main;
