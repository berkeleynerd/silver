with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P46:Integer range 0..9:=1;
Q46:Integer range 0..5:=2;
K46:constant Integer:=P46;
T46:String:="ab";
U46:String:=T46;
begin
P46:=(9-P46);
Q46:=K46;
T46:=U46;
Silver_IO.Put_Line(Integer'Image(P46));
U46:=T46;
Q46:=(5-Q46);
P46:=Q46;
T46:="cd";
Q46:=K46;
P46:=K46;
Silver_IO.Put_Line(T46&U46);
end Main;
