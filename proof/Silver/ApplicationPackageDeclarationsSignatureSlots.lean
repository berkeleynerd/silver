module

public import Silver.ApplicationPackageDeclarationsSignatureFinish

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.SignatureNative
open Compose

def StartSlot (completing : Bool) : SignatureStart → Prop
  | .returned _ => True
  | .ready state | .loop state => RoutineSlot completing state

def StepSlot (completing : Bool) : SignatureStep → Prop
  | .returned _ => True
  | .ready state | .next state => RoutineSlot completing state

theorem start_slot (calls : SignatureCalls) (source : Source) (outer : ParserState)
    (info : PackageBindings.Metadata) (completing : Bool) :
    StartSlot completing (signatureStart calls source outer info completing) := by
  cases completing <;> unfold signatureStart startSignatureBody <;>
    simp only [Bool.false_eq_true, ↓reduceIte] <;>
    repeat' first | trivial | (intro h; cases h) | split

private theorem finishFormal_slot (calls : SignatureCalls) (source : Source) (completing : Bool)
    (before : Nat) (state : SignatureState) (slot : RoutineSlot completing state) :
    StepSlot completing (finishFormal calls source before state) := by
  dsimp only [finishFormal]
  split <;> first | exact slot | (split <;> first | trivial | exact slot)

private theorem storeFormal_slot (calls : SignatureCalls) (source : Source) (completing : Bool)
    (before : Nat) (state : SignatureState) (first last index mode mark) (slot : RoutineSlot completing state) :
    StepSlot completing (storeFormal calls source completing before state first last index mode mark) := by
  cases completing <;> unfold storeFormal <;>
    simp only [Bool.false_eq_true, Bool.true_and, Bool.false_and, ↓reduceIte] <;>
    repeat' first | apply finishFormal_slot | exact slot | trivial | split

theorem iteration_slot (calls : SignatureCalls) (source : Source) (completing : Bool) (state : SignatureState)
    (slot : RoutineSlot completing state) : StepSlot completing (signatureStep calls source completing state) := by
  dsimp only [signatureStep, readFormalName, readFormalType]
  repeat' first | apply storeFormal_slot | exact slot | trivial | split

end Silver.ApplicationPackageDeclarations.SignatureNative
