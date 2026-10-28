package body Silver_Array_Bindings with SPARK_Mode => On is
   use type Scalars.Wide;
   function Hull_Model
     (Values : Element_Array; First, Last : Element_Index) return Scalars.Interval is
     (if First = Last then Scalars.Singleton (Values (First))
      else Scalars.Join (Hull_Model (Values, First, Last - 1), Scalars.Singleton (Values (Last))));

   function Lookup_Model
     (Text : String; Names : Metadata; First, After : Literal_Position;
      Index : Binding_Count) return Binding_Count is
     (if First = 0 or else After <= First or else Index = 0 then 0
      elsif Equal_Name (Text, Names.Items (Index).First, Names.Items (Index).After,
                        First, After)
      then Index else Lookup_Model (Text, Names, First, After, Index - 1));

   function Lookup
     (Text : String; Names : Metadata; First, After : Literal_Position)
      return Binding_Count is
      Index : Binding_Count := Names.Count;
   begin
      if First = 0 or else After <= First then return 0; end if;
      while Index > 0 loop
         pragma Loop_Invariant (Index <= Names.Count);
         pragma Loop_Invariant (Static =>
           Lookup_Model (Text, Names, First, After, Names.Count)
             = Lookup_Model (Text, Names, First, After, Index));
         pragma Loop_Variant (Decreases => Index);
         if Equal_Name (Text, Names.Items (Index).First, Names.Items (Index).After,
                        First, After)
         then return Index; end if;
         Index := Index - 1;
      end loop;
      return 0;
   end Lookup;

   function Read_Bounds
     (Names : Metadata; Values : Element_Array; Elaborating : Boolean;
      Target : Binding_Index; Index : Scalars.Interval)
      return Scalars.Interval is
      Item : constant Binding := Names.Items (Target);
   begin
      if Elaborating then
         declare
            First_Slot : constant Element_Index := Element_Slot (Item, Index.Lower);
            Last_Slot : constant Element_Index := Element_Slot (Item, Index.Upper);
            Hull : Scalars.Interval := Scalars.Singleton (Values (First_Slot));
         begin
            for Slot in First_Slot + 1 .. Last_Slot loop
               pragma Loop_Invariant (not Scalars.Is_Empty (Hull));
               pragma Loop_Invariant
                 (Static => Hull = Hull_Model (Values, First_Slot, Slot - 1));
               Hull := Scalars.Join (Hull, Scalars.Singleton (Values (Slot)));
            end loop;
            return Hull;
         end;
      else
         return Scalars.Full;
      end if;
   end Read_Bounds;
end Silver_Array_Bindings;
