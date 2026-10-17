with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P82:Integer range 0..9:=1;
Q82:Integer range 0..5:=2;
K82:constant Integer:=P82;
T82:String:="ab";
U82:String:=T82;
begin
P82:=(9-P82);
Q82:=K82;
T82:=U82;
Silver_IO.Put_Line(Integer'Image(P82));
U82:=T82;
Q82:=(5-Q82);
P82:=Q82;
T82:="cd";
Q82:=K82;
P82:=K82;
Silver_IO.Put_Line(T82&U82);
end Main;
