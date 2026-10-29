with Silver_IO;procedure Main is pragma SPARK_Mode(On);X:Integer:=2147483647;R:Integer:=0;begin R:=(X+1);Silver_IO.Put_Line(Integer'Image(R));end Main;
