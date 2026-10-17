with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P16:Integer range 0..9:=1;
Q16:Integer range 0..5:=2;
K16:constant Integer:=P16;
T16:String:="ab";
U16:String:=T16;
begin
P16:=(9-P16);
Q16:=K16;
T16:=U16;
Silver_IO.Put_Line(Integer'Image(P16));
U16:=T16;
Q16:=(5-Q16);
P16:=Q16;
T16:="cd";
Q16:=K16;
P16:=K16;
Silver_IO.Put_Line(T16&U16);
end Main;
