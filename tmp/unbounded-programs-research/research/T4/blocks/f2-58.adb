with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P58:Integer range 0..9:=1;
Q58:Integer range 0..5:=2;
K58:constant Integer:=P58;
T58:String:="ab";
U58:String:=T58;
begin
P58:=(9-P58);
Q58:=K58;
T58:=U58;
Silver_IO.Put_Line(Integer'Image(P58));
U58:=T58;
Q58:=(5-Q58);
P58:=Q58;
T58:="cd";
Q58:=K58;
P58:=K58;
Silver_IO.Put_Line(T58&U58);
end Main;
