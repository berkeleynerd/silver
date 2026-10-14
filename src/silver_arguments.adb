with Silver_Runtime;
with Silver_Output_Libc;

package body Silver_Arguments with SPARK_Mode => On is
   function Is_Message (Item : String) return Boolean is
     (Item'Length <= Silver_IO.Max_Length
      and then (for all Ch of Item => Character'Pos (Ch) in 32 .. 126));

   function Input_Is_Valid return Boolean is
   begin
      if Silver_Runtime.Argument_Count = 0 then
         return True;
      elsif Silver_Runtime.Argument_Count = 1 then
         return Is_Message (Silver_Runtime.Argument (1));
      end if;
      return False;
   end Input_Is_Valid;

   function First_Or_Default (Default : String) return String is
   begin
      if not Input_Is_Valid then
         return "";
      end if;
      if Silver_Runtime.Argument_Count = 0 then
         if Is_Message (Default) then
            return Result : String (1 .. Default'Length) := Default;
         end if;
      elsif Silver_Runtime.Argument_Count = 1 then
         declare
            Item : constant String := Silver_Runtime.Argument (1);
         begin
            if Is_Message (Item) then
               return Result : String (1 .. Item'Length) := Item;
            end if;
         end;
      end if;
      return "";
   end First_Or_Default;

   procedure Reject is
   begin
      Silver_Output_Libc.Set_Exit_Status (1);
   end Reject;
end Silver_Arguments;
