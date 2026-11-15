# Lean recovery — 2026-11-15

This is focused recovery for authorized #370, not complete source or language
assurance. The isolated implementation snapshot is `32895f4827` on
`recovery/procedures-lean-nativefs-20261115`. Linux aarch64 has 12 available CPUs
and 16,593,584 KiB total RAM. The selected diagnosis role is GPT-6 Astra / Max;
live runtime model/effort and cost are not independently exposed.

## Startup and retained state

The committed Nov 13 failure/source packets are available, but the original
x86_64 proof workspaces and compiled objects are absent on this host. A search
of the main checkout's `.silver` found no `.olean` files. The focused target
imports 104 project modules and does not require `OutputBodyCertificate`.
An authenticated Lean 4.34.1 aarch64 distribution was copied and validated by
`bootstrap_lean.py`; no shared mutable tool or proof-cache symlink is used.

The initial managed attempt on the host-mounted worktree failed before proof
building. Direct `import Lake` exposed errno 24, `Too many open files`, while
Linux RLIMIT_NOFILE was 1,048,576. The retained `filesystem-probe.py/json`
compares identical `Lake.olean` bytes: the mounted filesystem failed after
9,821 simultaneous handles; the native overlay opened 12,000. The same tiny
Lean import fails on the mount and succeeds on the overlay. The exact ceiling
varies with other host handles; no filesystem implementation cause is inferred.

The lead coordinated a new native-filesystem worktree at
`/home/agent/silver-worktrees/procedures-lean-370`. The mounted failed workspace
and evidence remain intact. This is an environment repair, not a proof result.

## Unchanged focused failure and next hypothesis

The unchanged `Silver.FunctionSourceParts.DeclarationLoopFunctionLocals` run
uses one managed Lake worker, automatic 12 Lean threads and `--memory-mb 8192`.
The current 16 GiB host and concurrently reserved native work justify this
reduction. The limit is Lean's periodic per-process threshold, not a hard OS
or total-workload cap. A separate five-second process-group sampler records
summed RSS and host available memory, with source-only SIGINT below 1.5 GiB
available. No such interruption occurred.

All 105 preceding build targets succeeded. The leaf failed after 67 seconds
with `Tactic decide failed` / `(kernel) excessive memory consumption detected`.
The complete build phase took 197.059 seconds; no fresh focused audit ran.
Sampled summed RSS peaked at 8.763 GiB. All built dependencies are preserved;
the failure is not an OOM kill, a successful theorem or complete assurance.
`baseline-target.lean`, `baseline-summary.json`, compressed log and resource
samples retain the unchanged input and observation.

The next narrow hypothesis replaces only the leaf's `decide +kernel` witness
with the existing checked `kernel_exact (Eq.refl (some expectedBody))` helper.
Its theorem, full reviewed token list, duplicate-detecting source extractor and
expected native loop remain unchanged. The kernel must still verify the exact
equality. This candidate is unvalidated until a fresh managed target and audit
pass; no memory limit is raised and no domain or obligation is weakened.

The direct witness also failed with the same kernel memory diagnostic: 30 s
for the leaf, 33.362 s for the build, sampled summed RSS 8.965 GiB. Its source,
log and resources are retained separately. This rules out removing the
`Decidable` construction alone as sufficient on this host; it does not identify
all allocation inside the kernel.

The next focused candidate partitions the 72,709 reviewed tokens into 73
contiguous segments of at most 1,000 tokens, avoiding a dangling `function`
marker at a boundary. Each scanner equality quantifies **every** arbitrary
suffix. Segment 64 contains the two matching declarations (specification and
one ordinary body); all other segments preserve the suffix's complete result
list. The final literal equality reconnects every ordered segment to the entire
reviewed token list, and assembly retains the extractor's singleton test.
No extractor, modeled behavior, source pin, native domain or obligation changes.
The initial segmented candidate remains unvalidated at this recorded boundary.

The initial segmented run failed independently at the target-containing scan
and complete-source concatenation equality, both at the 8 GiB threshold; the
other segment scans emitted no errors. A later assembly tactic also reported
a transparency error in its generated Fin proof. No audit ran. The exact failed
candidate is retained compressed. Its two separate RSS rises/falls do not
support attributing the failure merely to concurrent segment elaboration.

## Expected-text normalization: focused success

An isolated probe removed the whole reviewed source and scanner entirely. Even
then, reducing the expected 909-character loop text to its 171 tokens failed the
2 GiB kernel threshold. This identifies a separate expected-text decoding cost;
the earlier full-source failures alone did not distinguish it from scanning.

The normalized probe first proves that the exact literal's `toList` equals its
complete candidate character list using the existing `String.toList_ofList`
theorem and kernel-checked conversion. It rewrites that fact into the unchanged
`lexLine` alphabet, fuel and lexer calculation, then proves the same 171-token
result with `decide +kernel`. No source bytes or lexical conditions change, and
native candidate construction is not trusted.

