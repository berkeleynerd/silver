# Selected save private-printer control and preservation

2026-10-20 UTC, research #119 / #153, Linux x86_64. The first
`Hstr.replace` inside `Ident.find_unique`'s Not_found catch **cannot insert or
resize** on the selected route: it updates the original key just successfully
found. The later possibly inserting indices/value replacements are outside
the miss catches. If interrupted before returning, they abandon this printer;
they cannot leave a partial resize that a later proposition reuses.

This discharges the private-printer control residual named in the
[shape-builder allocation packet](retained-why-save-shape-builder-allocation.md),
under the same selected source/native, typed input, callback-owner and global
signal protocol premises. The new [packet](../evidence/retained-why-save-printer-control-20261020/README.md)
also bounds finite table scans and preserves the accepted suffix/candidate
bounds. It does not establish external service progress, physical capacity,
complete save termination or complete-save/pipeline assurance. All prior
packets remain byte-for-byte unchanged.

## Exact selected ownership and catches

`Gshape.t_bound_shape_task` creates one fresh printer with the empty blacklist
and identity sanitizers. Its two tables are created by Hashtbl.Make with size
1997, hence 2048 slots, size zero and positive initial_size. The Make wrapper
selects random=false. The printer type is abstract in ident.mli. The selected
shape code passes it through its local traversal closures; it neither publishes
it nor calls duplicate, forget, clear, reserve on a nonempty blacklist, or a
custom sanitizer. Indices store only integer payloads and values store strings.
Neither table, the alpha/name map nor either temporary formatter stores a
closure that exposes the printer to an exit or pending callback.

A nested save constructs another printer. Although the saves share the Shape
Buffer and global shape dictionaries, they do not share these local tables.
Allocation freshness and typed live-value preservation are the existing native
relation, not inferred from a source variable name. Immutable name bytes and
identifier tags make hash/equality congruent and stable. Hstr hashes/equates
strings; Hid hashes/equates immutable tags. These callbacks cannot write the
printer or run a Why scheduler. Their normal primitive/pending effects retain
the existing native-owner contracts.

The relevant source protected expressions are:

| Site | Protected work | Continuation after Not_found |
| --- | --- | --- |
| `ident_v5` | Only `Mid.find id !h` | Decode, printer access and Mid.add occur in its handler |
| `id_unique` | Only `Hid.find printer.values id` | Sanitizers, find_unique and Hid.replace occur in its handler |
| `find_unique` | Original Hstr.find, fetch, first Hstr.replace, final specname | Use the original name; then execute the final Hstr.replace outside this trap |
| `sn_decode` | String.index_from or operator-classification loop | Select another name classification; no printer mutation |
| `Gshape.do_d` | One Shape.t_shape proposition walk | Catches only ShapeTooLong, then copies/clears the shared Buffer and advances |

An OCaml handler body is outside its own protected trap. Native witnesses
confirm the specific boundaries: first replacement at `0x56d964`, trap removal
at `0x56d980`, final replacement at `0x56d9c6`; Hid.replace is at `0x56de1e` in
the id_unique miss handler. ident_v5 calls decoded at `0x7ea619` in its handler.
No source or native catch inside Hashtbl.replace/resize converts a failure into
a successful return from that operation.

## The existing-key update invariant

Induct over entry to each source operation while a particular printer remains
usable. Its tables have disjoint finite bucket chains, one binding per equality
class, valid stable hash placement, represented integer payloads, and scalar
size equal to the number of bindings. Creation establishes the invariant.
Read-only lookup/decoder failures and completed mutations preserve it. The
possibly interrupted-mutation cases are resolved below; abandonment is not
assumed for every private mutation.

To reach the first replacement, the original `Hstr.find indices name` must
have returned normally with an index. Thus the original key is present. Fetch
performs only candidate construction, decoder/formatter work and Hstr.mem;
it has no table mutation. A returning preemption callback does not mutate this
table; a nested save has a different table and cannot return normally to an
interrupted source operation. If an escaping Not_found is consumed before the
first replacement, control skips that replacement. Consequently every reached
first replacement still has its original key present, regardless of candidate
collisions or decoder classification changes.

The selected functorial `replace_bucket` found arm stores an equal key and the
new integer payload and returns false. The outer replace returns immediately
on false. The native branch at `0x983094` jumps to the return at `0x983130`,
bypassing bucket allocation, head publication, size increment and resize.
Its only table stores are the existing slot's key/data (`0x982fe1`,
`0x982ff2`). Neither store changes `next`, a bucket head, capacity or scalar
size. A prefix interruption therefore leaves the same keys, hash placement and
chains and either the old or new bounded integer payload. This remains true
even if a service boundary interrupts between these two stores; the argument
does not depend on treating their pair as atomic.

