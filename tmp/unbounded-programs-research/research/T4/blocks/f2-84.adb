with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P84:Integer range 0..9:=1;
Q84:Integer range 0..5:=2;
K84:constant Integer:=P84;
T84:String:="ab";
U84:String:=T84;
begin
P84:=(9-P84);
Q84:=K84;
T84:=U84;
Silver_IO.Put_Line(Integer'Image(P84));
U84:=T84;
Q84:=(5-Q84);
P84:=Q84;
T84:="cd";
Q84:=K84;
P84:=K84;
Silver_IO.Put_Line(T84&U84);
end Main;
