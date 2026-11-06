module

import all Init.Data.Repr
public import Silver.ImageModelConsumeNative

@[expose] public section
namespace Silver.ImageModel.ScannerNative

/-! Structural checks for the existing scanner trees. These rules inspect the
operators represented by constructors; they do not parse opaque token leaves or
replace the source interpretation premise. Every constructor is classified
explicitly, so extending the syntax requires revisiting these rules. -/

def Number.primary : Number → Bool
  | .literal _ | .unicodeMaximum | .byteMaximum | .idMaximum | .field _
  | .ordinal _ | .parens _ | .idMaximumOf _ _ | .hex => true
  | .add _ _ | .sub _ _ | .mul _ _ | .div _ _ => false

def Number.term : Number → Bool
  | .mul _ _ | .div _ _ => true
  | .add _ _ | .sub _ _ => false
  | .literal _ | .unicodeMaximum | .byteMaximum | .idMaximum | .field _
  | .ordinal _ | .parens _ | .idMaximumOf _ _ | .hex => true

/-- Bare arithmetic follows Ada precedence and left association, including for
operators whose mathematical extensions happen to be associative. -/
def Number.wellFormed : Number → Bool
  | .literal _ | .unicodeMaximum | .byteMaximum | .idMaximum | .field _
  | .ordinal _ | .hex => true
  | .add left right | .sub left right =>
      left.wellFormed && right.wellFormed && right.term
  | .mul left right | .div left right =>
      left.wellFormed && right.wellFormed && left.term && right.primary
  | .parens value => value.wellFormed
  | .idMaximumOf left right => left.wellFormed && right.wellFormed

def Test.primary : Test → Bool
  | .constant _ | .flag _ | .parens _ => true
  | .negated _ | .both _ _ | .either _ _ | .number _ _ _ | .mode _
  | .phase _ | .phaseIn _ | .itemEquals _ | .itemDifferent _
  | .itemIn _ | .itemNotIn _ => false

def Test.relation : Test → Bool
  | .constant _ | .flag _ | .negated _ | .parens _ | .number _ _ _
  | .mode _ | .phase _ | .phaseIn _ | .itemEquals _ | .itemDifferent _
  | .itemIn _ | .itemNotIn _ => true
  | .both _ _ | .either _ _ => false

def Test.conjunction : Test → Bool
  | .both _ _ => true
  | .either _ _ => false
  | .constant _ | .flag _ | .negated _ | .parens _ | .number _ _ _
  | .mode _ | .phase _ | .phaseIn _ | .itemEquals _ | .itemDifferent _
  | .itemIn _ | .itemNotIn _ => true

def Test.disjunction : Test → Bool
  | .either _ _ => true
  | .both _ _ => false
  | .constant _ | .flag _ | .negated _ | .parens _ | .number _ _ _
  | .mode _ | .phase _ | .phaseIn _ | .itemEquals _ | .itemDifferent _
  | .itemIn _ | .itemNotIn _ => true

def Test.wellFormed : Test → Bool
  | .constant _ | .flag _ | .mode _ | .phase _ | .itemEquals _ | .itemDifferent _ => true
  | .negated value => value.wellFormed && value.primary
  | .both left right =>
      left.wellFormed && right.wellFormed && left.conjunction && right.conjunction
  | .either left right =>
      left.wellFormed && right.wellFormed && left.disjunction && right.disjunction
  | .parens value => value.wellFormed
  | .number _ left right => left.wellFormed && right.wellFormed
  | .phaseIn values => !values.isEmpty
  | .itemIn values | .itemNotIn values => !values.isEmpty

def Action.wellFormed : Action → Bool
  | .number _ value | .decoded value => value.wellFormed
  | .flag _ value => value.wellFormed
  | .mode _ | .phase _ | .otherTheory | .zeroMatched | .liveAll | .spaces
  | .matchByte _ | .endString | .endTheory | .structural => true

/-- Skip is the empty sequence/optional-else sentinel. Case alternatives must
remain inside their matching case construct rather than occur as statements. -/
def Command.statement : Command → Bool
  | .skip | .returnNow | .action _ | .sequence _ _ | .choose _ _ _
  | .switchItem _ | .switchMode _ => true
  | .itemBranch _ _ _ | .modeBranch _ _ _ | .otherwise _ => false

def Command.itemAlternatives : Command → Bool
  | .skip | .itemBranch _ _ _ | .otherwise _ => true
  | .returnNow | .action _ | .sequence _ _ | .choose _ _ _ | .switchItem _
  | .switchMode _ | .modeBranch _ _ _ => false

def Command.modeAlternatives : Command → Bool
  | .skip | .modeBranch _ _ _ | .otherwise _ => true
  | .returnNow | .action _ | .sequence _ _ | .choose _ _ _ | .switchItem _
  | .switchMode _ | .itemBranch _ _ _ => false

def Command.wellFormed : Command → Bool
  | .skip | .returnNow => true
  | .action value => value.wellFormed
  | .sequence first second =>
      first.wellFormed && second.wellFormed && first.statement && second.statement
  | .choose test yes no =>
      test.wellFormed && yes.wellFormed && no.wellFormed && yes.statement && no.statement
  | .switchItem branches => branches.wellFormed && branches.itemAlternatives
  | .switchMode branches => branches.wellFormed && branches.modeAlternatives
  | .itemBranch choices body rest =>
      !choices.isEmpty && body.wellFormed && rest.wellFormed && body.statement && rest.itemAlternatives
  | .modeBranch modes body rest =>
      !modes.isEmpty && body.wellFormed && rest.wellFormed && body.statement && rest.modeAlternatives
  | .otherwise body => body.wellFormed && body.statement

