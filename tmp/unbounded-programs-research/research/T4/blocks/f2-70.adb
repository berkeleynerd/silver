with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P70:Integer range 0..9:=1;
Q70:Integer range 0..5:=2;
K70:constant Integer:=P70;
T70:String:="ab";
U70:String:=T70;
begin
P70:=(9-P70);
Q70:=K70;
T70:=U70;
Silver_IO.Put_Line(Integer'Image(P70));
U70:=T70;
Q70:=(5-Q70);
P70:=Q70;
T70:="cd";
Q70:=K70;
P70:=K70;
Silver_IO.Put_Line(T70&U70);
end Main;
