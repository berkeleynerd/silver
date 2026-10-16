with SPARK.Big_Integers;
with Silver_Report_Projection_Types;
with Silver_Report_Projection_Model;
with Silver_Report_Projection_Mapping;
with Silver_Report_Projection_Spans;
with Silver_Report_Projection_Keys;
with Silver_Report_Projection_Observations;
with Silver_Report_Observations;

--  Map raw member cursors once the member punctuation and the changed value's
--  endpoint have been established independently.
package Silver_Report_Projection_Member_Mapping
  with SPARK_Mode => On, Ghost => Static
is
   use SPARK.Big_Integers;
   use Silver_Report_Projection_Types;
   package Model renames Silver_Report_Projection_Model;
   package Mapping renames Silver_Report_Projection_Mapping;
   package Spans renames Silver_Report_Projection_Spans;
   package Keys renames Silver_Report_Projection_Keys;
   package Relations renames Silver_Report_Projection_Observations;
   package Scan renames Silver_Report_Observations;
   package Bytes renames Model.Byte_Sequences;
   use type Scan.Member_State;
   use type Scan.Member;

   function Key_Words (Text : Bytes.Sequence; Key : Scan.Span) return Boolean is
     (((Keys.Raw_Key (Text, Key.First, Key.Last) = Flow_Key) =
        Relations.Word (Text, Key, Relations.Flow_Name))
      and then ((Keys.Raw_Key (Text, Key.First, Key.Last) = Proof_Key) =
        Relations.Word (Text, Key, Relations.Proof_Name))
      and then ((Keys.Raw_Key (Text, Key.First, Key.Last) = Tree_Key) =
        Relations.Word (Text, Key, Relations.Tree_Name)))
     with Pre => Scan.Valid (Text, Key);

   procedure Classify_Key (Text : Bytes.Sequence; Key : Scan.Span)
     with Global => null, Pre => Scan.Valid (Text, Key),
       Post => Key_Words (Text, Key);

   procedure Assemble_Present_Member
     (Raw : Bytes.Sequence; Object : Scan.Span; Position : Big_Natural)
     with Global => null,
       Pre => Scan.Valid (Raw, Object)
         and then Object.First < Position and then Position <= Object.Last
         and then Spans.Retained (Raw, Object.First, Object.First)
         and then Spans.Retained (Raw, Object.Last, Object.Last)
         and then
           (declare M : constant Scan.Member := Scan.Member_Spec (Raw, Object, Position);
            begin M.State = Scan.Present
              and then Position < M.Value.First
              and then Spans.Retained (Raw, Position, M.Value.First - 1)
              and then Spans.Retained (Raw, M.Value.Last + 1, M.Next)
              and then Scan.Valid
                (Mapping.Output (Raw), Mapping.Mapped (Raw, M.Value.First, M.Value.Last))
              and then Scan.Value_Spec (Mapping.Output (Raw), Mapping.First (Raw, M.Value.First)) =
                Mapping.Last (Raw, M.Value.Last)),
       Post => Scan.Valid (Mapping.Output (Raw), Mapping.Mapped (Raw, Object.First, Object.Last))
         and then Mapping.First (Raw, Position) > Mapping.First (Raw, Object.First)
         and then Mapping.First (Raw, Position) <= Mapping.Last (Raw, Object.Last)
         and then
           (declare M : constant Scan.Member := Scan.Member_Spec (Raw, Object, Position);
                    N : constant Scan.Member := Scan.Member_Spec
                      (Mapping.Output (Raw), Mapping.Mapped (Raw, Object.First, Object.Last),
                       Mapping.First (Raw, Position));
            begin N = (Scan.Present, Mapping.Mapped (Raw, M.Key.First, M.Key.Last),
                        Mapping.Mapped (Raw, M.Value.First, M.Value.Last), Mapping.First (Raw, M.Next))
              and then Relations.Same_Content (Raw, M.Key, Mapping.Output (Raw), N.Key)
              and then Key_Words (Raw, M.Key) and then Key_Words (Mapping.Output (Raw), N.Key)
              and then Keys.Raw_Key (Raw, M.Key.First, M.Key.Last) =
                Keys.Raw_Key (Mapping.Output (Raw), N.Key.First, N.Key.Last)
              and then Relations.Word (Raw, M.Key, Relations.Flow_Name) =
                Relations.Word (Mapping.Output (Raw), N.Key, Relations.Flow_Name)
              and then Relations.Word (Raw, M.Key, Relations.Proof_Name) =
                Relations.Word (Mapping.Output (Raw), N.Key, Relations.Proof_Name)
              and then Relations.Word (Raw, M.Key, Relations.Tree_Name) =
                Relations.Word (Mapping.Output (Raw), N.Key, Relations.Tree_Name));
end Silver_Report_Projection_Member_Mapping;
