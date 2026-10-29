with Silver_IO;procedure Main is pragma SPARK_Mode(On);X:Integer:=0;R:Integer range 0..9:=0;begin if X>=1 and then X<=9 then if X=0 then R:=(1 / X);end if;end if;end Main;
