with Silver_Scalars;

package Silver_Integer_Image with SPARK_Mode => On is
   subtype Image_Length is Natural range 2 .. 11;
   subtype Possible_Length is Natural range 0 .. 11;

   --  Signed threshold tests avoid negating Integer'First. Ada's Image adds
   --  one sign or leading-space byte to the decimal magnitude.
   function Length_Of (Item : Silver_Scalars.Value) return Image_Length is
     (if Item > -10 and then Item < 10 then 2
      elsif Item > -100 and then Item < 100 then 3
      elsif Item > -1_000 and then Item < 1_000 then 4
      elsif Item > -10_000 and then Item < 10_000 then 5
      elsif Item > -100_000 and then Item < 100_000 then 6
      elsif Item > -1_000_000 and then Item < 1_000_000 then 7
      elsif Item > -10_000_000 and then Item < 10_000_000 then 8
      elsif Item > -100_000_000 and then Item < 100_000_000 then 9
      elsif Item > -1_000_000_000 and then Item < 1_000_000_000 then 10
      else 11);

   function Minimum_Length (Bounds : Silver_Scalars.Interval)
      return Possible_Length is
     (if Silver_Scalars.Is_Empty (Bounds) then 0
      elsif Bounds.Lower <= 0 and then Bounds.Upper >= 0 then 2
      else Image_Length'Min (Length_Of (Bounds.Lower), Length_Of (Bounds.Upper)));

   function Maximum_Length (Bounds : Silver_Scalars.Interval)
      return Possible_Length is
     (if Silver_Scalars.Is_Empty (Bounds) then 0
      else Image_Length'Max (Length_Of (Bounds.Lower), Length_Of (Bounds.Upper)));
end Silver_Integer_Image;
