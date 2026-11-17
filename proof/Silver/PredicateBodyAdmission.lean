module

public import Silver.PredicateAdmission
public import Silver.PredicateComposition
public import Silver.PredicateSourceSyntax
public import Silver.PredicateBodyScanner

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

def expandBody (before : ParserState) (scan : BodyScan) : ScanResult :=
  ⟨{before with position := scan.position, target := scan.target, capacity := scan.capacity, scalarNames := ScalarExpression.bodyEnvironment before.scalarNames},
    scan.assigned, scan.output⟩

def readStatements (text : Source) (scan : ScanResult) : ScanResult :=
  let result := readBody text (contextOf scan) (bodyOf scan) .endOnly scan.state.functions scan.state.procedures
  if result.position = 0 ∨ !completed result.facts.path then invalidScan else expandBody scan.state result

inductive Form | direct | argument
  deriving DecidableEq, Repr

def allForms : List Form := [.direct, .argument]

def Form.hasArguments : Form → Bool | .direct => false | .argument => true

def Form.helper : Form → Compose.Form | .direct => .direct | .argument => .argument

inductive Token | helper (token : ShellToken) | statements
  deriving DecidableEq, Repr

def Form.prefix (form : Form) : List ShellToken := currentHeader form.hasArguments

def Form.footer (_form : Form) : List ShellToken := [.word "end", .word "main", .symbol ";"]

def Form.tokens (form : Form) : List Token :=
  form.prefix.map Token.helper ++ [.statements] ++ form.footer.map Token.helper

def scanStep (text : Source) (form : Form) (token : Token) (scan : ScanResult) : ScanResult :=
  match token with
  | .helper token =>
      let next := step text form.helper token scan.state
      {scan with state := next, assigned := scan.assigned || next.assignedInFunctions}
  | .statements => readStatements text scan

def scanSuffix (text : Source) (form : Form) : List Token → ScanResult → ScanResult
  | [], scan =>
      if scan.state.position ≠ 0 ∧ Cursor.triviaPosition text scan.state.position = text.length + 1
      then scan else invalidScan
  | token :: rest, scan =>
      if scan.state.position = 0 then invalidScan
      else scanSuffix text form rest (scanStep text form token scan)

def formResult (text : Source) (form : Form) : ScanResult :=
  if decide (0 < text.length ∧ text.length ≤ maxSourceLength) && text.all allowedCharacter && withinWorkBudget text
  then scanSuffix text form form.tokens initialScan else invalidScan

def formAccepts (text : Source) (form : Form) : Bool := decide ((formResult text form).state.position ≠ 0)
def selectedForm (text : Source) : Option Form := allForms.find? (formAccepts text)
def accepts (text : Source) : Bool := (selectedForm text).isSome

def hasArguments (text : Source) : Bool := allForms.any fun form => formAccepts text form && form.hasArguments
def hasAssignment (text : Source) : Bool := allForms.any fun form => formAccepts text form && (formResult text form).assigned
def hasOutput (text : Source) : Bool := allForms.any fun form => formAccepts text form && (formResult text form).output

end Silver.Predicate
