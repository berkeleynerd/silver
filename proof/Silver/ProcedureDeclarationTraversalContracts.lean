module

public import Silver.ProcedureDeclarationDomains

@[expose] public section
namespace Silver.Compose.ProcedureDeclarationNative

/-- Written successful Parameters_At postcondition, with the native Count
components represented by active-prefix lengths. -/
structure ParametersPost (before after : ParserState) : Prop where
  position : before.position < after.position
  procedures : after.procedures.items.length = before.procedures.items.length
  functions : after.functions = before.functions
  parameters : before.procedures.parameters.length < after.procedures.parameters.length
  firstParameter : after.firstProcedureParameter = before.firstProcedureParameter
  pure : after.pure = before.pure

/-- The executable input-frame wrapper preserves both metadata tables and
the formal cursor while extending only the scalar/Boolean binding counts. -/
structure InputFramePost (before after : ParserState) : Prop where
  position : after.position = before.position
  functions : after.functions = before.functions
  procedures : after.procedures = before.procedures
  firstParameter : after.firstProcedureParameter = before.firstProcedureParameter
  scalars : before.scalarNames.length ≤ after.scalarNames.length
  booleans : before.booleanNames.length ≤ after.booleanNames.length

/-- Prefix and Prefix_Model share this exact written successful postcondition.
No closed-frame, fresh-frame or declaration-history premise is introduced. -/
structure PrefixPost (before after : ParserState) : Prop where
  position : before.position ≤ after.position
  functions : after.functions = before.functions
  procedures : after.procedures = before.procedures
  scalars : before.scalarNames.length ≤ after.scalarNames.length

/-- Full native domains and required runtime result projections for high-level
declaration composition. The complete source contracts remain in the source
checks; completed helper model equalities are derived separately. -/
structure HelperTraversalContracts (calls : Calls) : Prop where
  parameters : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state →
    let result := calls .procedureParameters text state arguments
    StateInput text result ∧ (result.position = 0 ∨ ParametersPost state result)
  inputFrame : ∀ text frame, InputFrameDomain text frame →
    let result := calls .procedureInputFrame text frame
    StateInput text result ∧ (result.position = 0 ∨ InputFramePost frame result)
  prefixModel : ∀ text readFrame frame index declarationCount,
    PrefixModelDomain text readFrame frame index declarationCount →
    let result := calls .procedurePrefixModel text readFrame frame index declarationCount
    StateInput text result ∧ (result.position = 0 ∨ PrefixPost frame result)
  «prefix» : ∀ text frame declarationCount, PrefixDomain text frame declarationCount →
    let result := calls .procedurePrefix text frame declarationCount
    StateInput text result ∧ (result.position = 0 ∨ PrefixPost frame result)

end Silver.Compose.ProcedureDeclarationNative
