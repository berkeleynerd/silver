module

public import Silver.PredicateBodyAdmission
public import Silver.PredicateNativeState

@[expose] public section

namespace Silver.Predicate.BooleanBodyNative
open Compose

set_option backward.dsimp.instances true

abbrev TargetCall := Source → Native.Context → Nat → Nat

def modelTarget : TargetCall := fun text context position => booleanTarget text context.model position

@[ext] structure Imports where
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  scalarLookup : Source → ScalarExpression.Environment → Nat → Nat → Nat
  booleanLookup : Source → BooleanBindings.Environment → Nat → Nat → Nat
  assignment : Source → Nat → Nat
  condition : Source → Native.Context → Nat → ActiveFlow → ConditionResult
  invalid : BodyScan → BodyScan

structure Frame where
  text : Source
  context : Native.Context
  position : Nat := 0
  scan : BodyScan := ⟨0, 0, 0, ⟨PathFacts.Context.empty, []⟩, false, false⟩
  first : Nat := 0
  after : Nat := 0
  target : Nat := 0
  value : ConditionResult := invalidCondition ⟨PathFacts.Context.empty, []⟩

inductive Expr : Type → Type 1
  | inputPosition : Expr Nat
  | scanPosition : Expr Nat
  | localFirst : Expr Nat
  | localAfter : Expr Nat
  | localTarget : Expr Nat
  | zero : Expr Nat
  | localValue : Expr ConditionResult
  | skip : Expr Nat → Expr Nat
  | nameAfter : Expr Nat → Expr Nat
  | scalarLookup : Expr Nat → Expr Nat → Expr Nat
  | booleanLookup : Expr Nat → Expr Nat → Expr Nat
  | target : Expr Nat → Expr Nat
  | assignment : Expr Nat → Expr Nat
  | condition : Expr Nat → Expr ConditionResult
  | mutable : Expr Nat → Expr Bool
  | valueAfter : Expr ConditionResult → Expr Nat
  | eqNat : Expr Nat → Expr Nat → Expr Bool
  | neNat : Expr Nat → Expr Nat → Expr Bool
  | leNat : Expr Nat → Expr Nat → Expr Bool
  | not : Expr Bool → Expr Bool
  | orElse : Expr Bool → Expr Bool → Expr Bool
  | invalid : Expr BodyScan
  | assigned : Expr Nat → Expr BodyScan
  | choose : Expr Bool → Expr α → Expr α → Expr α
  | group : Expr α → Expr α
  | locals : Expr α → Expr α
  | letFirst : Expr Nat → Expr α → Expr α
  | letAfter : Expr Nat → Expr α → Expr α
  | letTarget : Expr Nat → Expr α → Expr α
  | letValue : Expr ConditionResult → Expr α → Expr α
  | beginValue : Expr α → Expr α

def Expr.eval (imports : Imports) (target : TargetCall) (frame : Frame) : Expr α → α
  | .inputPosition => frame.position | .scanPosition => frame.scan.position
  | .localFirst => frame.first | .localAfter => frame.after | .localTarget => frame.target
  | .zero => 0 | .localValue => frame.value
  | .skip position => imports.skip frame.text (position.eval imports target frame)
  | .nameAfter first => imports.nameAfter frame.text (first.eval imports target frame)
  | .scalarLookup first after => imports.scalarLookup frame.text frame.context.scalarNames
      (first.eval imports target frame) (after.eval imports target frame)
  | .booleanLookup first after => imports.booleanLookup frame.text frame.context.booleanNames
      (first.eval imports target frame) (after.eval imports target frame)
  | .target position => target frame.text frame.context (position.eval imports target frame)
  | .assignment position => imports.assignment frame.text (position.eval imports target frame)
  | .condition position => imports.condition frame.text frame.context (position.eval imports target frame) frame.scan.facts
  | .mutable index => (BooleanBindings.binding frame.context.booleanNames (index.eval imports target frame)).mutable
  | .valueAfter value => (value.eval imports target frame).after
  | .eqNat left right => decide (left.eval imports target frame = right.eval imports target frame)
  | .neNat left right => decide (left.eval imports target frame ≠ right.eval imports target frame)
  | .leNat left right => decide (left.eval imports target frame ≤ right.eval imports target frame)
  | .not value => !value.eval imports target frame
  | .orElse left right => left.eval imports target frame || right.eval imports target frame
  | .invalid => imports.invalid frame.scan
  | .assigned position => {frame.scan with position := position.eval imports target frame, assigned := true}
  | .choose test yes no => if test.eval imports target frame then yes.eval imports target frame else no.eval imports target frame
  | .group value | .locals value | .beginValue value => value.eval imports target frame
  | .letFirst value body => body.eval imports target {frame with first := value.eval imports target frame}
  | .letAfter value body => body.eval imports target {frame with after := value.eval imports target frame}
  | .letTarget value body => body.eval imports target {frame with target := value.eval imports target frame}
  | .letValue value body => body.eval imports target {frame with value := value.eval imports target frame}

