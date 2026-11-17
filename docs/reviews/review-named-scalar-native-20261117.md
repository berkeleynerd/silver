# Final focused native review — named scalar arguments #392

Reviewed on 2026-11-17 on Linux aarch64. Selected reviewer setting: GPT-6
Astra, Max, as specified by the lead and project policy. Independent live
model/effort confirmation, total review elapsed time, token use and cost are
unavailable.

## Target and disposition

**No unresolved findings in this native implementation and focused-evidence
slice.** The focused coverage applies to the final native source, and no
input-domain weakening was found. The prior catalogue and bounded Boolean
test-coverage findings now have successful executable validation. A stack-report
precision note was corrected in `90b309460` during review.

Implementation target: `f4ed7cd513047df7c8a24c04b3fd107ee704db1c` in
`tmp/named-arguments-392`, including catalogue repair `eabd7127f` and Boolean
fixture `fa07b1df4`. The final output-profile SHA256 is
`de017ca035a5ffd358d5fa98646d017dfe4ef54bd822fafc40743a9a8ae66f53`;
the catalogue exporter SHA256 is
`2e46a16831e048dd64299a7bb31e554e9e478e7daa1a1eb79922be2bc34ccfab`.
The subsequently retained final behavior and compiled-layout packets were also
reviewed. Paths below are relative to that integration worktree.
Evidence subpaths such as `native/coverage.json` and `stack/README.md` are
under `docs/evidence/named-scalar-arguments-392-20261117/`.

This is the owner-authorized #392 named/reordered/mixed scalar-call scope, under
the same Oracle and capability requirements as the earlier reviews. No code,
artifacts, index, branch or cache was modified. Only this scratch report was
written. I read retained reports and hashes and independently repeated read-only
object disassembly; I ran no compiler, prover or regression jobs.

## Contracts, domains and implementation

- `src/silver_output_profile.adb:4944`: `Mark_Formal` has no precondition. Its
  domain is every 585-slot `Formal_Set` and every existing `Formal_Index`,
  including an already-true selected slot. `Global => null` and the complete
  pointwise postcondition retain every other bit. The sole delta aggregate is
  in this shared expression-function body; models and executable updates use
  the same helper. There is no freshness, name-uniqueness or metadata premise.
- The resolver/association helpers retain arbitrary valid metadata and all
  declared cursor/ordinal states. Lookup uses the existing case-insensitive
  comparison and deterministically selects the first matching formal. The
  association reader accepts a positional prefix followed by a named suffix;
  unknown selectors, duplicate selected slots and positional-after-named forms
  fail through executable checks. Exact ordinal count plus distinct selected
  indices covers every formal without defaults or omissions.
- `Lemma_Function_Actuals_Advance` at `:5157` states the exact successful
  nonfinal recursive branch, with arbitrary named/seen state and the same
  incoming facts. Its guards are the branch's existing successful resolver,
  typed payload, unseen slot and comma conditions. Its null Static body was
  proved before the walker consumed it. `Actuals_After` calls it at `:5233`
  before changing cursor, seen state or named state. No assumption or proof
  suppression replaces the recurrence obligation.
- Existing wrapper input domains and runtime/model-result postconditions are
  preserved. Recursive variants moved to the new tail models because the
  wrappers no longer recurse; termination was not dropped from a recursive
  implementation. `Procedure_Update_Step` adds metadata/slice arguments and
  their validity conditions needed for replay, without narrowing its existing
  formal or incoming-flow domain. Its callers establish the new argument
  conditions in their whole-subprogram checks.
- Function payloads retain the same incoming facts. Procedure admission and
  update replay use the selected formal's mode/type/bounds; every input is
  checked against the original `Scan.Facts`, even after earlier output updates.
  Payload-only alias replay excludes selector labels while retaining every
  actual read. Its own writable-payload exception requires both exact source
  endpoints, so another occurrence of that target is still rejected. Existing
  leaf payload/target contracts remain unchanged and permit the selected-formal
  calls; no new parameter-domain assumption was introduced.

## Focused evidence and applicability

I independently checked every row of `native/coverage.json` against the retained
managed events, exact captured source, native report and report summary. All
**26** scopes have successful original native exits, complete subprogram
selectors, canonical `all/all`, level 2, CVC5/Z3/Alt-Ergo, 30-second policy,
warnings/checks as errors, and no `pragma_assume`, skipped-flow or skipped-proof
entries. Their proof/flow messages select exactly the named helper, all selected
obligations are reported successful, and the totals agree at **506 checks**.
The reports' additional entity entries identify contract dependencies; they
are not additional checked scopes. Every selected declaration/body agrees with
the final source.

