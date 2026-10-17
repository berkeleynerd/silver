with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P54:Integer range 0..9:=1;
Q54:Integer range 0..5:=2;
K54:constant Integer:=P54;
T54:String:="ab";
U54:String:=T54;
begin
P54:=(9-P54);
Q54:=K54;
T54:=U54;
Silver_IO.Put_Line(Integer'Image(P54));
U54:=T54;
Q54:=(5-Q54);
P54:=Q54;
T54:="cd";
Q54:=K54;
P54:=K54;
Silver_IO.Put_Line(T54&U54);
end Main;
