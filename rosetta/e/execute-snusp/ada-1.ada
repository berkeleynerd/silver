with Ada.Finalization;
generic
   type Byte is mod <>;
   type Key_Type is private;
   with function "<" (Left, Right : in Key_Type) return Boolean is <>;
package Memory is

   type Memory is new Ada.Finalization.Limited_Controlled with private;

   function Get_Value (Storage : in Memory; Key : in Key_Type) return Byte;

   procedure Set_Value
     (Storage : in out Memory;
      Key     : in Key_Type;
      Value   : in Byte);

   procedure Increment (Storage : in out Memory; Key : in Key_Type);

   procedure Decrement (Storage : in out Memory; Key : in Key_Type);

private

   type Memory_Type;

   type Memory_Access is access Memory_Type;

   type Memory is new Ada.Finalization.Limited_Controlled with record
      Cells : Memory_Access;
   end record;

   procedure Initialize (Storage : in out Memory);
   procedure Finalize (Storage : in out Memory);

end Memory;
