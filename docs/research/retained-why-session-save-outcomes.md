# Retained save outcomes: small shape atoms and a returning cache catch

2026-10-19, Linux x86_64, research
[#119](https://github.com/berkeleynerd/silver/issues/119). This successor to the
accepted [exception prefix](retained-why-session-exception-prefix.md) and
[converter prefix](retained-why-sexplib-converter-prefix.md) closes two bounded
obligations. **For the preserved PID 97103 session formulas, ordinary SV6 shape
generation has a maximum buffer extent of 1,074 bytes. An escaping save
`Not_found` received by the first fold's `Trans.current` catch takes the
already-accounted cache-miss continuation.** Neither result closes the complete
save/exit exception family or the full interrupted handler stack. Complete `R`
remains null.

The [new evidence packet](../evidence/retained-why-session-save-outcomes-20261019/README.md)
contains a typed atom projection from the existing capture, 41 matching source
excerpts and 37 byte-checked installed-runtime limit bytes. It imports the
accepted forest, fully opened binder certificate and
native catch/poll correspondence without replaying their checkers. It introduces
no capture, native execution, disassembly, solver run or corpus scan.

## The shape append limit is proved from its inputs

The limit cannot be inferred from the number 1,024 alone. `Shape.push`
(`termcode.ml:349–351`) calls `Buffer.add_string` before `check`; `const_shape`
(`400–407`) checks only after flushing its formatter. `Buffer.resize`
(`buffer.ml:77–94`) can raise `Failure "Buffer.add: cannot grow buffer"`
before those checks. This is a representation failure, not physical exhaustion.

The new checker starts from all 66 formula roots in the accepted
`binder-certificate.json`, checks their equality with the proposition roots in
its five task chains, and follows typed term children, binder bodies, quantifier
triggers and **every deferred-substitution value**. It checks the field layouts
for names, symbols, constants and their integer representations. It reads the
frozen `session-blocks.jsonl` bytes; an absent needed block fails the extraction.
The earlier same-process complete-read and forest checks establish the input
coverage, and are reused unchanged. A maximum over arbitrary captured strings
would not supply this typed reachability argument.

The result is 1,545 distinct stored terms, 309 distinct identifiers, and ten
integer-constant objects. The longest reachable original name is **47 bytes**.
Every integer component is an immediate signed OCaml integer; their distinct
values are **0, 1, 32, 126 and 4,096**. There are no `Tcase` nodes or patterns,
and no real or string constants in this closure. Deduplication here establishes
atom coverage; occurrence multiplicities remain those of the accepted binder
certificate. Nothing treats 1,545 distinct nodes as the opened work count.

Opening and substituting the formulas preserves these original atom values and
names. `id_clone` keeps `id_string`; term substitution replaces variables with
already covered saved terms and constructs no new literal value. The only new
names relevant to shape output are the local alpha numbers and printer suffixes.
Under the accepted well-formedness, saved-substitution and noncolliding-freshness
premises, the existing **966** binder upper bound covers all fresh variables in
one save, including the explanation traversal. It therefore safely overbounds
the new identities that one fresh shape printer could encounter.

Each `Gshape.t_bound_shape_task` creates its own empty identifier printer and
alpha map (`termcode.ml:601–608`). Its possible identity domain is bounded by
`309 + 966 = 1,275`. For a bound that also covers a spurious `Not_found` turning
an identifier-cache hit into a miss, use the accepted opened term-occurrence
counts: the five goals have 1,435, 1,130, 1,170, 1,219 and 1,225 potential shape
term visits. Each visit calls `ident_shape` at most once, and there are no
pattern visits. Thus any one fresh printer has at most **1,435 name-assignment
calls**, even when every lookup takes its miss branch.

`Ident.find_unique` begins with an empty indices table, inserts at most one new
key per call, and advances a collision suffix through consecutive occupied
candidates. Previously stored indices are bounded by earlier calls; each
rejected candidate occupies a distinct key. The largest chosen suffix is at
most the number of calls, so its counter and `succ` stay small and a decimal
suffix uses at most four bytes. This avoids assuming perfect cache hits for
repeated identifiers. `decoded` calls `id_unique` only when `sn_decode` selected `SNword`;
the quote-repetition branch of `find_unique` is consequently not used for those
names. Nonword decoded atoms are substrings of original names. The internal
`sn_decode` formatted reconstruction uses only fixed punctuation and pieces of
the original string, bounded conservatively by original length plus ten bytes;
it is not an unbounded formatting callback.

The alpha counter starts at -1 and increments only for visited binders, so its
strings use at most three bytes under the conservative 966 bound. SV6 selects
`Common.const_v2`, which prints the decimal integer string. The actual values
need at most four bytes. This uses the fixed library's integer encoding and
decimal-conversion semantics, as the prior source/runtime correspondence does;
it is not a new proof of Zarith/GMP. No exponent expansion occurs on this route.
The absence of real and string constants is a checked property of these roots,
so neither their alternative formatting nor string escaping is silently assumed
to have constant expansion. If those roots change, the checker rejects this
instance-specific certificate.

The fresh constant formatter has no pending user output, tags are disabled, and
`pp_print_string` followed by `pp_print_flush` adds just that string. There are
no breaks, padding, quoting or implicit newline in this integer branch. In
particular, `print_string_def`'s up-to-four-byte character escaping is unreachable
for these constants. The accepted formatter-prefix family is reused for the
output closure; its direct identifier charge remains zero.

Every successful `push`, `pushc` or `const_shape` leaves the shape-buffer position
below 1,024. Before the next append it is therefore at most 1,023. The largest
atom is a name plus a four-byte suffix, at most **51 bytes**, giving
`1,023 + 51 = 1,074`. A constant flush contributes at most four bytes in total,
even if Format splits its output into several substring calls. This also bounds
the intermediate position during the flush. The first append starts after
`Buffer.clear`; a caught `ShapeTooLong` stops that proposition's traversal and
the caller clears the buffer before processing the next one.

An old large backing capacity does not invalidate this argument: it avoids
growth. When growth is needed, the capacity is below the requested small extent,
and doubling reaches it without approaching the string or integer limits.
The installed 64-bit runtime's `Sys.max_string_length` is
`8 * (2^54 - 1) - 1 = 144,115,188,075,855,863`, vastly above 1,074. Thus the
**named max-string-length branch in this shape buffer is unreachable**, under
the stated preservation and noninterference premises. Its exclusion comes from
a concrete bound, not from a healthy-resources assumption.

`Buffer`'s own comments (`96–127`) expressly allow its assertions to fail after
interfering signal/thread/finalizer mutation. The atom bound does not discharge
that different origin. The first interrupted inlining path does not use the
shape buffer; the accepted SIGINT protocol permits at most two serial saves and
no nested save on that worker. Local printers are fresh and not exported. The
remaining runtime-callback/alias-preservation join must still exclude an
independent mutator. This packet does not turn that open join into a new blanket
no-callback premise. Nor does it bound the separate GNAT debug escape buffer,
arbitrary exception-message buffers, filenames, or later normal-ending state.

There is also no `t_open_branch` call on these formula closures because no
`Tcase` occurs. The pattern-constructor exception route left conditional in the
earlier prefix is therefore absent here. This does not exclude unrelated logical
exceptions in other helpers. The previously inspected `t_open_bound` and
`t_open_quant` substitution bodies retain their unsafe-reconstruction meaning;
no blanket assertion about all logical exceptions is added.

## Partial saves preserve the charged roots, not all save state

`save_session` first clears the global shape dictionary and both per-goal shape
tables, selects SV6 and folds the preserved session forest. For each of the five
attached goals, its selected declarations are a subset of the accepted 62
proposition occurrences. There are at most `5 * (62 + 1) = 315` calls that can
add a nonempty proposition/explanation shape. A successful novel insertion
increments `Gshape.n` once; a prefix cannot overflow this counter. A second
serial save clears it before recomputing. This is a bound on this counter,
not on every serializer counter.

The three writes in `Gshape.add_shape` are not transactional. A failure can
leave the string-to-index map changed before the reverse map or `n` is updated;
per-goal shape tables and the global shape buffer can also be partial. They are
not proof-node links, raw-task bindings or logical formulas. The source writes
of this direct save route preserve those already certified roots. On a retry,
`clear_only_shape` resets the shape dictionary and both shape tables before
recomputation; entry to `t_bound_shape_task` clears the shared buffer position.
The all-detached guard remains false for the preserved attached forest, so it
does not skip this reset. Checksums are not cleared by `clear_only_shape`.

No stronger rollback claim follows. File backups and partial output, newly opened
channels, `session_dir_for_save`, prover-number assignments and exit gates can
remain changed. In particular `save` has no encompassing channel-cleanup
`Fun.protect`. Its separate prover IDs are not `Ident.id_register` values.
Retries do not refund identifier increments already charged in an earlier save.
Each unsuccessful binder traversal is a prefix bounded by 966, just as before.

## The named returning catch adds no repeat inlining work

`Trans.fold` creates a private empty `Wtask` table. `accum` walks backward along
the task chain, calling `current`; the **only** write to that table is in
`rewind`, after `fn task acc` returns. `rewind` begins only when backward
accumulation has ended, and never calls `current` or returns to `accum`.
Thus every call to `current` during this first application sees an empty table.
Its local `todo` and predecessor chain are not exposed to save. Direct save
neither accesses this table nor reenters this fold. Weak clearing changes
nothing about an empty table. The same noninterfering-runtime-callback join
applies to this private-state argument.

The accepted native evidence places the Ephemeron poll inside the `Not_found`
trap in `Trans.accum`: trap setup at `0x5aea71–0x5aea7e`, find call at
`0x5aea98`, catch at `0x5aeac4`, and `None` result at `0x5aead4`. The poll
`0x99ff17` precedes the empty-bucket test. This is an eligible interruption even
when there is no cache hit; no new native handler-stack capture is asserted.

If a save-origin **bare `Not_found`** escapes at this eligible point, `current`
returns `None`, exactly as the uninterruptible empty lookup would. No inlining
`fn` work has yet been performed on the backward walk. The continuation adds the
current task to `todo` once and subsequently rewinds each selected task once.
It therefore remains inside the existing **1,145** inlining-registration bound,
with the callback's own prefix charged separately. An exception from the later
`fn` evaluation is outside this `current` trap. This closes that specific
continuation obligation without requiring that `Not_found` actually be produced
by this capture's save; the rejected missing-raw-task witness stays rejected.

The trap does **not** consume `Failure`, `Invalid_argument`, `Assert_failure`,
`BadID`, or `TransFailure (_,Not_found)`. Those propagate beyond this catch.
`Trans.named` wraps an exception rather than resuming this application. A
controller catch can report `InternalFailure` and return to scheduling, but that
is not a continuation inside this same inlining invocation. This result does
not classify every other catch deeper in term/type/library code, or certify the
whole dynamic handler stack.

## Outcome partition and remaining exit join

| Named cause | Receiving route, charge and preserved scope |
| --- | --- |
| Ordinary `ShapeTooLong` | Caught by the per-proposition Gshape handler; next proposition starts with a cleared buffer. The total binder prefix remains at most 966. |
| Shape `Buffer.resize` maximum-length `Failure` | Excluded by the typed 1,074-byte bound under preserved inputs/noninterference; no environmental exclusion is used. |
| Shape-buffer assertion/bounds failure after a reentrant mutation | A distinct alias/pending-action obligation; not erased by the length bound. A primitive input uses the accepted zero-binder exception-printer prefix, but complete production/dispatch closure is still open. |
| Allocation failure or failed file service | Existing sufficient-resource/successful-service premises apply only when this is the demonstrated cause. An exception constructor alone does not establish that cause; finite representation and internal failures remain separate. Partial shape/output state is as above. |
| Save-origin bare `Not_found` at `Trans.current` | Consumed as the already-accounted first-walk cache miss. No extra inline iteration or rollback of the save prefix. |
| Different exception at that trap | Escapes this trap; wrappers/outer catches must be followed. No assertion that it immediately kills the process. |
| `exit` hook exception | Gate is cleared before the hook. It skips the older exit links on this attempt and prevents `sys_exit`; a later exit attempt skips this hook and can reach older links. The exception can unwind into an interrupted catch. |

Normal ending still executes `C.save_session` before reporting messages
(`gnat_main.ml:271–278`). It may operate on a later session forest, so this fixed
instance's 966/1,074/315 bounds are not automatically attached to that later
state. It requires its own input-preservation or changed-state bound. This
packet neither scopes it away as interruption nor claims it is covered by the
two-SIGINT-save bound.

The captured `at_exit` chain is Debug, standard Format flush, then `flush_all`.
`Stdlib.new_exit` clears each once-only gate before invoking the hook; there is
no catch inside `exit`. The uncaught-exception route makes another `do_at_exit`
attempt and suppresses its exception (`printexc.ml:327–360`). These facts bound
each captured hook's actual invocation to once while the chain is preserved;
they do not bound all output, all terminal `flush_all` attempts, or every
returning catch. The accepted empty Debug-statistics list and formatter/converter
families are reused; normal-ending, pending actions, remaining helper-origin
exceptions and their exact receiving continuations remain the next join.

The composed interface remains **`counter_end <= 63,573 + 2R`**, with
**`complete_R: null`** and **`exceptional_identifier_charge: null`**. The
representation and cache-catch lemmas reduce concrete uncertainty; 63,573 is
still not an established endpoint. No prior-history, arbitrary-session,
future-invocation, auxiliary-allocation or whole-pipeline result is claimed.
