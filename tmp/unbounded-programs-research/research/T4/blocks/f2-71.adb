with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P71:Integer range 0..9:=1;
Q71:Integer range 0..5:=2;
K71:constant Integer:=P71;
T71:String:="ab";
U71:String:=T71;
begin
P71:=(9-P71);
Q71:=K71;
T71:=U71;
Silver_IO.Put_Line(Integer'Image(P71));
U71:=T71;
Q71:=(5-Q71);
P71:=Q71;
T71:="cd";
Q71:=K71;
P71:=K71;
Silver_IO.Put_Line(T71&U71);
end Main;
