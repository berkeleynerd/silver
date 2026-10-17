with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P56:Integer range 0..9:=1;
Q56:Integer range 0..5:=2;
K56:constant Integer:=P56;
T56:String:="ab";
U56:String:=T56;
begin
P56:=(9-P56);
Q56:=K56;
T56:=U56;
Silver_IO.Put_Line(Integer'Image(P56));
U56:=T56;
Q56:=(5-Q56);
P56:=Q56;
T56:="cd";
Q56:=K56;
P56:=K56;
Silver_IO.Put_Line(T56&U56);
end Main;
