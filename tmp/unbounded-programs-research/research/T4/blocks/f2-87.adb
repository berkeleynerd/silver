with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P87:Integer range 0..9:=1;
Q87:Integer range 0..5:=2;
K87:constant Integer:=P87;
T87:String:="ab";
U87:String:=T87;
begin
P87:=(9-P87);
Q87:=K87;
T87:=U87;
Silver_IO.Put_Line(Integer'Image(P87));
U87:=T87;
Q87:=(5-Q87);
P87:=Q87;
T87:="cd";
Q87:=K87;
P87:=K87;
Silver_IO.Put_Line(T87&U87);
end Main;
