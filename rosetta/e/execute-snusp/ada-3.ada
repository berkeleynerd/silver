with Ada.Containers.Vectors;
with Ada.Strings.Fixed;
with Ada.Text_IO;
with Memory;
package SNUSP is

   type SNUSP_Machine is limited private;

   type Code is array (Positive range <>, Positive range <>) of Character;

   procedure Run (Machine : in out SNUSP_Machine; Input : in Code);

private

   type Byte is mod 2 ** 8;
   package Byte_Memory is new Memory (Byte => Byte, Key_Type => Positive);

   type Direction is (Up, Down, Left, Right);
   type Code_Pointer is record
      X, Y : Positive  := 1;
      Dir  : Direction := Right;
   end record;
   package Call_Stacks is new Ada.Containers.Vectors (
      Index_Type => Positive,
      Element_Type => Code_Pointer);

   type SNUSP_Machine is limited record
      Main_Memory            : Byte_Memory.Memory;
      Current_Memory_Pointer : Positive := 1;
      Call_Stack             : Call_Stacks.Vector;
      IP                     : Code_Pointer;
   end record;

end SNUSP;
