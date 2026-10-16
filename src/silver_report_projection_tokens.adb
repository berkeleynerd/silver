package body Silver_Report_Projection_Tokens with SPARK_Mode => On is
   procedure String_Step (S : State; Item : Character; Base : Depth_Range; Escaped : Boolean)
     with Pre => Structure.Well_Formed (S) and then not S.Failed
       and then String_Context (S, Base, Escaped)
       and then not Model.Advance_Spec (S, Item).Following.Failed,
       Post => (if Escaped then String_Context (Model.Advance_Spec (S, Item).Following, Base, False)
         elsif Item = '\' then String_Context (Model.Advance_Spec (S, Item).Following, Base, True)
         elsif Item = '"' then Bridge.End_Context (Model.Advance_Spec (S, Item).Following, Base)
         else String_Context (Model.Advance_Spec (S, Item).Following, Base, False))
   is
   begin
      null;
   end String_Step;

   procedure String_Head
     (Raw : Bytes.Sequence; First, Last : Big_Natural; Base : Depth_Range)
     with Pre => First >= 1 and then First <= Last and then Last <= Bytes.Length (Raw)
       and then Model.Scan_State (Raw, First - 1).Depth = Base
       and then Structure.String_Mode (Model.Scan_State (Raw, First - 1))
       and then not Model.Scan_State (Raw, First - 1).String_Is_Key
       and then (for all I in Raw => (if First < I and then I <= Last then
         Model.Scan_State (Raw, I - 1).Depth = Base
         and then Structure.String_Mode (Model.Scan_State (Raw, I - 1))
         and then not Model.Scan_State (Raw, I - 1).String_Is_Key)),
       Post => (for all I in Raw => (if First <= I and then I <= Last then
         Model.Scan_State (Raw, I - 1).Depth = Base
         and then Structure.String_Mode (Model.Scan_State (Raw, I - 1))
         and then not Model.Scan_State (Raw, I - 1).String_Is_Key))
   is
   begin
      null;
   end String_Head;

   procedure String_End
     (Raw : Bytes.Sequence; Start, Position : Big_Natural;
      Base : Depth_Range; Escaped : Boolean)
   is
      Current : constant State := Model.Scan_State (Raw, Position - 1);
      Last : constant Big_Natural := Observations.Value_From
        (Raw, Start, Position, Observations.Empty_Nesting, 0, True, Escaped, False);
   begin
      Bridge.Prefix_Context (Raw, Position - 1);
      pragma Assert (Position <= Bytes.Length (Raw));
      Bridge.Prefix_Context (Raw, Position);
      declare
         Item : constant Character := Bytes.Get (Raw, Position);
         Next : constant State := Model.Scan_State (Raw, Position);
         Next_Escaped : constant Boolean := not Escaped and then Item = '\';
      begin
         pragma Assert (Next = Model.Advance_Spec (Current, Item).Following);
         Parents.Inside_Token (Current, Item);
         pragma Assert (Parents.Same (Current, Next, Base));
         String_Step (Current, Item, Base, Escaped);
         pragma Assert (if Next.Mode /= Between_Tokens then Parents.Whole (Current, Next, Base));
         if not Escaped and then Item = '"' then
            pragma Assert (Last = Position);
            pragma Assert (Bridge.End_Context (Next, Base));
         else
            pragma Assert (String_Context (Next, Base, Next_Escaped));
            pragma Assert (Last = Observations.Value_From
              (Raw, Start, Position + 1, Observations.Empty_Nesting, 0, True, Next_Escaped, False));
            String_End (Raw, Start, Position + 1, Base, Next_Escaped);
            Parents.Same_Transitive (Current, Next, Model.Scan_State (Raw, Last), Base);
            Parents.Lift_Whole (Raw, Position + 1, Last, Current, Next, Base);
         end if;
         String_Head (Raw, Position, Last, Base);
         Parents.Whole_Head (Raw, Position, Last, Current, Base);
      end;
   end String_End;

   procedure Primitive_Step (S : State; Item : Character; Base : Depth_Range)
     with Pre => Structure.Well_Formed (S) and then not S.Failed
       and then Primitive_Context (S, Base)
       and then not Model.Advance_Spec (S, Item).Following.Failed,
       Post => Item not in '"' | '{' | '['
         and then (if Item in '}' | ']' | ',' or else Observations.Space (Item)
           then Primitive_End_Context (S, Base)
             and then (if S.Mode = In_Number then Model.Number_Ends (S.Number, Item))
           else S.Mode in In_Number | In_Literal
             and then (if S.Mode = In_Number then not Model.Number_Ends (S.Number, Item)))
   is
   begin
      case S.Mode is
         when Between_Tokens => null;
         when In_Number =>
            case S.Number is
               when After_Zero | Integer_Digits | Fraction_Digits | Exponent_Digits => null;
               when others =>
                  pragma Assert (Item not in '"' | '{' | '[' | '}' | ']' | ',');
                  pragma Assert (not Observations.Space (Item));
            end case;
         when In_Literal =>
            pragma Assert (Item not in '"' | '{' | '[' | '}' | ']' | ',');
            pragma Assert (not Observations.Space (Item));
         when others => pragma Assert (False);
      end case;
   end Primitive_Step;

   function Primitive_Inside
     (Raw : Bytes.Sequence; First, Last : Big_Natural; Base : Depth_Range) return Boolean is
     (for all I in Raw => (if First <= I and then I <= Last then
       Model.Scan_State (Raw, I - 1).Depth = Base
       and then Model.Scan_State (Raw, I - 1).Mode in In_Number | In_Literal
       and then (if Model.Scan_State (Raw, I - 1).Mode = In_Number then
         not Model.Number_Ends (Model.Scan_State (Raw, I - 1).Number, Bytes.Get (Raw, I)))))
     with Pre => First >= 1 and then First <= Last + 1 and then Last <= Bytes.Length (Raw);

   procedure Primitive_Head
     (Raw : Bytes.Sequence; First, Last : Big_Natural; Base : Depth_Range)
     with Pre => First >= 1 and then First <= Last and then Last <= Bytes.Length (Raw)
       and then Model.Scan_State (Raw, First - 1).Depth = Base
       and then Model.Scan_State (Raw, First - 1).Mode in In_Number | In_Literal
       and then (if Model.Scan_State (Raw, First - 1).Mode = In_Number then
         not Model.Number_Ends (Model.Scan_State (Raw, First - 1).Number, Bytes.Get (Raw, First)))
       and then Primitive_Inside (Raw, First + 1, Last, Base),
       Post => Primitive_Inside (Raw, First, Last, Base)
   is
   begin
      null;
   end Primitive_Head;

   procedure Primitive_End
     (Raw : Bytes.Sequence; Start, Position : Big_Natural; Base : Depth_Range)
   is
      Current : constant State := Model.Scan_State (Raw, Position - 1);
   begin
      Bridge.Prefix_Context (Raw, Position - 1);
      pragma Assert (Position <= Bytes.Length (Raw));
      Bridge.Prefix_Context (Raw, Position);
      declare
         Item : constant Character := Bytes.Get (Raw, Position);
         Next : constant State := Model.Scan_State (Raw, Position);
         Last : constant Big_Natural := Observations.Value_From
           (Raw, Start, Position, Observations.Empty_Nesting, 0, False, False, False);
      begin
         pragma Assert (Next = Model.Advance_Spec (Current, Item).Following);
         Primitive_Step (Current, Item, Base);
         if Item in '}' | ']' | ',' or else Observations.Space (Item) then
            pragma Assert (Primitive_End_Context (Current, Base));
         elsif Item in '"' | '{' | '[' then
            pragma Assert (False);
         else
            pragma Assert (Current.Mode in In_Number | In_Literal);
            Parents.Inside_Token (Current, Item);
            Primitive_End (Raw, Start, Position + 1, Base);
            pragma Assert (Last = Observations.Value_From
              (Raw, Start, Position + 1, Observations.Empty_Nesting, 0, False, False, False));
            Primitive_Head (Raw, Position, Last, Base);
         end if;
         declare
         begin
            if Last > Position then
               pragma Assert (Next.Mode /= Between_Tokens);
               Parents.Lift_Whole (Raw, Position + 1, Last, Current, Next, Base);
            end if;
            if Last >= Position then
               Parents.Same_Transitive (Current, Next, Model.Scan_State (Raw, Last), Base);
            end if;
            Parents.Whole_Head (Raw, Position, Last, Current, Base);
         end;
      end;
   end Primitive_End;
end Silver_Report_Projection_Tokens;
