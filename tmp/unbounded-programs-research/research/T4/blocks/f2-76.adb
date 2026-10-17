with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P76:Integer range 0..9:=1;
Q76:Integer range 0..5:=2;
K76:constant Integer:=P76;
T76:String:="ab";
U76:String:=T76;
begin
P76:=(9-P76);
Q76:=K76;
T76:=U76;
Silver_IO.Put_Line(Integer'Image(P76));
U76:=T76;
Q76:=(5-Q76);
P76:=Q76;
T76:="cd";
Q76:=K76;
P76:=K76;
Silver_IO.Put_Line(T76&U76);
end Main;
