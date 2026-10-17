package Silver_Path_Facts
  with SPARK_Mode => On
is
   Max_Length : constant := 4_096;
   subtype Length_Value is Natural range 0 .. Max_Length;
   subtype Operand_Count is Natural range 0 .. 64;
   subtype Expression_Length is Natural range 0 .. 65 * Max_Length;

   type Comparison is (Equal, Unequal, Less, Less_Equal, Greater, Greater_Equal);
   function Compare (Operator : Comparison; Left, Right : Expression_Length)
      return Boolean is
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

   --  Valid executions carry the immutable input length interval. Invalid
   --  input normalizes to length zero. Reject returns, so its effect is a flag.
   type Context is record
      Lower, Upper : Length_Value;
      Valid_Reachable, Invalid_Reachable, Invalid_Rejected : Boolean;
   end record;
   Empty_Context : constant Context := (0, 0, False, False, True);
   function Initial (Arguments : Boolean) return Context is
     (0, (if Arguments then Max_Length else 0), True, Arguments, False);
   function Ceiling (Facts : Context) return Length_Value is
     (if Facts.Valid_Reachable then Facts.Upper else 0);
   function Assume_Valid (Facts : Context) return Context is
     (Facts with delta Invalid_Reachable => False);
   function Assume_Invalid (Facts : Context) return Context is
     (Facts with delta Lower => 0, Upper => 0, Valid_Reachable => False);
   function Rejected (Facts : Context) return Context is
     (Facts with delta Invalid_Rejected => True);
   function Completed (Facts : Context) return Boolean is
     (not Facts.Invalid_Reachable or else Facts.Invalid_Rejected);
   function Keep_If (Facts : Context; Condition : Boolean) return Context is
     (if Condition then Facts else Empty_Context);

   function Intersect (Facts : Context; Lower, Upper : Natural) return Context is
     (declare
         Low : constant Natural := Natural'Max (Facts.Lower, Lower);
         High : constant Natural := Natural'Min (Facts.Upper, Upper);
         Valid : constant Boolean := Facts.Valid_Reachable and then Low <= High;
      begin
        (Lower => (if Valid then Low else 0),
         Upper => (if Valid then High else 0), Valid_Reachable => Valid,
         Invalid_Reachable => Facts.Invalid_Reachable and then Lower = 0,
         Invalid_Rejected => Facts.Invalid_Rejected));

   function Join (Left, Right : Context) return Context is
     (Lower => (if not Left.Valid_Reachable then Right.Lower
                elsif not Right.Valid_Reachable then Left.Lower
                else Length_Value'Min (Left.Lower, Right.Lower)),
      Upper => (if not Left.Valid_Reachable then Right.Upper
                elsif not Right.Valid_Reachable then Left.Upper
                else Length_Value'Max (Left.Upper, Right.Upper)),
      Valid_Reachable => Left.Valid_Reachable or else Right.Valid_Reachable,
      Invalid_Reachable => Left.Invalid_Reachable or else Right.Invalid_Reachable,
      Invalid_Rejected =>
        (not Left.Invalid_Reachable or else Left.Invalid_Rejected)
        and then (not Right.Invalid_Reachable or else Right.Invalid_Rejected));

   function Below (Facts : Context; Threshold : Length_Value) return Context is
     (if Threshold = 0 then Empty_Context else Intersect (Facts, 0, Threshold - 1));
   function Above (Facts : Context; Threshold : Length_Value) return Context is
     (Intersect (Facts, Threshold + 1, Ceiling (Facts)));
   function Refine_Input_True
     (Facts : Context; Operator : Comparison; Threshold : Length_Value)
      return Context is
     (case Operator is
        when Equal => Intersect (Facts, Threshold, Threshold),
        when Unequal => Join (Below (Facts, Threshold), Above (Facts, Threshold)),
        when Less => Below (Facts, Threshold),
        when Less_Equal => Intersect (Facts, 0, Threshold),
        when Greater => Above (Facts, Threshold),
        when Greater_Equal => Intersect (Facts, Threshold, Ceiling (Facts)));
   function Refine_Input
     (Facts : Context; Operator : Comparison; Threshold : Length_Value; Truth : Boolean)
      return Context is
     (Refine_Input_True
        (Facts, (if Truth then Operator else Complement (Operator)), Threshold));

   type Bound is record
      Static_Length : Length_Value;
      Dynamic : Boolean;
   end record;
   function Refine_Bounds
     (Facts : Context; Operator : Comparison; Left, Right : Bound; Truth : Boolean)
      return Context is
     (if Left.Dynamic and then Right.Dynamic then
        Keep_If (Facts, Compare (Operator, 0, 0) = Truth)
      elsif Left.Dynamic then Refine_Input (Facts, Operator, Right.Static_Length, Truth)
      elsif Right.Dynamic then Refine_Input (Facts, Swap (Operator), Left.Static_Length, Truth)
      else Keep_If (Facts, Compare (Operator, Left.Static_Length, Right.Static_Length) = Truth));

   type Summary is record
      Static_Length : Length_Value;
      Dynamic_Count : Operand_Count;
   end record;
   function Length_At (Value : Summary; Input_Length : Length_Value)
      return Expression_Length is
     (Value.Static_Length + Value.Dynamic_Count * Input_Length);
   function Fits (Facts : Context; Value : Summary) return Boolean is
     ((not Facts.Valid_Reachable or else Length_At (Value, Facts.Upper) <= Max_Length)
      and then (not Facts.Invalid_Reachable or else Length_At (Value, 0) <= Max_Length));
   function Same_Length (Facts : Context; Left, Right : Summary) return Boolean is
     ((Right.Dynamic_Count /= 0
       or else (Left.Static_Length <= Right.Static_Length
         and then (Left.Dynamic_Count /= 0
           or else Left.Static_Length = Right.Static_Length)))
      and then (not Facts.Valid_Reachable or else
        (Length_At (Left, Facts.Lower) = Length_At (Right, Facts.Lower)
         and then Length_At (Left, Facts.Upper) = Length_At (Right, Facts.Upper)))
      and then (not Facts.Invalid_Reachable or else Length_At (Left, 0) = Length_At (Right, 0)));
   function Equal_Increasing (Facts : Context; Left, Right : Summary) return Context
     with Pre => Left.Dynamic_Count > Right.Dynamic_Count;
   function Equal_Increasing (Facts : Context; Left, Right : Summary) return Context is
     (declare
         Numerator : constant Length_Value :=
           (if Right.Static_Length >= Left.Static_Length
            then Right.Static_Length - Left.Static_Length else 0);
         Candidate : constant Length_Value :=
           Numerator / (Left.Dynamic_Count - Right.Dynamic_Count);
      begin Keep_If (Intersect (Facts, Candidate, Candidate),
                    Length_At (Left, Candidate) = Length_At (Right, Candidate)));
   function Refine_Equal (Facts : Context; Left, Right : Summary) return Context is
     (if Left.Dynamic_Count = Right.Dynamic_Count then
        Keep_If (Facts, Left.Static_Length = Right.Static_Length)
      elsif Left.Dynamic_Count > Right.Dynamic_Count then Equal_Increasing (Facts, Left, Right)
      else Equal_Increasing (Facts, Right, Left));
end Silver_Path_Facts;
