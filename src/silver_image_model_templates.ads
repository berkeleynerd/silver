--  Complete pinned typed-JSON declarations and the two additive fragments.
--  Only W-node IDs and JSON whitespace are normalized during matching.
package Silver_Image_Model_Templates with SPARK_Mode => On is
   type Kind is (Integer_Template, String_Template, Image_Template,
                 Declarations_Fragment, Includes_Fragment);
   function Length (Item : Kind) return Positive
     with Global => null;
   function Byte_At (Item : Kind; Position : Positive) return Character
     with Global => null, Pre => Position <= Length (Item);
   Inserted_Node_Count : constant := 23;
end Silver_Image_Model_Templates;
