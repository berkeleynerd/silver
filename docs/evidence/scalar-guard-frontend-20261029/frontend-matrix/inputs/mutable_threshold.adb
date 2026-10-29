with Silver_IO;procedure Main is pragma SPARK_Mode(On);Y:Integer:=99;X:Integer:=0;R:Integer range 0..9:=0;begin Y:=99;if X>=0 and then X<=9 then if X=Y then R:=X;end if;end if;end Main;
