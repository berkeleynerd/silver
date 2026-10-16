package body Silver_Length_Intervals with SPARK_Mode => On is
   function Fits (Facts : Paths.Context; Value : Summary) return Boolean is
     (Value.Static_Length <= Paths.Max_Length
      and then (Is_Empty (Value) or else Paths.Fits (Facts, Upper (Value))));

   function Same_Length (Facts : Paths.Context; Left, Right : Summary) return Boolean is
     (if Is_Empty (Left) or else Is_Empty (Right) then
        Right.Dynamic_Count /= 0 or else Left.Minimum_Length <= Right.Static_Length
      else Paths.Same_Length (Facts, Lower (Left), Upper (Right))
        and then Paths.Same_Length (Facts, Upper (Left), Lower (Right)));

   function Equal_Increasing (Facts : Paths.Context; Left, Right : Summary)
      return Paths.Context
     with Global => null,
       Pre => Left.Dynamic_Count > Right.Dynamic_Count;
   function Equal_Increasing (Facts : Paths.Context; Left, Right : Summary)
      return Paths.Context is
     (if Right.Static_Length < Left.Minimum_Length then Paths.Empty_Context else
        (declare
            Difference : constant Positive := Left.Dynamic_Count - Right.Dynamic_Count;
            Numerator : constant Natural :=
              (if Right.Minimum_Length > Left.Static_Length
               then Right.Minimum_Length - Left.Static_Length else 0);
            Low : constant Natural := (Numerator + Difference - 1) / Difference;
            High : constant Natural := (Right.Static_Length - Left.Minimum_Length) / Difference;
         begin Paths.Intersect (Facts, Low, High)));

   function Refine_Equal (Facts : Paths.Context; Left, Right : Summary)
      return Paths.Context is
     (if Is_Empty (Left) or else Is_Empty (Right) then Paths.Empty_Context
      elsif Left.Dynamic_Count = Right.Dynamic_Count then
        Paths.Keep_If (Facts, Left.Minimum_Length <= Right.Static_Length
          and then Right.Minimum_Length <= Left.Static_Length)
      elsif Left.Dynamic_Count > Right.Dynamic_Count then Equal_Increasing (Facts, Left, Right)
      else Equal_Increasing (Facts, Right, Left));
end Silver_Length_Intervals;
