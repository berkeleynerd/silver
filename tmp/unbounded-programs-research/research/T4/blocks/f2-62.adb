with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P62:Integer range 0..9:=1;
Q62:Integer range 0..5:=2;
K62:constant Integer:=P62;
T62:String:="ab";
U62:String:=T62;
begin
P62:=(9-P62);
Q62:=K62;
T62:=U62;
Silver_IO.Put_Line(Integer'Image(P62));
U62:=T62;
Q62:=(5-Q62);
P62:=Q62;
T62:="cd";
Q62:=K62;
P62:=K62;
Silver_IO.Put_Line(T62&U62);
end Main;
