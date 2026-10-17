with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P92:Integer range 0..9:=1;
Q92:Integer range 0..5:=2;
K92:constant Integer:=P92;
T92:String:="ab";
U92:String:=T92;
begin
P92:=(9-P92);
Q92:=K92;
T92:=U92;
Silver_IO.Put_Line(Integer'Image(P92));
U92:=T92;
Q92:=(5-Q92);
P92:=Q92;
T92:="cd";
Q92:=K92;
P92:=K92;
Silver_IO.Put_Line(T92&U92);
end Main;
