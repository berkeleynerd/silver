package body SNUSP is

   procedure Move_IP (IP : in out Code_Pointer) is
   begin
      case IP.Dir is
         when Up =>
            IP.Y := IP.Y - 1;
         when Down =>
            IP.Y := IP.Y + 1;
         when Left =>
            IP.X := IP.X - 1;
         when Right =>
            IP.X := IP.X + 1;
      end case;
   end Move_IP;

   procedure Process_Next_Instruction
     (Machine : in out SNUSP_Machine;
      Input   : in Code)
   is
      Instruction : Character := Input (Machine.IP.Y, Machine.IP.X);
   begin
      case Instruction is
      when '>' =>
         Machine.Current_Memory_Pointer := Machine.Current_Memory_Pointer +
                                           1;
      when '<' =>
         Machine.Current_Memory_Pointer := Machine.Current_Memory_Pointer -
                                           1;
      when '+' =>
         Byte_Memory.Increment
           (Machine.Main_Memory,
            Machine.Current_Memory_Pointer);
      when '-' =>
         Byte_Memory.Decrement
           (Machine.Main_Memory,
            Machine.Current_Memory_Pointer);
      when ',' =>
         declare
            User_Input : Character;
            Value      : Byte;
         begin
            Ada.Text_IO.Get_Immediate (User_Input);
            Value := Character'Pos (User_Input);
            Byte_Memory.Set_Value
              (Machine.Main_Memory,
               Machine.Current_Memory_Pointer,
               Value);
         end;
      when '.' =>
         declare
            Value  : Byte      :=
               Byte_Memory.Get_Value
                 (Machine.Main_Memory,
                  Machine.Current_Memory_Pointer);
            Output : Character := Character'Val (Value);
         begin
            Ada.Text_IO.Put (Output);
         end;
      when '/' =>
         case Machine.IP.Dir is
            when Up =>
               Machine.IP.Dir := Right;
            when Down =>
               Machine.IP.Dir := Left;
            when Left =>
               Machine.IP.Dir := Down;
            when Right =>
               Machine.IP.Dir := Up;
         end case;
      when '\' =>
         case Machine.IP.Dir is
            when Up =>
               Machine.IP.Dir := Left;
            when Down =>
               Machine.IP.Dir := Right;
            when Left =>
               Machine.IP.Dir := Up;
            when Right =>
               Machine.IP.Dir := Down;
         end case;
      when '!' =>
         Move_IP (Machine.IP);
      when '?' =>
         if Byte_Memory.Get_Value
               (Machine.Main_Memory,
                Machine.Current_Memory_Pointer) =
            0
         then
            Move_IP (Machine.IP);
         end if;
      when '@' =>
         Call_Stacks.Append (Machine.Call_Stack, Machine.IP);
      when '#' =>
         Machine.IP := Call_Stacks.Last_Element (Machine.Call_Stack);
         Call_Stacks.Delete_Last (Machine.Call_Stack);
         Move_IP (Machine.IP);
      when others =>
         null;
      end case;
      Move_IP (Machine.IP);
   end Process_Next_Instruction;

   procedure Run (Machine : in out SNUSP_Machine; Input : in Code) is
   begin
      -- find begin ($)
      declare
         Start_Found : Boolean := False;
      begin
         for Row in Input'Range (1) loop
            for Col in Input'Range (2) loop
               if Input (Row, Col) = '$' then
                  if Start_Found then
                     raise Program_Error;
                  end if;
                  Start_Found  := True;
                  Machine.IP.Y := Row;
                  Machine.IP.X := Col;
               end if;
            end loop;
         end loop;
      end;

      loop
         Process_Next_Instruction (Machine, Input);
      end loop;
   exception
      when Constraint_Error =>
         null;
   end Run;

end SNUSP;
