# High procedure declaration library review

No material finding or exact stale API mismatch found in the reviewed drafts. This is a bounded read-only review,
not a claim that these two new modules have compiled. Their focused Lean checks and final source bridge remain pending.

Reviewed immutable copies: `ProcedureDeclarationBodyLibrary.lean` and `ProcedureDeclarationOuterLibrary.lean` here.
Exact SHA256 identities, compared dependencies, root/native worktree commits and timing are in `inputs.json`.
Body draft hash `cb3ccae03283a880b1d6e2a18e17c7c2a7eaf2f2cfc5dfa0d4a0e9f83953eaa0`;
outer draft hash `6388f88424eba22604549449270ff75cd9ae6e2e1fbec99fa6b0158ada8064ae`.
Accepted OuterDomains is byte-identical to root2425dc5580. The native low-library working source at b287c84887
includes uncommitted HelperLibraries/ParameterLibraries/PrefixLibraries; this review does not recast them as audited.
Selected reviewer setting: GPT-6 Astra Max from prior parent assignment; live setting not independently exposed.
Token and cost measurements unavailable. No proof run, source mutation, Oracle, GitHub or CLI-memory update for this review.

- Complete domains: `BodyDomain` matches the written Procedure_Body_At precondition in native lines6588–6594,
  including typed records, both state predicates, formal-pool growth, positive/in-range formal cursor,
  item capacity, and positive valid name span. The body theorem at BodyLibrary114 consumes that domain unchanged.
  It does not require a successful outer declaration, a closed/fresh frame, empty arrays, or a successful body.
  Zero-position paths remain covered by BodyImports branch guards and raw body equations.
- Callee preconditions: BodyLibrary128–155 derives the positive formal cursor from the actual successful
  Function_Locals reading, then obtains input-frame and prefix validity/count growth from their exact native
  postcondition projections. Parts at33–79 use ready-state validity and the local-count bound for context/scan
  validity. Metadata passed to the reader comes from the original frame, matching native lines6620–6623.
  The assignment/output-bit generalization at26 is valid because BodyScanInput uses only position, target,
  capacity and facts; it does not inspect those bits.
- Finish at82–112 derives both name-span bounds and the append SignatureType/capacity from the full BodyDomain
  and text bound. Metadata append, equality, hiding and operation-name checks use separately interpreted
  callees at their actual arguments. No accepted-name or append-result oracle is inserted.
- OuterLibrary17–73 starts from the full StateInput. The accepted header branch uses audited OuterDomains
  to construct the fresh frame, then low ParametersPost to obtain every BodyDomain field. Failed capacity,
  naming and cursor branches remain in DeclarationImports; ignoring the writable guard locally only proves
  a stronger body import on a larger already-valid domain, without changing native admission.
- No completed scanner law is assumed: BodyLinks/OuterLinks are direct callee identities. The low
  `source_parameters`, `source_inputFrame` and `source_prefix` APIs are derived from raw helper equations,
  source interpretations and native contract projections. Body reader meanings come from
  `source_reader_equations`, `tail_executable_unique` and `read_unique` (BodyLibrary45–51).
  OuterLibrary72 invokes `interpreted_body` with raw HighEquations and the just-constructed imports.
  The low helper API argument order, domain shapes and traversal field names match the current native files.

Ordinary next validation: compile these complete library targets after the low-library handoff; instantiate their
source equations/contracts in the final actual-source bridge. This is required remaining work, not an additional
approval step or a new finding.
