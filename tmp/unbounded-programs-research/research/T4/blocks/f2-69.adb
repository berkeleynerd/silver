with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P69:Integer range 0..9:=1;
Q69:Integer range 0..5:=2;
K69:constant Integer:=P69;
T69:String:="ab";
U69:String:=T69;
begin
P69:=(9-P69);
Q69:=K69;
T69:=U69;
Silver_IO.Put_Line(Integer'Image(P69));
U69:=T69;
Q69:=(5-Q69);
P69:=Q69;
T69:="cd";
Q69:=K69;
P69:=K69;
Silver_IO.Put_Line(T69&U69);
end Main;