Run `20261115T172007-8dc3d8f5e77f` passed on Linux aarch64 with one Lake worker,
automatic 12 Lean threads and a 2,048 MiB per-process threshold. Its fresh audit
covered 105 imported modules / 15,591 declarations, with only `propext`,
`Classical.choice` and `Quot.sound`. Monitor elapsed time was 15.014 s; sampled
largest process RSS was 1,580,176 KiB (1.507 GiB), summed RSS 2,558,000 KiB
(2.439 GiB), and minimum host available memory 13,180,320 KiB. No guard fired.
This is exact expected-token normalization, not the full leaf or full project.
The proof, detailed provenance, log and resources are retained separately.

The next smallest check applies this proved normalization to the original
whole-source theorem before its unchanged decision procedure. It will determine
whether token-source segmentation is necessary. The segmented candidate remains
a retained failure and is not selected for delivery. The independent certificate
core review is separately committed at `dca1f7b48`; it is not evidence that this
function-source recovery or complete source checkpoint has passed.

## Selected two-file repair and complete focused result

Implementation `81e09276c` changes only the leaf proof and adds the directly
required `FunctionLocalsExpectedTokens` helper. The public leaf theorem is
byte-identical to the original statement. The helper proves the exact 909-byte
expected string's complete 171-token result, and the leaf rewrites that fact
before checking the unchanged whole-source scanner with `kernel_exact` and a
direct equality witness. Every one of the 72,709 reviewed source tokens remains
in the scanner input; its complete duplicate-detecting `ordinaryFunctions` and
singleton test are unchanged. No source pin, Ada source, scanner, expected loop
or language/proof domain changes. `final-input-review.json` records identities.

A 2 GiB normalized whole-leaf probe failed, with additional memory used during
`decide` failure reporting; the subsequent direct-witness 4 GiB probe also failed
its threshold. Both are retained as failures. These were smaller diagnostic
allowances, not changes to the selected original 8 GiB recovery allocation.

`20261115T173223-fb4134e2af34` passed the original leaf and helper closure at that
8,192 MiB threshold: **107 imported modules / 15,604 declarations** freshly
audited, with only `propext`, `Classical.choice` and `Quot.sound`. It used one
Lake worker and default 12 Lean threads, retained all applicable semantic
objects, and performed no independent kernel replay. Build was 74.043 s, fresh
audit 1.088 s, managed runner 81.724 s and monitored invocation 85.077 s.
Sampled largest process RSS was 4,860,656 KiB (**4.636 GiB**); summed RSS was
5,987,024 KiB (**5.710 GiB**); available host memory stayed above 10,659,584 KiB
(**10.166 GiB**). The 10 GiB source-process-tree and 1.5 GiB host-headroom guards
did not fire. RSS samples can miss peaks and count shared pages repeatedly.

The committed success packet contains exact proof/source/tool/workspace and
artifact identities, the log, summary and resource observations. This is the
focused source-shape theorem and imported helper/model audit, **not** a complete
authoritative-source, facade or whole-project result.

## Adversarial controls and cleanup

Temporary managed controls check the frozen production bytes. The negative
run rejects a wrong character in the full 909-character candidate with an
explicit kernel declaration type mismatch, and rejects omission of the first
expected token as a false proposition. Neither failure is a memory diagnostic.
The negative run is intentionally failed; it supplies no successful audit.

Positive run `20261115T173725-aa334a489da8` passes five bounded predicates:
the exact expected body is extracted; a duplicate before it is rejected; a
duplicate following it across an append boundary is rejected; dropping its
first token cannot satisfy the expected body; and reversing body order cannot
satisfy it. Its fresh audit covers 91 modules / 10,541 declarations with the same
three foundations, under a 2,048 MiB process threshold. These controls supplement
the complete fixed-source theorem; they do not replace universal semantics.

Both temporary control modules, the initial segmented candidate and the earlier
probe modules are removed from `proof/`. Their exact sources and diagnostics
are retained compressed here. A final cached production-only run after removal
passes the same 107-module / 15,604-declaration audit, with no module rebuilt.
Its `production-cleanup-*` packet records final inputs and removal of stale
control artifacts. This cheap refresh is specifically justified by restoring
the production-only module inventory, not by repeating an expensive success.

## Required integration and host budget

The immediate new-helper consumer is the checked leaf. Its unchanged exported
theorem is assembled by `FunctionSourceCandidate.declarations`, then transported
to certified actual tokens by `FunctionSourceChecks.checked_source`, consumed
through `PredicateSourceChecks`. A full assembler check imports the other
function-source leaves; their previous unbounded-memory successes are not proof
that all fit the reduced host. No other leaf was proactively rewritten.

Recommend one Lake worker with the existing 8 GiB process threshold, default
12 threads and actual RSS/headroom monitoring for the next complete checkpoint,
subject to the independent output-aggregate result and concurrent native budget.
This measured leaf fits; it is not a guarantee for every other module. Keep
dense jobs serialized when their observed combined demand requires it. The
complete native/source/facade/module/axiom/provenance/regression checks and any
required final-source pin refresh remain with the lead. Changing the actual
source/pin correctly invalidates this leaf's corresponding cached result.

Independent review of this repair is assigned to the native-recovery author,
who did not author these Lean changes. The separate certificate-core review
remains at `dca1f7b48`. The live harness goal was read as null at handoff; no new
goal or CLI memory update is claimed. All source, caches and ignored scratch
remain in the owned native worktree. No GitHub writes, push or merge occurred.
