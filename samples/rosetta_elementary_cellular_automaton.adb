with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Width : constant Integer := 21;
   subtype Rule_Number is Integer range 0 .. 255;
   Rules : constant array (1 .. 3) of Rule_Number := (90, 30, 122);
   Initial : constant array (0 .. (Width - 1)) of Boolean :=
      (False, False, False, False, False, False, False, False, False, False,
       True, False, False, False, False, False, False, False, False, False,
       False);
   State : array (0 .. (Width - 1)) of Boolean :=
      (False, False, False, False, False, False, False, False, False, False,
       False, False, False, False, False, False, False, False, False, False,
       False);
   Next_State : array (0 .. (Width - 1)) of Boolean :=
      (False, False, False, False, False, False, False, False, False, False,
       False, False, False, False, False, False, False, False, False, False,
       False);
   Rule_Bits : array (0 .. 7) of Boolean :=
      (False, False, False, False, False, False, False, False);
   Remaining : Rule_Number := 0;
   Pattern : Integer range 0 .. 7 := 0;
begin
   for Rule of Rules loop
      Silver_IO.Put_Line ("Rule" & Integer'Image (Rule));
      Remaining := Rule;
      for Bit in 0 .. 7 loop
         Rule_Bits (Bit) := (Remaining mod 2) = 1;
         Remaining := (Remaining / 2);
      end loop;
      for I in 0 .. (Width - 1) loop
         State (I) := Initial (I);
      end loop;
      for Generation in 0 .. 15 loop
         for I in 0 .. (Width - 1) loop
            if State (I) then
               Silver_IO.Put ("#");
            else
               Silver_IO.Put (".");
            end if;
         end loop;
         Silver_IO.Put_Line ("");
         for I in 0 .. (Width - 1) loop
            Pattern := 0;
            if State (((I + (Width - 1)) mod Width)) then
               Pattern := 4;
            end if;
            if State (I) then
               Pattern := (Pattern + 2);
            end if;
            if State (((I + 1) mod Width)) then
               Pattern := (Pattern + 1);
            end if;
            Next_State (I) := Rule_Bits (Pattern);
         end loop;
         for I in 0 .. (Width - 1) loop
            State (I) := Next_State (I);
         end loop;
      end loop;
   end loop;
end Main;
