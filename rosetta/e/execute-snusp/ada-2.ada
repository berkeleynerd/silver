with Ada.Containers.Ordered_Maps;
with Ada.Unchecked_Deallocation;
package body Memory is

   package Memory_Maps is new Ada.Containers.Ordered_Maps (
      Key_Type => Key_Type,
      Element_Type => Byte);
   use type Memory_Maps.Cursor;

   type Memory_Type is record
      Map : Memory_Maps.Map;
   end record;

   function Get_Value (Storage : in Memory; Key : in Key_Type) return Byte is
      Result   : Byte               := 0;
      Position : Memory_Maps.Cursor :=
         Memory_Maps.Find (Storage.Cells.Map, Key);
   begin
      if Position /= Memory_Maps.No_Element then
         Result := Memory_Maps.Element (Position);
      end if;
      return Result;
   end Get_Value;

   procedure Set_Value
     (Storage : in out Memory;
      Key     : in Key_Type;
      Value   : in Byte)
   is
      Position : Memory_Maps.Cursor :=
         Memory_Maps.Find (Storage.Cells.Map, Key);
   begin
      if Position = Memory_Maps.No_Element then
         if Value /= 0 then
            Memory_Maps.Insert (Storage.Cells.Map, Key, Value);
         end if;
      else
         if Value = 0 then
            Memory_Maps.Delete (Storage.Cells.Map, Key);
         else
            Memory_Maps.Replace (Storage.Cells.Map, Key, Value);
         end if;
      end if;
   end Set_Value;

   procedure Increment (Storage : in out Memory; Key : in Key_Type) is
      Value : Byte := Get_Value (Storage, Key) + 1;
   begin
      Set_Value (Storage, Key, Value);
   end Increment;

   procedure Decrement (Storage : in out Memory; Key : in Key_Type) is
      Value : Byte := Get_Value (Storage, Key) - 1;
   begin
      Set_Value (Storage, Key, Value);
   end Decrement;

   procedure Initialize (Storage : in out Memory) is
   begin
      Storage.Cells := new Memory_Type;
   end Initialize;

   procedure Finalize (Storage : in out Memory) is
      procedure Free is new Ada.Unchecked_Deallocation (
         Object => Memory_Type,
         Name => Memory_Access);
   begin
      Memory_Maps.Clear (Storage.Cells.Map);
      Free (Storage.Cells);
   end Finalize;

end Memory;
