with Interfaces.C;
with Ada.Text_IO;
with System;

package Silver_Libc
  with SPARK_Mode => On
is
   --  Direct declarations of existing libc services, within the Oracle's
   --  approved OS/runtime trust boundary. There are no private C wrappers.
   function C_Open (Name, Mode : Interfaces.C.char_array) return System.Address
     with Import, Convention => C, External_Name => "fopen",
          Side_Effects, Always_Terminates => False, Global => (In_Out => Ada.Text_IO.File_System);
   function C_Get (File : System.Address) return Interfaces.C.int
     with Import, Convention => C, External_Name => "fgetc",
          Side_Effects, Always_Terminates => False, Global => (In_Out => Ada.Text_IO.File_System);
   function C_Put (Item : Interfaces.C.int; File : System.Address)
     return Interfaces.C.int
     with Import, Convention => C, External_Name => "fputc",
          Side_Effects, Always_Terminates => False, Global => (In_Out => Ada.Text_IO.File_System);
   function C_Error (File : System.Address) return Interfaces.C.int
     with Import, Convention => C, External_Name => "ferror",
          Side_Effects, Always_Terminates => False, Global => (In_Out => Ada.Text_IO.File_System);
   function C_Close (File : System.Address) return Interfaces.C.int
     with Import, Convention => C, External_Name => "fclose",
          Side_Effects, Always_Terminates => False, Global => (In_Out => Ada.Text_IO.File_System);
   function C_System (Command : Interfaces.C.char_array) return Interfaces.C.int
     with Import, Convention => C, External_Name => "system",
          Side_Effects, Always_Terminates => False, Global => (In_Out => Ada.Text_IO.File_System);
   function C_Mkdir (Name : Interfaces.C.char_array; Mode : Interfaces.C.unsigned)
     return Interfaces.C.int
     with Import, Convention => C, External_Name => "mkdir",
          Side_Effects, Always_Terminates => False, Global => (In_Out => Ada.Text_IO.File_System);
   function C_Mkdtemp (Template : in out Interfaces.C.char_array)
     return System.Address
     with Import, Convention => C, External_Name => "mkdtemp",
          Side_Effects, Always_Terminates => False, Global => (In_Out => Ada.Text_IO.File_System);

end Silver_Libc;
