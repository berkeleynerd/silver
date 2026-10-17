with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P88:Integer range 0..9:=1;
Q88:Integer range 0..5:=2;
K88:constant Integer:=P88;
T88:String:="ab";
U88:String:=T88;
begin
P88:=(9-P88);
Q88:=K88;
T88:=U88;
Silver_IO.Put_Line(Integer'Image(P88));
U88:=T88;
Q88:=(5-Q88);
P88:=Q88;
T88:="cd";
Q88:=K88;
P88:=K88;
Silver_IO.Put_Line(T88&U88);
end Main;
