with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P15:Integer range 0..9:=1;
Q15:Integer range 0..5:=2;
K15:constant Integer:=P15;
T15:String:="ab";
U15:String:=T15;
begin
P15:=(9-P15);
Q15:=K15;
T15:=U15;
Silver_IO.Put_Line(Integer'Image(P15));
U15:=T15;
Q15:=(5-Q15);
P15:=Q15;
T15:="cd";
Q15:=K15;
P15:=K15;
Silver_IO.Put_Line(T15&U15);
end Main;
