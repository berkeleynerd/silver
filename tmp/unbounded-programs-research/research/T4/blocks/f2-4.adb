with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P4:Integer range 0..9:=1;
Q4:Integer range 0..5:=2;
K4:constant Integer:=P4;
T4:String:="ab";
U4:String:=T4;
begin
P4:=(9-P4);
Q4:=K4;
T4:=U4;
Silver_IO.Put_Line(Integer'Image(P4));
U4:=T4;
Q4:=(5-Q4);
P4:=Q4;
T4:="cd";
Q4:=K4;
P4:=K4;
Silver_IO.Put_Line(T4&U4);
end Main;
