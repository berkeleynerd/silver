package body Silver_Reports with SPARK_Mode => On is
   --  Static ghost computations are verified by GNATprove but erased by
   --  GNAT. Their recursive mathematical definitions must not consume stack
   --  or be recomputed for every byte by executable loop assertions. All
   --  executable checks remain enabled by -gnata/-gnato.
   Prefix : constant String := """spark"":{""";
   Suffix : constant String := """:""all""}";
   Progress_Field : constant String := """progress"":""PROGRESS_PROOF""";
   Stop_Field : constant String := """stop_reason"":""STOP_REASON_NONE""";
   Flow_Field : constant String := """flow"":[]";
   Proof_Field : constant String := """proof"":[]";
   Skip_Flow_Field : constant String := """skip_flow_proof"":[]";
   Skip_Proof_Field : constant String := """skip_proof"":[]";
   Assume_Field : constant String := """pragma_assume"":[]";
   Warning_Field : constant String := """warn_error"":[]";
   subtype Cursor is Positive range 1 .. Max_Report_Length + 1;

   function Removed (Item : Character) return Boolean is
     (Item = ' ' or else Item = Character'Val (9)
      or else Item = Character'Val (10) or else Item = Character'Val (13));

   function Filtered_Prefix (Report : String; Count : Natural) return String
     with Ghost => Static, Global => null,
          Pre => Report'Length <= Max_Report_Length and then Count <= Report'Length,
          Post => Filtered_Prefix'Result'First = 1
            and then Filtered_Prefix'Result'Length <= Count,
          Subprogram_Variant => (Decreases => Count);

   function Filtered_Prefix (Report : String; Count : Natural) return String is
     (if Count = 0 then ""
      elsif Removed (Report (Report'First + (Count - 1)))
      then Filtered_Prefix (Report, Count - 1)
      else Filtered_Prefix (Report, Count - 1)
        & Report (Report'First + (Count - 1)));

   function Has_Substring (Text, Pattern : String) return Boolean
     with Ghost => Static, Global => null,
          Pre => Text'First = 1 and then Pattern'First = 1
            and then Text'Length <= Max_Report_Length
            and then Pattern'Length in 1 .. Max_Report_Length;

   function Has_Substring (Text, Pattern : String) return Boolean is
     (Pattern'Length <= Text'Length
      and then (for some Start in 1 .. (Text'Length - Pattern'Length) + 1 =>
        Text (Start .. Start + (Pattern'Length - 1)) = Pattern));

   function First_Prefix (Text : String; Position : Cursor) return Cursor
     with Ghost => Static, Global => null,
          Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
            and then Position <= Text'Length + 1,
          Post => First_Prefix'Result in Position .. Text'Length + 1,
          Subprogram_Variant => (Decreases => (Text'Length + 1) - Position);

   function First_Prefix (Text : String; Position : Cursor) return Cursor is
     (if Prefix'Length > (Text'Length - Position) + 1 then Text'Length + 1
      elsif Text (Position .. Position + (Prefix'Length - 1)) = Prefix
      then Position
      else First_Prefix (Text, Position + 1));

   function Digits_End (Text : String; Position : Cursor) return Cursor
     with Ghost => Static, Global => null,
          Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
            and then Position <= Text'Length + 1,
          Post => Digits_End'Result in Position .. Text'Length + 1,
          Subprogram_Variant => (Decreases => (Text'Length + 1) - Position);

   function Digits_End (Text : String; Position : Cursor) return Cursor is
     (if Position > Text'Length or else Text (Position) not in '0' .. '9'
      then Position else Digits_End (Text, Position + 1));

   function Entity_From (Text : String; Start : Cursor) return Boolean
     with Ghost => Static, Global => null,
          Pre => Text'First = 1 and then Text'Length <= Max_Report_Length
            and then Start <= Text'Length + 1;

   function Entity_From (Text : String; Start : Cursor) return Boolean is
     (Prefix'Length < (Text'Length - Start) + 1
      and then Text (Start + Prefix'Length) in '0' .. '9'
      and then Digits_End (Text, Start + Prefix'Length) + (Suffix'Length - 1)
        <= Text'Length
      and then Text (Digits_End (Text, Start + Prefix'Length) ..
        Digits_End (Text, Start + Prefix'Length) + (Suffix'Length - 1)) = Suffix);

   function One_Entity_Spec (Text : String) return Boolean
     with Ghost => Static, Global => null,
          Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function One_Entity_Spec (Text : String) return Boolean is
     (Text'Length >= Prefix'Length + Suffix'Length + 1
      and then Entity_From (Text, First_Prefix (Text, 1)));

   function Compact_Spec (Text : String) return Boolean
     with Ghost => Static, Global => null,
          Pre => Text'First = 1 and then Text'Length <= Max_Report_Length;

   function Compact_Spec (Text : String) return Boolean is
     (Has_Substring (Text, Progress_Field)
      and then Has_Substring (Text, Stop_Field)
      and then Has_Substring (Text, Flow_Field)
      and then Has_Substring (Text, Proof_Field)
      and then Has_Substring (Text, Skip_Flow_Field)
      and then Has_Substring (Text, Skip_Proof_Field)
      and then Has_Substring (Text, Assume_Field)
      and then Has_Substring (Text, Warning_Field)
      and then One_Entity_Spec (Text));

   function Recognizes_Null_Report (Report : String) return Boolean is
     (Report'Length in 1 .. Max_Report_Length
      and then Compact_Spec (Filtered_Prefix (Report, Report'Length)));

   procedure Equal_Substring (Left, Right, Pattern : String)
     with Ghost => Static, Global => null,
          Pre => Left'First = 1 and then Right'First = 1
            and then Left'Length <= Max_Report_Length
            and then Right'Length <= Max_Report_Length and then Left = Right
            and then Pattern'First = 1
            and then Pattern'Length in 1 .. Max_Report_Length,
          Post => Has_Substring (Left, Pattern) = Has_Substring (Right, Pattern)
   is
   begin
      null;
   end Equal_Substring;

   procedure Equal_First (Left, Right : String; Position : Cursor)
     with Ghost => Static, Global => null,
          Pre => Left'First = 1 and then Right'First = 1
            and then Left'Length <= Max_Report_Length
            and then Right'Length <= Max_Report_Length and then Left = Right
            and then Position <= Left'Length + 1,
          Post => First_Prefix (Left, Position) = First_Prefix (Right, Position),
          Subprogram_Variant => (Decreases => (Left'Length + 1) - Position)
   is
   begin
      if Prefix'Length <= (Left'Length - Position) + 1
        and then Left (Position .. Position + (Prefix'Length - 1)) /= Prefix
      then
         Equal_First (Left, Right, Position + 1);
      end if;
   end Equal_First;

   procedure Equal_Digits (Left, Right : String; Position : Cursor)
     with Ghost => Static, Global => null,
          Pre => Left'First = 1 and then Right'First = 1
            and then Left'Length <= Max_Report_Length
            and then Right'Length <= Max_Report_Length and then Left = Right
            and then Position <= Left'Length + 1,
          Post => Digits_End (Left, Position) = Digits_End (Right, Position),
          Subprogram_Variant => (Decreases => (Left'Length + 1) - Position)
   is
   begin
      if Position <= Left'Length and then Left (Position) in '0' .. '9' then
         Equal_Digits (Left, Right, Position + 1);
      end if;
   end Equal_Digits;

   procedure Equal_Compact (Left, Right : String)
     with Ghost => Static, Global => null,
          Pre => Left'First = 1 and then Right'First = 1
            and then Left'Length <= Max_Report_Length
            and then Right'Length <= Max_Report_Length and then Left = Right,
          Post => Compact_Spec (Left) = Compact_Spec (Right)
   is
      Start : constant Cursor := First_Prefix (Left, 1);
   begin
      Equal_Substring (Left, Right, Progress_Field);
      Equal_Substring (Left, Right, Stop_Field);
      Equal_Substring (Left, Right, Flow_Field);
      Equal_Substring (Left, Right, Proof_Field);
      Equal_Substring (Left, Right, Skip_Flow_Field);
      Equal_Substring (Left, Right, Skip_Proof_Field);
      Equal_Substring (Left, Right, Assume_Field);
      Equal_Substring (Left, Right, Warning_Field);
      Equal_First (Left, Right, 1);
      if Prefix'Length < (Left'Length - Start) + 1 then
         Equal_Digits (Left, Right, Start + Prefix'Length);
      end if;
      --  Establish the recursive entity predicate before combining it with
      --  the eight independent field predicates in Compact_Spec.
      pragma Assert (One_Entity_Spec (Left) = One_Entity_Spec (Right));
   end Equal_Compact;

   function Contains (Text, Pattern : String) return Boolean
     with Pre => Text'First = 1 and then Pattern'First = 1
       and then Text'Length <= Max_Report_Length
       and then Pattern'Length in 1 .. Max_Report_Length,
       Post => (Static => Contains'Result = Has_Substring (Text, Pattern))
   is
   begin
      if Pattern'Length > Text'Length then
         return False;
      end if;
      for Start in 1 .. (Text'Length - Pattern'Length) + 1 loop
         pragma Loop_Invariant
           (Static => (for all Earlier in 1 .. Start - 1 =>
              Text (Earlier .. Earlier + (Pattern'Length - 1)) /= Pattern));
         if Text (Start .. Start + (Pattern'Length - 1)) = Pattern then
            return True;
         end if;
      end loop;
      return False;
   end Contains;

   function One_Entity (Text : String) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
          Post => (Static => One_Entity'Result = One_Entity_Spec (Text))
   is
      Start : Cursor := 1;
      Position : Cursor;
   begin
      if Text'Length < Prefix'Length + Suffix'Length + 1 then
         return False;
      end if;
      while Start <= (Text'Length - Prefix'Length) + 1 loop
         pragma Loop_Invariant
           (Start in 1 .. (Text'Length - Prefix'Length) + 2);
         pragma Loop_Invariant
           (Static => First_Prefix (Text, 1) = First_Prefix (Text, Start));
         pragma Loop_Variant (Increases => Start);
         if Text (Start .. Start + (Prefix'Length - 1)) = Prefix then
            Position := Start + Prefix'Length;
            if Position > Text'Length
              or else Text (Position) not in '0' .. '9'
            then
               return False;
            end if;
            while Position <= Text'Length
              and then Text (Position) in '0' .. '9'
            loop
               pragma Loop_Invariant
                 (Position in Start + Prefix'Length .. Text'Length + 1);
               pragma Loop_Invariant
                 (Static => Digits_End (Text, Start + Prefix'Length)
                  = Digits_End (Text, Position));
               pragma Loop_Variant (Increases => Position);
               Position := Position + 1;
            end loop;
            return Position + (Suffix'Length - 1) <= Text'Length
              and then Text (Position .. Position + (Suffix'Length - 1)) = Suffix;
         end if;
         Start := Start + 1;
      end loop;
      return False;
   end One_Entity;

   function Matches_Compact (Text : String) return Boolean
     with Pre => Text'First = 1 and then Text'Length <= Max_Report_Length,
          Post => (Static => Matches_Compact'Result = Compact_Spec (Text))
   is
   begin
      return Contains (Text, Progress_Field)
        and then Contains (Text, Stop_Field)
        and then Contains (Text, Flow_Field)
        and then Contains (Text, Proof_Field)
        and then Contains (Text, Skip_Flow_Field)
        and then Contains (Text, Skip_Proof_Field)
        and then Contains (Text, Assume_Field)
        and then Contains (Text, Warning_Field)
        and then One_Entity (Text);
   end Matches_Compact;

   function Complete_Null_Proof (Report : String) return Boolean is
   begin
      if Report'Length = 0 or else Report'Length > Max_Report_Length then
         return False;
      end if;
      declare
         Compact : String (1 .. Report'Length) := (others => ' ');
         Last : Natural := 0;
      begin
         for Index in Report'Range loop
            pragma Loop_Invariant (Last <= Index - Report'First);
            pragma Loop_Invariant
              (Static => Compact (1 .. Last) = Filtered_Prefix (Report, Index - Report'First));
            if not Removed (Report (Index)) then
               Last := Last + 1;
               Compact (Last) := Report (Index);
            end if;
            pragma Assert
              (Static => Compact (1 .. Last) = Filtered_Prefix (Report, (Index - Report'First) + 1));
         end loop;
         pragma Assert
           (Static => Compact (1 .. Last) = Filtered_Prefix (Report, Report'Length));
         declare
            Text : constant String := Compact (1 .. Last);
         begin
            Equal_Compact (Text, Filtered_Prefix (Report, Report'Length));
            return Matches_Compact (Text);
         end;
      end;
   end Complete_Null_Proof;
end Silver_Reports;
