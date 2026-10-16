with Silver_Report_Observations;
with Silver_Report_Projection_Observations;

package Silver_Library_Reports with SPARK_Mode => On is
   --  Source-bounded application sequences can produce many proved checks and
   --  exact ghost-output advisories. This capacity uses the documented pinned
   --  producer envelope; it is not an additional statement-count restriction.
   Max_Report_Length : constant Positive := 16_777_216;
   Max_Runtime_Report_Length : constant Positive := 262_144;
   type Report_Kind is
     (Library_Body, Imported_Interface, Arguments_Body, Runtime_Interface);
   type Application_Kind is
     (Static_Output, Argument_Output, Assigned_Output, Selected_Output);

   --  Independent, terminating byte-traversal and complete report policy.
   --  This ghost specification is verified and erased from executable builds.
   function Runtime_Report_Policy (Report : String; Kind : Report_Kind) return Boolean
     with Ghost => Static, Global => null;
   function Application_Report_Policy
     (Report : String; Kind : Application_Kind := Argument_Output) return Boolean
     with Ghost => Static, Global => null;

   --  The complete audit policy over mathematical original-report bytes.
   --  Its definition has no report-storage guard and invokes no projector.
   function Unbounded_Runtime_Report_Policy
     (Report : Silver_Report_Observations.Bytes.Sequence; Kind : Report_Kind) return Boolean
     with Ghost => Static, Global => null;
   function Unbounded_Application_Report_Policy
     (Report : Silver_Report_Observations.Bytes.Sequence;
      Kind : Application_Kind := Argument_Output) return Boolean
     with Ghost => Static, Global => null;

   --  The original report is an unbounded mathematical byte sequence. Only
   --  storage of the projected representation is limited. The premise records
   --  actual scanner/member observations; it never assumes audit acceptance.
   procedure Application_Projection_Correspondence
     (Original : Silver_Report_Observations.Bytes.Sequence; Projected : String;
      Kind : Application_Kind := Argument_Output)
     with Ghost => Static, Global => null,
       Pre => Projected'First = 1 and then Projected'Length <= Max_Report_Length
         and then Silver_Report_Projection_Observations.Audit_Projection_Observations
           (Original, Silver_Report_Observations.From_String (Projected)),
       Post => Unbounded_Application_Report_Policy (Original, Kind) =
         Application_Report_Policy (Projected, Kind);

   procedure Runtime_Projection_Correspondence
     (Original : Silver_Report_Observations.Bytes.Sequence; Projected : String; Kind : Report_Kind)
     with Ghost => Static, Global => null,
       Pre => Projected'First = 1 and then Projected'Length <= Max_Runtime_Report_Length
         and then Silver_Report_Projection_Observations.Audit_Projection_Observations
           (Original, Silver_Report_Observations.From_String (Projected)),
       Post => Unbounded_Runtime_Report_Policy (Original, Kind) = Runtime_Report_Policy (Projected, Kind);

   --  Source-specific GNATprove 16.1 report policy for the selected runtime.
   --  This is a bounded format/coverage audit under the trusted tool premise,
   --  not authentication of independently supplied JSON or proof certificates.
   --  Require completed proof progress, no skipped/assumed/warning records,
   --  approved entity dependencies, and proved/info results for every check.
   --  Every owned IO/Arguments entity has all coverage; each approved imported
   --  package has all coverage and exactly its documented imports have spec
   --  coverage. Owned bodies require nonempty flow/proof checks, including the
   --  respective Put and Put_Line, or First_Or_Default postcondition results.
   --  Completeness of GNATprove's emitted check list remains a tool premise;
   --  neither the report length nor an historical check total is a proof rule.
   function Complete_Runtime_Proof
     (Report : String; Kind : Report_Kind) return Boolean
     with Global => null,
       Post => (Static => Complete_Runtime_Proof'Result = Runtime_Report_Policy (Report, Kind));
   --  Source membership selects the exact Main/callee entity set. Every emitted
   --  safety check must be a proved range, length or overflow check for Main.
   --  All output forms permit exact ineffective-initialization advisories; assigned and
   --  selected results additionally permit the exact unused-assignment advisory.
   --  All sequence forms permit the exact ineffective/unreachable-statement
   --  advisories from constant-folded comparisons and loops, and four exact unused ghost
   --  output messages from each of Put and Put_Line. Other diagnostics are rejected.
   --  These advisories do not remove safety checks or fixed object bounds.
   --  GNAT can omit callees after static elimination, including sequences with
   --  no output. Main-only reports retain the same check/dependency audit;
   --  argument sequences may retain the three argument callees without IO.
   function Complete_Application_Proof
     (Report : String; Kind : Application_Kind := Argument_Output) return Boolean
     with Global => null,
       Post => (Static => Complete_Application_Proof'Result = Application_Report_Policy (Report, Kind));
end Silver_Library_Reports;
