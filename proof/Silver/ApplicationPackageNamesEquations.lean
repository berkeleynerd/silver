module

public import Silver.ApplicationPackageNamesBodies

@[expose] public section

namespace Silver.ApplicationPackageNames.Native
open Compose ApplicationNative

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

/-- These equations expose every primitive call. They are not assumptions about
an admitted parser result or a whole helper's source-independent meaning. -/
def wordEquation (calls : Calls) (text : Source) (position : Nat) (word : String) : Nat :=
  let first := calls.skip text position
  let after := calls.nameAfter text first
  if decide (first ≠ 0) && decide (after > first) && calls.nameIs text first after word then after else 0

def pragmaEquation (calls : Calls) (text : Source) (position : Nat) : Nat :=
  calls.takeToken text
    (calls.takeToken text
      (calls.takeToken text
        (calls.takeToken text
          (calls.takeToken text (calls.takeToken text position (.word "pragma")) (.word "spark_mode"))
          (.symbol "(")) (.word "on")) (.symbol ")")) (.symbol ";")

def allowedEquation (calls : Calls) (text : Source) (name : PackageBindings.NameSpan) : Bool :=
  calls.validName text name && !calls.forbidden text name.first name.after &&
    !calls.nameIs text name.first name.after "main" &&
    !calls.nameIs text name.first name.after "ada" &&
    !calls.nameIs text name.first name.after "interfaces" &&
    !calls.nameIs text name.first name.after "system" &&
    !calls.nameIs text name.first name.after "gnat" &&
    !calls.nameIs text name.first name.after "silver_arguments" &&
    !calls.nameIs text name.first name.after "silver_output_libc" &&
    !calls.nameIs text name.first name.after "silver_runtime" &&
    !calls.nameIs text name.first name.after "integer" &&
    !calls.nameIs text name.first name.after "boolean" &&
    !calls.nameIs text name.first name.after "character"

def freshEquation (calls : Calls) (text : Source) (info : PackageBindings.Metadata)
    (name : PackageBindings.NameSpan) : Bool :=
  calls.validName text name && !calls.forbidden text name.first name.after &&
    !calls.sameName text name ⟨info.nameFirst,info.nameAfter⟩ &&
    decide (calls.lookupExport text info name = 0) && decide (calls.lookupState text info name = 0) &&
    (List.range info.routines.length).all (fun index => !calls.sameName text name (info.routineAt (index+1)).specName)

def typeEquation (calls : Calls) (text : Source) (frame : ParserState)
    (info : PackageBindings.Metadata) (position : Nat) : PackageTypeResult :=
  let first := calls.skip text position
  let last := calls.nameAfter text first
  let value := calls.functionType text frame position
  let exportId := calls.lookupExport text info ⟨first,last⟩
  if !calls.validName text ⟨first,last⟩ || decide (value.after ≠ last) then {}
  else if value.kind = .boolean then ⟨⟨first,last⟩,last,value.kind,.full,0⟩
  else if calls.nameIs text first last "integer" then ⟨⟨first,last⟩,last,value.kind,value.bounds,1⟩
  else if exportId ≠ 0 ∧ (info.exportAt exportId).kind = .integerSubtype then
    ⟨⟨first,last⟩,last,value.kind,value.bounds,exportId+1⟩
  else {}

theorem word_denotation (calls : Calls) (text : Source) (position : Nat) (word : String) :
    packageWordBody.eval calls.get ({text,position,word} : Inputs).locals = wordEquation calls text position word := by
  simp [packageWordBody, constant, Body.eval, Declaration.eval, Command.eval, packageWordResult,
    conjunction, apply2, apply4, Expr.eval, Calls.get, Inputs.locals, Locals.set,
    Native.text, Native.position, Native.first, Native.after, wordEquation]

theorem pragma_denotation (calls : Calls) (text : Source) (position : Nat) :
    sparkPragmaBody.eval calls.get ({text,position} : Inputs).locals = pragmaEquation calls text position := by
  rfl

theorem allowed_denotation (calls : Calls) (text : Source) (name : PackageBindings.NameSpan) :
    nameAllowedBody.eval calls.get ({text,name} : Inputs).locals = allowedEquation calls text name := by
  rfl

theorem fresh_denotation (calls : Calls) (text : Source) (info : PackageBindings.Metadata)
    (name : PackageBindings.NameSpan) :
    nameFreshBody.eval calls.get ({text,info,name} : Inputs).locals = freshEquation calls text info name := by
  simp [nameFreshBody, conjunction, apply2, apply3, Expr.eval, Calls.get, Inputs.locals, Locals.set,
    Native.text, Native.info, Native.name, Field.get, Index.get, freshEquation, Nat.add_comm]

theorem outer_denotation (calls : Calls) (info : PackageBindings.Metadata) (name : PackageBindings.NameSpan) :
    outerDeclarationBody.eval calls.get ({info,name} : Inputs).locals = outerDeclaration info name := by
  simp [outerDeclarationBody, Expr.eval, Inputs.locals, Locals.set,
    Native.info, Native.name, Field.get, Index.get, outerDeclaration, Nat.add_comm, Bool.beq_eq_decide_eq]

theorem type_denotation (calls : Calls) (text : Source) (frame : ParserState)
    (info : PackageBindings.Metadata) (position : Nat) :
    packageTypeBody.eval calls.get ({text,frame,info,position} : Inputs).locals = typeEquation calls text frame info position := by
  simp [packageTypeBody, constant, Body.eval, Declaration.eval, Command.eval,
    typeRejected, typeBoolean, typeInteger, typeExport, typeResult,
    apply2, apply3, apply4, Expr.eval, Calls.get, Inputs.locals, Locals.set, Field.get, Index.get,
    Native.text, Native.frame, Native.info, Native.position, Native.first, Native.last,
    Native.value, Native.exportId, typeEquation]

def modelCalls : Calls where
  skip := skipAt
  nameAfter := Compose.nameAfter
  takeToken := tokenAfter
  nameIs text first after word := Named.nameIs text first after (word.toList.map Char.toNat)
  forbidden := Named.forbiddenName
  validName text name := PackageBindings.validName (metadataText text) name
  sameName text left right := PackageBindings.sameName (metadataText text) left right
  lookupExport text info name := PackageBindings.lookupExport (metadataText text) info name
  lookupState text info name := PackageBindings.lookupState (metadataText text) info name
  functionType := functionTypeAt

theorem model_word (text : Source) (position : Nat) (word : String) :
    wordEquation modelCalls text position word = packageWord text position word := by
  unfold wordEquation modelCalls packageWord
  by_cases first : skipAt text position = 0
  · simp [first]
  · by_cases advanced : skipAt text position < Compose.nameAfter text (skipAt text position)
    · simp [first, advanced]
    · simp [first, advanced]

theorem model_pragma (text : Source) (position : Nat) :
    pragmaEquation modelCalls text position = sparkPragmaAfter text position := rfl

theorem model_allowed (text : Source) (name : PackageBindings.NameSpan) :
    allowedEquation modelCalls text name = packageNameAllowed text name := rfl

theorem model_fresh (text : Source) (info : PackageBindings.Metadata) (name : PackageBindings.NameSpan) :
    freshEquation modelCalls text info name = packageNameFresh text info name := rfl

theorem model_type (text : Source) (frame : ParserState) (info : PackageBindings.Metadata) (position : Nat) :
    typeEquation modelCalls text frame info position = packageTypeAt text frame info position := rfl

end Silver.ApplicationPackageNames.Native
