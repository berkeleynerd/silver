module

public import Silver.ApplicationPackageNamesSourceCandidate
public import Silver.ApplicationPackageNamesMeaning
public import Silver.OutputBodyCertificate
import all Init.Data.Repr

@[expose] public section

/-! Bind the complete package-name helper trees to the certified original
Output_Profile source. Candidate checks establish the typed trees independently;
these kernel comparisons also establish their unique actual-source extraction.
The package-identity rule is separate from Names.Operation_After visibility. -/
namespace Silver.ApplicationPackageNames.SourceChecks
open SourceBridge Native

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

theorem actual_checked : Checked Silver.Source.outputBodyTokens where
  expressions := candidate_checked.expressions
  expressionScopes := candidate_checked.expressionScopes
  bodies := candidate_checked.bodies
  bodyScopes := candidate_checked.bodyScopes
  wordBody := by
    refine Eq.trans ?_ candidate_checked.wordBody
    decide +kernel
  wordSpec := by
    refine Eq.trans ?_ candidate_checked.wordSpec
    decide +kernel
  pragmaBody := by
    refine Eq.trans ?_ candidate_checked.pragmaBody
    decide +kernel
  pragmaSpec := by
    refine Eq.trans ?_ candidate_checked.pragmaSpec
    decide +kernel
  allowedBody := by
    refine Eq.trans ?_ candidate_checked.allowedBody
    decide +kernel
  allowedSpec := by
    refine Eq.trans ?_ candidate_checked.allowedSpec
    decide +kernel
  freshBody := by
    refine Eq.trans ?_ candidate_checked.freshBody
    decide +kernel
  freshSpec := by
    refine Eq.trans ?_ candidate_checked.freshSpec
    decide +kernel
  packageType := by
    refine Eq.trans ?_ candidate_checked.packageType
    decide +kernel
  invalidType := by
    refine Eq.trans ?_ candidate_checked.invalidType
    decide +kernel
  typeBody := by
    refine Eq.trans ?_ candidate_checked.typeBody
    decide +kernel
  typeSpec := by
    refine Eq.trans ?_ candidate_checked.typeSpec
    decide +kernel
  outerBody := by
    refine Eq.trans ?_ candidate_checked.outerBody
    decide +kernel
  outerSpec := by
    refine Eq.trans ?_ candidate_checked.outerSpec
    decide +kernel

structure CheckedSource : Prop where
  implementation : Silver.Source.lex Silver.Source.outputProfileBody = some Silver.Source.outputBodyTokens
  names : Checked Silver.Source.outputBodyTokens

theorem checked_source : CheckedSource :=
  ⟨Silver.Source.outputBodyTokens_correct, actual_checked⟩

/-- The actual selected body has the package-identity meaning for every source
and span, including invalid names rejected by the first guard. -/
theorem checked_allowed_meaning (calls : Calls) (primitives : PrimitiveMeaning calls)
    (text : Source) (name : PackageBindings.NameSpan) :
    Checked Silver.Source.outputBodyTokens ∧
      nameAllowedBody.eval calls.get ({text, name} : Inputs).locals = packageNameAllowed text name :=
  ⟨actual_checked, (allowed_denotation calls text name).trans (allowed_meaning calls primitives text name)⟩

/-- Standard collisions are rejected by the interpreted actual-source tree;
this adds no successful admission or extra native-domain hypothesis. -/
theorem checked_standard_rejection (calls : Calls) (primitives : PrimitiveMeaning calls)
    (text : Source) (name : PackageBindings.NameSpan) (word : String)
    (standard : word ∈ standardPackageNames)
    (homograph : Named.nameIs text name.first name.after (word.toList.map Char.toNat) = true) :
    Checked Silver.Source.outputBodyTokens ∧
      nameAllowedBody.eval calls.get ({text, name} : Inputs).locals = false :=
  ⟨actual_checked, (checked_allowed_meaning calls primitives text name).2.trans
    (packageNameAllowed_standard text name word standard homograph)⟩

end Silver.ApplicationPackageNames.SourceChecks
