with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P55:Integer range 0..9:=1;
Q55:Integer range 0..5:=2;
K55:constant Integer:=P55;
T55:String:="ab";
U55:String:=T55;
begin
P55:=(9-P55);
Q55:=K55;
T55:=U55;
Silver_IO.Put_Line(Integer'Image(P55));
U55:=T55;
Q55:=(5-Q55);
P55:=Q55;
T55:="cd";
Q55:=K55;
P55:=K55;
Silver_IO.Put_Line(T55&U55);
end Main;
