with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P95:Integer range 0..9:=1;
Q95:Integer range 0..5:=2;
K95:constant Integer:=P95;
T95:String:="ab";
U95:String:=T95;
begin
P95:=(9-P95);
Q95:=K95;
T95:=U95;
Silver_IO.Put_Line(Integer'Image(P95));
U95:=T95;
Q95:=(5-Q95);
P95:=Q95;
T95:="cd";
Q95:=K95;
P95:=K95;
Silver_IO.Put_Line(T95&U95);
end Main;
