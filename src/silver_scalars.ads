package Silver_Scalars with SPARK_Mode => On is
   --  The admitted predefined Integer has this range on the pinned native
   --  GNAT targets. Wide arithmetic is compiler implementation machinery only.
   subtype Value is Integer range -2_147_483_648 .. 2_147_483_647;
   subtype Wide is Long_Long_Integer;
   Minimum : constant Wide := -2_147_483_648;
   Maximum : constant Wide := 2_147_483_647;

   type Interval is record
      Lower, Upper : Value;
   end record;
   Empty : constant Interval := (1, 0);
   Full : constant Interval := (Value'First, Value'Last);
   function Is_Empty (Bounds : Interval) return Boolean is
     (Bounds.Lower > Bounds.Upper);
   function Contains (Bounds : Interval; Item : Value) return Boolean is
     (Item >= Bounds.Lower and then Item <= Bounds.Upper);
   function Singleton (Item : Value) return Interval is ((Item, Item));
   function Normalize (Bounds : Interval) return Interval is
     (if Is_Empty (Bounds) then Empty else Bounds);
   function Join (Left, Right : Interval) return Interval is
     (if Is_Empty (Left) then Normalize (Right)
      elsif Is_Empty (Right) then Left
      else (Value'Min (Left.Lower, Right.Lower),
            Value'Max (Left.Upper, Right.Upper)));
   function Intersect (Left, Right : Interval) return Interval is
     (Normalize ((Value'Max (Left.Lower, Right.Lower),
                  Value'Min (Left.Upper, Right.Upper))));

   type Comparison is (Equal, Unequal, Less, Less_Equal, Greater, Greater_Equal);
   function Compare (Operator : Comparison; Left, Right : Value) return Boolean is
     (case Operator is
        when Equal => Left = Right,
        when Unequal => Left /= Right,
        when Less => Left < Right,
        when Less_Equal => Left <= Right,
        when Greater => Left > Right,
        when Greater_Equal => Left >= Right);
   function Complement (Operator : Comparison) return Comparison is
     (case Operator is
        when Equal => Unequal, when Unequal => Equal,
        when Less => Greater_Equal, when Less_Equal => Greater,
        when Greater => Less_Equal, when Greater_Equal => Less);
   function Swap (Operator : Comparison) return Comparison is
     (case Operator is
        when Equal => Equal, when Unequal => Unequal,
        when Less => Greater, when Less_Equal => Greater_Equal,
        when Greater => Less, when Greater_Equal => Less_Equal);
   function Below (Bounds : Interval; Threshold : Value) return Interval is
     (if Threshold = Value'First then Empty
      else Intersect (Bounds, (Value'First, Threshold - 1)));
   function Above (Bounds : Interval; Threshold : Value) return Interval is
     (if Threshold = Value'Last then Empty
      else Intersect (Bounds, (Threshold + 1, Value'Last)));
   function Refine_True
     (Bounds : Interval; Operator : Comparison; Threshold : Value)
      return Interval is
     (case Operator is
        when Equal => Intersect (Bounds, Singleton (Threshold)),
        when Unequal => Join (Below (Bounds, Threshold), Above (Bounds, Threshold)),
        when Less => Below (Bounds, Threshold),
        when Less_Equal => Intersect (Bounds, (Value'First, Threshold)),
        when Greater => Above (Bounds, Threshold),
        when Greater_Equal => Intersect (Bounds, (Threshold, Value'Last)));
   function Refine
     (Bounds : Interval; Operator : Comparison; Threshold : Value; Truth : Boolean)
      return Interval is
     (Refine_True
        (Bounds, (if Truth then Operator else Complement (Operator)), Threshold));

   type Check_Result is record
      Safe : Boolean;
      Bounds : Interval;
   end record;
   Invalid : constant Check_Result := (False, Empty);
   Unreachable : constant Check_Result := (True, Empty);
   function In_Range (Item : Wide) return Boolean is
     (Item >= Minimum and then Item <= Maximum);
   --  Static expression legality is checked independently by the parser.
   --  Unreachable bounds establish only vacuous dynamic safety, not permission
   --  to admit an Ada static expression whose value is outside its base type.
   function Checked (Lower, Upper : Wide) return Check_Result is
     (if Lower > Upper then Unreachable
      elsif In_Range (Lower) and then In_Range (Upper)
      then (True, (Value (Lower), Value (Upper))) else Invalid);
   function Add (Left, Right : Interval) return Check_Result is
     (if Is_Empty (Left) or else Is_Empty (Right) then Unreachable
      else Checked (Wide (Left.Lower) + Wide (Right.Lower),
                    Wide (Left.Upper) + Wide (Right.Upper)));
   function Subtract (Left, Right : Interval) return Check_Result is
     (if Is_Empty (Left) or else Is_Empty (Right) then Unreachable
      else Checked (Wide (Left.Lower) - Wide (Right.Upper),
                    Wide (Left.Upper) - Wide (Right.Lower)));
   function Negate (Operand : Interval) return Check_Result is
     (if Is_Empty (Operand) then Unreachable
      else Checked (-Wide (Operand.Upper), -Wide (Operand.Lower)));
   function Product_Minimum (Left, Right : Interval) return Wide is
     (Wide'Min (Wide'Min (Wide (Left.Lower) * Wide (Right.Lower),
                         Wide (Left.Lower) * Wide (Right.Upper)),
                Wide'Min (Wide (Left.Upper) * Wide (Right.Lower),
                         Wide (Left.Upper) * Wide (Right.Upper))));
   function Product_Maximum (Left, Right : Interval) return Wide is
     (Wide'Max (Wide'Max (Wide (Left.Lower) * Wide (Right.Lower),
                         Wide (Left.Lower) * Wide (Right.Upper)),
                Wide'Max (Wide (Left.Upper) * Wide (Right.Lower),
                         Wide (Left.Upper) * Wide (Right.Upper))));
   function Multiply (Left, Right : Interval) return Check_Result is
     (if Is_Empty (Left) or else Is_Empty (Right) then Unreachable
      else Checked (Product_Minimum (Left, Right), Product_Maximum (Left, Right)));
end Silver_Scalars;