def Expr.render : Expr α → List String
  | .inputPosition => ["position"] | .scanPosition => ["scan", ".", "position"]
  | .localFirst => ["first"] | .localAfter => ["after"] | .localTarget => ["target"]
  | .zero => ["0"] | .localValue => ["value"]
  | .skip position => Expressions.call "skip_at" [["text"], position.render]
  | .nameAfter first => Expressions.call "name_after" [["text"], first.render]
  | .scalarLookup first after => ["scalar_expressions", "."] ++
      Expressions.call "lookup" [["text"], ["context", ".", "scalar_names"], first.render, after.render]
  | .booleanLookup first after => Expressions.call "lookup_boolean"
      [["text"], ["context", ".", "boolean_names"], first.render, after.render]
  | .target position => Expressions.call "boolean_target" [["text"], ["context"], position.render]
  | .assignment position => Expressions.call "take_token" [["text"], position.render, ["assignment"]]
  | .condition position => Expressions.call "condition_model"
      [["text"], ["context"], position.render, ["scan", ".", "facts"]]
  | .mutable index => ["context", ".", "boolean_names", ".", "items", "("] ++ index.render ++ [")", ".", "mutable"]
  | .valueAfter value => value.render ++ [".", "after"]
  | .eqNat left right => left.render ++ ["="] ++ right.render
  | .neNat left right => left.render ++ ["/="] ++ right.render
  | .leNat left right => left.render ++ ["<="] ++ right.render
  | .not value => ["not"] ++ value.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .invalid => Expressions.call "invalid_body_model" [["scan"]]
  | .assigned position => ["(", "scan", "with", "delta", "position", "=>"] ++ position.render ++ [",", "assigned", "=>", "true", ")"]
  | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ ["else"] ++ no.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .locals value => ["declare"] ++ value.render
  | .letFirst value body => ["first", ":", "constant", "literal_position", ":="] ++ value.render ++ [";"] ++ body.render
  | .letAfter value body => ["after", ":", "constant", "literal_position", ":="] ++ value.render ++ [";"] ++ body.render
  | .letTarget value body => ["target", ":", "constant", "boolean_count", ":="] ++ value.render ++ [";"] ++ body.render
  | .letValue value body => ["value", ":", "constant", "condition_result", "(", "scan", ".", "count", ")", ":="] ++
      value.render ++ [";"] ++ body.render
  | .beginValue value => ["begin"] ++ value.render

/-- The condition-result selector requires a name, including a function call,
but cannot select from an explicitly parenthesized expression. -/
def Expr.prefix : Expr α → Bool
  | .inputPosition | .scanPosition | .localFirst | .localAfter | .localTarget | .localValue |
    .skip _ | .nameAfter _ | .scalarLookup _ _ | .booleanLookup _ _ | .target _ | .assignment _ |
    .condition _ | .mutable _ | .valueAfter _ | .invalid => true
  | .zero | .eqNat _ _ | .neNat _ _ | .leNat _ _ | .not _ | .orElse _ _ | .assigned _ |
    .choose _ _ _ | .group _ | .locals _ | .letFirst _ _ | .letAfter _ _ | .letTarget _ _ |
    .letValue _ _ | .beginValue _ => false

def Expr.primary : Expr α → Bool
  | .eqNat _ _ | .neNat _ _ | .leNat _ _ | .not _ | .orElse _ _ | .choose _ _ _
  | .locals _ | .letFirst _ _ | .letAfter _ _ | .letTarget _ _ | .letValue _ _ | .beginValue _ => false
  | _ => true

def Expr.relation : Expr α → Bool
  | .eqNat _ _ | .neNat _ _ | .leNat _ _ | .not _ => true
  | value => value.primary

def Expr.orHead : Expr α → Bool
  | .orElse _ _ => true
  | value => value.relation

def Expr.isLocal : Expr α → Bool
  | .letFirst _ _ | .letAfter _ _ | .letTarget _ _ | .letValue _ _ => true
  | _ => false

def Expr.isBegin : Expr α → Bool | .beginValue _ => true | _ => false

