package body Silver_Report_Projection_Keys with SPARK_Mode => On is
   function Key_Context
     (Raw : Bytes.Sequence; Start, Position, Slash : Big_Natural;
      S : State; Base : Positive) return Boolean is
     (S.Depth = Base and then S.String_Is_Key
      and then S.Mode in In_String | After_Escape | Unicode_Escape
      and then S.Stack (Base).Position in First_Key | Next_Key
      and then S.Name_Escaped = (Slash /= 0)
      and then
        (if Slash /= 0 then Start < Slash and then Slash < Position
           and then Bytes.Get (Raw, Slash) = '\'
         else S.Mode = In_String
           and then To_Big_Integer (S.Name_Length) =
             (if Position - Start - 1 <= 10 then Position - Start - 1 else 11)
           and then (for all I in 1 .. Natural'Min (S.Name_Length, 10) =>
             S.Name (I) = Bytes.Get (Raw, Start + To_Big_Integer (I)))))
     with Pre => Start >= 1 and then Start < Position
       and then Position <= Bytes.Length (Raw) + 1 and then Base <= Max_Depth;

   procedure Captured_Word
     (Raw : Bytes.Sequence; Start, Last, Slash : Big_Natural;
      S : State; Base : Positive; Name : String)
     with Global => null,
       Pre => Start >= 1 and then Start < Last and then Last <= Bytes.Length (Raw)
         and then Base <= Max_Depth
         and then Key_Context (Raw, Start, Last, Slash, S, Base)
         and then Bytes.Get (Raw, Start) = '"' and then Bytes.Get (Raw, Last) = '"'
         and then Name'First = 1 and then Name'Length in 1 .. 10
         and then (for all C of Name => C /= '\'),
       Post => Word (Raw, Start, Last, Name) =
         (not S.Name_Escaped and then S.Name_Length = Name'Length
          and then S.Name (1 .. Name'Length) = Name)
   is
   begin
      if Slash /= 0 then
         if Word (Raw, Start, Last, Name) then
            pragma Assert (Slash - Start >= 1 and then Slash - Start <= To_Big_Integer (Name'Length));
            declare
               I : constant Positive := To_Integer (Slash - Start);
            begin
               pragma Assert (I in Name'Range);
               pragma Assert (Bytes.Get (Raw, Slash) = Name (I));
            end;
         end if;
      elsif S.Name_Length = Name'Length then
         pragma Assert (Last = Start + To_Big_Integer (Name'Length) + 1);
         pragma Assert (for all I in Name'Range =>
           S.Name (I) = Bytes.Get (Raw, Start + To_Big_Integer (I)));
      else
         pragma Assert (Last /= Start + To_Big_Integer (Name'Length) + 1);
      end if;
   end Captured_Word;

   procedure Captured_Classification (S : State)
     with Global => null,
       Post => Model.Key_Name (S) =
         (if S.Name_Escaped then Other_Key
          elsif S.Name_Length = 4 and then S.Name (1 .. 4) = Flow_Name then Flow_Key
          elsif S.Name_Length = 5 and then S.Name (1 .. 5) = Proof_Name then Proof_Key
          elsif S.Name_Length = 10 and then S.Name = Tree_Name then Tree_Key
          else Other_Key)
   is
   begin
      null;
   end Captured_Classification;

   procedure Key_Step (S : State; C : Character)
     with Global => null,
       Pre => Structure.Well_Formed (S) and then not S.Failed
         and then Structure.String_Mode (S) and then S.String_Is_Key
         and then S.Depth > 0
         and then not Model.Advance_Spec (S, C).Following.Failed,
       Post => Frames_Preserved (S, Model.Advance_Spec (S, C).Following, S.Depth)
         and then Model.Keeping (Model.Advance_Spec (S, C).Following) = Model.Keeping (S)
         and then (if Model.Keeping (S) then Model.Advance_Spec (S, C).Length = 1
           and then Model.Advance_Spec (S, C).Bytes (1) = C)
         and then (if S.Mode /= In_String or else C /= '"' then
           Structure.String_Mode (Model.Advance_Spec (S, C).Following)
           and then Model.Advance_Spec (S, C).Following.String_Is_Key)
   is
   begin
      null;
   end Key_Step;

   procedure Retained_Head (Raw : Bytes.Sequence; First, Last : Big_Natural)
     with Global => null,
       Pre => First >= 1 and then First <= Last and then Last <= Bytes.Length (Raw)
         and then Spans.Retained (Raw, First + 1, Last)
         and then Model.Advance_Spec
           (Model.Scan_State (Raw, First - 1), Bytes.Get (Raw, First)).Length = 1
         and then Model.Advance_Spec
           (Model.Scan_State (Raw, First - 1), Bytes.Get (Raw, First)).Bytes (1) = Bytes.Get (Raw, First),
       Post => Spans.Retained (Raw, First, Last)
   is
   begin
      null;
   end Retained_Head;

   procedure Key_From
     (Raw : Bytes.Sequence; Start, Position, Slash : Big_Natural; Base : Positive)
     with Global => null,
       Pre => Bridge.Complete (Raw) and then Start >= 1 and then Start < Position
         and then Position <= Bytes.Length (Raw) + 1
         and then Base <= Max_Depth and then Bytes.Get (Raw, Start) = '"'
         and then Key_Context
           (Raw, Start, Position, Slash, Model.Scan_State (Raw, Position - 1), Base),
       Post => Observations.Value_From
         (Raw, Start, Position, Observations.Empty_Nesting, 0, True,
          Model.Scan_State (Raw, Position - 1).Mode = After_Escape, False) >= Position
         and then
           (declare Last : constant Big_Natural := Observations.Value_From
              (Raw, Start, Position, Observations.Empty_Nesting, 0, True,
               Model.Scan_State (Raw, Position - 1).Mode = After_Escape, False);
            S : constant State := Model.Scan_State (Raw, Last);
            begin S.Depth = Base and then S.Mode = Between_Tokens
              and then S.Stack (Base).Position = Colon
              and then S.Stack (Base).Key = Raw_Key (Raw, Start, Last)
              and then Frames_Preserved (Model.Scan_State (Raw, Position - 1), S, Base)
              and then Key_Interior (Raw, Position, Last, Base)
              and then (if Model.Keeping (Model.Scan_State (Raw, Position - 1)) then
                Spans.Retained (Raw, Position, Last))),
       Subprogram_Variant => (Decreases => Bytes.Length (Raw) + 1 - Position)
   is
      Before : constant State := Model.Scan_State (Raw, Position - 1);
   begin
      Bridge.Prefix_Context (Raw, Position - 1);
      if Position > Bytes.Length (Raw) then
         pragma Assert (False);
         return;
      end if;
      Bridge.Prefix_Context (Raw, Position);
      declare
         C : constant Character := Bytes.Get (Raw, Position);
         After : constant State := Model.Scan_State (Raw, Position);
         Next_Slash : constant Big_Natural :=
           (if Slash /= 0 then Slash elsif C = '\' then Position else 0);
      begin
         Key_Step (Before, C);
         if Before.Mode = In_String and then C = '"' then
            Captured_Classification (Before);
            Captured_Word (Raw, Start, Position, Slash, Before, Base, Flow_Name);
            Captured_Word (Raw, Start, Position, Slash, Before, Base, Proof_Name);
            Captured_Word (Raw, Start, Position, Slash, Before, Base, Tree_Name);
            pragma Assert (Word (Raw, Start, Position, Flow_Name) =
              (not Before.Name_Escaped and then Before.Name_Length = 4
                and then Before.Name (1 .. 4) = Flow_Name));
            pragma Assert (Word (Raw, Start, Position, Proof_Name) =
              (not Before.Name_Escaped and then Before.Name_Length = 5
                and then Before.Name (1 .. 5) = Proof_Name));
            pragma Assert (Word (Raw, Start, Position, Tree_Name) =
              (not Before.Name_Escaped and then Before.Name_Length = 10
                and then Before.Name = Tree_Name));
            if Before.Name_Escaped then
               pragma Assert (Raw_Key (Raw, Start, Position) = Other_Key);
            elsif Before.Name_Length = 4 and then Before.Name (1 .. 4) = Flow_Name then
               pragma Assert (Raw_Key (Raw, Start, Position) = Flow_Key);
            elsif Before.Name_Length = 5 and then Before.Name (1 .. 5) = Proof_Name then
               pragma Assert (Raw_Key (Raw, Start, Position) = Proof_Key);
            elsif Before.Name_Length = 10 and then Before.Name = Tree_Name then
               pragma Assert (Raw_Key (Raw, Start, Position) = Tree_Key);
            else
               pragma Assert (Raw_Key (Raw, Start, Position) = Other_Key);
            end if;
            pragma Assert (Model.Key_Name (Before) = Raw_Key (Raw, Start, Position));
            pragma Assert (After.Stack (Base).Key = Model.Key_Name (Before));
            pragma Assert (Observations.Value_From
              (Raw, Start, Position, Observations.Empty_Nesting, 0, True, False, False) = Position);
         else
            if Next_Slash = 0 then
               pragma Assert (Before.Mode = In_String);
               for I in 1 .. Natural'Min (After.Name_Length, 10) loop
                  if I <= Before.Name_Length then
                     pragma Assert (Before.Name (I) =
                       Bytes.Get (Raw, Start + To_Big_Integer (I)));
                     pragma Assert (After.Name (I) = Before.Name (I));
                  else
                     pragma Assert (Start + To_Big_Integer (I) = Position);
                     pragma Assert (After.Name (I) = C);
                  end if;
                  pragma Loop_Invariant (for all J in 1 .. I =>
                    After.Name (J) = Bytes.Get (Raw, Start + To_Big_Integer (J)));
               end loop;
            end if;
            pragma Assert (Key_Context (Raw, Start, Position + 1, Next_Slash, After, Base));
            case Before.Mode is
               when In_String =>
                  pragma Assert ((After.Mode = After_Escape) = (C = '\'));
               when After_Escape =>
                  pragma Assert (After.Mode /= After_Escape);
               when Unicode_Escape =>
                  pragma Assert (C /= '"' and then C /= '\');
                  pragma Assert (After.Mode /= After_Escape);
               when others => pragma Assert (False);
            end case;
            pragma Assert (Observations.Value_From
              (Raw, Start, Position, Observations.Empty_Nesting, 0, True,
               Before.Mode = After_Escape, False) =
                 Observations.Value_From
                   (Raw, Start, Position + 1, Observations.Empty_Nesting, 0, True,
                    After.Mode = After_Escape, False));
            Key_From (Raw, Start, Position + 1, Next_Slash, Base);
         end if;
         if Model.Keeping (Before) then
            Retained_Head (Raw, Position, Observations.Value_From
              (Raw, Start, Position, Observations.Empty_Nesting, 0, True,
               Before.Mode = After_Escape, False));
         end if;
      end;
   end Key_From;

   procedure Key_Boundary (Raw : Bytes.Sequence; Start : Big_Natural) is
      Before : constant State := Model.Scan_State (Raw, Start - 1);
   begin
      Bridge.Prefix_Context (Raw, Start - 1);
      Bridge.Prefix_Context (Raw, Start);
      pragma Assert (Key_Context
        (Raw, Start, Start + 1, 0, Model.Scan_State (Raw, Start), Before.Depth));
      Key_From (Raw, Start, Start + 1, 0, Before.Depth);
   end Key_Boundary;
end Silver_Report_Projection_Keys;
