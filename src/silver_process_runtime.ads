with Ada.Text_IO;

package Silver_Process_Runtime
  with SPARK_Mode => On
is
   --  Ada ABI models of the existing GNAT System.Strings types. The runtime
   --  copies argument values before its platform normalization and spawn.
   type String_Access is access String;
   type Argument_List is array (Positive range <>) of String_Access;
   type Argument_List_Access is access Argument_List;

   function Spawn (Program_Name : String; Args : Argument_List) return Integer
     with Import, Convention => Ada,
          External_Name => "system__os_lib__spawn__2",
          Side_Effects, Always_Terminates => False,
          Global => (In_Out => Ada.Text_IO.File_System),
          Pre => Program_Name'Length > 0
            and then (for all Ch of Program_Name => Ch /= Character'Val (0))
            and then Args'First = 1
            and then (for all Arg of Args => Arg /= null
              and then (for all Ch of Arg.all => Ch /= Character'Val (0)));

   --  Existing System.Strings.Free frees every string, then the list, and
   --  clears the caller's pointer. No Silver-owned deallocator is hidden here.
   procedure Free_List (Args : in out Argument_List_Access)
     with Import, Convention => Ada,
          External_Name => "system__strings__free__2",
          Global => null, Always_Terminates,
          Post => Args = null;
end Silver_Process_Runtime;
