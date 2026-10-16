package body Silver_Report_Observation_Windows with SPARK_Mode => On is
   use type Observations.Member;

   procedure Reverse_Window
     (Left, Right : Bytes.Sequence; First, Last : Offset; Shift : Big_Integer)
   is
   begin
      null;
   end Reverse_Window;

   procedure Space_End_Window
     (Left, Right : Bytes.Sequence; First, Last, Position : Offset; Shift : Big_Integer)
   is
   begin
      if Position > Last then return; end if;
      pragma Assert (Bytes.Get (Left, Position) = Bytes.Get (Right, Position + Shift));
      if Observations.Space (Bytes.Get (Left, Position)) then
         Space_End_Window (Left, Right, First, Last, Position + 1, Shift);
      end if;
   end Space_End_Window;

   procedure Space_End_Equivalent
     (Left, Right : Bytes.Sequence; First, Last, Position : Offset; Shift : Big_Integer)
   is
   begin
      if Observations.Space_End (Left, Position) <= Last then
         Space_End_Window (Left, Right, First, Last, Position, Shift);
      elsif Observations.Space_End (Right, Position + Shift) <= Last + Shift then
         Reverse_Window (Left, Right, First, Last, Shift);
         Space_End_Window
           (Right, Left, First + Shift, Last + Shift, Position + Shift, -Shift);
      end if;
   end Space_End_Equivalent;

   procedure Value_From_Progress
     (Text : Bytes.Sequence; Start, Position : Offset; Openers : Observations.Nesting;
      Level : Observations.Nesting_Level; Quoted, Escaped, Container : Boolean)
   is
   begin
      if Position > Bytes.Length (Text) then
         return;
      end if;
      if Quoted then
         if Escaped then
            Value_From_Progress
              (Text, Start, Position + 1, Openers, Level, True, False, Container);
         elsif Bytes.Get (Text, Position) = '\' then
            Value_From_Progress
              (Text, Start, Position + 1, Openers, Level, True, True, Container);
         elsif Bytes.Get (Text, Position) = '"' then
            if Container then
               Value_From_Progress
                 (Text, Start, Position + 1, Openers, Level, False, False, Container);
            end if;
         else
            Value_From_Progress
              (Text, Start, Position + 1, Openers, Level, True, False, Container);
         end if;
      elsif Bytes.Get (Text, Position) = '"' then
         Value_From_Progress
           (Text, Start, Position + 1, Openers, Level, True, Escaped, Container);
      elsif Bytes.Get (Text, Position) in '{' | '[' then
         if Level < 64 then
            Value_From_Progress
              (Text, Start, Position + 1, Observations.Pushed (Openers, Level + 1, Bytes.Get (Text, Position)),
               Level + 1, False, Escaped, Container);
         end if;
      elsif Bytes.Get (Text, Position) in '}' | ']' then
         if Level > 1
           and then not ((Bytes.Get (Text, Position) = '}' and then Openers (Level) /= '{')
             or else (Bytes.Get (Text, Position) = ']' and then Openers (Level) /= '['))
         then
            Value_From_Progress
              (Text, Start, Position + 1, Openers, Level - 1, False, Escaped, Container);
         end if;
      elsif not Container and then (Bytes.Get (Text, Position) = ',' or else Observations.Space (Bytes.Get (Text, Position))) then
         null;
      else
         Value_From_Progress
           (Text, Start, Position + 1, Openers, Level, False, Escaped, Container);
      end if;
   end Value_From_Progress;

   procedure Value_From_Window
     (Left, Right : Bytes.Sequence; First, Last, Start, Position : Offset;
      Shift : Big_Integer; Openers : Observations.Nesting;
      Level : Observations.Nesting_Level; Quoted, Escaped, Container : Boolean)
   is
   begin
      Value_From_Progress
        (Left, Start, Position, Openers, Level, Quoted, Escaped, Container);
      if Position > Last then
         return;
      end if;
      pragma Assert (Bytes.Get (Left, Position) = Bytes.Get (Right, Position + Shift));
      if Quoted then
         if Escaped then
            Value_From_Window
              (Left, Right, First, Last, Start, Position + 1, Shift, Openers, Level, True, False, Container);
         elsif Bytes.Get (Left, Position) = '\' then
            Value_From_Window
              (Left, Right, First, Last, Start, Position + 1, Shift, Openers, Level, True, True, Container);
         elsif Bytes.Get (Left, Position) = '"' then
            if Container then
               Value_From_Window
                 (Left, Right, First, Last, Start, Position + 1, Shift, Openers, Level, False, False, Container);
            end if;
         else
            Value_From_Window
              (Left, Right, First, Last, Start, Position + 1, Shift, Openers, Level, True, False, Container);
         end if;
      elsif Bytes.Get (Left, Position) = '"' then
         Value_From_Window
           (Left, Right, First, Last, Start, Position + 1, Shift, Openers, Level, True, Escaped, Container);
      elsif Bytes.Get (Left, Position) in '{' | '[' then
         if Level < 64 then
            Value_From_Window
              (Left, Right, First, Last, Start, Position + 1, Shift, Observations.Pushed (Openers, Level + 1, Bytes.Get (Left, Position)),
               Level + 1, False, Escaped, Container);
         end if;
      elsif Bytes.Get (Left, Position) in '}' | ']' then
         if Level > 1
           and then not ((Bytes.Get (Left, Position) = '}' and then Openers (Level) /= '{')
             or else (Bytes.Get (Left, Position) = ']' and then Openers (Level) /= '['))
         then
            Value_From_Window
              (Left, Right, First, Last, Start, Position + 1, Shift, Openers, Level - 1, False, Escaped, Container);
         end if;
      elsif not Container and then (Bytes.Get (Left, Position) = ',' or else Observations.Space (Bytes.Get (Left, Position))) then
         null;
      else
         Value_From_Window
           (Left, Right, First, Last, Start, Position + 1, Shift, Openers, Level, False, Escaped, Container);
      end if;
   end Value_From_Window;

   procedure Value_Spec_Window
     (Left, Right : Bytes.Sequence; First, Last, Start : Offset; Shift : Big_Integer)
   is
   begin
      pragma Assert (Start < Last);
      pragma Assert (Bytes.Get (Left, Start) = Bytes.Get (Right, Start + Shift));
      Value_From_Window
        (Left, Right, First, Last, Start, Start, Shift, Observations.Empty_Nesting,
         0, False, False, Bytes.Get (Left, Start) in '{' | '[');
   end Value_Spec_Window;

   procedure Closed_Value_Window
     (Left, Right : Bytes.Sequence; First, Last, Start : Offset; Shift : Big_Integer)
   is
   begin
      pragma Assert (Bytes.Get (Left, Start) = Bytes.Get (Right, Start + Shift));
      if Bytes.Get (Left, Start) = '"' then
         Value_From_Window
           (Left, Right, First, Last, Start, Start + 1, Shift,
            Observations.Empty_Nesting, 0, True, False, False);
      else
         Value_From_Window
           (Left, Right, First, Last, Start, Start, Shift,
            Observations.Empty_Nesting, 0, False, False, True);
      end if;
   end Closed_Value_Window;

   procedure Value_Spec_Equivalent
     (Left, Right : Bytes.Sequence; First, Last, Start : Offset; Shift : Big_Integer)
   is
   begin
      if Observations.Value_Spec (Left, Start) > 0
        and then Observations.Value_Spec (Left, Start) < Last
      then
         Value_Spec_Window (Left, Right, First, Last, Start, Shift);
      elsif Observations.Value_Spec (Right, Start + Shift) > 0
        and then Observations.Value_Spec (Right, Start + Shift) < Last + Shift
      then
         Reverse_Window (Left, Right, First, Last, Shift);
         Value_Spec_Window
           (Right, Left, First + Shift, Last + Shift, Start + Shift, -Shift);
      end if;
   end Value_Spec_Equivalent;

   procedure Member_At_Cursors
     (Text : Bytes.Sequence; Object : Observations.Span;
      Position, P, K, C, V, L, T, N : Offset)
     with Global => null,
       Pre => Observations.Valid (Text, Object)
         and then Position >= Object.First + 1
         and then Position <= Bytes.Length (Text) + 1
         and then P = Observations.Space_End (Text, Position)
         and then P < Object.Last and then Bytes.Get (Text, P) = '"'
         and then K = Observations.Value_Spec (Text, P)
         and then K > 0 and then K < Object.Last
         and then C = Observations.Space_End (Text, K + 1)
         and then C < Object.Last and then Bytes.Get (Text, C) = ':'
         and then V = Observations.Space_End (Text, C + 1)
         and then L = Observations.Value_Spec (Text, V)
         and then L > 0 and then L < Object.Last
         and then T = Observations.Space_End (Text, L + 1)
         and then T < Object.Last and then Bytes.Get (Text, T) = ','
         and then N = Observations.Space_End (Text, T + 1)
         and then N < Object.Last,
       Post => Observations.Member_Spec (Text, Object, Position) =
         (Observations.Present, (P, K), (V, L), N)
   is
   begin
      null;
   end Member_At_Cursors;

   procedure Member_Window
     (Left, Right : Bytes.Sequence; First, Last, Position : Offset; Shift : Big_Integer)
   is
      P : constant Offset := Observations.Space_End (Left, Position);
      K, C, V, L, T : Offset := 0;
      Left_Member : constant Observations.Member :=
        Observations.Member_Spec (Left, (First, Last), Position);
      Right_Member : constant Observations.Member :=
        Observations.Member_Spec (Right, (First + Shift, Last + Shift), Position + Shift);
   begin
      Space_End_Equivalent (Left, Right, First, Last, Position, Shift);
      if P < Last then
         pragma Assert (Bytes.Get (Left, P) = Bytes.Get (Right, P + Shift));
      end if;
      if P >= Last or else Bytes.Get (Left, P) /= '"' then
         pragma Assert (Shifted_Member (Left_Member, Right_Member, Shift));
         return;
      end if;
      Value_Spec_Equivalent (Left, Right, First, Last, P, Shift);
      K := Observations.Value_Spec (Left, P);
      if K = 0 or else K >= Last then
         pragma Assert (Shifted_Member (Left_Member, Right_Member, Shift));
         return;
      end if;
      Space_End_Equivalent (Left, Right, First, Last, K + 1, Shift);
      C := Observations.Space_End (Left, K + 1);
      if C < Last then
         pragma Assert (Bytes.Get (Left, C) = Bytes.Get (Right, C + Shift));
      end if;
      if C >= Last or else Bytes.Get (Left, C) /= ':' then
         pragma Assert (Shifted_Member (Left_Member, Right_Member, Shift));
         return;
      end if;
      Space_End_Equivalent (Left, Right, First, Last, C + 1, Shift);
      V := Observations.Space_End (Left, C + 1);
      if V >= Last then
         pragma Assert (Shifted_Member (Left_Member, Right_Member, Shift));
         return;
      end if;
      Value_Spec_Equivalent (Left, Right, First, Last, V, Shift);
      L := Observations.Value_Spec (Left, V);
      if L = 0 or else L >= Last then
         pragma Assert (Shifted_Member (Left_Member, Right_Member, Shift));
         return;
      end if;
      Space_End_Equivalent (Left, Right, First, Last, L + 1, Shift);
      T := Observations.Space_End (Left, L + 1);
      if T < Last then
         pragma Assert (Bytes.Get (Left, T) = Bytes.Get (Right, T + Shift));
      end if;
      if T >= Last or else Bytes.Get (Left, T) /= ',' then
         pragma Assert (Shifted_Member (Left_Member, Right_Member, Shift));
         return;
      end if;
      Space_End_Equivalent (Left, Right, First, Last, T + 1, Shift);
      declare
         N : constant Offset := Observations.Space_End (Left, T + 1);
      begin
         if N >= Last then
            pragma Assert (Left_Member = Observations.Bad_Member);
            pragma Assert (Right_Member = Observations.Bad_Member);
         else
            pragma Assert (Left_Member = (Observations.Present, (P, K), (V, L), N));
            Member_At_Cursors
              (Right, (First + Shift, Last + Shift), Position + Shift,
               P + Shift, K + Shift, C + Shift, V + Shift, L + Shift,
               T + Shift, N + Shift);
            pragma Assert (Right_Member = (Observations.Present,
              (P + Shift, K + Shift), (V + Shift, L + Shift), N + Shift));
         end if;
      end;
   end Member_Window;

   procedure Item_Window
     (Left, Right : Bytes.Sequence; First, Last, Position : Offset; Shift : Big_Integer)
   is
      P : constant Offset := Observations.Space_End (Left, Position);
      L, T : Offset := 0;
   begin
      Space_End_Equivalent (Left, Right, First, Last, Position, Shift);
      if P >= Last or else Bytes.Get (Left, P) /= '{' then return; end if;
      Value_Spec_Equivalent (Left, Right, First, Last, P, Shift);
      L := Observations.Value_Spec (Left, P);
      if L = 0 or else L >= Last then return; end if;
      Space_End_Equivalent (Left, Right, First, Last, L + 1, Shift);
      T := Observations.Space_End (Left, L + 1);
      if T >= Last or else Bytes.Get (Left, T) /= ',' then return; end if;
      Space_End_Equivalent (Left, Right, First, Last, T + 1, Shift);
   end Item_Window;
end Silver_Report_Observation_Windows;
