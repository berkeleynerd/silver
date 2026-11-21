with Silver_IO;

procedure Main is
   pragma SPARK_Mode (On);

   subtype Coefficient is Integer range -20 .. 20;
   subtype Argument is Integer range -10 .. 10;
   subtype Bounded_Result is Integer range -1000 .. 1000;
   type Polynomial is array (0 .. 3) of Coefficient;

   procedure Horner
     (Coefficients : in Polynomial;
      X : in Argument;
      Value : out Bounded_Result;
      Succeeded : out Boolean)
   is
      Accumulator : Bounded_Result := 0;
   begin
      Value := 0;
      Succeeded := True;
      for I in reverse Coefficients'Range loop
         if Succeeded then
            --  A conservative capacity guard covers every coefficient and X.
            --  Refusal is explicit; a partial accumulator is never a result.
            if Accumulator >= -98 and then Accumulator <= 98 then
               Accumulator := (Accumulator * X + Coefficients (I));
            else
               Succeeded := False;
            end if;
         end if;
      end loop;
      if Succeeded then
         Value := Accumulator;
      else
         Value := 0;
      end if;
   end Horner;

   Coefficients : constant Polynomial := (-19, 7, -4, 6);
   Result : Bounded_Result := 0;
   Succeeded : Boolean := False;
begin
   Horner (Coefficients, X => 3, Value => Result, Succeeded => Succeeded);
   if Succeeded then
      Silver_IO.Put_Line ("At 3:" & Integer'Image (Result));
   else
      Silver_IO.Put_Line ("At 3: capacity exceeded");
   end if;
   Horner (Coefficients, 10, Result, Succeeded);
   if Succeeded then
      Silver_IO.Put_Line ("At 10:" & Integer'Image (Result));
   else
      Silver_IO.Put_Line ("At 10: capacity exceeded");
   end if;
end Main;
