with Silver_Application_Units;

procedure Packing_Check is
   use Silver_Application_Units;
   Empty : constant String (9 .. 8) := "";
   High : constant String (Integer'Last - 2 .. Integer'Last) :=
     ('A', Character'Val (13), Character'Val (255));
   Body_Text : constant String (17 .. 21) := "--EOF";
   Main_Text : constant String (5 .. 7) :=
     (Character'Val (0), Character'Val (10), 'z');
   Packed : constant Bundle := Pack (High, Body_Text, Main_Text);
   Long_Text : constant String (1 .. Max_Source_Length) := (others => 'x');
   Full : constant Bundle :=
     Pack (Long_Text (1 .. Max_Source_Length - 2), "b", "m");
begin
   pragma Assert (not Fits (Empty, "b", "m"));
   pragma Assert (not Fits ("s", Empty, "m"));
   pragma Assert (not Fits ("s", "b", Empty));
   pragma Assert (not Fits (Long_Text, "b", "m"));
   pragma Assert (not Fits ("s", Long_Text, "m"));
   pragma Assert (not Fits ("s", "b", Long_Text));
   pragma Assert (not Fits (Long_Text, Long_Text, Long_Text));
   pragma Assert (Valid (Packed));
   pragma Assert (Unit_Source (Packed, Package_Specification) = High);
   pragma Assert (Unit_Source (Packed, Package_Body) = Body_Text);
   pragma Assert (Unit_Source (Packed, Main_Body) = Main_Text);
   pragma Assert (Unit_Span (Packed, Package_Specification) =
     (First => 1, After => 4));
   pragma Assert (Unit_Span (Packed, Package_Body) =
     (First => 4, After => 9));
   pragma Assert (Unit_Span (Packed, Main_Body) =
     (First => 9, After => 12));
   pragma Assert (Prefix (Packed, Package_Body)'First = 1);
   pragma Assert (Prefix (Packed, Package_Body)'Last = 8);
   pragma Assert (Prefix (Packed, Package_Body) (4 .. 8) = Body_Text);
   pragma Assert (Packed.Used = 11);
   pragma Assert (for all I in Packed.Used + 1 .. Max_Source_Length =>
     Packed.Pool (I) = Character'Val (0));
   pragma Assert (Valid (Full));
   pragma Assert (Full.Used = Max_Source_Length);
   pragma Assert (Unit_Span (Full, Main_Body).After = Max_Source_Length + 1);
end Packing_Check;