def Expr.wellFormed : Expr α → Bool
  | .inputPosition | .scanPosition | .localFirst | .localAfter | .localTarget | .zero | .localValue | .invalid => true
  | .skip value | .nameAfter value | .target value | .assignment value | .condition value | .mutable value
  | .assigned value => value.primary && value.wellFormed
  | .valueAfter value => value.prefix && value.wellFormed
  | .scalarLookup left right | .booleanLookup left right | .eqNat left right | .neNat left right | .leNat left right =>
      left.primary && right.primary && left.wellFormed && right.wellFormed
  | .not value => value.primary && value.wellFormed
  | .orElse left right => left.orHead && right.relation && left.wellFormed && right.wellFormed
  | .choose test yes no => test.orHead && yes.primary && no.primary && test.wellFormed && yes.wellFormed && no.wellFormed
  | .group value => value.wellFormed
  | .locals value => value.isLocal && value.wellFormed
  | .letFirst value body | .letAfter value body | .letTarget value body | .letValue value body =>
      value.primary && value.wellFormed && (body.isLocal || body.isBegin) && body.wellFormed
  | .beginValue value => value.primary && value.wellFormed

structure Scope where
  first : Bool := false
  after : Bool := false
  target : Bool := false
  value : Bool := false

def Expr.scoped (scope : Scope) : Expr α → Bool
  | .localFirst => scope.first | .localAfter => scope.after | .localTarget => scope.target | .localValue => scope.value
  | .inputPosition | .scanPosition | .zero | .invalid => true
  | .skip value | .nameAfter value | .target value | .assignment value | .condition value | .mutable value
  | .valueAfter value | .assigned value | .not value | .group value | .locals value | .beginValue value => value.scoped scope
  | .scalarLookup left right | .booleanLookup left right | .eqNat left right | .neNat left right | .leNat left right
  | .orElse left right => left.scoped scope && right.scoped scope
  | .choose test yes no => test.scoped scope && yes.scoped scope && no.scoped scope
  | .letFirst value body => value.scoped scope && body.scoped {scope with first := true}
  | .letAfter value body => value.scoped scope && body.scoped {scope with after := true}
  | .letTarget value body => value.scoped scope && body.scoped {scope with target := true}
  | .letValue value body => value.scoped scope && body.scoped {scope with value := true}

def Expr.Sized (imports : Imports) (target : TargetCall) (frame : Frame) : Expr α → Prop
  | .inputPosition | .scanPosition | .localFirst | .localAfter | .localTarget | .zero | .localValue | .invalid => True
  | .skip value | .nameAfter value | .target value | .assignment value | .condition value | .mutable value
  | .valueAfter value | .assigned value | .not value | .group value | .locals value | .beginValue value => value.Sized imports target frame
  | .scalarLookup left right | .booleanLookup left right | .eqNat left right | .neNat left right | .leNat left right
  | .orElse left right => left.Sized imports target frame ∧ right.Sized imports target frame
  | .choose test yes no => test.Sized imports target frame ∧
      (if test.eval imports target frame then yes.Sized imports target frame else no.Sized imports target frame)
  | .letFirst value body => value.Sized imports target frame ∧ body.Sized imports target {frame with first := value.eval imports target frame}
  | .letAfter value body => value.Sized imports target frame ∧ body.Sized imports target {frame with after := value.eval imports target frame}
  | .letTarget value body => value.Sized imports target frame ∧ body.Sized imports target {frame with target := value.eval imports target frame}
  | .letValue value body => value.Sized imports target frame ∧ (value.eval imports target frame).Counts frame.scan.count ∧
      body.Sized imports target {frame with value := value.eval imports target frame}

def targetBody : Expr Nat :=
  .locals (.letFirst (.skip .inputPosition) (.letAfter (.nameAfter .localFirst)
    (.beginValue (.group (.choose (.neNat (.scalarLookup .localFirst .localAfter) .zero)
      .zero (.booleanLookup .localFirst .localAfter))))))

def assignmentBody : Expr BodyScan :=
  .locals (.letFirst (.skip .scanPosition) (.letAfter (.nameAfter .localFirst)
    (.letTarget (.target .scanPosition) (.letValue (.condition (.assignment .localAfter))
      (.beginValue (.group (.choose
        (.orElse (.orElse (.eqNat .localTarget .zero) (.not (.mutable .localTarget)))
          (.leNat (.valueAfter .localValue) .scanPosition))
        .invalid (.assigned (.valueAfter .localValue)))))))))

def targetEquation (imports : Imports) (text : Source) (context : Native.Context) (position : Nat) : Nat :=
  let first := imports.skip text position
  let after := imports.nameAfter text first
  if imports.scalarLookup text context.scalarNames first after ≠ 0 then 0
  else imports.booleanLookup text context.booleanNames first after

