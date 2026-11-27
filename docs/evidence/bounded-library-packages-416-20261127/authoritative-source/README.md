# Authoritative package source checkpoint — 2026-11-27

Run `20261127T215103-4a33f22a63ac` passed all twelve requested targets and a
fresh axiom audit of 137,382 declarations across 463 project modules. All 1,605
captured inputs match the final source worktree. The six differences against
primary are exactly the four new source-check modules and the two source-pin
repair files delivered with this packet. This is focused source assurance;
complete feature semantics and the complete project audit remain separate gates.

The requested targets bind Admission, Bodies, Call, Declarations, Import, Main,
Names, Statement, Support, package spelling and Charge to the authoritative
Output_Profile source, plus the inherited NamesSourceBridge. The new Bodies,
Declarations and Statement modules instantiate their existing complete typed
source requirements. Spelling also includes Silver_Profile.Lowercase's checked
translation; Charge retains its original procedure header and all executable
statements, including both output parameters. Raw imported-call semantics and
the final source/tool endpoint remain explicit composition requirements.

The output body is SHA256
`f91894e7a0f7088abd621313e731b71424fd031783faa5d8b9a2f3a180f699da`.
The initial batch built its eight line-certificate modules and full
OutputBodyCertificate. Those successful objects were retained and revalidated
by Lake throughout subsequent attempts; no new certificate rebuild was needed.

## Whole-file pin review and repair

The previous expected output specification and implementation still represented
#410. Independent re-lexing of all ten expected source shapes found exactly those
two stale pins; the other eight already matched their current Ada. The
specification grows from 724 to 1,048 tokens, adding package/unit dependencies,
Imported_Package, Analysis_Result and application analysis/member entry points.
Its headers, aliases and record are checked by Admission and Import source
requirements. A diagnostic event initially mistyped these counts as 1,531 and
1,903; a later checkpoint corrects them, and the retained comparison JSON gives
the measured counts.

The implementation grows from 81,277 to 101,032 tokens. The old pin exactly
matches the source at `bcc7946aa0`; the token-diff JSON records the 126 changed
spans. Review grouped the changes with their corresponding models/source trees:
qualified Boolean/subtype bindings and lookups; Parser_State's source context
and package identity; strengthened validity; context-aware existing expression,
declaration and runtime-operation calls; and the new package name/type/effect,
call/statement, declaration, completion/unit/Main, import and admission readers.
The related implementations and candidate proofs were already integrated in
#416. This pin update records that source change and does not itself establish
its semantics. Final original-callee/domain composition remains mandatory.

The expected implementation remains an independently stored literal, now in
13 named chunks of at most 8,192 tokens. The adjacent verification record
confirms exact concatenated token order. Every chunk retains the previous
local recursion/heartbeat limits; no global or local budget was increased.
The `CompleteShape` proposition is unchanged. Its large body equality uses the
existing `kernel_exact (Eq.refl Source.outputBodyTokens)` witness helper, which
checks the witness at that exact equality in Lean's kernel. It introduces no
axiom, hash comparison or unchecked evaluation, and does not alias the expected
pin to the generated tokens. All other conjuncts retain their original proofs.

## Attempts and resource use

The seven failed batches remain failed in the retained logs/events. They exposed
the old body pin, literal declaration depth, ineffective inline chunking, public
module visibility, per-declaration option scoping, large-equality elaborator
conversion, and the old specification pin. The final run reused their valid
completed targets and passed the aggregate audit. No failed run is relabelled
successful, and no whole-feature validation is inferred from these targets.

Linux x86_64, Lean 4.34.1, two Lake workers and two threads per process,
16,384 MiB per process, actual CPUs 6–7 within the host's eight-CPU allocation.
The final incremental run took 266.045 seconds; the initial batch included the
expensive fresh source certificate build. A fresh axiom audit was performed;
there was no clean rebuild or independent kernel replay. Selected proof work
category: Astra Max; runtime settings are not independently exposed.
