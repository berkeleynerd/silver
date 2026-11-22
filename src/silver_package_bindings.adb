package body Silver_Package_Bindings with SPARK_Mode => On is
   package Units renames Silver_Application_Units;
   package Scalars renames Silver_Scalars;

   function Valid_Metadata (Text : String; Info : Metadata) return Boolean is
     (Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
      and then Info.Units (Units.Package_Specification).First = 1
      and then Info.Units (Units.Package_Specification).First <
        Info.Units (Units.Package_Specification).After
      and then Info.Units (Units.Package_Body).First =
        Info.Units (Units.Package_Specification).After
      and then Info.Units (Units.Package_Body).First <
        Info.Units (Units.Package_Body).After
      and then Info.Units (Units.Main_Body).First =
        Info.Units (Units.Package_Body).After
      and then Info.Units (Units.Main_Body).First < Info.Units (Units.Main_Body).After
      and then Info.Units (Units.Main_Body).After = Text'Last + 1
      and then Valid_Name (Text, (Info.Name_First, Info.Name_After))
      and then In_Unit ((Info.Name_First, Info.Name_After),
                        Info.Units (Units.Package_Specification))
      and then (if Info.Body_Name_First = 0 then
          Info.Body_Name_After = 0 and then Info.State_Count = 0 and then Info.Completed = 0
        else In_Unit ((Info.Body_Name_First, Info.Body_Name_After),
                       Info.Units (Units.Package_Body))
          and then Same_Name (Text, (Info.Name_First, Info.Name_After),
                              (Info.Body_Name_First, Info.Body_Name_After)))
      and then Info.Completed <= Info.Routine_Count
      and then (for all I in 1 .. Info.Export_Count =>
        Valid_Name (Text, Info.Exports (I).Name)
        and then In_Unit (Info.Exports (I).Name,
                          Info.Units (Units.Package_Specification))
        and then not Scalars.Is_Empty (Info.Exports (I).Bounds)
        and then (if Info.Exports (I).Kind = Integer_Subtype then
          Info.Exports (I).Type_Identity = I + 1))
      and then (for all I in 1 .. Info.State_Count =>
        Valid_Name (Text, Info.States (I).Name)
        and then In_Unit (Info.States (I).Name, Info.Units (Units.Package_Body))
        and then not Scalars.Is_Empty (Info.States (I).Declared_Bounds)
        and then not Scalars.Is_Empty (Info.States (I).Initial_Bounds)
        and then Info.States (I).Initial_Bounds.Lower =
          Info.States (I).Initial_Bounds.Upper
        and then Info.States (I).Initial_Bounds.Lower >=
          Info.States (I).Declared_Bounds.Lower
        and then Info.States (I).Initial_Bounds.Upper <=
          Info.States (I).Declared_Bounds.Upper
        and then Info.States (I).Initializer_First >= Info.Units (Units.Package_Body).First
        and then Info.States (I).Initializer_First < Info.States (I).Initializer_After
        and then Info.States (I).Initializer_After <= Info.Units (Units.Package_Body).After)
      and then (for all I in 1 .. Info.Parameter_Count =>
        Valid_Name (Text, Info.Parameters (I).Spec_Name)
        and then In_Unit (Info.Parameters (I).Spec_Name,
                          Info.Units (Units.Package_Specification))
        and then not Scalars.Is_Empty (Info.Parameters (I).Bounds))
      and then (for all I in 1 .. Info.Routine_Count =>
        Valid_Name (Text, Info.Routines (I).Spec_Name)
        and then In_Unit (Info.Routines (I).Spec_Name,
                          Info.Units (Units.Package_Specification))
        and then Info.Routines (I).Spec_First >=
          Info.Units (Units.Package_Specification).First
        and then Info.Routines (I).Spec_First <= Info.Routines (I).Spec_Name.First
        and then Info.Routines (I).Spec_Name.After < Info.Routines (I).Spec_After
        and then Info.Routines (I).Spec_After <=
          Info.Units (Units.Package_Specification).After
        and then (if Info.Routines (I).Count = 0 then
            Info.Routines (I).Formal_First = 0
          else Info.Routines (I).Formal_First > 0
            and then Info.Routines (I).Formal_First <= Info.Parameter_Count
            and then Info.Routines (I).Count <=
              Info.Parameter_Count - Info.Routines (I).Formal_First + 1)
        and then Within (Info.Routines (I).May_Read, Info.State_Count)
        and then Within (Info.Routines (I).May_Write, Info.State_Count)
        and then (if Info.Routines (I).Kind = Function_Routine then
          not Scalars.Is_Empty (Info.Routines (I).Result_Bounds)
          and then Info.Routines (I).May_Write = Empty_State_Set)
        and then (if I <= Info.Completed then
          In_Unit (Info.Routines (I).Body_Name, Info.Units (Units.Package_Body))
          and then Same_Name (Text, Info.Routines (I).Spec_Name,
                                   Info.Routines (I).Body_Name)
          and then Info.Routines (I).Body_First >= Info.Units (Units.Package_Body).First
          and then Info.Routines (I).Body_First <= Info.Routines (I).Body_Name.First
          and then Info.Routines (I).Body_Name.After < Info.Routines (I).Body_After
          and then Info.Routines (I).Body_After <= Info.Units (Units.Package_Body).After
          and then (if Info.Routines (I).Count > 0 then
            (for all J in Info.Routines (I).Formal_First ..
                 Info.Routines (I).Formal_First + Info.Routines (I).Count - 1 =>
              In_Unit (Info.Parameters (J).Body_Name, Info.Units (Units.Package_Body))
              and then Same_Name (Text, Info.Parameters (J).Spec_Name,
                                       Info.Parameters (J).Body_Name)))));

   function Export_Lookup_Model
     (Text : String; Info : Metadata; Name : Name_Span;
      Limit : Export_Count_Type) return Export_Count_Type is
     (if Limit = 0 then 0
      elsif Same_Name (Text, Info.Exports (Limit).Name, Name) then Limit
      else Export_Lookup_Model (Text, Info, Name, Limit - 1));

   function Lookup_Export
     (Text : String; Info : Metadata; Name : Name_Span) return Export_Count_Type is
      Limit : Export_Count_Type := Info.Export_Count;
   begin
      while Limit > 0 loop
         pragma Loop_Invariant (Limit <= Info.Export_Count);
         pragma Loop_Invariant (Static =>
           Export_Lookup_Model (Text, Info, Name, Info.Export_Count) =
             Export_Lookup_Model (Text, Info, Name, Limit));
         pragma Loop_Variant (Decreases => Limit);
         if Same_Name (Text, Info.Exports (Limit).Name, Name) then return Limit; end if;
         Limit := Limit - 1;
      end loop;
      return 0;
   end Lookup_Export;

   function State_Lookup_Model
     (Text : String; Info : Metadata; Name : Name_Span;
      Limit : State_Count_Type) return State_Count_Type is
     (if Limit = 0 then 0
      elsif Same_Name (Text, Info.States (Limit).Name, Name) then Limit
      else State_Lookup_Model (Text, Info, Name, Limit - 1));

   function Lookup_State
     (Text : String; Info : Metadata; Name : Name_Span) return State_Count_Type is
      Limit : State_Count_Type := Info.State_Count;
   begin
      while Limit > 0 loop
         pragma Loop_Invariant (Limit <= Info.State_Count);
         pragma Loop_Invariant (Static =>
           State_Lookup_Model (Text, Info, Name, Info.State_Count) =
             State_Lookup_Model (Text, Info, Name, Limit));
         pragma Loop_Variant (Decreases => Limit);
         if Same_Name (Text, Info.States (Limit).Name, Name) then return Limit; end if;
         Limit := Limit - 1;
      end loop;
      return 0;
   end Lookup_State;

   function Routine_Lookup_Model
     (Text : String; Info : Metadata; Name : Name_Span;
      Limit : Routine_Count_Type) return Routine_Count_Type is
     (if Limit = 0 then 0
      elsif Same_Name (Text, Info.Routines (Limit).Spec_Name, Name) then Limit
      else Routine_Lookup_Model (Text, Info, Name, Limit - 1));

   function Lookup_Routine
     (Text : String; Info : Metadata; Name : Name_Span;
      Completed_Only : Boolean := True) return Routine_Count_Type is
      Initial : constant Routine_Count_Type :=
        (if Completed_Only then Info.Completed else Info.Routine_Count);
      Limit : Routine_Count_Type := Initial;
   begin
      while Limit > 0 loop
         pragma Loop_Invariant (Limit <= Initial);
         pragma Loop_Invariant (Static =>
           Routine_Lookup_Model (Text, Info, Name, Initial) =
             Routine_Lookup_Model (Text, Info, Name, Limit));
         pragma Loop_Variant (Decreases => Limit);
         if Same_Name (Text, Info.Routines (Limit).Spec_Name, Name) then return Limit; end if;
         Limit := Limit - 1;
      end loop;
      return 0;
   end Lookup_Routine;
end Silver_Package_Bindings;
