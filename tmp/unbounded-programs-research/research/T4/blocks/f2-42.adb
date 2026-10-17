with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P42:Integer range 0..9:=1;
Q42:Integer range 0..5:=2;
K42:constant Integer:=P42;
T42:String:="ab";
U42:String:=T42;
begin
P42:=(9-P42);
Q42:=K42;
T42:=U42;
Silver_IO.Put_Line(Integer'Image(P42));
U42:=T42;
Q42:=(5-Q42);
P42:=Q42;
T42:="cd";
Q42:=K42;
P42:=K42;
Silver_IO.Put_Line(T42&U42);
end Main;
