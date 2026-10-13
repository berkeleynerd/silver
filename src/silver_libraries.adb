with Silver_Build;
with Silver_Platform;
with Silver_Library_Reports;
with Silver_Library_Sources;

package body Silver_Libraries with SPARK_Mode => On is
   use Silver_Platform;
   use type Silver_Library_Reports.Report_Kind;
   Library_Directory : constant String := Silver_Build.Source_Directory;

   function File_Name (Kind : Unit_Kind) return String is
     (case Kind is
        when IO_Specification => "silver_io.ads",
        when IO_Implementation => "silver_io.adb",
        when Imported_Interface => "silver_output_libc.ads",
        when Arguments_Specification => "silver_arguments.ads",
        when Arguments_Implementation => "silver_arguments.adb",
        when Runtime_Interface => "silver_runtime.ads");

   function Expected_Source (Kind : Unit_Kind) return String is
   begin
      --  Callers need the source value and its verified bounds, without
      --  unfolding every byte of the generated constants in their proofs.
      case Kind is
         when IO_Specification =>
            return Silver_Library_Sources.IO_Specification;
         when IO_Implementation =>
            return Silver_Library_Sources.IO_Implementation;
         when Imported_Interface =>
            return Silver_Library_Sources.Imported_Interface;
         when Arguments_Specification =>
            return Silver_Library_Sources.Arguments_Specification;
         when Arguments_Implementation =>
            return Silver_Library_Sources.Arguments_Implementation;
         when Runtime_Interface =>
            return Silver_Library_Sources.Runtime_Interface;
      end case;
   end Expected_Source;

   procedure Check_Proof_Evidence (Directory : String; Success : out Boolean) is
      Report : String (1 .. Silver_Library_Reports.Max_Runtime_Report_Length);
      Last : Natural;
      Too_Long, Read_Success : Boolean;
   begin
      Success := False;
      Proof_Complete := False;
      Accepted_Reports := (others => False);
      for Kind in Silver_Library_Reports.Report_Kind loop
         pragma Loop_Invariant (Static =>
           (for all Earlier in Silver_Library_Reports.Report_Kind =>
             (if Earlier < Kind then Accepted_Reports (Earlier))));
         declare
            Name : constant String := Directory & "/obj/gnatprove/" &
              (case Kind is
                 when Silver_Library_Reports.Library_Body => "silver_io.spark",
                 when Silver_Library_Reports.Imported_Interface => "silver_output_libc.spark",
                 when Silver_Library_Reports.Arguments_Body => "silver_arguments.spark",
                 when Silver_Library_Reports.Runtime_Interface => "silver_runtime.spark");
            Accepted : Boolean;
         begin
            Read_File (Name, Report, Last, Too_Long, Read_Success);
            if not Read_Success or else Too_Long then
               return;
            end if;
            Accepted := Silver_Library_Reports.Complete_Runtime_Proof (Report (1 .. Last), Kind);
            Accepted_Reports (Kind) := Read_Success and then not Too_Long and then Accepted;
            if not Accepted then
               return;
            end if;
         end;
      end loop;
      --  Every selected, fully read report passed the source-specific checker.
      Proof_Complete := True;
      Success := True;
   end Check_Proof_Evidence;

   procedure Same_Sources
     (Directory : String; Expected : Source_Set; Success : out Boolean)
   is
      Observed : Source_Buffer;
      Last : Natural;
      Too_Long : Boolean;
   begin
      Checked := (Bytes => (others => (others => Character'Val (0))),
                  Lengths => (others => 0));
      for Kind in Unit_Kind loop
         pragma Loop_Invariant
           (Static => (for all Earlier in Unit_Kind =>
              (if Earlier < Kind then Checked.Bytes (Earlier) (1 .. Checked.Lengths (Earlier))
                  = Expected.Bytes (Earlier) (1 .. Expected.Lengths (Earlier))
                and then Checked.Lengths (Earlier) = Expected.Lengths (Earlier))));
         Read_File (Directory & "/" & File_Name (Kind), Observed, Last, Too_Long, Success);
         if not Success or else Too_Long or else Last /= Expected.Lengths (Kind)
           or else Observed (1 .. Last) /= Expected.Bytes (Kind) (1 .. Expected.Lengths (Kind))
         then
            Success := False;
            return;
         end if;
         Checked.Bytes (Kind) := Observed;
         Checked.Lengths (Kind) := Last;
      end loop;
   end Same_Sources;

   procedure Capture_And_Snapshot
     (Directory : String; Sources : out Source_Set; Success : out Boolean)
   is
      Last : Natural;
      Too_Long : Boolean;
   begin
      Sources := (Bytes => (others => (others => Character'Val (0))),
                  Lengths => (others => 0));
      Captured := Sources;
      Checked := Sources;
      --  Vacuous success before any file; every completed write contributes
      --  its actual closure, count and content observation below.
      All_Written := True;
      Success := False;
      if not Valid_Directory (Library_Directory) then
         return;
      end if;
      for Kind in Unit_Kind loop
         pragma Loop_Invariant
           (for all Earlier in Unit_Kind => (if Earlier < Kind then Sources.Lengths (Earlier) > 0));
         pragma Loop_Invariant (Static =>
           (for all Earlier in Unit_Kind => (if Earlier < Kind then
             Sources.Bytes (Earlier) (1 .. Sources.Lengths (Earlier)) = Expected_Source (Earlier))));
         pragma Loop_Invariant
           (Static => Captured = Sources and then All_Written);
         Read_File (Library_Directory & "/" & File_Name (Kind), Sources.Bytes (Kind),
                    Last, Too_Long, Success);
         if not Success or else Too_Long or else Last = 0
           or else Sources.Bytes (Kind) (1 .. Last) /= Expected_Source (Kind)
         then
            Success := False;
            Sources.Lengths := (others => 0);
            return;
         end if;
         Sources.Lengths (Kind) := Last;
         --  Sources contains the actual bytes returned by Read_File. This
         --  summary does not create source identity: the executable comparison
         --  to Expected_Source and final Same_Sources check establish it.
         Captured := Sources;
         Write_File (Directory & "/" & File_Name (Kind),
                     Sources.Bytes (Kind) (1 .. Sources.Lengths (Kind)), Success);
         if not Success then
            Sources.Lengths := (others => 0);
            return;
         end if;
         All_Written := All_Written and then Write_Closed
           and then Written_Count = Sources.Lengths (Kind)
           and then Written_Bytes (1 .. Written_Count) = Sources.Bytes (Kind) (1 .. Sources.Lengths (Kind));
      end loop;
      Same_Sources (Directory, Sources, Success);
      if not Success then
         Sources.Lengths := (others => 0);
      end if;
   end Capture_And_Snapshot;
end Silver_Libraries;
