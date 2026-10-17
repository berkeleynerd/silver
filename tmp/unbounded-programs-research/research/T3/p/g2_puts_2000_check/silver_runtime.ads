with Ada.Command_Line;

package Silver_Runtime
  with SPARK_Mode => On,
       Abstract_State => (Exit_State with External => Async_Readers)
is
   --  Explicit models of the existing GNAT runtime entry points. The compiler
   --  never calls Ada.Command_Line.Remove, so its argument vector is immutable.
   --  The GNAT runtime and its ABI are in the Oracle's trusted dependencies.
   function Argument_Count return Natural
     with Import, Convention => Ada,
          External_Name => "ada__command_line__argument_count",
          Global => null;

   function Argument (Number : Positive) return String
     with Import, Convention => Ada,
          External_Name => "ada__command_line__argument",
          Global => null,
          Pre => Number <= Argument_Count;

   procedure Set_Exit_Status (Code : Ada.Command_Line.Exit_Status)
     with Import, Convention => C,
          External_Name => "__gnat_set_exit_status",
          Global => (Output => Exit_State), Always_Terminates;
end Silver_Runtime;
