with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P78:Integer range 0..9:=1;
Q78:Integer range 0..5:=2;
K78:constant Integer:=P78;
T78:String:="ab";
U78:String:=T78;
begin
P78:=(9-P78);
Q78:=K78;
T78:=U78;
Silver_IO.Put_Line(Integer'Image(P78));
U78:=T78;
Q78:=(5-Q78);
P78:=Q78;
T78:="cd";
Q78:=K78;
P78:=K78;
Silver_IO.Put_Line(T78&U78);
end Main;
