with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P68:Integer range 0..9:=1;
Q68:Integer range 0..5:=2;
K68:constant Integer:=P68;
T68:String:="ab";
U68:String:=T68;
begin
P68:=(9-P68);
Q68:=K68;
T68:=U68;
Silver_IO.Put_Line(Integer'Image(P68));
U68:=T68;
Q68:=(5-Q68);
P68:=Q68;
T68:="cd";
Q68:=K68;
P68:=K68;
Silver_IO.Put_Line(T68&U68);
end Main;
