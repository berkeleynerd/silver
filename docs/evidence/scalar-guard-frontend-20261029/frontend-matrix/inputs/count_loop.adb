with Silver_IO;procedure Main is pragma SPARK_Mode(On);X:Integer:=0;R:Integer range 0..9:=0;begin for I in 1..1 loop if X>=0 and then X<=9 then if X=99 then R:=X;end if;end if;end loop;end Main;
