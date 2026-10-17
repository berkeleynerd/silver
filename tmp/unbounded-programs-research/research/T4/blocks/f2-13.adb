with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P13:Integer range 0..9:=1;
Q13:Integer range 0..5:=2;
K13:constant Integer:=P13;
T13:String:="ab";
U13:String:=T13;
begin
P13:=(9-P13);
Q13:=K13;
T13:=U13;
Silver_IO.Put_Line(Integer'Image(P13));
U13:=T13;
Q13:=(5-Q13);
P13:=Q13;
T13:="cd";
Q13:=K13;
P13:=K13;
Silver_IO.Put_Line(T13&U13);
end Main;
