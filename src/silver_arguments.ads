with Ada.Text_IO;
with Silver_IO;

package Silver_Arguments with SPARK_Mode => On is
   --  Both queries observe the immutable GNAT argument vector. An absent
   --  argument selects Default; one valid argument preserves its exact bytes,
   --  including the empty String. Invalid input is handled by the caller's
   --  required validity guard and Reject branch, never printed as a fallback.
   function Input_Is_Valid return Boolean with Global => null;

   --  Return canonical one-based bounds while preserving the selected bytes.
   --  This also applies to shifted and null-range Default values.
   function First_Or_Default (Default : String) return String
     with Global => null,
          Post => First_Or_Default'Result'First = 1
            and then First_Or_Default'Result'Length <= Silver_IO.Max_Length
            and then (for all Ch of First_Or_Default'Result =>
              Character'Pos (Ch) in 32 .. 126);

   procedure Reject
     with Global => (In_Out => Ada.Text_IO.File_System), Always_Terminates;
end Silver_Arguments;
