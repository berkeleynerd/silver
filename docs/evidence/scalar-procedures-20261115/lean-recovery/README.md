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
