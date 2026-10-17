with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P73:Integer range 0..9:=1;
Q73:Integer range 0..5:=2;
K73:constant Integer:=P73;
T73:String:="ab";
U73:String:=T73;
begin
P73:=(9-P73);
Q73:=K73;
T73:=U73;
Silver_IO.Put_Line(Integer'Image(P73));
U73:=T73;
Q73:=(5-Q73);
P73:=Q73;
T73:="cd";
Q73:=K73;
P73:=K73;
Silver_IO.Put_Line(T73&U73);
end Main;
