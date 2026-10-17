with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
P85:Integer range 0..9:=1;
Q85:Integer range 0..5:=2;
K85:constant Integer:=P85;
T85:String:="ab";
U85:String:=T85;
begin
P85:=(9-P85);
Q85:=K85;
T85:=U85;
Silver_IO.Put_Line(Integer'Image(P85));
U85:=T85;
Q85:=(5-Q85);
P85:=Q85;
T85:="cd";
Q85:=K85;
P85:=K85;
Silver_IO.Put_Line(T85&U85);
end Main;
