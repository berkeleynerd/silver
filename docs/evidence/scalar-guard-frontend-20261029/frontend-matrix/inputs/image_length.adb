with Silver_IO;procedure Main is pragma SPARK_Mode(On);X:Integer:=0;S:String:=" 0";begin if X>=0 and then X<=9 then if X=99 then S:=Integer'Image(X);end if;end if;end Main;
