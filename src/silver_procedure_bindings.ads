with Silver_Profile;
with Silver_Output_Lexical;
with Silver_Scalars;
with Silver_Array_Bindings;
with Silver_Function_Bindings;

package Silver_Procedure_Bindings with SPARK_Mode => On is
   use Silver_Profile;
   use type Silver_Function_Bindings.Scalar_Kind;
   use Silver_Output_Lexical;

   --  Every complete procedure consumes more than 32 source bytes. Each
   --  single-name explicit-mode formal consumes at least seven disjoint bytes.
   Max_Procedures : constant Positive := Max_Source_Length / 32;
   Max_Formals : constant Positive := Max_Source_Length / 7;
   subtype Procedure_Count is Natural range 0 .. Max_Procedures;
   subtype Procedure_Index is Positive range 1 .. Max_Procedures;
   subtype Formal_Count is Natural range 0 .. Max_Formals;
   subtype Formal_Index is Positive range 1 .. Max_Formals;
   type Parameter_Mode is (Input, Output, Input_Output);
   type Formal is record
      First, After : Literal_Position;
      Kind : Silver_Function_Bindings.Scalar_Kind;
      Bounds : Silver_Scalars.Interval;
      Type_Id : Silver_Array_Bindings.Type_Count := 0;
      Mode : Parameter_Mode;
   end record;
   Empty_Formal : constant Formal :=
     (0, 0, Silver_Function_Bindings.Integer_Kind, Silver_Scalars.Empty, 0, Input);
   type Formal_Array is array (Formal_Index) of Formal;
   type Signature is record
      First, After : Literal_Position;
      Formal_First : Formal_Count;
      Count : Formal_Count;
   end record;
   Empty_Signature : constant Signature := (0, 0, 0, 0);
   type Signature_Array is array (Procedure_Index) of Signature;
   type Metadata is record
      Count : Procedure_Count;
      Items : Signature_Array;
      Parameter_Count : Formal_Count;
      Parameters : Formal_Array;
   end record;
   Empty_Metadata : constant Metadata :=
     (0, (others => Empty_Signature), 0, (others => Empty_Formal));

   function Valid_Metadata (Text : String; Procedures : Metadata) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_Metadata (Text : String; Procedures : Metadata) return Boolean is
     ((for all I in 1 .. Procedures.Parameter_Count =>
         Procedures.Parameters (I).First > 0
         and then Valid_Name_State
           (Text, Procedures.Parameters (I).First, Procedures.Parameters (I).After)
         and then not Silver_Scalars.Is_Empty (Procedures.Parameters (I).Bounds)
         and then (if Procedures.Parameters (I).Type_Id /= 0 then
           Procedures.Parameters (I).Mode = Input
           and then Procedures.Parameters (I).Kind = Silver_Function_Bindings.Integer_Kind))
      and then (for all I in 1 .. Procedures.Count =>
         Procedures.Items (I).First > 0
         and then Valid_Name_State
           (Text, Procedures.Items (I).First, Procedures.Items (I).After)
         and then Procedures.Items (I).Count > 0
         and then Procedures.Items (I).Formal_First > 0
         and then Procedures.Items (I).Formal_First <= Procedures.Parameter_Count
         and then Procedures.Items (I).Count <=
           Procedures.Parameter_Count - Procedures.Items (I).Formal_First + 1));

   function Lookup_Model
     (Text : String; Procedures : Metadata; First, After : Literal_Position;
      Index : Procedure_Count) return Procedure_Count
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Metadata (Text, Procedures) and then Index <= Procedures.Count
         and then First <= Text'Last + 1 and then After <= Text'Last + 1,
       Post => Lookup_Model'Result <= Index,
       Subprogram_Variant => (Decreases => Index);
   function Lookup
     (Text : String; Procedures : Metadata; First, After : Literal_Position)
      return Procedure_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Metadata (Text, Procedures)
         and then First <= Text'Last + 1 and then After <= Text'Last + 1,
       Post => (Runtime => Lookup'Result <= Procedures.Count,
         Static => Lookup'Result =
           Lookup_Model (Text, Procedures, First, After, Procedures.Count));
   function Append_Formal (Procedures : Metadata; Item : Formal) return Metadata is
     (Procedures with delta Parameter_Count => Procedures.Parameter_Count + 1,
       Parameters => (Procedures.Parameters with delta Procedures.Parameter_Count + 1 => Item))
     with Pre => Procedures.Parameter_Count < Max_Formals;
   function Append (Procedures : Metadata; Item : Signature) return Metadata is
     (Procedures with delta Count => Procedures.Count + 1,
       Items => (Procedures.Items with delta Procedures.Count + 1 => Item))
     with Pre => Procedures.Count < Max_Procedures;
end Silver_Procedure_Bindings;
