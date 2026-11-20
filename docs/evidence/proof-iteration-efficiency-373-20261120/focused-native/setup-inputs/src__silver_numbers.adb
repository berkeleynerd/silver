package body Silver_Numbers with SPARK_Mode => On is
   function Represents (Text : String; Value : Natural) return Boolean is
     (if Text'Length = 0 then Value = 0
      else Text (Text'Last) in '0' .. '9'
        and then Character'Pos (Text (Text'Last)) - Character'Pos ('0')
          = Value rem 10
        and then Represents (Text (Text'First .. Text'Last - 1), Value / 10));

   function Decimal (Value : Natural) return String is
      Buffer : String (1 .. Natural'Width) := (others => '0');
      Rest : Natural := Value;
   begin
      --  This statically bounded loop is completely unrolled by GNATprove,
      --  preserving each quotient/remainder step for the exact-value proof.
      for Index in reverse Buffer'Range loop
         Buffer (Index) := Character'Val (Character'Pos ('0') + (Rest rem 10));
         Rest := Rest / 10;
         if Rest = 0 then
            return Buffer (Index .. Buffer'Last);
         end if;
      end loop;
      return Buffer;
   end Decimal;
end Silver_Numbers;
