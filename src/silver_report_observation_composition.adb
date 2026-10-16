package body Silver_Report_Observation_Composition with SPARK_Mode => On is
   procedure Prefix_Insensitive
     (Text : Bytes.Sequence; Start, Position : Offset;
      Left, Right : Observations.Nesting; Level : Observations.Nesting_Level;
      Quoted, Escaped, Container : Boolean)
   is
   begin
      if Position > Bytes.Length (Text) then return; end if;
      if Quoted then
         if Escaped then
            Prefix_Insensitive
              (Text, Start, Position + 1, Left, Right, Level, True, False, Container);
         elsif Bytes.Get (Text, Position) = '\' then
            Prefix_Insensitive
              (Text, Start, Position + 1, Left, Right, Level, True, True, Container);
         elsif Bytes.Get (Text, Position) = '"' then
            if Container then
               Prefix_Insensitive
              (Text, Start, Position + 1, Left, Right, Level, False, False, Container);
            end if;
         else
            Prefix_Insensitive
              (Text, Start, Position + 1, Left, Right, Level, True, False, Container);
         end if;
      elsif Bytes.Get (Text, Position) = '"' then
         Prefix_Insensitive
              (Text, Start, Position + 1, Left, Right, Level, True, Escaped, Container);
      elsif Bytes.Get (Text, Position) in '{' | '[' then
         if Level < 64 then
            Prefix_Insensitive
              (Text, Start, Position + 1, Observations.Pushed (Left, Level + 1, Bytes.Get (Text, Position)),
               Observations.Pushed (Right, Level + 1, Bytes.Get (Text, Position)), Level + 1, False, Escaped, Container);
         end if;
      elsif Bytes.Get (Text, Position) in '}' | ']' then
         if Level > 1
           and then not ((Bytes.Get (Text, Position) = '}' and then Left (Level) /= '{')
             or else (Bytes.Get (Text, Position) = ']' and then Left (Level) /= '['))
         then
            Prefix_Insensitive
              (Text, Start, Position + 1, Left, Right, Level - 1, False, Escaped, Container);
         end if;
      elsif not Container and then (Bytes.Get (Text, Position) = ',' or else Observations.Space (Bytes.Get (Text, Position))) then
         null;
      else
         Prefix_Insensitive
              (Text, Start, Position + 1, Left, Right, Level, False, Escaped, Container);
      end if;
   end Prefix_Insensitive;

   procedure Container_Closes
     (Text : Bytes.Sequence; Start, Position : Offset;
      Openers : Observations.Nesting; Level : Observations.Nesting_Level;
      Quoted, Escaped : Boolean)
   is
   begin
      if Position > Bytes.Length (Text) then return; end if;
      if Quoted then
         if Escaped then
            Container_Closes
              (Text, Start, Position + 1, Openers, Level, True, False);
         elsif Bytes.Get (Text, Position) = '\' then
            Container_Closes
              (Text, Start, Position + 1, Openers, Level, True, True);
         elsif Bytes.Get (Text, Position) = '"' then
            Container_Closes
              (Text, Start, Position + 1, Openers, Level, False, False);
         else
            Container_Closes
              (Text, Start, Position + 1, Openers, Level, True, False);
         end if;
      elsif Bytes.Get (Text, Position) = '"' then
         Container_Closes
              (Text, Start, Position + 1, Openers, Level, True, Escaped);
      elsif Bytes.Get (Text, Position) in '{' | '[' then
         if Level < 64 then
            Container_Closes
              (Text, Start, Position + 1, Observations.Pushed (Openers, Level + 1, Bytes.Get (Text, Position)), Level + 1, False, Escaped);
         end if;
      elsif Bytes.Get (Text, Position) in '}' | ']' then
         if Level > 1
           and then not ((Bytes.Get (Text, Position) = '}' and then Openers (Level) /= '{')
             or else (Bytes.Get (Text, Position) = ']' and then Openers (Level) /= '['))
         then
            Container_Closes
              (Text, Start, Position + 1, Openers, Level - 1, False, Escaped);
         end if;
      else
         Container_Closes
              (Text, Start, Position + 1, Openers, Level, False, Escaped);
      end if;
   end Container_Closes;

   procedure Plain_Skip
     (Text : Bytes.Sequence; Start, First, After : Offset;
      Openers : Observations.Nesting; Level : Observations.Nesting_Level)
   is
   begin
      if First < After then
         pragma Assert (Bytes.Get (Text, First) not in '"' | '{' | '[' | '}' | ']');
         Plain_Skip (Text, Start, First + 1, After, Openers, Level);
      end if;
   end Plain_Skip;

   procedure Quoted_Continuation
     (Text : Bytes.Sequence; Start, First, Position, Last : Offset;
      Openers : Observations.Nesting; Level : Observations.Nesting_Level;
      Escaped : Boolean)
     with Global => null,
       Pre => Start >= 1 and then Start <= First and then First <= Position
         and then Position <= Bytes.Length (Text) + 1 and then Last > 0
         and then Observations.Value_From
           (Text, First, Position, Observations.Empty_Nesting, 0, True, Escaped, False) = Last,
       Post => Observations.Value_From
         (Text, Start, Position, Openers, Level, True, Escaped, True) =
           Observations.Value_From
         (Text, Start, Last + 1, Openers, Level, False, False, True),
       Subprogram_Variant => (Decreases => Bytes.Length (Text) + 1 - Position)
   is
   begin
      pragma Assert (Position <= Bytes.Length (Text));
      if Escaped then
         Quoted_Continuation (Text, Start, First, Position + 1, Last, Openers, Level, False);
      elsif Bytes.Get (Text, Position) = '\' then
         Quoted_Continuation (Text, Start, First, Position + 1, Last, Openers, Level, True);
      elsif Bytes.Get (Text, Position) /= '"' then
         Quoted_Continuation (Text, Start, First, Position + 1, Last, Openers, Level, False);
      end if;
   end Quoted_Continuation;

   procedure Quoted_Skip
     (Text : Bytes.Sequence; Start, First, Last : Offset;
      Openers : Observations.Nesting; Level : Observations.Nesting_Level)
   is
   begin
      Quoted_Continuation (Text, Start, First, First + 1, Last, Openers, Level, False);
   end Quoted_Skip;

   procedure Empty_Object_Skip
     (Text : Bytes.Sequence; Start, First : Offset;
      Openers : Observations.Nesting; Level : Observations.Nesting_Level)
   is
   begin
      Prefix_Insensitive
        (Text, Start, First + 2, Observations.Pushed (Openers, Level + 1, '{'),
         Openers, Level, False, False, True);
   end Empty_Object_Skip;
end Silver_Report_Observation_Composition;