If this interruption delivers Not_found, find_unique consumes it and performs
its final original-name replacement with zero. That key is still present.
If the later specname call is interrupted after the first update, its Not_found
fallback likewise retains valid structure and resets the original key to zero.
No rollback of the intermediate integer is assumed. An exception of another
constructor is not consumed by this catch.

Thus the first replacement's missing-key/resize branch is excluded by a
noncircular induction. The fact that first replacements cannot corrupt
structure is proved directly from their mutation shape; potentially inserting
replacements are handled by a separate escape argument.

## Why a failed inserting replacement cannot retain its owner

The final Hstr.replace and Hid.replace can insert and resize. They are outside
all three printer/map miss catches above. An exception from them skips the
remaining find_unique/id_unique/ident_v5 handler code. The only enclosing catch
that could continue using this same printer is do_d's ShapeTooLong catch.
That constructor cannot arrive from an active printer mutation on this route.

This is a constructor-origin argument, not an assumption that allocation or
I/O cannot fail. The source archive contains exactly four ShapeTooLong
references: its private declaration (`termcode.ml:342`), the sole raise in
Shape.check (`347`), the legacy shape wrapper catch (`539`), and do_d's catch
(`618`). Termcode's interface exports neither Shape nor this exception.
Every selected SV6 call of check is dynamically inside the current do_d
protected walk. Other shape entry points also install the displayed legacy
catch. Ordinary ShapeTooLong therefore reaches its nearest shape catch, with
all previously returned printer operations completed; it is never produced
inside Hashtbl's code, hashing/equality, identifier decoding, or scalar Format.

The fixed-source typed/no-reflection and native-owner relation is essential
here. Ordinary primitive failures can throw their specified constructors,
including Not_found, Exit, Out_of_memory, Stack_overflow, Failure or
Invalid_argument; none manufactures this private exception identity. This
does not declare that the previously listed primitive family exhausts every
tool exception. Other tool constructors simply do not match do_d's catch.
No additional callback or native entry with access to the private constructor
is introduced under the accepted initialization/preservation contract.

The accepted pending-client and five-process exit attachment supplies the
remaining dynamic closure: collector/custom/native owners and the one-worker
SIGVTALRM preemption route have no Shape.check entry; the application signal
client is GNAT's save-and-exit handler; and the preserved exit hooks are Debug
with an empty statistics-callback list, standard Format flush, and flush_all.
These output owners cannot manufacture ShapeTooLong or recover this printer.
The signal save performs its own selected shape walks under its own nearest
do_d catches. SIGINT is blocked while that handler runs, so no second nested
signal save can introduce an uncovered inner shape raise. Exit/output failures
can escape, but their selected owners do not produce ShapeTooLong. This joins
the existing callback/exit effect contract; it does not replace the unfinished
cost or failed-service arguments for those owners.

If a pending action replaces an already raised exception, faithful runtime
semantics propagates the callback's actual result through the existing trap
chain; it does not queue the private shape exception for delivery in a later
table operation. A signal-save callback either terminates or raises, never
returns normally to the interrupted mutation. Thus a failed potentially
resizing replacement unwinds out of this printer's traversal. A higher save,
controller or scheduler catch can continue the application, but cannot resume
the discarded local do_d/printer owner. This is the specific abandonment
proof; it is not imported from the statistics table's different catch shape.

Successful replacements finish their in-place resize before the next printer
operation. A later ordinary check can raise ShapeTooLong and continue with
the next proposition, but its reused tables are already structurally valid.
The induction now closes: no surviving printer contains an interrupted
insertion/resize prefix. An abandoned table may remain temporarily reachable
from suspended runtime roots; that is storage ownership, not an available
continuation that can traverse or mutate it again.

## Finite scans, rehash prefixes and candidate search

At most P id_unique/find_unique entries occur per printer, using the accepted
per-task full shape-walk count. Only the final indices replacement can add a
key, so each indices table has at most P bindings; Hid has at most P as well.
The previous 2P indices allowance remains a safe overbound. A spurious lookup
Not_found can change the chosen name or overwrite an existing value but does
not add another source insertion site. No uniqueness/meaning-of-shape claim
is necessary for structural finiteness.

