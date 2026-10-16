with SPARK.Big_Integers;
with SPARK.Containers.Functional.Infinite_Sequences;
with Silver_Report_Projection_Types;

--  Mathematical byte observations and a functional JSON transition model.
--  No model definition calls the executable Advance function. The separate
--  executable package must prove equality to these grammar equations.
package Silver_Report_Projection_Model
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   use Silver_Report_Projection_Types;

   package Byte_Sequences is new SPARK.Containers.Functional.Infinite_Sequences
     (Element_Type => Character, Use_Logical_Equality => True);
   use type Byte_Sequences.Sequence;

   function White (C : Character) return Boolean is
     (C in ' ' | Character'Val (9) | Character'Val (10) | Character'Val (13));
   function Hexadecimal (C : Character) return Boolean is
     (C in '0' .. '9' | 'A' .. 'F' | 'a' .. 'f');
   function Terminal_Number (P : Number_Position) return Boolean is
     (P in After_Zero | Integer_Digits | Fraction_Digits | Exponent_Digits);

   function Keeping (S : State) return Boolean is
     (S.Depth = 0 or else S.Stack (S.Depth).Keep);
   function Erasing_Value (S : State) return Boolean is
     (Keeping (S) and then S.Depth > 0
      and then S.Stack (S.Depth).Role = Check_Record
      and then S.Stack (S.Depth).Position = Object_Value
      and then S.Stack (S.Depth).Key = Tree_Key);

   function Silence (S : State) return Transition is
     ((Following => S, Bytes => (others => ' '), Length => 0));
   function Observed (S : State; C : Character; Keep : Boolean)
     return Transition is
     ((Following => S,
       Bytes => (if Keep then (1 => C, 2 => ' ') else (others => ' ')),
       Length => (if Keep then 1 else 0)));

   function Ended (S : State) return State is
     (if S.Depth = 0 then (S with delta Finished => True)
      else (S with delta Stack =>
        (S.Stack with delta S.Depth =>
          (S.Stack (S.Depth) with delta Position =>
            (if S.Stack (S.Depth).Container = Object_Container
             then Object_Separator else Array_Separator)))));

   function Key_Name (S : State) return Key_Kind is
     (if S.Name_Escaped then Other_Key
      elsif S.Name_Length = 4 and then S.Name (1 .. 4) = "flow" then Flow_Key
      elsif S.Name_Length = 5 and then S.Name (1 .. 5) = "proof" then Proof_Key
      elsif S.Name_Length = 10 and then S.Name = "check_tree" then Tree_Key
      else Other_Key);
   function Ended_Key (S : State) return State is
     (if S.Depth = 0 then (S with delta Failed => True)
      else (S with delta Stack =>
        (S.Stack with delta S.Depth =>
          (S.Stack (S.Depth) with delta Key => Key_Name (S), Position => Colon))));
   function Ended_String (S : State) return State is
     (if S.String_Is_Key then Ended_Key ((S with delta Mode => Between_Tokens))
      else Ended ((S with delta Mode => Between_Tokens)));
   function Started_String (S : State; Is_Key, Keep : Boolean) return State is
     (S with delta Mode => In_String, String_Is_Key => Is_Key,
       Token_Keep => Keep, Name_Length => 0, Name_Escaped => False,
       Name => (others => ' '));

   function Child_Role (S : State; C : Character) return Role_Kind is
     (if S.Depth = 0 and then C = '{' then Root_Object
      elsif S.Depth > 0 and then S.Stack (S.Depth).Role = Root_Object
        and then S.Stack (S.Depth).Position = Object_Value
        and then S.Stack (S.Depth).Key in Flow_Key | Proof_Key
        and then C = '[' then Check_List
      elsif S.Depth > 0 and then S.Stack (S.Depth).Role = Check_List
        and then C = '{' then Check_Record
      else Ordinary);

   function Started_Container (S : State; C : Character) return State is
     (if S.Depth = Max_Depth then (S with delta Failed => True)
      else (S with delta Depth => S.Depth + 1, Stack =>
        (S.Stack with delta S.Depth + 1 =>
          (Container => (if C = '{' then Object_Container else Array_Container),
           Position => (if C = '{' then First_Key else First_Item),
           Role => Child_Role (S, C), Key => Other_Key,
           Keep => Keeping (S) and then not Erasing_Value (S)))))
     with Pre => C in '{' | '[';

   function Started_Value (S : State; C : Character) return State is
     (if C in '{' | '[' then Started_Container (S, C)
      elsif C = '"' then Started_String
        (S, False, Keeping (S) and then not Erasing_Value (S))
      elsif C = '-' or else C in '0' .. '9' then
        (S with delta Mode => In_Number,
          Token_Keep => Keeping (S) and then not Erasing_Value (S),
          Number => (if C = '-' then After_Minus
                     elsif C = '0' then After_Zero else Integer_Digits))
      elsif C in 't' | 'f' | 'n' then
        (S with delta Mode => In_Literal,
          Token_Keep => Keeping (S) and then not Erasing_Value (S),
          Literal => (if C = 't' then True_Literal
                      elsif C = 'f' then False_Literal else Null_Literal),
          Literal_Position => 2)
      else (S with delta Failed => True));

   function Value_Transition (S : State; C : Character) return Transition is
     ((Following => Started_Value ((S with delta Started => True), C),
       Bytes => (if Erasing_Value (S) then "{}"
                 elsif Keeping (S) then (1 => C, 2 => ' ')
                 else (others => ' ')),
       Length => (if Erasing_Value (S) then 2 elsif Keeping (S) then 1 else 0)));

   function Closes_Container (S : State; C : Character) return Boolean is
     (S.Depth > 0 and then
        ((C = '}' and then S.Stack (S.Depth).Container = Object_Container
           and then S.Stack (S.Depth).Position in First_Key | Object_Separator)
         or else
         (C = ']' and then S.Stack (S.Depth).Container = Array_Container
           and then S.Stack (S.Depth).Position in First_Item | Array_Separator)));

   function Positioned_Transition (S : State; C : Character) return Transition is
     (case S.Stack (S.Depth).Position is
        when First_Key | Next_Key =>
          (if C = '"' then Observed (Started_String (S, True, Keeping (S)), C, Keeping (S))
           else Silence ((S with delta Failed => True))),
        when Colon =>
          (if C = ':' then Observed
             ((S with delta Stack => (S.Stack with delta S.Depth =>
                (S.Stack (S.Depth) with delta Position => Object_Value))), C, Keeping (S))
           else Silence ((S with delta Failed => True))),
        when Object_Value | First_Item | Next_Item => Value_Transition (S, C),
        when Object_Separator | Array_Separator =>
          (if C = ',' then Observed
             ((S with delta Stack => (S.Stack with delta S.Depth =>
                (S.Stack (S.Depth) with delta Position =>
                  (if S.Stack (S.Depth).Container = Object_Container
                   then Next_Key else Next_Item)))), C, Keeping (S))
           else Silence ((S with delta Failed => True))))
     with Pre => S.Depth > 0;

   function Between_Transition (S : State; C : Character) return Transition is
     (if White (C) then Observed (S, C, Keeping (S))
      elsif S.Finished then Silence ((S with delta Failed => True))
      elsif S.Depth = 0 then
        (if S.Started then Silence ((S with delta Failed => True))
         else Value_Transition (S, C))
      elsif C in '}' | ']' then
        (if Closes_Container (S, C)
         then Observed (Ended ((S with delta Depth => S.Depth - 1)), C, Keeping (S))
         else Silence ((S with delta Failed => True)))
      else Positioned_Transition (S, C));

   function Number_Ends (P : Number_Position; C : Character) return Boolean is
     (case P is
        when After_Zero => C not in '.' | 'e' | 'E',
        when Integer_Digits | Fraction_Digits => C not in '0' .. '9' | 'e' | 'E'
          and then (P = Fraction_Digits or else C /= '.'),
        when Exponent_Digits => C not in '0' .. '9',
        when others => False);
   function Number_Accepts (P : Number_Position; C : Character) return Boolean is
     (case P is
        when After_Minus | After_Dot | After_Exponent_Sign => C in '0' .. '9',
        when After_Exponent => C in '0' .. '9' | '+' | '-',
        when others => True);
   function Number_After (P : Number_Position; C : Character) return Number_Position is
     (case P is
        when After_Minus =>
          (if C = '0' then After_Zero elsif C in '1' .. '9' then Integer_Digits else P),
        when After_Zero | Integer_Digits =>
          (if C in '0' .. '9' and then P = Integer_Digits then P
           elsif C = '.' then After_Dot elsif C in 'e' | 'E' then After_Exponent else P),
        when After_Dot => (if C in '0' .. '9' then Fraction_Digits else P),
        when Fraction_Digits => (if C in 'e' | 'E' then After_Exponent else P),
        when After_Exponent =>
          (if C in '+' | '-' then After_Exponent_Sign
           elsif C in '0' .. '9' then Exponent_Digits else P),
        when After_Exponent_Sign => (if C in '0' .. '9' then Exponent_Digits else P),
        when Exponent_Digits => P);
   function Number_Transition (S : State; C : Character) return Transition is
     (if Number_Ends (S.Number, C)
      then Between_Transition (Ended ((S with delta Mode => Between_Tokens)), C)
      else Observed
        ((S with delta Number => Number_After (S.Number, C),
          Failed => S.Failed or else not Number_Accepts (S.Number, C)), C, S.Token_Keep));

   function Key_Character (S : State; C : Character) return State is
     (if S.String_Is_Key and then S.Name_Length < 11 then
        (S with delta Name_Length => S.Name_Length + 1,
          Name => (if S.Name_Length < 10
                   then (S.Name with delta S.Name_Length + 1 => C) else S.Name))
      else S);
   function String_Transition (S : State; C : Character) return Transition is
     (Observed
        ((if Character'Pos (C) < 32 then (S with delta Failed => True)
          elsif C = '"' then Ended_String (S)
          elsif C = '\' then (S with delta Mode => After_Escape, Name_Escaped => True)
          else Key_Character (S, C)), C, S.Token_Keep));
   function Escape_Transition (S : State; C : Character) return Transition is
     (Observed
        ((if C = 'u' then (S with delta Mode => Unicode_Escape, Unicode_Left => 4)
          elsif C in '"' | '\' | '/' | 'b' | 'f' | 'n' | 'r' | 't'
          then (S with delta Mode => In_String)
          else (S with delta Failed => True)), C, S.Token_Keep));
   function Unicode_Transition (S : State; C : Character) return Transition is
     (Observed
        ((if not Hexadecimal (C) or else S.Unicode_Left = 0
          then (S with delta Failed => True)
          else (S with delta Unicode_Left => S.Unicode_Left - 1,
            Mode => (if S.Unicode_Left = 1 then In_String else S.Mode))), C, S.Token_Keep));

   function Literal_Text (L : Literal_Kind) return String is
     (case L is when True_Literal => "true", when False_Literal => "false",
       when Null_Literal => "null");
   function Literal_Transition (S : State; C : Character) return Transition is
     (Observed
        ((if S.Literal_Position > Literal_Text (S.Literal)'Length
            or else C /= Literal_Text (S.Literal) (S.Literal_Position)
          then (S with delta Failed => True)
          elsif S.Literal_Position = Literal_Text (S.Literal)'Length
          then Ended ((S with delta Mode => Between_Tokens))
          else (S with delta Literal_Position => S.Literal_Position + 1)), C, S.Token_Keep));

   function Advance_Spec (Before : State; Item : Character) return Transition is
     (if Before.Failed then Silence (Before)
      else (case Before.Mode is
        when Between_Tokens => Between_Transition (Before, Item),
        when In_Number => Number_Transition (Before, Item),
        when In_String => String_Transition (Before, Item),
        when After_Escape => Escape_Transition (Before, Item),
        when Unicode_Escape => Unicode_Transition (Before, Item),
        when In_Literal => Literal_Transition (Before, Item)));

   procedure Advance_Congruence (Left, Right : State; Item : Character)
     with Global => null, Pre => Left = Right,
       Post => Advance_Spec (Left, Item) = Advance_Spec (Right, Item);

   function Append_Emission
     (Prefix : Byte_Sequences.Sequence; T : Transition)
      return Byte_Sequences.Sequence is
     (if T.Length = 0 then Prefix
      elsif T.Length = 1 then Byte_Sequences.Add (Prefix, T.Bytes (1))
      else Byte_Sequences.Add (Byte_Sequences.Add (Prefix, T.Bytes (1)), T.Bytes (2)))
     with Post => Byte_Sequences.Length (Append_Emission'Result) =
       Byte_Sequences.Length (Prefix) + To_Big_Integer (T.Length);

   procedure Emission_Congruence
     (Left, Right : Byte_Sequences.Sequence; LT, RT : Transition)
     with Global => null, Pre => Left = Right and then LT = RT,
       Post => Append_Emission (Left, LT) = Append_Emission (Right, RT);

   type Run_Result is record
      Current : State;
      Emitted : Byte_Sequences.Sequence;
   end record;
   function Empty_Run return Run_Result is
     ((Current => Initial_State, Emitted => Byte_Sequences.Empty_Sequence));
   function Next_Run (Before : Run_Result; Item : Character) return Run_Result is
     ((Current => Advance_Spec (Before.Current, Item).Following,
       Emitted => Append_Emission
         (Before.Emitted, Advance_Spec (Before.Current, Item))));

   --  A mathematical scan of the observations has no machine-sized counter.
   --  This recurrence uses the independent grammar above, never Advance.
   function Scan_State (Raw : Byte_Sequences.Sequence; Count : Big_Natural)
     return State
     with Pre => Count <= Byte_Sequences.Length (Raw),
       Subprogram_Variant => (Decreases => Count);
   function Scan_State (Raw : Byte_Sequences.Sequence; Count : Big_Natural)
     return State is
     (if Count = 0 then Initial_State
      else Advance_Spec
        (Scan_State (Raw, Count - 1), Byte_Sequences.Get (Raw, Count)).Following);
   function Scan_Bytes (Raw : Byte_Sequences.Sequence; Count : Big_Natural)
     return Byte_Sequences.Sequence
     with Pre => Count <= Byte_Sequences.Length (Raw),
       Subprogram_Variant => (Decreases => Count);
   function Scan_Bytes (Raw : Byte_Sequences.Sequence; Count : Big_Natural)
     return Byte_Sequences.Sequence is
     (if Count = 0 then Byte_Sequences.Empty_Sequence
      else Append_Emission (Scan_Bytes (Raw, Count - 1), Advance_Spec
        (Scan_State (Raw, Count - 1), Byte_Sequences.Get (Raw, Count))));
   function Scan (Raw : Byte_Sequences.Sequence; Count : Big_Natural)
     return Run_Result is
     ((Current => Scan_State (Raw, Count), Emitted => Scan_Bytes (Raw, Count)))
     with Pre => Count <= Byte_Sequences.Length (Raw);

   function Refines
     (Raw, Emitted : Byte_Sequences.Sequence; Current : State) return Boolean is
     (Current = Scan (Raw, Byte_Sequences.Length (Raw)).Current
      and then Emitted = Scan (Raw, Byte_Sequences.Length (Raw)).Emitted);

   procedure Scan_Prefix
     (Left, Right : Byte_Sequences.Sequence; Count : Big_Natural)
     with Global => null,
       Pre => Left <= Right and then Count <= Byte_Sequences.Length (Left),
       Post => Scan_State (Left, Count) = Scan_State (Right, Count)
         and then Scan_Bytes (Left, Count) = Scan_Bytes (Right, Count),
       Subprogram_Variant => (Decreases => Count);

   procedure Extend_Observations
     (Raw, Emitted : Byte_Sequences.Sequence; Current : State; Item : Character)
     with Global => null, Pre => Refines (Raw, Emitted, Current),
       Post => Refines
         (Byte_Sequences.Add (Raw, Item),
          Append_Emission (Emitted, Advance_Spec (Current, Item)),
          Advance_Spec (Current, Item).Following);

   function Matches
     (Bytes : Byte_Sequences.Sequence; Buffer : String; Count : Natural)
      return Boolean is
     (Byte_Sequences.Length (Bytes) = To_Big_Integer (Count)
      and then (for all I in 1 .. Count =>
        Byte_Sequences.Get (Bytes, To_Big_Integer (I)) = Buffer (I)))
     with Pre => Buffer'First = 1 and then Count <= Buffer'Length;

end Silver_Report_Projection_Model;
