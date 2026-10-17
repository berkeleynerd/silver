with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P31:Integer range 0..9:=1;
Q31:Integer range 0..5:=2;
K31:constant Integer:=P31;
T31:String:="ab";
U31:String:=T31;
begin
P31:=(9-P31);
Q31:=K31;
T31:=U31;
Silver_IO.Put_Line(Integer'Image(P31));
U31:=T31;
Q31:=(5-Q31);
P31:=Q31;
T31:="cd";
Q31:=K31;
P31:=K31;
Silver_IO.Put_Line(T31&U31);
end Main;
