with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P7:Integer range 0..9:=1;
Q7:Integer range 0..5:=2;
K7:constant Integer:=P7;
T7:String:="ab";
U7:String:=T7;
begin
P7:=(9-P7);
Q7:=K7;
T7:=U7;
Silver_IO.Put_Line(Integer'Image(P7));
U7:=T7;
Q7:=(5-Q7);
P7:=Q7;
T7:="cd";
Q7:=K7;
P7:=K7;
Silver_IO.Put_Line(T7&U7);
end Main;
