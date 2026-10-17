with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P64:Integer range 0..9:=1;
Q64:Integer range 0..5:=2;
K64:constant Integer:=P64;
T64:String:="ab";
U64:String:=T64;
begin
P64:=(9-P64);
Q64:=K64;
T64:=U64;
Silver_IO.Put_Line(Integer'Image(P64));
U64:=T64;
Q64:=(5-Q64);
P64:=Q64;
T64:="cd";
Q64:=K64;
P64:=K64;
Silver_IO.Put_Line(T64&U64);
end Main;
