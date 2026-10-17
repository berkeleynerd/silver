with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P81:Integer range 0..9:=1;
Q81:Integer range 0..5:=2;
K81:constant Integer:=P81;
T81:String:="ab";
U81:String:=T81;
begin
P81:=(9-P81);
Q81:=K81;
T81:=U81;
Silver_IO.Put_Line(Integer'Image(P81));
U81:=T81;
Q81:=(5-Q81);
P81:=Q81;
T81:="cd";
Q81:=K81;
P81:=K81;
Silver_IO.Put_Line(T81&U81);
end Main;
