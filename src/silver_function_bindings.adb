package body Silver_Function_Bindings with SPARK_Mode => On is
   function Lookup_Model
     (Text : String; Functions : Metadata; First, After : Literal_Position;
      Index : Function_Count) return Function_Count is
     (if First = 0 or else After <= First or else Index = 0 then 0
      elsif Equal_Name (Text, Functions.Items (Index).First,
                       Functions.Items (Index).After, First, After)
      then Index
      else Lookup_Model (Text, Functions, First, After, Index - 1));

   function Lookup
     (Text : String; Functions : Metadata; First, After : Literal_Position)
      return Function_Count is
      Index : Function_Count := Functions.Count;
   begin
      if First = 0 or else After <= First then return 0; end if;
      while Index > 0 loop
         pragma Loop_Invariant (Index <= Functions.Count);
         pragma Loop_Invariant (Static =>
           Lookup_Model (Text, Functions, First, After, Functions.Count)
             = Lookup_Model (Text, Functions, First, After, Index));
         pragma Loop_Variant (Decreases => Index);
         if Equal_Name (Text, Functions.Items (Index).First,
                        Functions.Items (Index).After, First, After)
         then
            return Index;
         end if;
         Index := Index - 1;
      end loop;
      return 0;
   end Lookup;
end Silver_Function_Bindings;
