with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P18:Integer range 0..9:=1;
Q18:Integer range 0..5:=2;
K18:constant Integer:=P18;
T18:String:="ab";
U18:String:=T18;
begin
P18:=(9-P18);
Q18:=K18;
T18:=U18;
Silver_IO.Put_Line(Integer'Image(P18));
U18:=T18;
Q18:=(5-Q18);
P18:=Q18;
T18:="cd";
Q18:=K18;
P18:=K18;
Silver_IO.Put_Line(T18&U18);
end Main;
