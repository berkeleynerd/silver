with Silver_Profile;
with Silver_Output_Lexical;
with Silver_Scalars;
with Silver_Array_Bindings;

package Silver_Function_Bindings with SPARK_Mode => On is
   use Silver_Profile;
   use Silver_Output_Lexical;

   --  Every complete function consumes more than 32 source bytes. Each
   --  single-name explicit-in formal consumes at least seven disjoint bytes.
   Max_Functions : constant Positive := Max_Source_Length / 32;
   Max_Formals : constant Positive := Max_Source_Length / 7;
   subtype Function_Count is Natural range 0 .. Max_Functions;
   subtype Function_Index is Positive range 1 .. Max_Functions;
   subtype Formal_Count is Natural range 0 .. Max_Formals;
   subtype Formal_Index is Positive range 1 .. Max_Formals;
   type Scalar_Kind is (Integer_Kind, Boolean_Kind);
   type Formal is record
      First, After : Literal_Position;
      Kind : Scalar_Kind;
      Bounds : Silver_Scalars.Interval;
      Type_Id : Silver_Array_Bindings.Type_Count := 0;
   end record;
   Empty_Formal : constant Formal := (0, 0, Integer_Kind, Silver_Scalars.Empty, 0);
   type Formal_Array is array (Formal_Index) of Formal;
   type Signature is record
      First, After : Literal_Position;
      Formal_First : Formal_Count;
      Count : Formal_Count;
      Result_Kind : Scalar_Kind;
      Result_Bounds : Silver_Scalars.Interval;
   end record;
   Empty_Signature : constant Signature :=
     (0, 0, 0, 0, Integer_Kind, Silver_Scalars.Empty);
   type Signature_Array is array (Function_Index) of Signature;
   type Metadata is record
      Count : Function_Count;
      Items : Signature_Array;
      Parameter_Count : Formal_Count;
      Parameters : Formal_Array;
   end record;
   Empty_Metadata : constant Metadata :=
     (0, (others => Empty_Signature), 0, (others => Empty_Formal));

   function Valid_Metadata (Text : String; Functions : Metadata) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_Metadata (Text : String; Functions : Metadata) return Boolean is
     ((for all I in 1 .. Functions.Parameter_Count =>
         Functions.Parameters (I).First > 0
         and then Valid_Name_State
           (Text, Functions.Parameters (I).First, Functions.Parameters (I).After)
         and then not Silver_Scalars.Is_Empty (Functions.Parameters (I).Bounds)
         and then (if Functions.Parameters (I).Type_Id /= 0 then
           Functions.Parameters (I).Kind = Integer_Kind))
      and then (for all I in 1 .. Functions.Count =>
         Functions.Items (I).First > 0
         and then Valid_Name_State
           (Text, Functions.Items (I).First, Functions.Items (I).After)
         and then Functions.Items (I).Count > 0
         and then Functions.Items (I).Formal_First > 0
         and then Functions.Items (I).Formal_First <= Functions.Parameter_Count
         and then Functions.Items (I).Count <=
           Functions.Parameter_Count - Functions.Items (I).Formal_First + 1
         and then not Silver_Scalars.Is_Empty (Functions.Items (I).Result_Bounds)));

   function Lookup_Model
     (Text : String; Functions : Metadata; First, After : Literal_Position;
      Index : Function_Count) return Function_Count
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Metadata (Text, Functions) and then Index <= Functions.Count
         and then First <= Text'Last + 1 and then After <= Text'Last + 1,
       Post => Lookup_Model'Result <= Index,
       Subprogram_Variant => (Decreases => Index);
   function Lookup
     (Text : String; Functions : Metadata; First, After : Literal_Position)
      return Function_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Metadata (Text, Functions)
         and then First <= Text'Last + 1 and then After <= Text'Last + 1,
       Post => (Runtime => Lookup'Result <= Functions.Count,
         Static => Lookup'Result =
           Lookup_Model (Text, Functions, First, After, Functions.Count));
   function Append_Formal (Functions : Metadata; Item : Formal) return Metadata is
     (Functions with delta Parameter_Count => Functions.Parameter_Count + 1,
       Parameters => (Functions.Parameters with delta Functions.Parameter_Count + 1 => Item))
     with Pre => Functions.Parameter_Count < Max_Formals;
   function Append (Functions : Metadata; Item : Signature) return Metadata is
     (Functions with delta Count => Functions.Count + 1,
       Items => (Functions.Items with delta Functions.Count + 1 => Item))
     with Pre => Functions.Count < Max_Functions;
end Silver_Function_Bindings;
