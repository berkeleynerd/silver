with Ada.Command_Line;
with Ada.Text_IO;
procedure Main is
   -- Measurement tooling, not Silver source or a compiler implementation.
   -- Fields mirror the current integer interval/path/result storage shapes.
   Max_Bindings : constant Positive := 4096 / 12;
   type Interval is record Lower, Upper : Integer; end record;
   type Scalar_Vector is array (Positive range <>) of Interval;
   type Path_Context is record
      Lower, Upper : Natural range 0 .. 4096;
      Valid_Reachable, Invalid_Reachable, Invalid_Rejected : Boolean;
   end record;
   type Current_Result is record
      After : Natural;
      When_True, When_False : Path_Context;
   end record;
   type Fixed_Result is record
      Header : Current_Result;
      When_True, When_False : Scalar_Vector (1 .. Max_Bindings);
   end record;
   type Active_Result (Count : Positive) is record
      Header : Current_Result;
      When_True, When_False : Scalar_Vector (1 .. Count);
   end record;
   Mode : constant String := Ada.Command_Line.Argument (1);
   Depth : constant Natural := Natural'Value (Ada.Command_Line.Argument (2));
   Count : constant Positive := Positive'Value (Ada.Command_Line.Argument (3));
   Seed : constant Integer := Integer'Value (Ada.Command_Line.Argument (4));
   function Header (Level : Natural) return Current_Result is
     ((Level, (0, 4096, True, True, False), (0, 4096, True, True, False)));
   function Current (Level : Natural) return Long_Long_Integer is
      Frame : constant Current_Result := Header (Level);
      Inner : Long_Long_Integer := 0;
   begin
      if Level > 0 then Inner := Current (Level - 1); end if;
      return Inner + Long_Long_Integer (Frame.After);
   end Current;
   function Fixed (Level : Natural) return Long_Long_Integer is
      Frame : Fixed_Result :=
        (Header (Level), (others => (Seed + Level, Seed)),
         (others => (Seed, Seed + Level + 1)));
      Inner : Long_Long_Integer := 0;
   begin
      if Level > 0 then Inner := Fixed (Level - 1); end if;
      for I in Frame.When_True'Range loop
         Inner := Inner + Long_Long_Integer (Frame.When_True (I).Lower)
           + Long_Long_Integer (Frame.When_False (I).Upper);
      end loop;
      return Inner + Long_Long_Integer (Frame.Header.After);
   end Fixed;
   function Active (Level : Natural) return Long_Long_Integer is
      Frame : Active_Result (Count) :=
        (Count, Header (Level), (others => (Seed + Level, Seed)),
         (others => (Seed, Seed + Level + 1)));
      Inner : Long_Long_Integer := 0;
   begin
      if Level > 0 then Inner := Active (Level - 1); end if;
      for I in Frame.When_True'Range loop
         Inner := Inner + Long_Long_Integer (Frame.When_True (I).Lower)
           + Long_Long_Integer (Frame.When_False (I).Upper);
      end loop;
      return Inner + Long_Long_Integer (Frame.Header.After);
   end Active;
   Layout : Active_Result (Count);
   Answer : Long_Long_Integer;
begin
   Ada.Text_IO.Put_Line ("interval_bits=" & Integer'Image (Interval'Object_Size));
   Ada.Text_IO.Put_Line ("current_result_bits=" & Integer'Image (Current_Result'Object_Size));
   Ada.Text_IO.Put_Line ("fixed_result_bits=" & Integer'Image (Fixed_Result'Object_Size));
   Ada.Text_IO.Put_Line ("active_result_bits=" & Integer'Image (Layout'Size));
   if Mode = "current" then Answer := Current (Depth);
   elsif Mode = "fixed" then Answer := Fixed (Depth);
   elsif Mode = "active" then Answer := Active (Depth);
   else raise Constraint_Error;
   end if;
   Ada.Text_IO.Put_Line (Long_Long_Integer'Image (Answer));
end Main;
