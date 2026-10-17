with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P36:Integer range 0..9:=1;
Q36:Integer range 0..5:=2;
K36:constant Integer:=P36;
T36:String:="ab";
U36:String:=T36;
begin
P36:=(9-P36);
Q36:=K36;
T36:=U36;
Silver_IO.Put_Line(Integer'Image(P36));
U36:=T36;
Q36:=(5-Q36);
P36:=Q36;
T36:="cd";
Q36:=K36;
P36:=K36;
Silver_IO.Put_Line(T36&U36);
end Main;
