with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P28:Integer range 0..9:=1;
Q28:Integer range 0..5:=2;
K28:constant Integer:=P28;
T28:String:="ab";
U28:String:=T28;
begin
P28:=(9-P28);
Q28:=K28;
T28:=U28;
Silver_IO.Put_Line(Integer'Image(P28));
U28:=T28;
Q28:=(5-Q28);
P28:=Q28;
T28:="cd";
Q28:=K28;
P28:=K28;
Silver_IO.Put_Line(T28&U28);
end Main;
