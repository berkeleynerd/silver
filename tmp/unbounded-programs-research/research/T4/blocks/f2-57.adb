with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P57:Integer range 0..9:=1;
Q57:Integer range 0..5:=2;
K57:constant Integer:=P57;
T57:String:="ab";
U57:String:=T57;
begin
P57:=(9-P57);
Q57:=K57;
T57:=U57;
Silver_IO.Put_Line(Integer'Image(P57));
U57:=T57;
Q57:=(5-Q57);
P57:=Q57;
T57:="cd";
Q57:=K57;
P57:=K57;
Silver_IO.Put_Line(T57&U57);
end Main;
