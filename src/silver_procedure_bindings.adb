package body Silver_Procedure_Bindings with SPARK_Mode => On is
   function Lookup_Model
     (Text : String; Procedures : Metadata; First, After : Literal_Position;
      Index : Procedure_Count) return Procedure_Count is
     (if First = 0 or else After <= First or else Index = 0 then 0
      elsif Equal_Name (Text, Procedures.Items (Index).First,
                       Procedures.Items (Index).After, First, After)
      then Index
      else Lookup_Model (Text, Procedures, First, After, Index - 1));

   function Lookup
     (Text : String; Procedures : Metadata; First, After : Literal_Position)
      return Procedure_Count is
      Index : Procedure_Count := Procedures.Count;
   begin
      if First = 0 or else After <= First then return 0; end if;
      while Index > 0 loop
         pragma Loop_Invariant (Index <= Procedures.Count);
         pragma Loop_Invariant (Static =>
           Lookup_Model (Text, Procedures, First, After, Procedures.Count)
             = Lookup_Model (Text, Procedures, First, After, Index));
         pragma Loop_Variant (Decreases => Index);
         if Equal_Name (Text, Procedures.Items (Index).First,
                        Procedures.Items (Index).After, First, After)
         then
            return Index;
         end if;
         Index := Index - 1;
      end loop;
      return 0;
   end Lookup;
end Silver_Procedure_Bindings;
