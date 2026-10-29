with Silver_IO;procedure Main is pragma SPARK_Mode(On);X:Integer:=0;R:Integer range 0..9:=0;begin if X>=0 and then X<=9 then if X/=99 or else X<0 then null;else R:=X;end if;end if;end Main;
