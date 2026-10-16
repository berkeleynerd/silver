package Silver_Image_Theory with SPARK_Mode => On is
   --  Native proof representation of the checked Lean Image length theorem.
   --  The typed producer adapter must establish the clone symbol identities.
   Theory_Text : constant String :=
     "module Integer_Image_Length" & Character'Val (10) &
     "use int.Int" & Character'Val (10) &
     "type image" & Character'Val (10) &
     "type text" & Character'Val (10) &
     "function scalar_image (v : int) : image" & Character'Val (10) &
     "function string_image (x : image) (size : int) : text" & Character'Val (10) &
     "function length (x : text) : int" & Character'Val (10) &
     "axiom checked_length:" & Character'Val (10) &
     "  forall v : int. -2147483648 <= v /\ v <= 2147483647 ->" & Character'Val (10) &
     "    length (string_image (scalar_image v) 12) = 1 + (if -10 < v /\ v < 10 then 1 else (if -100 < v /\ v < 100 then 2 else (if -1000 < v /\ v < 1000 then 3 else (if -10000 < v /\ v < 10000 then 4 else (if -100000 < v /\ v < 100000 then 5 else (if -1000000 < v /\ v < 1000000 then 6 else (if -10000000 < v /\ v < 10000000 then 7 else (if -100000000 < v /\ v < 100000000 then 8 else (if -1000000000 < v /\ v < 1000000000 then 9 else 10)))))))))" & Character'Val (10) &
     "end" & Character'Val (10);
end Silver_Image_Theory;
