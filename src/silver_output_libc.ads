with Interfaces.C;
with Ada.Text_IO;
with System;
package Silver_Output_Libc with SPARK_Mode => On is
   --  Direct declarations of existing libc, with no Silver-owned C bodies.
   --  File_System is initialized by Ada.Text_IO elaboration and conservatively
   --  covers output streams and process exit, as in the compiler bindings.
   --  Imported bodies, byte/status semantics and progress are trusted; see
   --  docs/trusted-boundary.md and docs/hello-runtime-experiment.md.
   function Put_Byte (Item : Interfaces.C.int) return Interfaces.C.int
     with Import, Convention => C, External_Name => "putchar",
          Side_Effects, Always_Terminates => False,
          Global => (In_Out => Ada.Text_IO.File_System);
   --  A null Stream flushes every open C output stream. Zero means success.
   function Flush (Stream : System.Address) return Interfaces.C.int
     with Import, Convention => C, External_Name => "fflush",
          Side_Effects, Always_Terminates => False,
          Global => (In_Out => Ada.Text_IO.File_System);
   --  exit flushes C streams and terminates; its argument 1 is nonzero.
   --  It can block while flushing, so termination is an environmental premise.
   procedure Fail (Status : Interfaces.C.int)
     with Import, Convention => C, External_Name => "exit", No_Return,
          Always_Terminates => False,
          Global => (In_Out => Ada.Text_IO.File_System);
end Silver_Output_Libc;
