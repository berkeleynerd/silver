with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P26:Integer range 0..9:=1;
Q26:Integer range 0..5:=2;
K26:constant Integer:=P26;
T26:String:="ab";
U26:String:=T26;
begin
P26:=(9-P26);
Q26:=K26;
T26:=U26;
Silver_IO.Put_Line(Integer'Image(P26));
U26:=T26;
Q26:=(5-Q26);
P26:=Q26;
T26:="cd";
Q26:=K26;
P26:=K26;
Silver_IO.Put_Line(T26&U26);
end Main;
