module

public import Silver.ApplicationAdmissionModel
public import Silver.ApplicationPackageTypes

@[expose] public section

/-! Equations of the original-unit Main reader. The callees remain explicit
until their typed source interpretations are composed. Acceptance exposes the
actual declaration frame, statement scan, context start and exact EOF check;
it supplies no assumed well-formedness or safety certificate. -/
namespace Silver.ApplicationPackageMain
open Compose Predicate ApplicationPackages
open ApplicationAdmission (AnalysisResult invalidAnalysis)
open ApplicationUnits (Bundle)

structure Calls where
  importedPackage : Source → Source
  samePackageSpelling : Source → PackageBindings.Metadata → Source → Bool
  readContext : Source → Nat → Nat → Nat → Names.Context
  takeToken : Source → Nat → ShellToken → Nat
  sparkPragmaAfter : Source → Nat → Nat
  importedFrame : Source → ParserState → PackageBindings.Metadata → Nat → ParserState
  argumentAt : Source → ParserState → ParserState
  readDeclarations : Source → ParserState → Bool → ParserState
  contextOf : ScanResult → ParseContext
  bodyOf : ScanResult → BodyScan
  applicationTail : Source → ParseContext → ApplicationScan → PackageBindings.Metadata →
    BodyStop → Bool → FunctionBindings.Metadata → ProcedureBindings.Metadata → ApplicationScan
  skipAt : Source → Nat → Nat
  completed : PathFacts.Context → Bool

def textOf (sources : Bundle) : Source := sources.pool.take sources.used

def contextClauses (calls : Calls) (sources : Bundle) (info : PackageBindings.Metadata) : Names.Context :=
  calls.readContext (textOf sources) (sources.units .mainBody).first info.nameFirst info.nameAfter

def mainStart (calls : Calls) (sources : Bundle) (info : PackageBindings.Metadata) : Nat :=
  let text := textOf sources
  calls.sparkPragmaAfter text (calls.takeToken text (calls.takeToken text
    (calls.takeToken text (contextClauses calls sources info).after (.word "procedure"))
      (.word "main")) (.word "is"))

def argumentFrame (calls : Calls) (sources : Bundle) (exports : ParserState)
    (info : PackageBindings.Metadata) : ParserState :=
  let frame := calls.importedFrame (textOf sources) exports info (mainStart calls sources info)
  if (contextClauses calls sources info).argumentsWith then calls.argumentAt (textOf sources) frame else frame

def declarationsFrame (calls : Calls) (sources : Bundle) (exports : ParserState)
    (info : PackageBindings.Metadata) : ParserState :=
  calls.readDeclarations (textOf sources) (argumentFrame calls sources exports info)
    (contextClauses calls sources info).argumentsWith

def bodyFrame (calls : Calls) (sources : Bundle) (exports : ParserState)
    (info : PackageBindings.Metadata) : ParserState :=
  let frame := declarationsFrame calls sources exports info
  {frame with position := calls.takeToken (textOf sources) frame.position (.word "begin")}

def bodyScan (calls : Calls) (sources : Bundle) (exports : ParserState)
    (info : PackageBindings.Metadata) : ApplicationScan :=
  let frame := bodyFrame calls sources exports info
  let scan : ScanResult := ⟨frame, frame.assignedInFunctions, false⟩
  calls.applicationTail (textOf sources) (calls.contextOf scan)
    (applicationOf (calls.bodyOf scan)) info .endOnly true frame.functions frame.procedures

def following (calls : Calls) (sources : Bundle) (exports : ParserState)
    (info : PackageBindings.Metadata) : Nat :=
  let text := textOf sources
  calls.takeToken text (calls.takeToken text
    (calls.takeToken text (bodyScan calls sources exports info).scan.position (.word "end"))
      (.word "main")) (.symbol ";")

def acceptedResult (calls : Calls) (sources : Bundle) (exports : ParserState)
    (info : PackageBindings.Metadata) : AnalysisResult :=
  let frame := bodyFrame calls sources exports info
  let result := bodyScan calls sources exports info
  {accepted := true, packageInfo := info,
    mainFunctions := frame.functions, mainProcedures := frame.procedures,
    usesArguments := (contextClauses calls sources info).argumentsWith,
    usesAssignment := result.scan.assigned, usesOutput := result.scan.output}

