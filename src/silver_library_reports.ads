package Silver_Library_Reports with SPARK_Mode => On is
   Max_Report_Length : constant Positive := 262_144;
   type Report_Kind is
     (Library_Body, Imported_Interface, Arguments_Body, Runtime_Interface);

   --  Source-specific GNATprove 16.1 report policy for the selected runtime.
   --  This is a bounded format/coverage audit under the trusted tool premise,
   --  not authentication of independently supplied JSON or proof certificates.
   --  Require completed proof progress, no skipped/assumed/warning records,
   --  approved entity dependencies, and proved/info results for every check.
   --  Every owned IO/Arguments entity has all coverage; each approved imported
   --  package has all coverage and exactly its documented imports have spec
   --  coverage. Owned bodies require nonempty flow/proof checks, including the
   --  respective Put_Line or First_Or_Default postcondition result.
   --  Completeness of GNATprove's emitted check list remains a tool premise;
   --  neither the report length nor an historical check total is a proof rule.
   function Complete_Runtime_Proof
     (Report : String; Kind : Report_Kind) return Boolean
     with Global => null;
end Silver_Library_Reports;
