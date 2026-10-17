with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P14:Integer range 0..9:=1;
Q14:Integer range 0..5:=2;
K14:constant Integer:=P14;
T14:String:="ab";
U14:String:=T14;
begin
P14:=(9-P14);
Q14:=K14;
T14:=U14;
Silver_IO.Put_Line(Integer'Image(P14));
U14:=T14;
Q14:=(5-Q14);
P14:=Q14;
T14:="cd";
Q14:=K14;
P14:=K14;
Silver_IO.Put_Line(T14&U14);
end Main;