Coverage includes all 13 new helpers, seven changed helper/model bodies and
the six affected caller scopes through `Basic_Body`. Applicability is stronger
than the coverage generator's local-text comparison:

- Six earlier resolver/association runs use source
  `672d7209c145f43c6d0eea505dbdf6e892370fea840241dab11aefe0c4bcc7d8`.
  Their implementations, contracts and dependency closure are unchanged by the
  later marker/recurrence/walker edits.
- Four shared-marker/model/lemma runs use source
  `7dd36ab8d8e4d7503464f437c3cbadfca037dc2212aa9a7e45183489a211eeec`.
  Its only subsequently changed subprogram is `Actuals_After`, which none of
  these four calls. Their final-source applicability is preserved.
- The remaining 16 scopes use the exact final `de017ca…` source, including the
  whole function/procedure walkers, payload alias replay, update chain and
  affected callers. The final function walker run is
  `20261117T030726-c84f7e1c4a36`; `Basic_Body` is
  `20261117T032207-69c04762d371`.
- For every covering run, all **133 other recorded `src/` inputs** match the
  integration checkout; only the output-profile and separately reviewed
  catalogue bodies were excluded from that comparison. The unchanged metadata
  packages retain their original domains. Project configuration and canonical
  policy were not changed by #392.

The two catalogue checks also match final source and retained report hashes:
`Export_Constructs`, run `20261117T032921-f38b729850b7`, has one successful flow
dependency check and no proof VCs; public `Export`, run
`20261117T032925-b5754f351131`, has no generated checks. Both complete selected
subprograms are reported `all` in SPARK. Zero generated obligations are not
being represented as additional numerical proofs.

## Compiled storage and final behavior

`Formal_Set` remains a constrained 585-Boolean array. The source adds bounded
return-by-value copying and its complete runtime postcondition; this is not an
in-place storage optimization. Executable walkers are loops, so marker frames
do not accumulate with the number of actuals.

I hash-checked the compiled output-profile object
`7d05960be26c5c8a0ff50773d78ff0c8159abd4049d7c53664e6d8199d0327f5`
and independently reproduced all ten retained symbol disassemblies with the
pinned objdump. `Mark_Formal` has 688-byte and 640-byte fixed outer/wrapped
frames, bounded 585-byte copies, the complete quantified postcondition loop,
and no allocator call in either marker routine. Its three callers receive the
result in bounded local buffers before copying it to their seen set.

The retained walker fixed frames are 400/1376 bytes for `Actuals_After`,
400/1360 for `Procedure_Actuals_After`, and 656/1872 for `Procedure_Updates`.
The last wrapped body also has two count-sized dynamic local stack reservations
and secondary-stack mark/release activity. The review requested that distinction
be explicit; `stack/README.md`, corrected in `90b309460`, now labels the fixed
frames and describes the additional reservations. These observations do not
bound complete call-chain stack use or peak memory, and do not claim improved
performance or allocation behavior.

The final incremental build `20261117T033259-3ca6b2ad891b` includes the exact
final output-profile and catalogue sources. I verified the final retained source,
test and catalogue snapshots and inspected the successful managed logs:

- `20261117T033524-4250165f9b34`: all **16** named methods passed in **35.218 s**,
  including the full-route Boolean return, Boolean in-out and procedure-to-
  procedure fixture. Its independently derived output is `true`, `true`,
  `false`. The many-formal and 4096/4097-byte source cases also passed.
- `20261117T033625-fc16dd2501f6`: executable catalogue/committed JSON parity
  passed. Both test runs identify compiler SHA256
  `c8564820c277d6b5128df7b1eba4e5b69f5c97177242f6854f263c6e8203b860`.

These checks used the established 16 MiB process stack and four reserved workers.
Positive application cases use fresh proof/build workspaces; the compiler build
was incremental and retained caches. The tests establish observed behavior for
their actual inputs, not a universal stack or assurance theorem.

## Remaining assurance boundary

The lead began complete native run `20261117T034048-8c22c1e6a33d` after the
focused applicability result; it was active at this review handoff. No complete
native result is certified here. Final integrated native and Lean/source
assurance, the final source-certificate integration review, complete regression
inventory and delivery consistency remain separate requirements. The existing
trusted external toolchain, restricted Ada-to-Lean interpretation and cache
assumptions remain applicable. This report does not close #392.