Each find/mem/replace-bucket scan visits at most P cells. A reached resize
starts with disjoint valid old buckets. Doubling a power-of-two capacity
splits each old bucket into two new indices, and different old buckets cannot
share either new index. insert_bucket saves the current cell's original next
before relinking a previously visited tail. Every such link points forward
in that old bucket's input order. Unvisited cells' next fields are unchanged.
Thus the redistribution traversal consumes each original cell at most once,
including any prefix abandoned before final tail cleanup. Completed cleanup
removes cross-class suffix links and returns disjoint valid new buckets.
This is only a first/from-valid resize argument; it is not applied to an
arbitrarily reused malformed table. No printer operation sets the traversal
flag or requests copy mode.

| Case | P; each table's binding/scan bound | Capacity bound | Resize calls per table |
| --- | ---: | ---: | ---: |
| Put_Line | 5979 | 4096 | 1 |
| Put | 5531 | 4096 | 1 |
| First_Or_Default | 3352 | 2048 | 0 |
| Is_Message | 1276 | 2048 | 0 |
| Input_Is_Valid | 1435 | 2048 | 0 |

The per-table resize count includes a final abandoned attempt: it cannot be
retried on a surviving owner. Native find_rec, replace_bucket and candidate
advance/retreat are tail/backedge loops; the finite scan bound does not create
a new callback nesting depth. The parallel stack packet owns their exact
frames and native/runtime bridges.

Retain the accepted `Q=P(P+1)` suffix bound and
`S=P*(Q+2P+4)` specname-call bound. At call k, at most k-1 keys have been added
to indices, which is stronger than the previous 2(k-1) allowance. A successful
original-key read obtains a stored nonnegative index bounded by Q's preceding
recurrence. Increasing indices yield distinct candidate names: decimal and
quote suffixes are each injective and the two suffix families are disjoint.
An interrupted decoder can change families, but cannot make different indices
reuse the same occupied key. Therefore advance encounters at most 2(k-1)
occupied candidates before a hole; retreat strictly decreases its positive
index. A caught Not_found skips the rest of the protected computation and
selects the original name; it does not restart fetch. Partial first updates
are bounded and may be zeroed, so the original recurrence still applies.
All previously checked suffix/successor and individual-string guards survive.

As a loose cumulative structural traversal allowance per printer,
`5P+S` bounds table-client entries (Hid.find, Hstr.find/mem, and the three
replacement sites), and `P*(8P+S)` bounds their bucket visits plus redistribution
prefixes, even charging a P-cell resize at every replacement. These are tool
steps, not a bound on wall-clock time or the internals of hash, allocation,
pending, I/O or collector services. The old allocation result stays valid;
this packet does not silently replace its larger table/candidate charges.

## One interval budget and limits

There remain at most three save entries over the whole interval, at most two
escaping signal-save exceptions, and at most one simultaneously active signal
save below an ordinary save. A nested save has separate printers and is already
one of those three entries. When an outer miss/decoder catch consumes a
callback-origin exception, that same exception is no longer available to a
higher catch. The next printer/root/proposition does not restore the budget.
Ordinary lookup misses and decoder sentinels are separately bounded source
events; they do not spend a signal exception. The packet checks the two-use
ledger and rejects a third consumption.

Without the named external premises, the usable export is null. Supplying
them enables the selected no-first-resize, reusable-table preservation and
finite tool-traversal result. Unknown or changed callback/exit configuration,
arbitrary custom sanitizers, nonempty blacklists, table escape/forget operations,
or an unclassified native OCaml entry are outside this theorem. This is not
an extra guarantee for every possible identifier-printer client.

Source argument and native trap/arm selection remain inspected reasoning,
not machine-proved OCaml semantics. The checker binds the imported result
identities, 18 exact source ranges, all four exception references and selected
native byte/control facts; it does not prove the semantic induction merely
by hashing files. No new native target, disassembly, capture, proof/solver,
source fetch or predecessor-checker execution occurred. Physical resources,
service progress and complete save/pipeline flags remain false.

Selected author setting: GPT-6 Astra / Extra High, explicitly assigned by the
parent. Runtime confirmation and individual token/cost measurements are
unavailable. Base `795b52bebde77d2d35533d5ff94c0894ab836afa`; parent owns review,
integration, issues and durable memory. CLI memory was not updated.
The focused check passed five cases, 18 source excerpts, four constructor
references, 21 native bodies / 6,528 bytes and 11 inspected native control facts
in 0.412580 seconds. No duplicate successful validation was run.
