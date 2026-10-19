# Retained Why save-outcome review

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**Accept the bounded claims at
`0aa373fb93f9db980a404a9346c1eab88969b4c7`. No material findings.**
For the preserved PID 97103 formula forest, the ordinary SV6 shape-buffer
extent is at most 1,074 bytes. A save-origin bare `Not_found` received by
the specified first-fold `Trans.current` trap takes its already-accounted
cache-miss continuation. These are conditional source lemmas, not complete
save/exit exception closure. `complete_R` and `exceptional_identifier_charge`
remain null; 63,573 is not an established counter endpoint.

## Inputs, settings and evidence

The exact target adds the
[save-outcome note](../research/retained-why-session-save-outcomes.md) and
[eight-file packet](../evidence/retained-why-session-save-outcomes-20261019/README.md).
I inspected the argument, checker, atom certificate, input manifest, source
excerpts, installed-runtime windows, retained result and round record. The
accepted formula/binder and exception/converter arguments remain dependencies;
this review does not rerun their capture, forest or occurrence proofs.
The author freezes accepted inputs at
`040fba6e247e3735f9731a7581ec609b251d4a78`, reviewed in
`5455245a014b4cecb832339601c97e6787eabbb5`.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned by the lead.
Runtime confirmation, token usage and monetary cost are unavailable.
Inspection began **01:44:42 UTC** and reached the completed source/evidence
checkpoint at **01:48:52 UTC**, **250 seconds** at one-second resolution,
excluding report preparation and commit. Actual host: Linux 7.0.14 x86_64.
A separate sparse worktree freezes the target. Only this new report is owned
and committed; the lead owns integration, issue records and publication.
The owner-authorized #119 scope, Oracle and installed-source correspondence
remain unchanged. No CLI memory update is claimed.

The retained author check passed in **0.8903099570015911 seconds**. It checks
the new typed projection and 41 source excerpts, and compares three installed
instruction windows totaling 37 bytes. I reused that successful run.
Independent input/member/excerpt identity checks passed over all five pinned
records, 16 source members and 41 excerpts in **0.9237997050004196 seconds**.
A separate narrow audit of named atom bytes, four delayed-substitution edges,
retained occurrence arithmetic and the 37 installed bytes passed in
**0.10178915700089419 seconds**. No checker, Context, capture, native tool,
disassembler, solver, predecessor or corpus replay was performed.

## Typed coverage and preserved atoms

The extractor starts at the accepted certificate's formula roots and checks
their equality with the union of proposition roots in the five task chains.
Its term constructor tags and record widths match the source definitions
(`term.ml:17–48,93–108,224–254`). OCaml immediate `Ttrue`/`Tfalse` and the
ten block constructors are distinguished correctly. It follows argument and
branch children, binder bodies, trigger lists and every deferred-substitution
value. Identifier and symbol record fields, OCaml string lengths, and the
constant/integer encodings agree with the pinned definitions. Missing required
blocks and malformed layouts fail extraction.

The accepted result covers **66 roots, 1,545 distinct stored terms, 309
identifiers and ten integer-constant objects**. Deduplication supplies atom
coverage only. The opened occurrence and binder bounds retain their separate
accepted multiplicities. I directly checked every recorded identifier's name
bytes and all ten constant payloads against the frozen capture, without
replaying the recursive projection. The maximum original name is 47 bytes;
integer values are exactly 0, 1, 32, 126 and 4,096. The four nonempty delayed
substitution records have covered values:

| Bind-info pointer | Substitution-map pointer | Value term pointer |
| --- | --- | --- |
| 139793603767808 | 139793603768104 | 139793603870752 |
| 139793603782120 | 139793603782416 | 139793603835408 |
| 139793603926944 | 139793603927456 | 139793604036640 |
| 139793603944728 | 139793603945240 | 139793604002336 |

The absence of `Tcase`, patterns, real constants and string constants is a
property of this checked closure. In particular, a case hidden in a saved
substitution is not excluded merely by inspecting outer syntax. This removes
the specific `t_open_branch` pattern-constructor route for these formulas,
not unrelated logical exceptions in other helpers.

Opening and unsafe substitution preserve the relevant atoms. `id_clone`
preserves the original `id_string`; fresh variables use that clone. The
lexically bound unsafe constructors and `t_map_unsafe` preserve constants and
function symbols (`term.ml:635–678,739–781,799–832`). Substitution values are
already in the covered closure. Attribute copying changes attributes/location,
not literal values or symbol names. The result still relies on the accepted
typed graph, valid cached substitutions and noncolliding freshness premises.

## Printer bounds and the pre-guard buffer operation

Each Gshape task starts with an empty identifier printer, alpha map and
counter (`termcode.ml:601–608`). The imported occurrence sums are 1,435,
1,130, 1,170, 1,219 and 1,225 across the five tasks. Every term visit makes
at most one `ident_shape` call, and there are no pattern visits. Thus **1,435
assignment calls per fresh printer** is a sound ceiling even if identifier
lookups spuriously take their miss branches. It is stronger for this purpose
than bounding only distinct identities by `309+966`.

`find_unique` starts with empty indices and a default identity sanitizer
(`ident.ml:225–286`). Its keys are never removed on this route. An assignment
adds at most one key, and a suffix search tests distinct candidate names.
Stored indices describe earlier searches; the advance/retreat logic does not
create an independent accumulating counter. The chosen suffix is bounded by
assignment calls, giving four decimal digits. `decoded` calls `id_unique`
only for the word classification; the quote-repetition case is not selected
for those names. The recorded atoms also contain no `mixfix ` name, so the
decoder's internal missing-bracket `Not_found` branch does not undermine that
classification in this instance. Nonword outputs are original-name substrings;
the decoder's fixed-punctuation reconstruction has a bounded intermediate.
This is not a general theorem about arbitrary decoder inputs or asynchronous
exceptions in every formatting helper.

