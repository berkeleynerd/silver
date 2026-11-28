module

public import Silver.ApplicationPackageSpellingCandidate
public import Silver.OutputBodyCertificate
public import Silver.SourceBridge
import all Init.Data.Repr

@[expose] public section

namespace Silver.ApplicationPackageSpelling.SourceChecks
open Silver.SourceBridge

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

theorem actual_checked : Checked Silver.Source.outputBodyTokens where
  tree := checked_tree
  header := by
    refine Eq.trans ?_ candidate_checked.header
    decide +kernel
  body := by
    refine Eq.trans ?_ candidate_checked.body
    decide +kernel

structure CheckedSource : Prop where
  implementation : Silver.Source.lex Silver.Source.outputProfileBody = some Silver.Source.outputBodyTokens
  helper : Checked Silver.Source.outputBodyTokens
  lowercase : NumericTranslation "lowercase" Silver.Expressions.lowercaseBody

theorem checked_source : CheckedSource :=
  ⟨Silver.Source.outputBodyTokens_correct, actual_checked, Silver.SourceBridge.actual_lowercase⟩

/-- The existing lexical primitive denotes the lowercase operation used by the
comparison tree; its translation is part of checked_source above. -/
theorem lowercase_meaning (context : Silver.Expressions.Context) :
    Silver.Expressions.lowercaseBody.eval context = (Silver.lowercase context.item : Int) :=
  Silver.Expressions.lowercaseBody_denotation context

theorem actual_meaning (calls : PackageBindings.Native.Calls)
    (primitives : PackageBindings.Native.Primitives calls) (equations : PackageBindings.Native.Equations calls)
    (source : PackageBindings.Text) (metadata : PackageBindings.Metadata) (word : PackageBindings.Text) :
    CheckedSource ∧ body.eval calls (inputs source metadata word) = some (sameSpelling source metadata word) :=
  ⟨checked_source, imported_body_meaning calls primitives equations source metadata word⟩

end Silver.ApplicationPackageSpelling.SourceChecks