def packageMainAt (calls : Calls) (sources : Bundle) (exports : ParserState)
    (info : PackageBindings.Metadata) : AnalysisResult :=
  if !calls.samePackageSpelling (textOf sources) info (calls.importedPackage (sources.unitSource .mainBody)) ||
      decide ((contextClauses calls sources info).after = 0) then invalidAnalysis
  else if mainStart calls sources info = 0 then invalidAnalysis
  else if (argumentFrame calls sources exports info).position = 0 then invalidAnalysis
  else if (bodyFrame calls sources exports info).position = 0 then invalidAnalysis
  else if following calls sources exports info = 0 ∨
      calls.skipAt (textOf sources) (following calls sources exports info) ≠ (textOf sources).length + 1 ∨
      calls.completed (bodyScan calls sources exports info).scan.facts.path ≠ true then invalidAnalysis
  else acceptedResult calls sources exports info

structure Accepted (calls : Calls) (sources : Bundle) (exports : ParserState)
    (info : PackageBindings.Metadata) : Prop where
  imported : calls.samePackageSpelling (textOf sources) info
    (calls.importedPackage (sources.unitSource .mainBody)) = true
  contextPresent : (contextClauses calls sources info).after ≠ 0
  startPresent : mainStart calls sources info ≠ 0
  argumentPresent : (argumentFrame calls sources exports info).position ≠ 0
  bodyPresent : (bodyFrame calls sources exports info).position ≠ 0
  footerPresent : following calls sources exports info ≠ 0
  eof : calls.skipAt (textOf sources) (following calls sources exports info) = (textOf sources).length + 1
  completed : calls.completed (bodyScan calls sources exports info).scan.facts.path = true

theorem packageMainAt_accepted_iff (calls : Calls) (sources : Bundle) (exports : ParserState)
    (info : PackageBindings.Metadata) :
    (packageMainAt calls sources exports info).accepted = true ↔ Accepted calls sources exports info := by
  unfold packageMainAt
  split
  · rename_i rejected
    constructor
    · simp [invalidAnalysis]
    · intro accepted
      simp [accepted.imported, accepted.contextPresent] at rejected
  · rename_i imported
    have importedFacts : calls.samePackageSpelling (textOf sources) info
        (calls.importedPackage (sources.unitSource .mainBody)) = true ∧
        (contextClauses calls sources info).after ≠ 0 := by
      simpa only [Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq,
        not_or, Bool.not_eq_false] using imported
    split
    · rename_i missing
      constructor
      · simp [invalidAnalysis]
      · intro accepted; exact False.elim (accepted.startPresent missing)
    · rename_i start
      split
      · rename_i missing
        constructor
        · simp [invalidAnalysis]
        · intro accepted; exact False.elim (accepted.argumentPresent missing)
      · rename_i argument
        split
        · rename_i missing
          constructor
          · simp [invalidAnalysis]
          · intro accepted; exact False.elim (accepted.bodyPresent missing)
        · rename_i body
          split
          · rename_i rejected
            constructor
            · simp [invalidAnalysis]
            · intro accepted
              rcases rejected with missing | nonfinal | incomplete
              · exact False.elim (accepted.footerPresent missing)
              · exact False.elim (nonfinal accepted.eof)
              · exact False.elim (incomplete accepted.completed)
          · rename_i footer
            have footerFacts := not_or.mp footer
            have lastFacts := not_or.mp footerFacts.2
            constructor
            · intro _
              exact ⟨importedFacts.1, importedFacts.2, start, argument, body,
                footerFacts.1, Classical.not_not.mp lastFacts.1, Classical.not_not.mp lastFacts.2⟩
            · intro _; rfl

theorem packageMainAt_result {calls : Calls} {sources : Bundle} {exports : ParserState}
    {info : PackageBindings.Metadata} (accepted : (packageMainAt calls sources exports info).accepted = true) :
    packageMainAt calls sources exports info = acceptedResult calls sources exports info := by
  have facts := (packageMainAt_accepted_iff calls sources exports info).mp accepted
  simp only [packageMainAt, facts.imported, Bool.not_true, facts.contextPresent, decide_false,
    Bool.false_or, Bool.false_eq_true, ↓reduceIte, facts.startPresent, facts.argumentPresent,
    facts.bodyPresent, facts.footerPresent, facts.eof, ne_eq, not_true_eq_false,
    facts.completed, or_self]

theorem packageMainAt_tables {calls : Calls} {sources : Bundle} {exports : ParserState}
    {info : PackageBindings.Metadata} (accepted : (packageMainAt calls sources exports info).accepted = true) :
    (packageMainAt calls sources exports info).packageInfo = info ∧
      (packageMainAt calls sources exports info).mainFunctions =
        (declarationsFrame calls sources exports info).functions ∧
      (packageMainAt calls sources exports info).mainProcedures =
        (declarationsFrame calls sources exports info).procedures := by
  rw [packageMainAt_result accepted]
  exact ⟨rfl, rfl, rfl⟩

end Silver.ApplicationPackageMain
