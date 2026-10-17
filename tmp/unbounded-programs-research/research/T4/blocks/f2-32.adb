with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P32:Integer range 0..9:=1;
Q32:Integer range 0..5:=2;
K32:constant Integer:=P32;
T32:String:="ab";
U32:String:=T32;
begin
P32:=(9-P32);
Q32:=K32;
T32:=U32;
Silver_IO.Put_Line(Integer'Image(P32));
U32:=T32;
Q32:=(5-Q32);
P32:=Q32;
T32:="cd";
Q32:=K32;
P32:=K32;
Silver_IO.Put_Line(T32&U32);
end Main;
