package body Silver_Report_Projection_Model with SPARK_Mode => On is
   procedure Advance_Congruence (Left, Right : State; Item : Character) is
   begin
      null;
   end Advance_Congruence;

   procedure Emission_Congruence
     (Left, Right : Byte_Sequences.Sequence; LT, RT : Transition) is
   begin
      Byte_Sequences.Lemma_Eq_Extensional (Left, Right);
   end Emission_Congruence;

   procedure Scan_Prefix
     (Left, Right : Byte_Sequences.Sequence; Count : Big_Natural) is
   begin
      if Count > 0 then
         Scan_Prefix (Left, Right, Count - 1);
         pragma Assert (Byte_Sequences.Get (Left, Count) = Byte_Sequences.Get (Right, Count));
         Advance_Congruence
           (Scan_State (Left, Count - 1), Scan_State (Right, Count - 1),
            Byte_Sequences.Get (Left, Count));
         Emission_Congruence
           (Scan_Bytes (Left, Count - 1), Scan_Bytes (Right, Count - 1),
            Advance_Spec (Scan_State (Left, Count - 1), Byte_Sequences.Get (Left, Count)),
            Advance_Spec (Scan_State (Right, Count - 1), Byte_Sequences.Get (Right, Count)));
         pragma Assert (Scan_State (Left, Count) = Advance_Spec
           (Scan_State (Left, Count - 1), Byte_Sequences.Get (Left, Count)).Following);
         pragma Assert (Scan_State (Right, Count) = Advance_Spec
           (Scan_State (Right, Count - 1), Byte_Sequences.Get (Right, Count)).Following);
         pragma Assert (Advance_Spec
           (Scan_State (Left, Count - 1), Byte_Sequences.Get (Left, Count)) = Advance_Spec
           (Scan_State (Right, Count - 1), Byte_Sequences.Get (Right, Count)));
         pragma Assert (Scan_State (Left, Count) = Scan_State (Right, Count));
      else
         pragma Assert (Scan_State (Left, Count) = Initial_State);
         pragma Assert (Scan_State (Right, Count) = Initial_State);
      end if;
   end Scan_Prefix;

   procedure Extend_Observations
     (Raw, Emitted : Byte_Sequences.Sequence; Current : State; Item : Character)
   is
      Extended : constant Byte_Sequences.Sequence := Byte_Sequences.Add (Raw, Item);
   begin
      Scan_Prefix (Raw, Extended, Byte_Sequences.Length (Raw));
      pragma Assert (Scan (Extended, Byte_Sequences.Length (Raw)).Current = Current);
      pragma Assert (Scan (Extended, Byte_Sequences.Length (Raw)).Emitted = Emitted);
      Byte_Sequences.Lemma_Eq_Extensional
        (Scan (Extended, Byte_Sequences.Length (Raw)).Emitted, Emitted);
      Advance_Congruence
        (Scan_State (Extended, Byte_Sequences.Length (Raw)), Current, Item);
      Emission_Congruence
        (Scan_Bytes (Extended, Byte_Sequences.Length (Raw)), Emitted,
         Advance_Spec (Scan_State (Extended, Byte_Sequences.Length (Raw)), Item),
         Advance_Spec (Current, Item));
      pragma Assert (Scan_State (Extended, Byte_Sequences.Length (Extended)) =
        Advance_Spec (Current, Item).Following);
   end Extend_Observations;
end Silver_Report_Projection_Model;
