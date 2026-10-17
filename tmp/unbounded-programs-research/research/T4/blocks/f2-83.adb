with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P83:Integer range 0..9:=1;
Q83:Integer range 0..5:=2;
K83:constant Integer:=P83;
T83:String:="ab";
U83:String:=T83;
begin
P83:=(9-P83);
Q83:=K83;
T83:=U83;
Silver_IO.Put_Line(Integer'Image(P83));
U83:=T83;
Q83:=(5-Q83);
P83:=Q83;
T83:="cd";
Q83:=K83;
P83:=K83;
Silver_IO.Put_Line(T83&U83);
end Main;
