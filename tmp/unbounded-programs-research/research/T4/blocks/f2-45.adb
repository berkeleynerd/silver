with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P45:Integer range 0..9:=1;
Q45:Integer range 0..5:=2;
K45:constant Integer:=P45;
T45:String:="ab";
U45:String:=T45;
begin
P45:=(9-P45);
Q45:=K45;
T45:=U45;
Silver_IO.Put_Line(Integer'Image(P45));
U45:=T45;
Q45:=(5-Q45);
P45:=Q45;
T45:="cd";
Q45:=K45;
P45:=K45;
Silver_IO.Put_Line(T45&U45);
end Main;