/-- All named current command trees, including the case-alternative trees.
Checking the complete bodies recursively also checks every inline operand. -/
def currentTrees : List Command :=
  [structuralOpenObject, structuralCloseObject, structuralOpenArray,
   structuralOffset, structuralCloseArray, structuralColon, structuralComma,
   structuralQuote, structuralNumber, structuralLiteral, structuralCases,
   structuralCommands, consumeString, consumeEscapes, consumeEscape,
   consumeUnicode, consumeNumberClose, consumeIdDigit, consumeNumber,
   consumeCases, consumeCommands]

theorem checked_precedence : currentTrees.all Command.wellFormed = true ∧
    structuralCommands.wellFormed = true ∧ consumeCommands.wellFormed = true ∧
    structuralCommands.statement = true ∧ consumeCommands.statement = true := by decide +kernel

/-- The reported multiply/add collisions preserve tokens but fail precedence.
The decimal and hexadecimal scanner accumulation trees both remain accepted. -/
theorem accumulation_controls :
    (Number.add (.mul (.field .unicodeValue) (.literal 16)) (.field .digit)).render =
      (Number.mul (.field .unicodeValue) (.add (.literal 16) (.field .digit))).render ∧
    (Number.add (.mul (.field .unicodeValue) (.literal 16)) (.field .digit)).wellFormed = true ∧
    (Number.mul (.field .unicodeValue) (.add (.literal 16) (.field .digit))).wellFormed = false ∧
    (Number.add (.mul (.field .numberValue) (.literal 10)) (.field .digit)).render =
      (Number.mul (.field .numberValue) (.add (.literal 10) (.field .digit))).render ∧
    (Number.add (.mul (.field .numberValue) (.literal 10)) (.field .digit)).wellFormed = true ∧
    (Number.mul (.field .numberValue) (.add (.literal 10) (.field .digit))).wellFormed = false := by decide +kernel

theorem arithmetic_association_controls :
    (Number.sub (.sub (.field .bytes) (.literal 1)) (.literal 2)).render =
      (Number.sub (.field .bytes) (.sub (.literal 1) (.literal 2))).render ∧
    (Number.sub (.sub (.field .bytes) (.literal 1)) (.literal 2)).wellFormed = true ∧
    (Number.sub (.field .bytes) (.sub (.literal 1) (.literal 2))).wellFormed = false ∧
    (Number.div (.div (.field .numberValue) (.literal 10)) (.literal 2)).render =
      (Number.div (.field .numberValue) (.div (.literal 10) (.literal 2))).render ∧
    (Number.div (.div (.field .numberValue) (.literal 10)) (.literal 2)).wellFormed = true ∧
    (Number.div (.field .numberValue) (.div (.literal 10) (.literal 2))).wellFormed = false ∧
    (Number.mul (.parens (.add (.literal 10) (.field .digit))) (.literal 2)).wellFormed = true := by decide +kernel

theorem boolean_controls :
    (Test.negated (.both (.flag .failed) (.flag .inTheory))).render =
      (Test.both (.negated (.flag .failed)) (.flag .inTheory)).render ∧
    (Test.negated (.both (.flag .failed) (.flag .inTheory))).wellFormed = false ∧
    (Test.both (.negated (.flag .failed)) (.flag .inTheory)).wellFormed = true ∧
    (Test.negated (.number .equal (.field .bytes) (.literal 0))).wellFormed = false ∧
    (Test.negated (.parens (.number .equal (.field .bytes) (.literal 0)))).wellFormed = true ∧
    (Test.both (.either (.flag .failed) (.flag .inTheory)) (.flag .numberDigits)).wellFormed = false ∧
    (Test.either (.flag .failed) (.both (.flag .inTheory) (.flag .numberDigits))).wellFormed = false ∧
    (Test.both (.both (.flag .failed) (.flag .inTheory)) (.flag .numberDigits)).wellFormed = true ∧
    (Test.both (.flag .failed) (.both (.flag .inTheory) (.flag .numberDigits))).wellFormed = true ∧
    (Test.either (.either (.flag .failed) (.flag .inTheory)) (.flag .numberDigits)).wellFormed = true ∧
    (Test.either (.flag .failed) (.either (.flag .inTheory) (.flag .numberDigits))).wellFormed = true := by decide +kernel

/-- Recursion reaches action expressions, conditional tests and case bodies;
wrong case-alternative categories are rejected at their surrounding command. -/
theorem command_controls :
    (Command.action (.number .numberValue (.mul (.field .numberValue)
      (.add (.literal 10) (.field .digit))))).wellFormed = false ∧
    (Command.choose (.negated (.both (.flag .failed) (.flag .inTheory))) .returnNow .skip).wellFormed = false ∧
    (Command.switchItem (.itemBranch decimal
      (.action (.flag .failed (.negated (.both (.flag .failed) (.flag .inTheory)))) ) .skip)).wellFormed = false ∧
    (Command.switchItem (.modeBranch [.between] .returnNow .skip)).wellFormed = false ∧
    (Command.switchMode (.itemBranch decimal .returnNow .skip)).wellFormed = false ∧
    (Command.sequence (.otherwise .returnNow) .skip).wellFormed = false := by decide +kernel

end Silver.ImageModel.ScannerNative
