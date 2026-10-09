with Interfaces.C;
with System;
with Silver_Output_Libc;
package body Silver_IO with SPARK_Mode => On is
   use type Interfaces.C.int;
   procedure Put_Line (Item : String) is
      Status : Interfaces.C.int;
   begin
      Written_Bytes := (others => Character'Val (0));
      Written_Count := 0;
      Flushed := False;
      Succeeded := False;
      if Item'Length > Max_Length then
         Silver_Output_Libc.Set_Exit_Status (1);
         return;
      end if;
      --  The input may have any String lower bound; only its length is bounded.
      for Index in Item'Range loop
         pragma Loop_Invariant (Static => Written_Count = Index - Item'First);
         pragma Loop_Invariant
           (Static => (for all Offset in 1 .. Written_Count =>
              Written_Bytes (Offset) = Item (Item'First + (Offset - 1))));
         Status := Silver_Output_Libc.Put_Byte
           (Interfaces.C.int (Character'Pos (Item (Index))));
         if Status /= Interfaces.C.int (Character'Pos (Item (Index))) then
            Silver_Output_Libc.Set_Exit_Status (1);
            return;
         end if;
         Written_Count := Written_Count + 1;
         Written_Bytes (Written_Count) := Item (Index);
      end loop;
      Status := Silver_Output_Libc.Put_Byte (10);
      if Status /= 10 then
         Silver_Output_Libc.Set_Exit_Status (1);
         return;
      end if;
      Written_Count := Written_Count + 1;
      Written_Bytes (Written_Count) := Character'Val (10);
      --  NULL requests flushing of all C output streams. Admitted application
      --  code has no stream creation, reassignment or other output operations.
      Status := Silver_Output_Libc.Flush (System.Null_Address);
      if Status /= 0 then
         Silver_Output_Libc.Set_Exit_Status (1);
         return;
      end if;
      Flushed := True;
      Succeeded := True;
   end Put_Line;
end Silver_IO;
