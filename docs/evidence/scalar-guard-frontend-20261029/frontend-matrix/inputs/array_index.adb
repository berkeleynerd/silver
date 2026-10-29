with Silver_IO;procedure Main is pragma SPARK_Mode(On);A:constant array(1..2)of Integer:=(7,8);X:Integer:=0;R:Integer:=0;begin if X>=1 and then X<=2 then if X=99 then R:=A(X);end if;end if;end Main;
