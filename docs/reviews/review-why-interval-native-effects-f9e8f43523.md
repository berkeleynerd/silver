# Retained Why interval native-effects review

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119),
coverage finding [#144](https://github.com/berkeleynerd/silver/issues/144).
**Accept the correction/frontier packet at
`f9e8f43523b394c7855cf1a9f25ac9686cc4d690`; no material findings.**
The additional major-GC and root-scanner/predecessor dispatch obligations are
supported. The packet correctly withdraws the four-only boundary and buffer
condition while preserving the typed/API and classified OCaml-client lemmas.
Complete native coverage, initial configuration and interval preservation
remain open on #119; `R` and exceptional identifier charge remain null.

## Inputs and review record

The exact target is the [research note](../research/retained-why-interval-native-effects.md)
and its complete [15-file evidence packet](../evidence/retained-why-interval-native-effects-20261019/README.md),
based on `fa85a5ea0d`. Inspection covered the argument, checker, five-input
manifest, eight-file source projection, eleven installed-body projections,
both read-coverage records, Zarith source/retrieval records, measured results
and round record. The inherited capture is run
`20261019T000304-fcb988ec2c03`, PID 97103, executable SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
OCaml revision is `8eb41f72ded84df884c3671734c947f612091f84`; Zarith revision
is `667d742948914aa1f80d5ad5abb98bc412335e51`.

I compared the superseded claims in
[save preservation](../research/retained-why-save-preservation.md) and its
[accepted review](review-why-save-preservation-3700c2adc7.md), source
`3700c2adc7` / review `d81d5ec56e`, with this correction. Accepted capture,
typed atom/binder, signal, finalizer, Memprof, destructor and fixed-loaded-code
results are reused at their stated scopes. The accepted #143 repair
`8b686a52e5` / review `7ffaa134f4` remains a separate result.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned by the lead.
Runtime model/effort confirmation, token usage and monetary cost are unavailable.
Inspection ran from **12:31:09 to 12:33:24 UTC**, **135 seconds** at one-second
resolution, excluding report preparation and commit. Actual host: Linux 7.0.14
x86_64. Separate worktree:
`tmp/review-why-interval-native-effects-f9e8f43523`. Only this report is owned
and committed. The live subthread goal was null; owner-resumed authorization
remains in force. CLI memory was not updated. The lead owns integration,
historical-claim notices, issues, board, durable memory and publication.

## Dispatch and configuration argument

`major_gc.c:132,420–430` defines a distinct major hook and dispatches it after
initializing sweeping. The retained machine body loads `0xfaaf60` at
`0x9c4375`, tests the loaded value and tail-calls it at `0x9c4385` when nonnull.
The mark and clean routes reach this body at `0x9c4e91` and `0x9c5361`.
Neither the source guard nor the machine guard is the finalizer-queue guard.
Excluding registered OCaml finalizers therefore does not exclude this native
dispatch. No actual invocation or nonnull unknown owner is inferred.

The minor and major root routes independently load the outer root hook at
`0x9c2bae` and `0x9c2fcf`, both addressing `0xfaac98`. Their nonnull paths
tail-call the hook, supplying `caml_oldify_one` or the preserved `caml_darken`
action. Thread initialization loads the old outer value into `%rdx` at
`0x9b8e80`, installs `caml_thread_scan_roots` at `0x9b8e83`, then saves `%rdx`
to `0xfaaa48` at `0x9b8e94`. The source save-before-install order and installed
store order agree on the captured predecessor dependency.

In the Thread scanner, the current-thread comparison skips the already scanned
stack; it does not return from the scanner. The loop proceeds to the saved
predecessor load at `0x9b83c3`, null test and tail call at `0x9b83d8`.
Consequently one worker does not eliminate this callback edge. Identifying
Thread as the outer hook owner leaves the predecessor configuration and
effects to establish.

These witnesses are sufficient to refute the earlier exhaustive four-cell
description. They do not supply the hooks' values at the interval cut or a
complete setter/effect relation. The packet correctly separates source null
initializers, the Thread ownership transition, interval-start configuration,
later writes and effects of dispatched owners. Seven is explicitly a targeted
projection size. It is never promoted to a complete native-interface count.

## Corrected claim and retained useful results

The earlier opening “isolates ... to four,” exact-interface description and
four-hook-only condition on the 1,074-byte buffer argument are all explicitly
superseded. The arithmetic remains conditional on complete relevant native
noninterference. Private typed Shape/printer/fold facts and the classified
OCaml-client results remain useful within their original premises; native
reentry through an unclassified configured callback is still an obligation.
The #143 shared-base-plus-offset objection concerns setter exclusion for the
original cells. Even repairing that inference cannot remove the additional
dispatch interfaces shown here. This separation is accurate.

The existing faithful collector, allocator, libc and numeric-library contracts
remain applicable. For example, `caml_fl_p_init_merge` selects an internal
free-list implementation under the reviewed allocation-policy interface.
An indirect instruction alone does not require proving that trusted
implementation. Conversely, faithfulness to a configurable application hook
does not imply an empty client set. The packet introduces no blanket
no-callback premise and leaves a complete reached-interface summary open.

The bounded numeric subcase is also correctly stated. The accepted saved-root
atoms are immediate values 0, 1, 32, 126 and 4,096. The retained source chain
ends in Zarith `format "%d"`; `Z_ARG` selects zero or one limb. Width zero,
no prefix and no sign give a 5- or 69-byte native buffer and, for nonzero
values, an 8-byte limb copy. The native shift, size calculation and branch
corroborate these bounds. Nonzero formatting still calls `__gmpn_get_str@plt`
at `0x9aeab5`; at most four decimal digits follows for this finite domain
under the existing numeric/allocation contracts. The note does not extend
this domain to arbitrary inlining operands or exceptional printers, or treat
the installed version string as historical source identity.

## Evidence checks and remaining work

The author's successful **3.5172335079987533-second** projection/read check and
**0.43773691001115367-second** default check are reused. The separate original
four-cell check remains separately recorded. I inspected the byte-overlap
predicate and reconciled the two frozen coverage records: 835,579 core reads
and 49,728 session reads, with the same member identities, supply no overlapping
read of any targeted cell. The streams were not rescanned. Unobserved values
remain unobserved; BSS or mapping metadata does not establish their values at
the cut. Even observing the candidate seven values would leave interface
completeness, history where needed, and interval preservation open.

A separate read-only reconciliation passed in **0.38465000699216034 seconds**:
five inherited file identities; eight OCaml members and 19 exact excerpts;
all 2,218 native projection records and 9,040 bytes including padding against
the pinned executable through ELF load segments; text/JSON correspondence;
seven decoded RIP-relative targets, seven direct branch destinations and four
indirect tail-call encodings; three Zarith file identities; seven target
addresses and retained false/null frontier fields. Byte correspondence and
decoded local edges support the inspected argument without establishing a
universal compiled-source refinement or all-client theorem.

The constructive successor is appropriate: establish the bounded interval's
complete relevant application-callback interface/configuration/effect summary,
including these routes and the original four, using accepted runtime/library
contracts at their actual scopes. Then derive any essential missing initial
observations from that summary. This avoids treating another fixed address
list or an arbitrary seven-cell capture as sufficient. Ordinary ending-save
reentry, other exception continuations and output/exit closure retain their
existing separate obligations.

No native target, capture, disassembler, old checker, graph replay, build,
prover, Lean or corpus run was performed. No production, Oracle, tool, admission
or source pin changed. Report links and staged whitespace were checked; the
target source/evidence files remain unchanged. The correction satisfies #144's
claim-withdrawal scope; full #119 capacity completion is still open.
