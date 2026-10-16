with Ada.Text_IO;
with Interfaces.C;

package Silver_Image_Libc with SPARK_Mode => On is
   --  Existing POSIX link: atomically publish a fully written file, without
   --  replacing an existing destination. Both paths stay on the same filesystem.
   function C_Link (Existing_Name, New_Name : Interfaces.C.char_array)
     return Interfaces.C.int
     with Import, Convention => C, External_Name => "link",
       Side_Effects, Always_Terminates => False,
       Global => (In_Out => Ada.Text_IO.File_System);
end Silver_Image_Libc;
