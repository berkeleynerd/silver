with Ada.Text_IO;
package Silver_IO with SPARK_Mode => On is
   --  Application membership restricts literals separately. The executable
   --  guard makes this implementation safe for every String argument.
   Max_Length : constant Positive := 4_096;
   --  Static observations record bytes only after successful libc calls.
   --  GNAT erases this verification state and its assertions from execution.
   Written_Bytes : String (1 .. Max_Length + 1) := (others => Character'Val (0))
     with Ghost => Static;
   Written_Count : Natural range 0 .. Max_Length + 1 := 0 with Ghost => Static;
   Flushed : Boolean := False with Ghost => Static;
   --  Normal return means that every input byte and LF were accepted by
   --  putchar, and fflush(NULL) completed successfully. Any detected failure
   --  exits with status 1; there is no successful partial return.
   --  Environmental blocking is modeled by Always_Terminates => False.
   procedure Put_Line (Item : String)
     with Global => (In_Out => Ada.Text_IO.File_System,
                     Output => (Written_Bytes, Written_Count, Flushed)),
          Always_Terminates => False,
          Post => (Static => Item'Length <= Max_Length
            and then Written_Count = Item'Length + 1
            and then Written_Bytes (1 .. Item'Length) = Item
            and then Written_Bytes (Written_Count) = Character'Val (10)
            and then Flushed);
end Silver_IO;
