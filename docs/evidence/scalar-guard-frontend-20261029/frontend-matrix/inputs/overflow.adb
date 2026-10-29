with Silver_IO;procedure Main is pragma SPARK_Mode(On);X:Integer:=0;begin if X>=-2 and then X<=-1 then if X=99 then X:=(X + 2147483647);end if;end if;end Main;
