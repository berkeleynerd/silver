with Silver_Function_Bindings;
with Silver_Procedure_Bindings;
with Silver_Report_Observations;
with Silver_Report_Projection_Observations;
with Silver_Application_Report_Metadata;

package Silver_Library_Reports with SPARK_Mode => On is
   package Application_Metadata renames Silver_Application_Report_Metadata;
   subtype Application_Context is Application_Metadata.Context;
   Empty_Context : constant Application_Context := Application_Metadata.Empty_Context;
   package Function_Bindings renames Silver_Function_Bindings;
   subtype Function_Metadata is Function_Bindings.Metadata;
   Empty_Functions : constant Function_Metadata := Function_Bindings.Empty_Metadata;
   package Procedure_Bindings renames Silver_Procedure_Bindings;
   subtype Procedure_Metadata is Procedure_Bindings.Metadata;
   Empty_Procedures : constant Procedure_Metadata := Procedure_Bindings.Empty_Metadata;
   --  Source-bounded application sequences can produce many proved checks and
   --  exact implicit-state-output and repeated array-loop advisories. This capacity uses
   --  the documented pinned producer envelope; it is not an additional statement-count restriction.
   Max_Report_Length : constant Positive := 268_435_456;
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
     (Report : String; Kind : Application_Kind := Argument_Output;
      Source : String := ""; Functions : Function_Metadata := Empty_Functions;
      Procedures : Procedure_Metadata := Empty_Procedures; Context : Application_Context := Empty_Context) return Boolean
     with Ghost => Static, Global => null;

   --  The complete audit policy over mathematical original-report bytes.
   --  Its definition has no report-storage guard and invokes no projector.
   function Unbounded_Runtime_Report_Policy
     (Report : Silver_Report_Observations.Bytes.Sequence; Kind : Report_Kind) return Boolean
     with Ghost => Static, Global => null;
   function Unbounded_Application_Report_Policy
     (Report : Silver_Report_Observations.Bytes.Sequence;
      Kind : Application_Kind := Argument_Output;
      Source : String := ""; Functions : Function_Metadata := Empty_Functions;
      Procedures : Procedure_Metadata := Empty_Procedures; Context : Application_Context := Empty_Context) return Boolean
     with Ghost => Static, Global => null;

   --  The original report is an unbounded mathematical byte sequence. Only
   --  storage of the projected representation is limited. The premise records
   --  actual scanner/member observations; it never assumes audit acceptance.
   procedure Application_Projection_Correspondence
     (Original : Silver_Report_Observations.Bytes.Sequence; Projected : String;
      Kind : Application_Kind := Argument_Output;
      Source : String := ""; Functions : Function_Metadata := Empty_Functions;
      Procedures : Procedure_Metadata := Empty_Procedures; Context : Application_Context := Empty_Context)
     with Ghost => Static, Global => null,
       Pre => Projected'First = 1 and then Projected'Length <= Max_Report_Length
         and then Silver_Report_Projection_Observations.Audit_Projection_Observations
           (Original, Silver_Report_Observations.From_String (Projected)),
       Post => Unbounded_Application_Report_Policy (Original, Kind, Source, Functions, Procedures, Context => Context) =
         Application_Report_Policy (Projected, Kind, Source, Functions, Procedures, Context => Context);

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
   --  Source membership selects Main, every declared local subprogram, and the
   --  applicable runtime callees. Every local subprogram has distinct all coverage,
   --  even if unused. Functions require one successful implicit termination record;
   --  each procedure out formal requires one successful initialization record with
   --  its exact owner and source-case name. Inout formals need no such witness.
   --  Every emitted safety check must be a proved range, length, overflow,
   --  nonzero-divisor or index check for Main or an identified local subprogram.
   --  Local dependency references permit only effects and absence-of-run-time-error
   --  claims; no author postcondition is introduced by this report policy.
   --  All output forms permit exact ineffective-initialization advisories; assigned and
   --  selected results additionally permit the exact unused-assignment advisory.
   --  All sequence forms permit the exact ineffective/unreachable-statement
   --  advisories from constant-folded comparisons and loops, and four exact unused ghost
   --  output messages from each of Put and Put_Line. Local functions/procedures
   --  also permit the exact UNUSED_VARIABLE unused-formal advisory. The exact
   --  INEFFECTIVE unused-copy-back message names a declared procedure callee.
   --  INOUT_ONLY_READ accepts only '"NAME" is not modified, could be IN' for
   --  a procedure in out formal. UNUSED_INITIAL_VALUE accepts only
   --  'unused initial value of "NAME"' for procedure in/in out or function in.
   --  Both bind exact declared owner/formal spelling, never Main, with warning
   --  severity, flow provenance, main.adb, positive locations and no suppression
   --  or justification. Formal binding uses neither columns nor record order.
   --  The warning list permits the exact array-initialization information-loss
   --  note and the pinned Image advisory, with the producer's Image, image
   --  or IMAGE spelling in its message and the exact producer state,
   --  no entity or justification, empty suppression string and empty proof tree.
   --  Other diagnostics are rejected.
   --  These advisories do not remove safety checks or fixed object bounds.
   --  GNAT can omit callees after static elimination, including sequences with
   --  no output. Reports without runtime callees retain the check/dependency audit;
   --  argument sequences may retain the three argument callees without IO.
   function Complete_Application_Proof
     (Report : String; Kind : Application_Kind := Argument_Output;
      Source : String := ""; Functions : Function_Metadata := Empty_Functions;
      Procedures : Procedure_Metadata := Empty_Procedures; Context : Application_Context := Empty_Context) return Boolean
     with Global => null,
       Post => (Static => Complete_Application_Proof'Result = Application_Report_Policy (Report, Kind, Source, Functions, Procedures, Context => Context));
end Silver_Library_Reports;
