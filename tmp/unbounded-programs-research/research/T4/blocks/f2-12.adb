with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P12:Integer range 0..9:=1;
Q12:Integer range 0..5:=2;
K12:constant Integer:=P12;
T12:String:="ab";
U12:String:=T12;
begin
P12:=(9-P12);
Q12:=K12;
T12:=U12;
Silver_IO.Put_Line(Integer'Image(P12));
U12:=T12;
Q12:=(5-Q12);
P12:=Q12;
T12:="cd";
Q12:=K12;
P12:=K12;
Silver_IO.Put_Line(T12&U12);
end Main;
