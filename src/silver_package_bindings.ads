with Silver_Profile;
with Silver_Output_Lexical;
with Silver_Scalars;
with Silver_Function_Bindings;
with Silver_Procedure_Bindings;
with Silver_Application_Units;

package Silver_Package_Bindings with SPARK_Mode => On is
   use Silver_Output_Lexical;
   use type Silver_Function_Bindings.Scalar_Kind;
   use type Silver_Procedure_Bindings.Parameter_Mode;

   Max_Source_Length : constant Positive := Silver_Profile.Max_Source_Length;
   --  These pools charge original declarations, never repeated captures.
   --  A body-private named-subtype object can occupy seven bytes (A:S:=0;).
   Max_States : constant Positive := Max_Source_Length / 7;
   Max_Exports : constant Positive := Max_Source_Length / 12;
   Max_Routines : constant Positive := Max_Source_Length / 32;
   Max_Formals : constant Positive := Max_Source_Length / 7;

   subtype State_Count_Type is Natural range 0 .. Max_States;
   subtype State_Index is Positive range 1 .. Max_States;
   subtype State_Id is State_Count_Type;
   subtype Export_Count_Type is Natural range 0 .. Max_Exports;
   subtype Export_Index is Positive range 1 .. Max_Exports;
   subtype Routine_Count_Type is Natural range 0 .. Max_Routines;
   subtype Routine_Index is Positive range 1 .. Max_Routines;
   subtype Formal_Count_Type is Natural range 0 .. Max_Formals;
   subtype Formal_Index is Positive range 1 .. Max_Formals;

   type Name_Span is record
      First, After : Literal_Position := 0;
   end record;
   No_Name : constant Name_Span := (0, 0);

   --  0 denotes predefined Boolean, 1 predefined Integer, and I+1 denotes
   --  the named Integer subtype declared by Exports(I). Identity is retained
   --  even when two different subtype declarations have equal bounds.
   subtype Type_Id is Natural range 0 .. Max_Exports + 1;
   Boolean_Type : constant Type_Id := 0;
   Integer_Type : constant Type_Id := 1;

   type Export_Kind is
     (Integer_Subtype, Integer_Constant, Boolean_Constant);
   type Export_Declaration is record
      Name : Name_Span := No_Name;
      Kind : Export_Kind := Integer_Subtype;
      Bounds : Silver_Scalars.Interval := Silver_Scalars.Empty;
      Type_Name : Name_Span := No_Name;
      Type_Identity : Type_Id := Integer_Type;
      Initializer_First, Initializer_After : Literal_Position := 0;
      Boolean_Value : Boolean := False;
   end record;
   type Export_Array is array (Export_Index) of Export_Declaration;

   type State_Declaration is record
      Name : Name_Span := No_Name;
      Kind : Silver_Function_Bindings.Scalar_Kind :=
        Silver_Function_Bindings.Integer_Kind;
      Type_Name : Name_Span := No_Name;
      Type_Identity : Type_Id := Integer_Type;
      Declared_Bounds : Silver_Scalars.Interval := Silver_Scalars.Empty;
      Initial_Bounds : Silver_Scalars.Interval := Silver_Scalars.Empty;
      Initializer_First, Initializer_After : Literal_Position := 0;
      Boolean_Initial : Boolean := False;
   end record;
   type State_Array is array (State_Index) of State_Declaration;

   --  State identity is declaration order. The two sets remain separate from
   --  the explicit formal pool, including for routines that capture all state.
   type State_Set is array (State_Index) of Boolean with Pack;
   Empty_State_Set : constant State_Set := (others => False);

   type Formal is record
      Spec_Name, Body_Name : Name_Span := No_Name;
      Spec_Type_Name, Body_Type_Name : Name_Span := No_Name;
      Kind : Silver_Function_Bindings.Scalar_Kind :=
        Silver_Function_Bindings.Integer_Kind;
      Bounds : Silver_Scalars.Interval := Silver_Scalars.Empty;
      Type_Identity : Type_Id := Integer_Type;
      Mode : Silver_Procedure_Bindings.Parameter_Mode :=
        Silver_Procedure_Bindings.Input;
   end record;
   type Formal_Array is array (Formal_Index) of Formal;

   type Routine_Kind is (Function_Routine, Procedure_Routine);
   type Routine is record
      Kind : Routine_Kind := Procedure_Routine;
      Spec_Name, Body_Name : Name_Span := No_Name;
      Spec_First, Spec_After : Literal_Position := 0;
      Body_First, Body_After : Literal_Position := 0;
      Formal_First : Formal_Count_Type := 0;
      Count : Formal_Count_Type := 0;
      Result_Kind : Silver_Function_Bindings.Scalar_Kind :=
        Silver_Function_Bindings.Integer_Kind;
      Result_Bounds : Silver_Scalars.Interval := Silver_Scalars.Empty;
      Result_Type_Identity : Type_Id := Integer_Type;
      Spec_Result_Name, Body_Result_Name : Name_Span := No_Name;
      May_Read, May_Write : State_Set := Empty_State_Set;
      Assigned : Boolean := False;
   end record;
   type Routine_Array is array (Routine_Index) of Routine;

   type Metadata is record
      Name_First, Name_After : Literal_Position := 0;
      Body_Name_First, Body_Name_After : Literal_Position := 0;
      Units : Silver_Application_Units.Span_Array := (others => (1, 1));
      Export_Count : Export_Count_Type := 0;
      Exports : Export_Array := (others => (others => <>));
      State_Count : State_Count_Type := 0;
      States : State_Array := (others => (others => <>));
      Routine_Count : Routine_Count_Type := 0;
      Routines : Routine_Array := (others => (others => <>));
      Completed : Routine_Count_Type := 0;
      Parameter_Count : Formal_Count_Type := 0;
      Parameters : Formal_Array := (others => (others => <>));
      Assigned : Boolean := False;
   end record;
   Empty_Metadata : constant Metadata := (others => <>);

   --  Total predicates also support the driver's discovery boundary and the
   --  report adapter's rejection of malformed metadata.
   function Is_Identifier (Name : String) return Boolean
     with Global => null;
   function Is_Identifier (Name : String) return Boolean is
     (Name'Length in 1 .. Max_Source_Length
      and then Is_Letter (Name (Name'First))
      and then Name (Name'Last) /= '_'
      and then (for all I in Name'Range =>
        Silver_Profile.Is_Identifier_Character (Name (I))
        and then (if Name (I) = '_' then
          I > Name'First and then Name (I - 1) /= '_')));

   function Valid_Name (Text : String; Name : Name_Span) return Boolean is
     (Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
      and then Name.First > 0 and then Name.First < Name.After
      and then Name.After <= Text'Last + 1
      and then Is_Identifier (Text (Name.First .. Name.After - 1)))
     with Global => null;

   function In_Unit
     (Name : Name_Span; Unit : Silver_Application_Units.Span) return Boolean is
     (Name.First >= Unit.First and then Name.First < Name.After
      and then Name.After <= Unit.After)
     with Global => null;

   function Same_Name
     (Text : String; Left, Right : Name_Span) return Boolean is
     (Valid_Name (Text, Left) and then Valid_Name (Text, Right)
      and then Equal_Name
        (Text, Left.First, Left.After, Right.First, Right.After))
     with Global => null;

   function Union (Left, Right : State_Set) return State_Set is
     (for I in State_Index => Left (I) or Right (I))
     with Global => null,
       Post => (for all I in State_Index =>
         Union'Result (I) = (Left (I) or Right (I)));

   function Within (Effect : State_Set; Count : State_Count_Type) return Boolean is
     (for all I in State_Index => (if I > Count then not Effect (I)))
     with Global => null;

   function Valid_Metadata (Text : String; Info : Metadata) return Boolean
     with Global => null,
       Post => (if Valid_Metadata'Result then
         Valid_Name (Text, (Info.Name_First, Info.Name_After))
         and then Info.Units (Silver_Application_Units.Main_Body).First
           <= Text'Last + 1);
   function Complete_Metadata (Text : String; Info : Metadata) return Boolean is
     (Valid_Metadata (Text, Info)
      and then Info.Body_Name_First > 0
      and then Info.Completed = Info.Routine_Count)
     with Global => null;

   function Export_Lookup_Model
     (Text : String; Info : Metadata; Name : Name_Span;
      Limit : Export_Count_Type) return Export_Count_Type
     with Ghost => Static, Global => null,
       Pre => Limit <= Info.Export_Count,
       Post => Export_Lookup_Model'Result <= Limit,
       Subprogram_Variant => (Decreases => Limit);
   function Lookup_Export
     (Text : String; Info : Metadata; Name : Name_Span) return Export_Count_Type
     with Global => null,
       Post => (Runtime => Lookup_Export'Result <= Info.Export_Count,
         Static => Lookup_Export'Result =
           Export_Lookup_Model (Text, Info, Name, Info.Export_Count));

   function State_Lookup_Model
     (Text : String; Info : Metadata; Name : Name_Span;
      Limit : State_Count_Type) return State_Count_Type
     with Ghost => Static, Global => null,
       Pre => Limit <= Info.State_Count,
       Post => State_Lookup_Model'Result <= Limit,
       Subprogram_Variant => (Decreases => Limit);
   function Lookup_State
     (Text : String; Info : Metadata; Name : Name_Span) return State_Count_Type
     with Global => null,
       Post => (Runtime => Lookup_State'Result <= Info.State_Count,
         Static => Lookup_State'Result =
           State_Lookup_Model (Text, Info, Name, Info.State_Count));

   function Routine_Lookup_Model
     (Text : String; Info : Metadata; Name : Name_Span;
      Limit : Routine_Count_Type) return Routine_Count_Type
     with Ghost => Static, Global => null,
       Pre => Limit <= Info.Routine_Count,
       Post => Routine_Lookup_Model'Result <= Limit,
       Subprogram_Variant => (Decreases => Limit);
   function Lookup_Routine
     (Text : String; Info : Metadata; Name : Name_Span;
      Completed_Only : Boolean := True) return Routine_Count_Type
     with Global => null,
       Pre => Info.Completed <= Info.Routine_Count,
       Post => (Runtime => Lookup_Routine'Result <=
           (if Completed_Only then Info.Completed else Info.Routine_Count),
         Static => Lookup_Routine'Result = Routine_Lookup_Model
           (Text, Info, Name,
            (if Completed_Only then Info.Completed else Info.Routine_Count)));
end Silver_Package_Bindings;
