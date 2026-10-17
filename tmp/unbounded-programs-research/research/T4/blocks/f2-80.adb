with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P80:Integer range 0..9:=1;
Q80:Integer range 0..5:=2;
K80:constant Integer:=P80;
T80:String:="ab";
U80:String:=T80;
begin
P80:=(9-P80);
Q80:=K80;
T80:=U80;
Silver_IO.Put_Line(Integer'Image(P80));
U80:=T80;
Q80:=(5-Q80);
P80:=Q80;
T80:="cd";
Q80:=K80;
P80:=K80;
Silver_IO.Put_Line(T80&U80);
end Main;
