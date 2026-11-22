# Independent finite Type_Count review — 2026-11-21

Review target: **2372feb90f**, `Carry native type-count representation through
formal metadata (Refs #410)`. Context: required syntax 40ffcc8a55 and shared
native-domain consumers a67669f23b. Reviewer: `/root/410_shared_source_resume`,
selected inherited GPT-6 Astra Max; live model/effort not independently exposed.
The reviewer did not author the seven files changed by 2372feb90f. This was a
read-only review; local source was imported unchanged for dependency validation.

**Result: no material finding in the bounded finite-range repair.** The added
condition records a native scalar subtype constraint that was already present
in the source and Native.FormalType. It does not impose a declaration-history or
current-type-table-membership condition on raw metadata. Complete feature and
source-endpoint validation remain separate pending work.

## Source and domain correspondence

- `src/silver_array_bindings.ads:15` defines Max_Types as Max_Source_Length / 24;
  Type_Count is Natural range 0 .. Max_Types. Both actual Formal.Type_Id fields
  use that subtype (`silver_function_bindings.ads:23`,
  `silver_procedure_bindings.ads:25`). Lean ArrayBindings.maxTypes is 4096 / 24,
  matching the existing fixed Max_Source_Length.
- Both Native.FormalType definitions already require `typeId <= maxTypes`.
  The repair adds that same condition to the two mathematical ValidFormal
  predicates, retaining the existing positive-name, bounded/nonempty-interval,
  integer-kind and procedure-input-mode conditions.
- There is no new `typeId <= types.length`, table-history, parser-reachability or
  successful-lookup assumption in ValidFormal, ValidMetadata, Native.FormalType,
  Native.MetadataType, formal_test or validMetadata_meaning. A nonzero identity
  within Type_Count remains representable even without a corresponding current
  table entry. Source lookup/history claims remain separate derived facts.

## Constructor and preservation coverage

- Function `parameterStep_valid` and procedure `procedureParameterStep_valid`
  derive the new bound from the unconditional `formalTypeAt_typeId_bound` and
  the already-required ValidTypes capacity bound. Scalar fallback returns zero;
  nominal lookup returns an index bounded by the actual type table. Neither
  constructor theorem gains a premise or drops a rejection guard.
- The procedure constructor retains its existing executable mode rejection:
  nonzero identity must be an Integer input. It derives the finite bound in the
  accepted branch; it does not change the permitted signature or actual domain.
- Generic appendFormal_valid, append_valid and valid_empty preserve the complete
  validity predicate, so retained formals and newly appended signatures carry
  the bound without extra endpoint hypotheses.
- ProcedureMetadataSemantics.formalModel_valid transports the bound when
  converting a procedure formal to the existing function-input representation;
  the type identity is copied unchanged. Its previously existing type-resolution
  premise remains separate and unchanged by this repair.
- In a67669f23b, native_state_record consumes the new validity component to
  derive the already-existing Native.FormalType for both formal pools. The raw
  append-array record theorem takes the native `typeId <= maxTypes` domain and
  lets executable guards reject zero/unresolved IDs or capacity failures. It
  does not replace that domain with a successful-lookup premise.

## Invalid, zero and capacity cases

The two formal_test equivalences retain their original Native.FormalType
premise and Boolean test. The forward direction obtains the added mathematical
bound from that existing native premise; the reverse direction ignores it when
recovering the same native test. Native.MetadataType is unchanged and still
permits typed invalid names, empty intervals, zero identities, zero active
prefixes and full-capacity active prefixes. Thus validMetadata_meaning still
proves both true and false outcomes over the entire native typed domain, rather
than checking only already-valid metadata. Unused fixed-array cells remain
outside the active-prefix interpretation, as before. IDs greater than maxTypes
are outside the actual Formal field subtype, not newly rejected native inputs.

## Evidence and remaining scope

Focused run **20261121T191841-33ce803f0c2d** passed a fresh module/axiom audit of
146 modules and 22,242 declarations with two workers/two threads. Its targets
include both NativeEquations modules, both admitted HeaderValidity modules,
ProcedureMetadataSemantics, FunctionDeclarationHeaderEquations and
FunctionDeclarationStateRecords. Evidence and an immutable cache snapshot are
retained by the function stream under
`tmp/named-array-call-source-410/tmp/resume-20261121-source/`.

The review does not claim a complete project/source/native audit. The metadata
change invalidates affected consumers; the shared BasicLibraries/BodyLibraries
focus is next. The procedure source stream separately retains the full native
PrefixStepDomain: its prepared raw append proof splits the actual type/mode
checks and constructs ValidFormal only in the scalar-zero branch. That pending
procedure proof is outside this review result and must be checked by its owner;
no stronger PrefixStepDomain premise is justified by this repair.

Elapsed review time and token/cost measurements were not captured.
