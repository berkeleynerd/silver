with Silver_Report_Projection_Windows;
with Silver_Report_Observation_Assembly;

package body Silver_Report_Projection_Member_Mapping with SPARK_Mode => On is
   package Projected_Windows renames Silver_Report_Projection_Windows;
   package Assembly renames Silver_Report_Observation_Assembly;

   procedure Classify_Key (Text : Bytes.Sequence; Key : Scan.Span)
   is
   begin
      null;
   end Classify_Key;

   procedure Word_Content
     (Left, Right : Bytes.Sequence; L, R : Scan.Span; Name : String)
     with Global => null, Pre => Relations.Same_Content (Left, L, Right, R),
       Post => Relations.Word (Left, L, Name) = Relations.Word (Right, R, Name)
   is
   begin
      null;
   end Word_Content;

   procedure Assemble_Present_Member
     (Raw : Bytes.Sequence; Object : Scan.Span; Position : Big_Natural)
   is
      M : constant Scan.Member := Scan.Member_Spec (Raw, Object, Position);
      Before_Shift : constant Big_Integer := Projected_Windows.Shift (Raw, Position);
      After_Shift : constant Big_Integer := Projected_Windows.Shift (Raw, M.Value.Last + 1);
   begin
      pragma Assert (Model.Advance_Spec
        (Model.Scan_State (Raw, Object.First - 1), Bytes.Get (Raw, Object.First)).Length = 1);
      pragma Assert (Model.Advance_Spec
        (Model.Scan_State (Raw, Object.Last - 1), Bytes.Get (Raw, Object.Last)).Length = 1);
      Mapping.Nonempty_Range (Raw, Object.First, Object.Last);
      Mapping.Interior_Position (Raw, Object.First, Position, Object.Last);
      Mapping.Interior_End (Raw, M.Value.Last, Object.Last);

      Spans.Retained_Range (Raw, Position, M.Value.First - 1);
      Projected_Windows.Exact_Window (Raw, Position, M.Value.First - 1);
      Projected_Windows.Offset_Within (Raw, Position, M.Value.First - 1, M.Key.First);
      Projected_Windows.Offset_Within (Raw, Position, M.Value.First - 1, M.Key.Last + 1);
      Projected_Windows.Offset_Within (Raw, Position, M.Value.First - 1, M.Value.First);

      Spans.Retained_Range (Raw, M.Value.Last + 1, M.Next);
      Projected_Windows.Exact_Window (Raw, M.Value.Last + 1, M.Next);
      Projected_Windows.Offset_Within (Raw, M.Value.Last + 1, M.Next, M.Next);
      Mapping.Emission_At (Raw, M.Next);
      pragma Assert (Model.Advance_Spec
        (Model.Scan_State (Raw, M.Next - 1), Bytes.Get (Raw, M.Next)).Length = 1);
      pragma Assert (Mapping.First (Raw, M.Next) = Mapping.Last (Raw, M.Next));
      if M.Next < Object.Last then
         Mapping.Interior_End (Raw, M.Next, Object.Last);
      end if;
      pragma Assert ((M.Next = Object.Last) =
        (M.Next + After_Shift = Mapping.Last (Raw, Object.Last)));

      pragma Assert (not Scan.Space (Bytes.Get (Mapping.Output (Raw), Mapping.First (Raw, M.Value.First))));
      Assembly.Member_Transfer
        (Raw, Mapping.Output (Raw), Object, Mapping.Mapped (Raw, Object.First, Object.Last),
         Position, Before_Shift, After_Shift);

      Spans.Retained_Range (Raw, M.Key.First, M.Key.Last);
      Mapping.Exact_Content (Raw, M.Key.First, M.Key.Last);
      declare
         N : constant Scan.Member := Scan.Member_Spec
           (Mapping.Output (Raw), Mapping.Mapped (Raw, Object.First, Object.Last),
            Mapping.First (Raw, Position));
         Target_Key : constant Scan.Span := N.Key;
      begin
         pragma Assert (N = (Scan.Present, Mapping.Mapped (Raw, M.Key.First, M.Key.Last),
           Mapping.Mapped (Raw, M.Value.First, M.Value.Last), Mapping.First (Raw, M.Next)));
         pragma Assert (Relations.Same_Content (Raw, M.Key, Mapping.Output (Raw), Target_Key));
         Classify_Key (Raw, M.Key);
         Classify_Key (Mapping.Output (Raw), Target_Key);
         Word_Content (Raw, Mapping.Output (Raw), M.Key, Target_Key, Relations.Flow_Name);
         Word_Content (Raw, Mapping.Output (Raw), M.Key, Target_Key, Relations.Proof_Name);
         Word_Content (Raw, Mapping.Output (Raw), M.Key, Target_Key, Relations.Tree_Name);
         pragma Assert (Keys.Raw_Key (Raw, M.Key.First, M.Key.Last) =
           Keys.Raw_Key (Mapping.Output (Raw), Target_Key.First, Target_Key.Last));
      end;
   end Assemble_Present_Member;
end Silver_Report_Projection_Member_Mapping;
