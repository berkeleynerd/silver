with Silver_Application_Units;
with Silver_Function_Bindings;
with Silver_Procedure_Bindings;
with Silver_Package_Bindings;

--  Source-derived report identities. These are views of admitted original
--  declarations, never identities inferred from the producer's report.
package Silver_Application_Report_Metadata with SPARK_Mode => On is
   package Packages renames Silver_Package_Bindings;
   package Functions renames Silver_Function_Bindings;
   package Procedures renames Silver_Procedure_Bindings;
   package Units renames Silver_Application_Units;
   use type Packages.Routine_Kind;
   use type Functions.Metadata;
   use type Procedures.Metadata;
   use type Procedures.Parameter_Mode;

   type Report_Scope is (Main_Report, Package_Report);
   type Routine_Identity is record
      Name : Packages.Name_Span := Packages.No_Name;
      Kind : Packages.Routine_Kind := Packages.Procedure_Routine;
      May_Write : Packages.State_Set := Packages.Empty_State_Set;
      Has_Explicit_Output : Boolean := False;
   end record;
   type Routine_Array is array (Packages.Routine_Index) of Routine_Identity;
   type State_Names is array (Packages.State_Index) of Packages.Name_Span;
   type Context is record
      Enabled : Boolean := False;
      Scope : Report_Scope := Main_Report;
      Package_Name : Packages.Name_Span := Packages.No_Name;
      Source_Units : Units.Span_Array := (others => (1, 1));
      Routine_Count : Packages.Routine_Count_Type := 0;
      Routines : Routine_Array := (others => (others => <>));
      State_Count : Packages.State_Count_Type := 0;
      States : State_Names := (others => Packages.No_Name);
   end record;
   Empty_Context : constant Context := (others => <>);

   function Has_Explicit_Output
     (Info : Packages.Metadata; Item : Packages.Routine) return Boolean is
     (Item.Kind = Packages.Procedure_Routine
      and then Item.Count > 0 and then Item.Formal_First > 0
      and then Item.Formal_First <= Info.Parameter_Count
      and then Item.Count <= Info.Parameter_Count - Item.Formal_First + 1
      and then (for some I in Item.Formal_First .. Item.Formal_First + Item.Count - 1 =>
        Info.Parameters (I).Mode in Procedures.Output | Procedures.Input_Output))
     with Global => null;

   function View (Info : Packages.Metadata; Scope : Report_Scope) return Context is
     (Enabled => True, Scope => Scope,
      Package_Name => (Info.Name_First, Info.Name_After),
      Source_Units => Info.Units,
      Routine_Count => Info.Routine_Count,
      Routines => (for I in Packages.Routine_Index =>
        (Name => Info.Routines (I).Spec_Name,
         Kind => Info.Routines (I).Kind,
         May_Write => Info.Routines (I).May_Write,
         Has_Explicit_Output => Has_Explicit_Output (Info, Info.Routines (I)))),
      State_Count => Info.State_Count,
      States => (for I in Packages.State_Index => Info.States (I).Name))
     with Global => null;

   function For_Main (Info : Packages.Metadata) return Context is
     (View (Info, Main_Report)) with Global => null;
   function For_Package (Info : Packages.Metadata) return Context is
     (View (Info, Package_Report)) with Global => null;

   --  These predicates are total over all typed contexts, including empty and
   --  malformed metadata. Package admission supplies their stronger source facts.
   function Valid (Source : String; Item : Context) return Boolean is
     (not Item.Enabled or else
       (Source'First = 1 and then Source'Length in 1 .. Units.Max_Source_Length
        and then Item.Source_Units (Units.Package_Specification).First = 1
        and then Item.Source_Units (Units.Package_Specification).First <
          Item.Source_Units (Units.Package_Specification).After
        and then Item.Source_Units (Units.Package_Body).First =
          Item.Source_Units (Units.Package_Specification).After
        and then Item.Source_Units (Units.Package_Body).First <
          Item.Source_Units (Units.Package_Body).After
        and then Item.Source_Units (Units.Main_Body).First =
          Item.Source_Units (Units.Package_Body).After
        and then Item.Source_Units (Units.Main_Body).First <
          Item.Source_Units (Units.Main_Body).After
        and then Item.Source_Units (Units.Main_Body).After = Source'Length + 1
        and then Packages.Valid_Name (Source, Item.Package_Name)
        and then Packages.In_Unit
          (Item.Package_Name, Item.Source_Units (Units.Package_Specification))
        and then (for all I in 1 .. Item.Routine_Count =>
          Packages.Valid_Name (Source, Item.Routines (I).Name)
          and then Packages.In_Unit
            (Item.Routines (I).Name, Item.Source_Units (Units.Package_Specification))
          and then Packages.Within (Item.Routines (I).May_Write, Item.State_Count)
          and then (if Item.Routines (I).Kind = Packages.Function_Routine then
            (for all S in Packages.State_Index => not Item.Routines (I).May_Write (S))))
        and then (for all I in 1 .. Item.State_Count =>
          Packages.Valid_Name (Source, Item.States (I))
          and then Packages.In_Unit
            (Item.States (I), Item.Source_Units (Units.Package_Body)))))
     with Global => null;

   function Owns_Package (Item : Context) return Boolean is
     (Item.Enabled and then Item.Scope = Package_Report) with Global => null;

   function Owned_Views_Match
     (Item : Context; Owned_Functions : Functions.Metadata;
      Owned_Procedures : Procedures.Metadata) return Boolean is
     (not Owns_Package (Item) or else
       (Owned_Functions.Count + Owned_Procedures.Count = Item.Routine_Count
        and then (for all R in 1 .. Item.Routine_Count =>
          (if Item.Routines (R).Kind = Packages.Function_Routine then
            (for some F in 1 .. Owned_Functions.Count =>
              Owned_Functions.Items (F).First = Item.Routines (R).Name.First
              and then Owned_Functions.Items (F).After = Item.Routines (R).Name.After)
           else (for some P in 1 .. Owned_Procedures.Count =>
              Owned_Procedures.Items (P).First = Item.Routines (R).Name.First
              and then Owned_Procedures.Items (P).After = Item.Routines (R).Name.After)))))
     with Global => null;

   function Owner_Name (Source : String; Item : Context) return String is
     (if not Owns_Package (Item) then "Main"
      elsif Packages.Valid_Name (Source, Item.Package_Name) then
        Source (Item.Package_Name.First .. Item.Package_Name.After - 1)
      else "") with Global => null;

   function Fold (C : Character) return Character is
     (if C in 'A' .. 'Z' then Character'Val (Character'Pos (C) + 32) else C)
     with Global => null;
   function Folded (Text : String) return String is
     (for I in Text'Range => Fold (Text (I)))
     with Global => null,
       Post => Folded'Result'First = Text'First
         and then Folded'Result'Last = Text'Last
         and then (for all I in Text'Range => Folded'Result (I) = Fold (Text (I)));

   function Package_File
     (Source : String; Item : Context; Body_File : Boolean := False) return String is
     (if Item.Enabled and then Packages.Valid_Name (Source, Item.Package_Name) then
        Folded (Source (Item.Package_Name.First .. Item.Package_Name.After - 1)) &
          (if Body_File then ".adb" else ".ads")
      else "") with Global => null;
   function Declaration_File (Source : String; Item : Context) return String is
     (if Owns_Package (Item) then Package_File (Source, Item) else "main.adb")
     with Global => null;
   function Implementation_File (Source : String; Item : Context) return String is
     (if Owns_Package (Item) then Package_File (Source, Item, True) else "main.adb")
     with Global => null;

   --  Preserve the explicit formal pool and its slice indices. The reports
   --  need no implicit global captures or array/type-name interpretation.
   --  Zero-formal signatures are intentionally allowed in these report views;
   --  the old local-callable Valid_Metadata predicate is never assumed here.
   function Function_Parameters (Info : Packages.Metadata) return Functions.Formal_Array is
     (for I in Functions.Formal_Index =>
       (First => Info.Parameters (I).Spec_Name.First,
        After => Info.Parameters (I).Spec_Name.After,
        Kind => Info.Parameters (I).Kind,
        Bounds => Info.Parameters (I).Bounds, Type_Id => 0))
     with Global => null;
   function Procedure_Parameters (Info : Packages.Metadata) return Procedures.Formal_Array is
     (for I in Procedures.Formal_Index =>
       (First => Info.Parameters (I).Spec_Name.First,
        After => Info.Parameters (I).Spec_Name.After,
        Kind => Info.Parameters (I).Kind,
        Bounds => Info.Parameters (I).Bounds, Type_Id => 0,
        Mode => Info.Parameters (I).Mode))
     with Global => null;
   function Function_View (Item : Packages.Routine) return Functions.Signature is
     (First => Item.Spec_Name.First, After => Item.Spec_Name.After,
      Formal_First => Item.Formal_First, Count => Item.Count,
      Result_Kind => Item.Result_Kind, Result_Bounds => Item.Result_Bounds)
     with Global => null;
   function Procedure_View (Item : Packages.Routine) return Procedures.Signature is
     (First => Item.Spec_Name.First, After => Item.Spec_Name.After,
      Formal_First => Item.Formal_First, Count => Item.Count)
     with Global => null;

   function Function_Model
     (Info : Packages.Metadata; Count : Packages.Routine_Count_Type) return Functions.Metadata
     with Ghost => Static, Global => null, Pre => Count <= Info.Routine_Count,
       Post => Function_Model'Result.Count <= Count,
       Subprogram_Variant => (Decreases => Count);
   function Procedure_Model
     (Info : Packages.Metadata; Count : Packages.Routine_Count_Type) return Procedures.Metadata
     with Ghost => Static, Global => null, Pre => Count <= Info.Routine_Count,
       Post => Procedure_Model'Result.Count <= Count,
       Subprogram_Variant => (Decreases => Count);

   function Owned_Functions (Info : Packages.Metadata) return Functions.Metadata
     with Global => null,
       Post => (Runtime => Owned_Functions'Result.Count <= Info.Routine_Count,
         Static => Owned_Functions'Result = Function_Model (Info, Info.Routine_Count));
   function Owned_Procedures (Info : Packages.Metadata) return Procedures.Metadata
     with Global => null,
       Post => (Runtime => Owned_Procedures'Result.Count <= Info.Routine_Count,
         Static => Owned_Procedures'Result = Procedure_Model (Info, Info.Routine_Count));
end Silver_Application_Report_Metadata;
