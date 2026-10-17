with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P97:Integer range 0..9:=1;
Q97:Integer range 0..5:=2;
K97:constant Integer:=P97;
T97:String:="ab";
U97:String:=T97;
begin
P97:=(9-P97);
Q97:=K97;
T97:=U97;
Silver_IO.Put_Line(Integer'Image(P97));
U97:=T97;
Q97:=(5-Q97);
P97:=Q97;
T97:="cd";
Q97:=K97;
P97:=K97;
Silver_IO.Put_Line(T97&U97);
end Main;
