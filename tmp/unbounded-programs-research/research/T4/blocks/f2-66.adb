with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P66:Integer range 0..9:=1;
Q66:Integer range 0..5:=2;
K66:constant Integer:=P66;
T66:String:="ab";
U66:String:=T66;
begin
P66:=(9-P66);
Q66:=K66;
T66:=U66;
Silver_IO.Put_Line(Integer'Image(P66));
U66:=T66;
Q66:=(5-Q66);
P66:=Q66;
T66:="cd";
Q66:=K66;
P66:=K66;
Silver_IO.Put_Line(T66&U66);
end Main;
