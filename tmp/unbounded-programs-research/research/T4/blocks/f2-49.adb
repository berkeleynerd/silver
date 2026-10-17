with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P49:Integer range 0..9:=1;
Q49:Integer range 0..5:=2;
K49:constant Integer:=P49;
T49:String:="ab";
U49:String:=T49;
begin
P49:=(9-P49);
Q49:=K49;
T49:=U49;
Silver_IO.Put_Line(Integer'Image(P49));
U49:=T49;
Q49:=(5-Q49);
P49:=Q49;
T49:="cd";
Q49:=K49;
P49:=K49;
Silver_IO.Put_Line(T49&U49);
end Main;
