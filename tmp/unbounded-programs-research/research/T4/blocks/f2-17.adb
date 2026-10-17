with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P17:Integer range 0..9:=1;
Q17:Integer range 0..5:=2;
K17:constant Integer:=P17;
T17:String:="ab";
U17:String:=T17;
begin
P17:=(9-P17);
Q17:=K17;
T17:=U17;
Silver_IO.Put_Line(Integer'Image(P17));
U17:=T17;
Q17:=(5-Q17);
P17:=Q17;
T17:="cd";
Q17:=K17;
P17:=K17;
Silver_IO.Put_Line(T17&U17);
end Main;
