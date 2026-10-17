with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P30:Integer range 0..9:=1;
Q30:Integer range 0..5:=2;
K30:constant Integer:=P30;
T30:String:="ab";
U30:String:=T30;
begin
P30:=(9-P30);
Q30:=K30;
T30:=U30;
Silver_IO.Put_Line(Integer'Image(P30));
U30:=T30;
Q30:=(5-Q30);
P30:=Q30;
T30:="cd";
Q30:=K30;
P30:=K30;
Silver_IO.Put_Line(T30&U30);
end Main;
