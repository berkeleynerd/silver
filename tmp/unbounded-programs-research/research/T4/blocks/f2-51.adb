with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P51:Integer range 0..9:=1;
Q51:Integer range 0..5:=2;
K51:constant Integer:=P51;
T51:String:="ab";
U51:String:=T51;
begin
P51:=(9-P51);
Q51:=K51;
T51:=U51;
Silver_IO.Put_Line(Integer'Image(P51));
U51:=T51;
Q51:=(5-Q51);
P51:=Q51;
T51:="cd";
Q51:=K51;
P51:=K51;
Silver_IO.Put_Line(T51&U51);
end Main;
