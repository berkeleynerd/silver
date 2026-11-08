with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   subtype Sign_Value is Integer range -1 .. 1;

   function Signum (X : in Integer) return Sign_Value is
      Result : Sign_Value := 0;
   begin
      if X < 0 then
         Result := -1;
      elsif X > 0 then
         Result := 1;
      else
         Result := 0;
      end if;
      return Result;
   end Signum;

   Inputs : constant array (1 .. 5) of Integer :=
      (-10, 42, 0, -2147483648, 2147483647);
   Result : Sign_Value := 0;
begin
   for Value of Inputs loop
      Result := Signum (Value);
      Silver_IO.Put_Line
         ("signum(" & Integer'Image (Value) & ") =" & Integer'Image (Result));
   end loop;
end Main;
