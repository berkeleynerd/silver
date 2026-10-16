with SPARK.Big_Integers;
with Silver_Report_Observations;

--  Byte-derived structural agreement between an original report and its
--  projected representation. No definition mentions audit acceptance or calls
--  the projector. Ordered member observations retain duplicate-key behavior.
package Silver_Report_Projection_Observations
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   package Scan renames Silver_Report_Observations;
   package Bytes renames Scan.Bytes;
   use type Bytes.Sequence;
   use type Scan.Member_State;

   Flow_Name : constant String := "flow";
   Proof_Name : constant String := "proof";
   Tree_Name : constant String := "check_tree";

   function Word (Text : Bytes.Sequence; Item : Scan.Span; Expected : String)
     return Boolean is
     (Scan.Valid (Text, Item)
      and then Item.Last - Item.First = To_Big_Integer (Expected'Length) + 1
      and then Bytes.Get (Text, Item.First) = '"'
      and then Bytes.Get (Text, Item.Last) = '"'
      and then (for all I in Expected'Range =>
        Bytes.Get (Text, Item.First + 1 + To_Big_Integer (I - Expected'First)) = Expected (I)));

   function Same_Content
     (Raw : Bytes.Sequence; L : Scan.Span; Projected : Bytes.Sequence; R : Scan.Span)
     return Boolean is
     (Scan.Valid (Raw, L) and then Scan.Valid (Projected, R)
      and then L.Last - L.First = R.Last - R.First
      and then (for all I in Raw =>
        (if I >= L.First and then I <= L.Last then
           Bytes.Get (Raw, I) = Bytes.Get (Projected, R.First + I - L.First))));

   function Empty_Object (Text : Bytes.Sequence; Item : Scan.Span) return Boolean is
     (Scan.Valid (Text, Item) and then Item.Last = Item.First + 1
      and then Bytes.Get (Text, Item.First) = '{'
      and then Bytes.Get (Text, Item.Last) = '}');

   function Record_Members
     (Raw : Bytes.Sequence; L : Scan.Span; LP : Scan.Offset;
      Projected : Bytes.Sequence; R : Scan.Span; RP : Scan.Offset) return Boolean
     with Global => null,
       Pre => Scan.Valid (Raw, L) and then Scan.Valid (Projected, R)
         and then LP >= L.First + 1 and then LP <= Bytes.Length (Raw) + 1
         and then RP >= R.First + 1 and then RP <= Bytes.Length (Projected) + 1,
       Subprogram_Variant => (Decreases => Bytes.Length (Raw) + 1 - LP);

   function Record_Members
     (Raw : Bytes.Sequence; L : Scan.Span; LP : Scan.Offset;
      Projected : Bytes.Sequence; R : Scan.Span; RP : Scan.Offset) return Boolean is
     (declare LM : constant Scan.Member := Scan.Member_Spec (Raw, L, LP);
              RM : constant Scan.Member := Scan.Member_Spec (Projected, R, RP);
      begin LM.State = RM.State and then
        (case LM.State is
           when Scan.Broken | Scan.Finished => True,
           when Scan.Present =>
             Same_Content (Raw, LM.Key, Projected, RM.Key)
             and then
               (if Word (Raw, LM.Key, Tree_Name) then Empty_Object (Projected, RM.Value)
                else Same_Content (Raw, LM.Value, Projected, RM.Value))
             and then Record_Members (Raw, L, LM.Next, Projected, R, RM.Next)));

   function Check_Record
     (Raw : Bytes.Sequence; L : Scan.Span; Projected : Bytes.Sequence; R : Scan.Span)
     return Boolean is
     (Scan.Valid (Raw, L) and then Scan.Valid (Projected, R)
      and then Bytes.Get (Raw, L.First) = '{' and then Bytes.Get (Raw, L.Last) = '}'
      and then Bytes.Get (Projected, R.First) = '{' and then Bytes.Get (Projected, R.Last) = '}'
      and then Record_Members (Raw, L, L.First + 1, Projected, R, R.First + 1));

   function List_Items
     (Raw : Bytes.Sequence; L : Scan.Span; LP : Scan.Offset;
      Projected : Bytes.Sequence; R : Scan.Span; RP : Scan.Offset) return Boolean
     with Global => null,
       Pre => Scan.Valid (Raw, L) and then Scan.Valid (Projected, R)
         and then LP >= L.First + 1 and then LP <= Bytes.Length (Raw) + 1
         and then RP >= R.First + 1 and then RP <= Bytes.Length (Projected) + 1,
       Subprogram_Variant => (Decreases => Bytes.Length (Raw) + 1 - LP);

   function List_Items
     (Raw : Bytes.Sequence; L : Scan.Span; LP : Scan.Offset;
      Projected : Bytes.Sequence; R : Scan.Span; RP : Scan.Offset) return Boolean is
     (declare LM : constant Scan.Member := Scan.Item_Spec (Raw, L, LP);
              RM : constant Scan.Member := Scan.Item_Spec (Projected, R, RP);
      begin LM.State = RM.State and then
        (case LM.State is
           when Scan.Broken | Scan.Finished => True,
           when Scan.Present =>
             Check_Record (Raw, LM.Value, Projected, RM.Value)
             and then List_Items (Raw, L, LM.Next, Projected, R, RM.Next)));

   function Check_List
     (Raw : Bytes.Sequence; L : Scan.Span; Projected : Bytes.Sequence; R : Scan.Span)
     return Boolean is
     (Scan.Valid (Raw, L) and then Scan.Valid (Projected, R)
      and then Bytes.Get (Raw, L.First) = Bytes.Get (Projected, R.First)
      and then Bytes.Get (Raw, L.Last) = Bytes.Get (Projected, R.Last)
      and then (if Bytes.Get (Raw, L.First) = '[' and then Bytes.Get (Raw, L.Last) = ']'
        then List_Items (Raw, L, L.First + 1, Projected, R, R.First + 1)
        else Same_Content (Raw, L, Projected, R)));

   function Root_Members
     (Raw : Bytes.Sequence; L : Scan.Span; LP : Scan.Offset;
      Projected : Bytes.Sequence; R : Scan.Span; RP : Scan.Offset) return Boolean
     with Global => null,
       Pre => Scan.Valid (Raw, L) and then Scan.Valid (Projected, R)
         and then LP >= L.First + 1 and then LP <= Bytes.Length (Raw) + 1
         and then RP >= R.First + 1 and then RP <= Bytes.Length (Projected) + 1,
       Subprogram_Variant => (Decreases => Bytes.Length (Raw) + 1 - LP);

   function Root_Members
     (Raw : Bytes.Sequence; L : Scan.Span; LP : Scan.Offset;
      Projected : Bytes.Sequence; R : Scan.Span; RP : Scan.Offset) return Boolean is
     (declare LM : constant Scan.Member := Scan.Member_Spec (Raw, L, LP);
              RM : constant Scan.Member := Scan.Member_Spec (Projected, R, RP);
      begin LM.State = RM.State and then
        (case LM.State is
           when Scan.Broken | Scan.Finished => True,
           when Scan.Present =>
             Same_Content (Raw, LM.Key, Projected, RM.Key)
             and then
               (if Word (Raw, LM.Key, Flow_Name) or else Word (Raw, LM.Key, Proof_Name)
                then Check_List (Raw, LM.Value, Projected, RM.Value)
                else Same_Content (Raw, LM.Value, Projected, RM.Value))
             and then Root_Members (Raw, L, LM.Next, Projected, R, RM.Next)));

   function Root_Objects
     (Raw : Bytes.Sequence; L : Scan.Span; Projected : Bytes.Sequence; R : Scan.Span)
     return Boolean is
     (Scan.Valid (Raw, L) and then Scan.Valid (Projected, R)
      and then Bytes.Get (Raw, L.First) = '{' and then Bytes.Get (Raw, L.Last) = '}'
      and then Bytes.Get (Projected, R.First) = '{' and then Bytes.Get (Projected, R.Last) = '}'
      and then Root_Members (Raw, L, L.First + 1, Projected, R, R.First + 1));

   function Audit_Projection_Observations (Raw, Projected : Bytes.Sequence) return Boolean is
     (Raw = Projected or else
       (declare LS : constant Scan.Offset := Scan.Space_End (Raw, 1);
                LL : constant Scan.Offset := Scan.Value_Spec (Raw, LS);
                RS : constant Scan.Offset := Scan.Space_End (Projected, 1);
                RL : constant Scan.Offset := Scan.Value_Spec (Projected, RS);
        begin LL /= 0 and then RL /= 0
          and then Scan.Space_End (Raw, LL + 1) = Bytes.Length (Raw) + 1
          and then Scan.Space_End (Projected, RL + 1) = Bytes.Length (Projected) + 1
          and then Root_Objects (Raw, (LS, LL), Projected, (RS, RL))));
end Silver_Report_Projection_Observations;
