with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P20:Integer range 0..9:=1;
Q20:Integer range 0..5:=2;
K20:constant Integer:=P20;
T20:String:="ab";
U20:String:=T20;
begin
P20:=(9-P20);
Q20:=K20;
T20:=U20;
Silver_IO.Put_Line(Integer'Image(P20));
U20:=T20;
Q20:=(5-Q20);
P20:=Q20;
T20:="cd";
Q20:=K20;
P20:=K20;
Silver_IO.Put_Line(T20&U20);
end Main;
