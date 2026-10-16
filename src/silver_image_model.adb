with Silver_Image_Model_Templates;

package body Silver_Image_Model with SPARK_Mode => On is
   package Templates renames Silver_Image_Model_Templates;

   function Template_Kind (Kind : Selected_Theory) return Templates.Kind is
     (case Kind is
        when Integer_Theory => Templates.Integer_Template,
        when String_Theory => Templates.String_Template,
        when Image_Theory => Templates.Image_Template);

   function Fragment_Kind (Kind : Insertion_Kind) return Templates.Kind is
     (case Kind is
        when Declarations_Insertion => Templates.Declarations_Fragment,
        when Includes_Insertion => Templates.Includes_Fragment);

   function Insertion_Length (Kind : Insertion_Kind) return Positive is
     (Templates.Length (Fragment_Kind (Kind)));

   function Insertion_Byte
     (Kind : Insertion_Kind; Position : Positive) return Character is
     (Templates.Byte_At (Fragment_Kind (Kind), Position));

   procedure Match_Byte (Current : in out State; Item : Character) is
   begin
      if Current.In_Theory then
         for Kind in Selected_Theory loop
            if Current.Live (Kind) then
               if Current.Matched (Kind) < Templates.Length (Template_Kind (Kind))
                 and then Templates.Byte_At
                   (Template_Kind (Kind), Current.Matched (Kind) + 1) = Item
               then
                  Current.Matched (Kind) := Current.Matched (Kind) + 1;
               else
                  Current.Live (Kind) := False;
               end if;
            end if;
         end loop;
      end if;
   end Match_Byte;

   function Hex (Item : Character) return Natural is
     (if Item in '0' .. '9' then Character'Pos (Item) - Character'Pos ('0')
      elsif Item in 'a' .. 'f' then (Character'Pos (Item) - Character'Pos ('a')) + 10
      elsif Item in 'A' .. 'F' then (Character'Pos (Item) - Character'Pos ('A')) + 10
      else 16);

   procedure Decoded (Current : in out State; Code : Natural) with
     Pre => Code <= 65_535
   is
      Hex_Characters : constant String := "0123456789abcdef";
   begin
      if Current.String_Length < 22 then
         Current.String_Length := Current.String_Length + 1;
         if Current.String_Length <= 21 then
            Current.String_Prefix (Current.String_Length) :=
              (if Code <= 127 then Character'Val (Code) else Character'Val (127));
         end if;
      end if;
      if Code >= 127 then
         Current.Live := (others => False);
      elsif Code = 34 or else Code = 92 then
         Match_Byte (Current, '\');
         Match_Byte (Current, Character'Val (Code));
      elsif Code < 32 then
         Match_Byte (Current, '\');
         case Code is
            when 8 => Match_Byte (Current, 'b');
            when 9 => Match_Byte (Current, 't');
            when 10 => Match_Byte (Current, 'n');
            when 12 => Match_Byte (Current, 'f');
            when 13 => Match_Byte (Current, 'r');
            when others =>
               Match_Byte (Current, 'u');
               Match_Byte (Current, '0');
               Match_Byte (Current, '0');
               Match_Byte (Current, Hex_Characters (Code / 16 + 1));
               Match_Byte (Current, Hex_Characters (Code mod 16 + 1));
         end case;
      else
         Match_Byte (Current, Character'Val (Code));
      end if;
   end Decoded;

   function Named (Current : State; Name : String) return Boolean is
     (Name'Length <= 21 and then Current.String_Length = Name'Length
      and then Current.String_Prefix (1 .. Current.String_Length) = Name);

   procedure End_String (Current : in out State) is
   begin
      Match_Byte (Current, '"');
      Current.Mode := Between_Tokens;
      if Current.String_Is_Key then
         if Named (Current, "theory_declarations") then
            Current.Phase := Root_Colon;
         else
            Current.Failed := True;
         end if;
      elsif Current.String_Is_Theory_Tag then
         if not Named (Current, "W_THEORY_DECLARATION") then
            Current.Failed := True;
         end if;
      elsif Current.String_Is_Name then
         if Named (Current, "Standard__integer") then
            Current.Theory := Integer_Theory;
         elsif Named (Current, "Standard__string") then
            Current.Theory := String_Theory;
         elsif Named (Current, "Standard_String__Img") then
            Current.Theory := Image_Theory;
         end if;
      end if;
      Current.Node_Id_Pending := Current.String_Is_Tag
        and then Current.String_Length >= 2
        and then Current.String_Prefix (1 .. 2) = "W_";
   end End_String;

   procedure End_Theory (Current : in out State) is
   begin
      Match_Byte (Current, ']');
      if Current.Field /= 7 then
         Current.Failed := True;
      end if;
      if Current.Theory /= Other_Theory then
         if Current.Seen (Current.Theory)
           or else not Current.Live (Current.Theory)
           or else Current.Matched (Current.Theory) /=
             Templates.Length (Template_Kind (Current.Theory))
         then
            Current.Failed := True;
         end if;
         Current.Seen (Current.Theory) := True;
         if Current.Theory = Image_Theory then
            Current.Declarations_Offset := Current.Candidate_Declarations;
            Current.Includes_Offset := Current.Candidate_Includes;
         end if;
      end if;
      Current.In_Theory := False;
      Current.Depth := 2;
      Current.Phase := Theory_Separator;
   end End_Theory;

   procedure Structural (Current : in out State; Item : Character) is
   begin
      if Item in ' ' | Character'Val (9) | Character'Val (10) | Character'Val (13) then
         return;
      end if;
      if Current.Node_Id_Pending and then Item /= ','
        and then Item not in '0' .. '9'
      then
         Current.Failed := True;
         return;
      end if;
      case Item is
         when '{' =>
            if Current.Phase = Before_Root and then Current.Depth = 0 then
               Current.Depth := 1;
               Current.Phase := Root_Key;
            elsif Current.In_Theory and then Current.Depth < Byte_Count'Last then
               Current.Depth := Current.Depth + 1;
               Match_Byte (Current, Item);
            else
               Current.Failed := True;
            end if;
         when '}' =>
            if Current.Phase = Root_End and then Current.Depth = 1 then
               Current.Depth := 0;
               Current.Phase := After_Root;
            elsif Current.In_Theory and then Current.Depth > 3 then
               Current.Depth := Current.Depth - 1;
               Match_Byte (Current, Item);
            else
               Current.Failed := True;
            end if;
         when '[' =>
            if Current.Phase = Root_List and then Current.Depth = 1 then
               Current.Depth := 2;
               Current.Phase := First_Theory;
            elsif Current.Depth = 2
              and then Current.Phase in First_Theory | Next_Theory
            then
               Current.In_Theory := True;
               Current.Theory := Other_Theory;
               Current.Field := 0;
               Current.Candidate_Declarations := 0;
               Current.Candidate_Includes := 0;
               Current.Matched := (others => 0);
               Current.Live := (others => True);
               Current.Depth := 3;
               Match_Byte (Current, Item);
            elsif Current.In_Theory and then Current.Depth < Byte_Count'Last then
               Current.Depth := Current.Depth + 1;
               Match_Byte (Current, Item);
            else
               Current.Failed := True;
            end if;
         when ']' =>
            if Current.Depth = 2
              and then Current.Phase in First_Theory | Theory_Separator
            then
               Current.Depth := 1;
               Current.Phase := Root_End;
            elsif Current.In_Theory and then Current.Depth = 3 then
               End_Theory (Current);
            elsif Current.In_Theory and then Current.Depth > 3 then
               if Current.Depth = 4 and then Current.Bytes > 0 then
                  if Current.Field = 3 then
                     Current.Candidate_Declarations := Current.Bytes - 1;
                  elsif Current.Field = 6 then
                     Current.Candidate_Includes := Current.Bytes - 1;
                  end if;
               end if;
               Current.Depth := Current.Depth - 1;
               Match_Byte (Current, Item);
            else
               Current.Failed := True;
            end if;
         when ':' =>
            if Current.Phase = Root_Colon and then Current.Depth = 1 then
               Current.Phase := Root_List;
            elsif Current.In_Theory then
               Match_Byte (Current, Item);
            else
               Current.Failed := True;
            end if;
         when ',' =>
            if Current.Depth = 2 and then Current.Phase = Theory_Separator then
               Current.Phase := Next_Theory;
            elsif Current.In_Theory then
               if Current.Depth = 3 then
                  if Current.Field < 7 then
                     Current.Field := Current.Field + 1;
                  else
                     Current.Failed := True;
                  end if;
               end if;
               Match_Byte (Current, Item);
            else
               Current.Failed := True;
            end if;
         when '"' =>
            if Current.In_Theory
              or else (Current.Depth = 1 and then Current.Phase = Root_Key)
            then
               Current.String_Is_Tag := Current.Previous_Array_Start;
               Current.String_Is_Key := Current.Depth = 1;
               Current.String_Is_Name := Current.Depth = 3 and then Current.Field = 4;
               Current.String_Is_Theory_Tag := Current.Depth = 3 and then Current.Field = 0;
               Current.String_Length := 0;
               Current.String_Prefix := (others => ' ');
               Current.Mode := In_String;
               Match_Byte (Current, Item);
            else
               Current.Failed := True;
            end if;
         when '0' .. '9' | '-' =>
            if Current.In_Theory then
               Current.Number_Is_Id := Current.Node_Id_Pending;
               Current.Node_Id_Pending := False;
               Current.Number_Value := 0;
               Current.Number_Digits := Item in '0' .. '9';
               Current.Mode := In_Number;
               if Current.Number_Is_Id then
                  if Item in '0' .. '9' then
                     Current.Number_Value := Character'Pos (Item) - Character'Pos ('0');
                     Match_Byte (Current, '0');
                  else
                     Current.Failed := True;
                  end if;
               else
                  Match_Byte (Current, Item);
               end if;
            else
               Current.Failed := True;
            end if;
         when 't' | 'f' | 'n' =>
            if Current.In_Theory then
               Current.Mode := In_Literal;
               Match_Byte (Current, Item);
            else
               Current.Failed := True;
            end if;
         when others =>
            Current.Failed := True;
      end case;
      Current.Previous_Array_Start := Item = '[';
   end Structural;

   procedure Consume (Current : in out State; Item : Character) is
      Digit : Natural;
   begin
      if Current.Failed then
         return;
      elsif Current.Bytes = Byte_Count'Last then
         Current.Failed := True;
         return;
      end if;
      Current.Bytes := Current.Bytes + 1;
      case Current.Mode is
         when In_String =>
            if Item = '"' then
               End_String (Current);
            elsif Item = '\' then
               Current.Mode := After_Escape;
            elsif Character'Pos (Item) < 32 then
               Current.Failed := True;
            else
               Decoded (Current, Character'Pos (Item));
            end if;
         when After_Escape =>
            Current.Mode := In_String;
            case Item is
               when '"' | '\' | '/' => Decoded (Current, Character'Pos (Item));
               when 'b' => Decoded (Current, 8);
               when 't' => Decoded (Current, 9);
               when 'n' => Decoded (Current, 10);
               when 'f' => Decoded (Current, 12);
               when 'r' => Decoded (Current, 13);
               when 'u' =>
                  Current.Mode := In_Unicode;
                  Current.Unicode_Left := 4;
                  Current.Unicode_Value := 0;
               when others => Current.Failed := True;
            end case;
         when In_Unicode =>
            Digit := Hex (Item);
            if Digit < 16 and then Current.Unicode_Left > 0
              and then Current.Unicode_Value <= (65_535 - Digit) / 16
            then
               Current.Unicode_Value := Current.Unicode_Value * 16 + Digit;
               Current.Unicode_Left := Current.Unicode_Left - 1;
               if Current.Unicode_Left = 0 then
                  Decoded (Current, Current.Unicode_Value);
                  Current.Mode := In_String;
               end if;
            else
               Current.Failed := True;
            end if;
         when In_Number | In_Literal =>
            if Item in ' ' | Character'Val (9) | Character'Val (10) | Character'Val (13)
              | ',' | ']' | '}' | ':' | '[' | '{' | '"'
            then
               if Current.Mode = In_Number and then Current.Number_Is_Id then
                  if not Current.Number_Digits then
                     Current.Failed := True;
                  else
                     Current.Greatest_Id := Original_Node_Id'Max
                       (Current.Greatest_Id, Current.Number_Value);
                  end if;
               end if;
               Current.Mode := Between_Tokens;
               Structural (Current, Item);
            elsif Current.Mode = In_Number and then Current.Number_Is_Id then
               if Item in '0' .. '9' then
                  Digit := Character'Pos (Item) - Character'Pos ('0');
                  if Current.Number_Value <= (Original_Node_Id'Last - Digit) / 10 then
                     Current.Number_Value := Current.Number_Value * 10 + Digit;
                     Current.Number_Digits := True;
                  else
                     Current.Failed := True;
                  end if;
               else
                  Current.Failed := True;
               end if;
            else
               Match_Byte (Current, Item);
            end if;
         when Between_Tokens => Structural (Current, Item);
      end case;
   end Consume;

   function Finish (Current : State) return Plan is
      Result : Plan := (Bytes => Current.Bytes, Greatest_Id => Current.Greatest_Id,
                        others => <>);
   begin
      if Current.Failed or else Current.Mode /= Between_Tokens
        or else Current.Phase /= After_Root or else Current.Depth /= 0
        or else Current.In_Theory or else Current.Node_Id_Pending
      then
         return Result;
      elsif not Current.Seen (Image_Theory) then
         Result.Kind := Unchanged;
      elsif Current.Seen (Integer_Theory) and then Current.Seen (String_Theory)
        and then Current.Declarations_Offset < Current.Includes_Offset
        and then Current.Includes_Offset < Current.Bytes
      then
         Result.Kind := Refine;
         Result.Declarations_Offset := Current.Declarations_Offset;
         Result.Includes_Offset := Current.Includes_Offset;
      end if;
      return Result;
   end Finish;
end Silver_Image_Model;
