with Silver_Profile;
with Silver_Output_Lexical;
with Silver_Scalars;

package Silver_Array_Bindings with SPARK_Mode => On is
   use Silver_Profile;
   use Silver_Output_Lexical;
   package Scalars renames Silver_Scalars;
   use type Scalars.Wide;
   use type Scalars.Interval;
   --  The shortest two-component spelling A:array(0..1)of S:=(0,0);
   --  needs 25 bytes; a single-component named association needs more.
   Max_Bindings : constant Positive := Max_Source_Length / 24;
   --  Each explicitly initialized component consumes a scalar token and an
   --  aggregate delimiter. No admitted initializer expands an omitted suffix.
   Max_Elements : constant Positive := Max_Source_Length / 2;
   subtype Binding_Count is Natural range 0 .. Max_Bindings;
   subtype Binding_Index is Positive range 1 .. Max_Bindings;
   subtype Element_Count is Natural range 0 .. Max_Elements;
   subtype Element_Index is Positive range 1 .. Max_Elements;
   type Element_Array is array (Element_Index) of Scalars.Value;
   type Binding is record
      First, After : Literal_Position;
      Bounds : Scalars.Interval;
      Offset, Length : Element_Count;
      Mutable : Boolean;
      Component_Bounds : Scalars.Interval;
   end record;
   Empty_Binding : constant Binding :=
     (0, 0, Scalars.Empty, 0, 0, False, Scalars.Full);
   type Binding_Array is array (Binding_Index) of Binding;
   type Metadata is record
      Count : Binding_Count;
      Items : Binding_Array;
   end record;
   Empty_Metadata : constant Metadata := (0, (others => Empty_Binding));
   Empty_Values : constant Element_Array := (others => 0);
   type Environment is record
      Names : Metadata;
      Used : Element_Count;
      Values : Element_Array;
   end record;
   Empty_Environment : constant Environment := (Empty_Metadata, 0, Empty_Values);

   function Valid_Binding (Item : Binding) return Boolean is
     (not Scalars.Is_Empty (Item.Bounds)
      and then Item.Length > 0
      and then Item.Offset <= Max_Elements - Item.Length
      and then Scalars.Wide (Item.Bounds.Upper) - Scalars.Wide (Item.Bounds.Lower)
        = Scalars.Wide (Item.Length) - 1
      and then not Scalars.Is_Empty (Item.Component_Bounds));
   function Valid_Metadata (Text : String; Names : Metadata) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_Metadata (Text : String; Names : Metadata) return Boolean is
     (for all Index in 1 .. Names.Count =>
        Names.Items (Index).First > 0
        and then Valid_Name_State
          (Text, Names.Items (Index).First, Names.Items (Index).After)
        and then Valid_Binding (Names.Items (Index))
        and then (if Index > 1 then Names.Items (Index).Offset >=
          Names.Items (Index - 1).Offset + Names.Items (Index - 1).Length));
   function Valid_Environment (Text : String; Names : Environment) return Boolean
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length;
   function Valid_Environment (Text : String; Names : Environment) return Boolean is
     (Valid_Metadata (Text, Names.Names)
      and then (for all Index in 1 .. Names.Names.Count =>
        Names.Names.Items (Index).Offset + Names.Names.Items (Index).Length <= Names.Used));
   function Lookup_Model
     (Text : String; Names : Metadata; First, After : Literal_Position;
      Index : Binding_Count) return Binding_Count
     with Ghost => Static, Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Metadata (Text, Names) and then Index <= Names.Count
         and then First <= Text'Last + 1 and then After <= Text'Last + 1,
       Post => Lookup_Model'Result <= Index,
       Subprogram_Variant => (Decreases => Index);
   function Lookup
     (Text : String; Names : Metadata; First, After : Literal_Position)
      return Binding_Count
     with Global => null,
       Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length
         and then Valid_Metadata (Text, Names)
         and then First <= Text'Last + 1 and then After <= Text'Last + 1,
       Post => (Runtime => Lookup'Result <= Names.Count,
         Static => Lookup'Result = Lookup_Model (Text, Names, First, After, Names.Count));
   function Contains (Item : Binding; Index : Scalars.Interval) return Boolean is
     (not Scalars.Is_Empty (Index)
      and then Index.Lower >= Item.Bounds.Lower
      and then Index.Upper <= Item.Bounds.Upper);
   function Element_Slot (Item : Binding; Index : Scalars.Value) return Element_Index is
     (Element_Index ((Scalars.Wide (Item.Offset) + 1)
       + (Scalars.Wide (Index) - Scalars.Wide (Item.Bounds.Lower))))
     with Global => null,
       Pre => Valid_Binding (Item) and then Contains (Item, Scalars.Singleton (Index));
   function Hull_Model
     (Values : Element_Array; First, Last : Element_Index) return Scalars.Interval
     with Ghost => Static, Global => null, Pre => First <= Last,
       Post => not Scalars.Is_Empty (Hull_Model'Result),
       Subprogram_Variant => (Decreases => Last);
   function Read_Bounds
     (Names : Metadata; Values : Element_Array; Elaborating : Boolean;
      Target : Binding_Index; Index : Scalars.Interval)
      return Scalars.Interval
     with Global => null,
       Pre => Target <= Names.Count
         and then Valid_Binding (Names.Items (Target))
         and then Contains (Names.Items (Target), Index),
       Post => (Runtime => not Scalars.Is_Empty (Read_Bounds'Result),
         Static => Read_Bounds'Result =
           (if Elaborating then Hull_Model
              (Values, Element_Slot (Names.Items (Target), Index.Lower),
               Element_Slot (Names.Items (Target), Index.Upper))
            else Names.Items (Target).Component_Bounds));
end Silver_Array_Bindings;
