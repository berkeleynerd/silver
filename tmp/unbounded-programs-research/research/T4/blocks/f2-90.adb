with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P90:Integer range 0..9:=1;
Q90:Integer range 0..5:=2;
K90:constant Integer:=P90;
T90:String:="ab";
U90:String:=T90;
begin
P90:=(9-P90);
Q90:=K90;
T90:=U90;
Silver_IO.Put_Line(Integer'Image(P90));
U90:=T90;
Q90:=(5-Q90);
P90:=Q90;
T90:="cd";
Q90:=K90;
P90:=K90;
Silver_IO.Put_Line(T90&U90);
end Main;
