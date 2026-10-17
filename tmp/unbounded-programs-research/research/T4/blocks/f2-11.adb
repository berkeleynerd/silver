with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P11:Integer range 0..9:=1;
Q11:Integer range 0..5:=2;
K11:constant Integer:=P11;
T11:String:="ab";
U11:String:=T11;
begin
P11:=(9-P11);
Q11:=K11;
T11:=U11;
Silver_IO.Put_Line(Integer'Image(P11));
U11:=T11;
Q11:=(5-Q11);
P11:=Q11;
T11:="cd";
Q11:=K11;
P11:=K11;
Silver_IO.Put_Line(T11&U11);
end Main;