The alpha counter starts at -1 and is incremented at most the accepted 966
binder times, giving at most three decimal bytes. SV6's integer constant
branch prints only the decimal integer string, at most four bytes here
(`termcode.ml:218–229,400–407`). Its fresh formatter has no user queue or tags;
plain `pp_print_string` followed by `pp_print_flush` adds neither quoting nor
a newline. No real exponent or string-escaping branch is reachable for these
constants. Fixed-library numeric and formatter semantics remain the existing
source/runtime correspondence assumptions.

The 1,024 check alone would be insufficient: it runs **after** appending or
flushing. The largest appended atom is instead bounded by `47+4=51` bytes.
After each successful guard the position is at most 1,023, so an append can
reach at most **1,074** before `ShapeTooLong` stops the proposition. The
four-byte constant flush is bounded in total even if split across output
calls. Gshape copies the resulting bounded contents and clears the position
before the next proposition (`termcode.ml:609–622`).

An old large backing does not make growth dangerous. If growth is required,
the old capacity is below the requested extent; doubling to cover at most
1,074 stays small. The installed windows and `Sys` source establish
`max_string_length = 8*(2^54-1)-1 = 144115188075855863`, not a guessed
host-language limit. Consequently the named maximum-string-length
`Buffer.resize` failure is excluded for this buffer under the stated preserved
input and noninterference conditions. This does not exclude physical failures,
unrelated buffers or representation failures from other origins.

In particular, `buffer.ml:96–127` explicitly describes interfering signal,
thread and finalizer mutations. The packet retains that alias/pending-action
obligation. The atom bound is not a blanket no-callback theorem, and the
accepted absence of nested signal saves does not itself discharge every
independent runtime mutator.

## Partial state and the returning catch

There are at most `5*(62+1)=315` proposition/explanation insertions per save.
Each call increments `Gshape.n` at most once; a partial call does not add an
unbounded retry. The attached forest prevents the all-detached guard from
skipping the next save's reset. `clear_only_shape` resets the dictionary,
reverse map, count and both per-goal shape tables; each task also clears the
buffer position. It does not clear checksums or undo all serialization effects.

The source does not make the three `add_shape` writes transactional.
Partial maps, buffer contents, file backups/output, opened channels, prover
number assignments, `session_dir_for_save` and exit gates can survive an
exception. Direct save writes preserve the charged proof-node links, raw-task
bindings and formulas; this is a scoped source-write result, not a complete
heap-alias theorem. Retry does not refund identifier increments. Every aborted
traversal remains charged as a prefix of the accepted 966-binder envelope.

For the **first application** of the fresh `Trans.fold`, the private Wtask
table is empty throughout backward accumulation (`trans.ml:75–103`). Its only
write is in `rewind`, after `fn task acc` returns. Rewind does not call
`current` or return to the backward walk. Direct save neither accesses this
private table/todo chain nor invokes this fold. Weak clearing cannot add a
cache entry. These facts remain conditional on the explicit nonreentrancy and
runtime-state preservation boundary; later applications of a reused transform
are not silently included.

The accepted installed evidence places the Ephemeron poll at `0x99ff17`
inside the trap established at `0x5aea71–0x5aea7e`, with the find call at
`0x5aea98`, `Not_found` handler at `0x5aeac4` and `None` result at `0x5aead4`.
The poll precedes the empty-bucket test, so an empty cache still admits the
interruption. Reusing this exact evidence avoids inventing a captured dynamic
handler stack.

If a save-origin bare `Not_found` escapes there, the resulting `None` matches
the ordinary empty lookup. No inline `fn` has run during the backward phase;
the continuation enqueues the current task once and rewinds each selected
task once. The 1,145 inlining-registration allowance is therefore not repeated,
and the save's own prefix remains separately charged. This conditional lemma
does not assert that the retained save actually produces `Not_found`; the
withdrawn missing-raw-task witness stays withdrawn. Exceptions from later
`fn` execution are outside this trap. Other constructors, including a wrapped
`TransFailure (_, Not_found)`, are not consumed by this bare catch.

## Precise next obligation and disposition

The next required lemma is a **pending-action and state-preservation join at
the eligible polls**: enumerate the independent runtime/finalizer callbacks
that can execute; establish whether they can alias or reenter the shared shape
buffer, local printer, fold cache/todo or charged session roots; and attach
each remaining escaping constructor to its actual receiving trap and ensuing
identifier work. A callback that raises without mutating a root still needs
its receiving continuation classified. The accepted bare-cache-miss lemma
closes one such continuation, not the complete interrupted handler stack.

Normal ending remains separate: `gnat_main.ml:271–278` saves before reporting
and may see a later forest. It needs a preserved-input or changed-state bound;
the captured 66-root instance and two serial SIGINT-save envelope cannot be
substituted without that join. Captured `at_exit` gates are cleared before
their hooks, so an exception may skip older links and prevent `sys_exit` on
that attempt. A later attempt can reach older links; the terminal `flush_all`
is not itself a once-only hook. Output effects, escaping hook exceptions and
returning outer catches remain required.

These precise open obligations agree with the target's null `R` and null
exceptional charge. No full-current-grammar, arbitrary-session, prior-history,
later-invocation, auxiliary-allocation or whole-pipeline guarantee follows.
No Oracle, production source, tool pin or admission rule changed.
`git diff --cached --check` passed for this report.
