with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P35:Integer range 0..9:=1;
Q35:Integer range 0..5:=2;
K35:constant Integer:=P35;
T35:String:="ab";
U35:String:=T35;
begin
P35:=(9-P35);
Q35:=K35;
T35:=U35;
Silver_IO.Put_Line(Integer'Image(P35));
U35:=T35;
Q35:=(5-Q35);
P35:=Q35;
T35:="cd";
Q35:=K35;
P35:=K35;
Silver_IO.Put_Line(T35&U35);
end Main;