def assignmentEquation (imports : Imports) (targetCall : TargetCall) (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  let first := imports.skip text scan.position
  let after := imports.nameAfter text first
  let target := targetCall text context scan.position
  let value := imports.condition text context (imports.assignment text after) scan.facts
  if target = 0 ∨ !(BooleanBindings.binding context.booleanNames target).mutable ∨ value.after ≤ scan.position
  then imports.invalid scan else {scan with position := value.after, assigned := true}

theorem target_denotation (imports : Imports) (target : TargetCall) (text : Source) (context : Native.Context) (position : Nat) :
    targetBody.eval imports target {text, context, position} = targetEquation imports text context position := by
  dsimp only [targetBody, Expr.eval, targetEquation]
  simp +instances only [decide_eq_true_eq]

theorem assignment_denotation (imports : Imports) (target : TargetCall) (text : Source) (context : Native.Context) (scan : BodyScan) :
    assignmentBody.eval imports target {text, context, scan} = assignmentEquation imports target text context scan := by
  dsimp only [assignmentBody, Expr.eval, assignmentEquation]
  simp +instances only [Bool.or_eq_true, decide_eq_true_eq, or_assoc]

theorem checked_precedence : targetBody.wellFormed = true ∧ assignmentBody.wellFormed = true := by decide +kernel

namespace StructuralControls

theorem selected_prefixes :
    (Expr.valueAfter (.group .localValue)).wellFormed = false ∧
    (Expr.valueAfter (.group (.choose (.mutable .localTarget) .localValue .localValue))).wellFormed = false ∧
    (Expr.valueAfter .localValue).wellFormed = true ∧
    (Expr.valueAfter (.condition .inputPosition)).wellFormed = true := by decide +kernel

private def atom : Expr Bool := .mutable .localTarget

private theorem not_collision :
    (Expr.not (.orElse atom atom)).render = (Expr.orElse (.not atom) atom).render ∧
    (Expr.not (.orElse atom atom)).wellFormed = false ∧
    (Expr.orElse (.not atom) atom).wellFormed = true := by decide +kernel

private theorem categories_and_nested_children :
    (Expr.eqNat (.choose atom .zero .inputPosition) .zero).wellFormed = false ∧
    (Expr.eqNat (.group (.choose atom .zero .inputPosition)) .zero).wellFormed = true ∧
    (Expr.valueAfter (.condition (.choose atom .zero .inputPosition))).wellFormed = false ∧
    (Expr.valueAfter (.condition (.group (.choose atom .zero .inputPosition)))).wellFormed = true ∧
    (Expr.group (.not (.orElse atom atom))).wellFormed = false ∧
    (Expr.group (.not (.group (.orElse atom atom)))).wellFormed = true := by decide +kernel

end StructuralControls

theorem checked_scopes : targetBody.scoped {} = true ∧ assignmentBody.scoped {} = true := by decide +kernel

def modelImports : Imports where
  skip := skipAt
  nameAfter := Compose.nameAfter
  scalarLookup := ScalarExpression.lookup
  booleanLookup := BooleanBindings.lookup
  assignment := fun text position => fixedAfter text position ":=" false
  condition := fun text context position facts => readCondition text context.model position facts
  invalid := invalidBody

theorem target_model (text : Source) (context : Native.Context) (position : Nat) :
    targetBody.eval modelImports modelTarget {text, context, position} = booleanTarget text context.model position := by
  rw [target_denotation]
  rfl

theorem assignment_model (text : Source) (context : Native.Context) (scan : BodyScan) :
    assignmentBody.eval modelImports modelTarget {text, context, scan} = booleanAssignmentBody text context.model scan := by
  rw [assignment_denotation]
  rfl

theorem assignment_sized (text : Source) (context : Native.Context) (scan : BodyScan) :
    assignmentBody.Sized modelImports modelTarget {text, context, scan} := by
  simp +instances only [assignmentBody, Expr.Sized, Expr.eval, modelImports, true_and, and_true]
  constructor
  · exact condition_counts _ _ _ _
  · exact (show ∀ b : Bool, (if b then True else True) from by intro b; cases b <;> trivial) _

def targetEval (imports : Imports) (text : Source) (context : Native.Context) (position : Nat) : Nat :=
  targetBody.eval imports modelTarget {text, context, position}

def assignmentEval (imports : Imports) (target : TargetCall) (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  assignmentBody.eval imports target {text, context, scan}

structure Calls where
  target : TargetCall
  assignmentModel : Source → Native.Context → BodyScan → BodyScan
  assignment : Source → Native.Context → BodyScan → BodyScan

def modelCalls : Calls where
  target := modelTarget
  assignmentModel := fun text context scan => booleanAssignmentBody text context.model scan
  assignment := fun text context scan => booleanAssignmentBody text context.model scan

end Silver.Predicate.BooleanBodyNative
