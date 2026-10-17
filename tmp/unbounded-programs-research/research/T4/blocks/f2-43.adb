with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P43:Integer range 0..9:=1;
Q43:Integer range 0..5:=2;
K43:constant Integer:=P43;
T43:String:="ab";
U43:String:=T43;
begin
P43:=(9-P43);
Q43:=K43;
T43:=U43;
Silver_IO.Put_Line(Integer'Image(P43));
U43:=T43;
Q43:=(5-Q43);
P43:=Q43;
T43:="cd";
Q43:=K43;
P43:=K43;
Silver_IO.Put_Line(T43&U43);
end Main;
