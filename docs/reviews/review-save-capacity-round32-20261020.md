# Review: selected save capacity, Round 32

2026-10-20 UTC, Linux x86_64, owner-authorized research #119 / #153.

Accepted at the stated source/runtime and normal-service scope after the
clarifications below. The five retained continuations have selectable-path
bound R=116,162, usable U inputs, selected Format-core bounds and attempted
concat construction bounds under the named premises. No remaining finding
blocks those scoped results. Complete formatter/save capacity and #119 remain
unfinished.

## Exact inputs and governing scope

The isolated review worktree started at
`5108d43221cf3e16fdc02abd890af0f4c535efa3`, after published base
`2866d4642c43444abd18e0b6e9600edaa216b99b`, and fast-forwarded to final input
`5a45438c03ce20ca9c8731245e03bd9cea5d4e7a`. The semantic aggregate is
`e7f203e3bde292c2cd345b966bd3c3600385090c`; the final commit adds its input
reconciliation packet. The Round 31 worktree/report is preserved. Only this
new report is reviewer-authored.

| Component | Author origin | Integration input |
| --- | --- | --- |
| Restored-path construction | Lead-authored | `5108d43221cf3e16fdc02abd890af0f4c535efa3` |
| Initial selectable path state | `9cd8ab6810f59b603da443a69b632304ae1e86fa` | `7df9abf0b43d044285acb8f6371045ce7c36896a` |
| Later library origins and writer closure | `61c325ab2b8434836ff24014bbe51e6b40beda21` | `f114d4fad3643e6c1bcc6f8388d19581f1eca875` |
| Path/input composition | Lead-authored | `e7f203e3bde292c2cd345b966bd3c3600385090c` |
| Author/native-pin reconciliation | Lead-authored | `5a45438c03ce20ca9c8731245e03bd9cea5d4e7a` |

Inputs are the four research notes `retained-why-path-construction.md`,
`retained-why-path-initial-state.md`, `retained-why-path-library-origins.md`
and `retained-why-save-path-input-join.md`, their three corresponding component
evidence directories, and `docs/evidence/retained-why-save-round32-20261020/`.
They include source ranges, retained instruction/literal witnesses, input
identities/censuses, transfer and checker code, and exported results. Accepted
Round 31 path-payload, serializer/occurrence and global save-budget results
remain dependencies at
their recorded scope; their successful checkers were not replayed.

AGENTS.md and the applicable Oracle/review rules govern this bounded task.
The source revisions remain Why3 `9390baf120ef260547dfa14f08e11c890b203d9c`
and OCaml `8eb41f72ded84df884c3671734c947f612091f84`; installed executable
SHA-256 is `7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
The named source/native behavior relation is an external premise, not a
whole-binary refinement theorem. Native frame/pending behavior cannot stand
in for complete resource bounds.

The child harness returned no live goal. The parent supplies the active,
unfinished full #119 objective and retains integration, issue/memory and
publication ownership. No new goal was created by this reviewer.

## Finite input and attempted construction

The argument starts from a finite immutable nonempty list whose dot-joined
length is `J=sum(a_i)+m-1<=R`. It does not infer an attempted length from a
successfully returned string. Nonnegative lengths give `m<=R+1`; the one-byte
separator is essential, especially for a list of empty components. The selected
native separator literal is checked as the one-byte dot, including its object
header and padding.

Every nonfinal `sum_lengths` update is a prefix of J. Its internal addition
`length(hd)+1` and its addition to the previous accumulator are both at most
J; the final unchecked addition is also at most J. At
`R<=2^57-9`, all these tagged-integer values fit and the monotonicity guard
cannot reject. The string allocator's installed limit is exactly that bound.
Its requested block is `8*(1+floor((J+8)/8))` bytes including the header,
with represented word count and padding/index arithmetic. J=0 still requests
16 bytes. This is one requested string object, including a failed allocation
attempt; internal allocator retries and metadata are not charged as caller
objects by this result.

The copy induction preserves offsets from zero through J. Each component's
source range is its complete string, and each separator copy is the one-byte
dot. Every destination interval fits the allocated object. It makes at most
`2*m-1` memmove calls and copies J bytes on completion; any interrupted prefix
does no more. There is no intermediate concatenation string/list, and the
bytes-to-string identity returns the same object. Immutability and rooted
input preservation, supplied by the selected source/runtime premise, are
needed to relate the sum and copy passes.

## Native continuation and private destination

The selected `save_ident` body calls `String.concat` directly at `0x7fb6af`;
the concat body calls the sum pass, byte allocator and copy pass in that order.
The sum backedge at `0x951bd1` targets `0x951b44` after the stack prologue;
the copy backedge at `0x951cf9` targets `0x951be4` after its prologue. Thus
direct loop stack growth per component is zero. GC return jumps at
`0x951bdb` and `0x951d03` target `0x951b4d` and `0x951bf0`, respectively,
past the poll for the current component. A normally returned GC/pending call
does not repeat that poll before processing the component. This bounds direct
loop polls; it does not bound GC, callback, trampoline or libc stack/work.

`caml_blit_string` decodes offsets/length, calls memmove and returns without
an OCaml allocation or poll. The selected save/concat/loop bodies have no
handler that restarts an interrupted copy. The destination remains local
until return. A signal-origin Not_found unwinds to the `save_ident` handler
at `0x7fb6c0`; it loads the original identifier name and proceeds to printing.
It neither recovers the partial destination nor starts another concat. Other
exceptions unwind the save. Nested saves have separate destinations. These
are source/private-owner facts under faithful runtime effects, not a claim
that arbitrary unchecked native mutation cannot find the object.

The accepted N identifier occurrences and single `r<=3` save budget therefore
give at most `r*N` concat attempts, including a failing last prefix. Multiplying
the per-attempt object, traversal, copy and memmove bounds is valid without
assuming every lookup/allocation/save succeeds. An empty restored list or a
missing lookup reduces attempts. The budget is not restarted at ordinary
ending. Complete restore-table traversal/cycle capacity remains separate from
construction after a finite list is returned.

The interface rejects unknown premises and invalid numeric input, and withholds
actual construction bounds when a premise is missing. All complete allocator,
pending-callback, restore-table, save and pipeline flags remain false even when
the conditional construction premises are supplied.

## Initial selectable paths and suspended mutations

The new initial-state note and complete packet attach the source argument to
PIDs 17310, 17514, 17631, 17704 and 17869. The first four stop at
`Gnat_checks.iter` entry before scheduling. The fifth stops at the
`Driver.apply` closure for `inline_trivial`, after
`counterexamples_dependent_intros`. Their own argv, environment, image
identities, load biases, observed PCs and exit roots are checked; matching
configuration alone would not prove callback ownership or initialization.

The source-prefix capability and native-initialization arguments apply to
these inputs. The review does not transplant the earlier PID 97103 numeric,
representation-domain or first-fold native theorem. The private Theory
tables expose no old bucket/array continuation. Their hash/equality functions
read integer tags; resize copies cached hashes rather than invoking a user
comparator. Allocation, weak primitives, pending dispatch and raising remain
explicit successors. Under the named source/runtime behavior relation, their
selected clients cannot enter either captured cut while preserving a resumable
table mutation. In particular, one-worker Thread yield does not execute the
GNAT scheduler, and SIGINT's save/exit route does not call the scheduler,
driver preparation or parser.

The fresh Debug -> Format -> flush_all chain has true once-only gates and an
empty statistics list. Stdlib only prepends hooks and clears gates; Debug
only prepends statistics callbacks. Those source mutation rules, private
ownership and the single-worker relation justify the history inference from
the observed roots. An earlier extra callback cannot disappear, and the two
observed hooks cannot already have run. The zero cleanup selector and fixed
native lifetime owners exclude another preparation route within their stated
external behavior contracts.

Exception handling was challenged separately. Outside catches receive control
after table frames unwind; the local replace Not_found catch only performs
insertion/resize. With no receiving OCaml trap, diagnostic work can occur
before physical stack unwinding. The retained `printexc.c:107–162` source
calls the handler and then terminates, so even a callback there has no
continuation that resumes the abandoned operation. This is a no-resumption
argument, not a zero-diagnostic-work assumption. A previously interrupted
resize may have left a partial current array; the accepted census inventories
that actual array, so transactional resize is not needed.

Consequently the unique cached-hash candidate census covers initial paths
selectable for the captured serialized tags. Each nonempty candidate has one
component and at most six bytes. Initial identifier-weighted totals are
607 / 503 / 334 / 74 / 86 bytes. Other current payloads remain partly decoded,
and later writers are covered separately below. These are neither whole-table
payload maxima nor whole-interval R/U.

One attachment issue was corrected before author freeze: the draft inline
branch used the plan's apply address without comparing the actual observed
snapshot PC. The final checker requires the `inline_trivial_entry` label,
subtracts that process's load bias from its observed PC, and checks equality
with `0x5d7aa0`. It exports the observed PC, label and bias for every case.
This repair makes the executable input attachment explicit; no semantic
counterexample was established. No remaining initial-state finding blocks
the bounded result. No endpoint stack was observed.

## Later library origins and writer closure

The library-origin note, checker and evidence are reviewed separately from
the earlier conditional suffix lemma. The new source induction discharges
the named-module selection requirement and replaces the unnecessarily broad
body-symbol locality premise. This review examines the retained origin,
clone, registry, task/meta and result-dispatch sources, the source/reference
censuses, and the relevant selected transform/printer/error-owner boundaries.
It reuses the accepted encoding/tuple and fixed-library DAG/suffix results.

`Env.create_env` uses its own counter. The two selected lifetime constructors
give distinct tags 0 and 1, so the outer environment memo cannot redirect a
lookup by an identifier-tag alias. Inner file keys are structural string
lists, module keys are strings, and both check equality after hashing. The
fixed loadpath/input relation supplies the installed file bytes on later
reads. A completed parse is published under its input path. Parser slices
start with an empty file map, and selected pending clients do not enter the
parser. Loss, failure and reparse can remove a binding or reconstruct the
same named definition; they do not substitute a different edge of the DAG.

The relevant value invariant covers declarations, namespace units, introduced
heads, and type-definition graphs. It does not require global `restore_its`,
`restore_rs` or `restore_pv` tables to be collision free. A foreign expression
symbol can affect typing, validation or a body without selecting a foreign
module or injecting that symbol's definition as a declaration. Lexical type
construction uses string tables/current namespaces. Type/declaration
hash-cons equality checks physical introduced symbols, and the per-clone maps
start empty apart from bounded namespace substitutions. Automatic uses select
only the fixed builtin families and tuples. The interface implementation's
shared clone state is outside this parser route.

The recursive `clone_type_decl` case needs both the visited type symbol and
its possibly aliased local definition to satisfy the family invariant.
Checking only the copied name would not suffice. Both come from the selected
type definitions, local substitutions or builtins; the `kn` map is the receiving
module's declaration map. The selected explicit type definitions are abstract
or the `Finite int | Infinite` variant and have no invariant/witness VC route.
Global expression restoration does not supply their definition graphs.

Review identified another necessary alias boundary: nested `Elet` cloning
can publish routine logical heads into the shared `cl.ls_table` through
`sm_save_rs`. Later Dlogic reconstruction can select such a head under a tag
alias. The author strengthened the invariant and added exact source excerpts
for these local heads. Typing supplies lexical binders; Dexpr's extra routine
proxy is named `h`; routine creation, recursive effect repair and clone
construction preserve the supplied name. A restored foreign routine is a
reference, not a spliced `let_defn` body. Therefore this additional map writer
also stays within the lexical/fixed stem bound. The revised argument does not
rely on the false generalization that body-local names can never affect a
top-level head. No numerical bound change is needed.

The selected 20 outer transforms and three SMT printer names are joined to
fixed string-keyed registrations. All four discrimination flag tables and
their 16 registered callbacks are included, along with the earlier encoding
dispatch. Task insertion/export and symbol/term/declaration reconstruction
do not call Theory path insertion. Algebraic tuple construction is the bounded
exception; literal initialization reads exactly int.Int and real.Real. Their
whole-file dependency closure is the accepted four-file DAG. Printer,
save/ending, selected pending and exception owners introduce no other parser
or Theory writer root. Private memo aliases can change a result within these
callback families, not install a new registered function.

Model-result parsing was checked rather than inferred from the command-line
counterexample option. Fourteen resolved drivers, eleven prefix libraries
and five native inputs contain no `get_counterexmp` outside driver comments.
The private meta type, finite module-initialization registration census and
separate counter give stable distinct meta tags. Selected constructors preserve
existing metas or add the displayed non-counterexample constants; task
hash-consing compares the tdecl/previous task. Reconstructed and memoized tasks
therefore retain the empty counterexample-meta entry. `prove_task_prepared`
passes `get_model=None`, and `record_model` does not call the model parser in
that branch, even on model-looking prover text. This excludes its additional
library reads without silently extending the four-file lemma.

With those source boundaries, later installed nonempty payloads satisfy
`3*38,678+128 = 116,162` under the explicit normal numeric/allocation-service
contract. Repeated clones preserve lexical stems; namespace ancestry follows
the acyclic named DAG. The statement permits identifier-tag collisions,
reparses, partial failures and loss to fallback. It does not bound parse counts,
task sizes, failed numerical services or complete helper execution.

The final frozen checker reproduces 79 source witnesses, the 20-transform
dispatch and seven generated JSON objects. This corroborates the source
attachment and census, not the semantic induction itself.

## Composed path and formatter inputs

The final composition takes `max(6,116162)`. Cached hashes remain immutable,
so unrelated initial cells cannot become eligible merely through resize.
Later old-array continuations can carry partly decoded unrelated initial cells;
the bounded statement is about their payloads eligible for the captured
serialized tags. Review requested this qualifier explicitly, and the frozen
note includes it. Every later installation is covered by the writer result.
No preservation of the originally selected binding is needed.

The composition also explicitly checks later-writer coverage and its
normal-service requirement, in addition to initial-state completeness. With
the accepted occurrence/continuation bounds it derives
`U=C+N*max(F,R)`, `d=20`, `B=1024*Q+6*U+32*Q*d` and `E=128*Q+U`.
Its four external premises map to the inherited Format-core and construction
interfaces without treating any complete-capacity flag as established.

| Case | U upper bound | B+E+79 | Concat destination-block subtotal across all saves |
| --- | ---: | ---: | ---: |
| Put_Line | 7,670,360 | 54,645,943 | 23,002,848 |
| Put | 6,391,978 | 45,552,117 | 19,169,040 |
| First_Or_Default | 3,951,491 | 28,189,156 | 11,849,952 |
| Is_Message | 581,155 | 4,148,804 | 1,742,640 |
| Input_Is_Valid | 697,270 | 4,968,777 | 2,091,168 |

All Format sentinel expressions are below `1,000,000,010`; the separate
container/depth guards pass. Each concat requests at most 116,176 destination
bytes including its string header/padding. The subtotals use the one global
three-save budget, not a budget reset at ordinary ending. Offered XML bounds
are output-contract extents, not delivered file sizes; concat subtotals exclude
all other allocations and allocator/GC overhead.

Default output retains null usable R/U and transfer outputs. Removing any
one named external premise withholds them. Supplying all four admits only the
scoped transfers and leaves every complete restore-table, allocator/pending,
formatter, save and pipeline flag false. No runtime service success is reported
as observed. The reviewer reproduced the exact retained result and checked all
five cases plus four missing-premise variants.

The remaining work includes complete restore-table lookup, formatter
accumulator construction, aggregate allocation/native layout, stack/GC,
numeric failures, channel/file offsets, pathname, diagnostic and exit capacity.
The full driver/solver/server/report transfers, fixed-library/current-grammar
coverage and whole-rule composition/correspondence remain #119 obligations.
The named external source/native behavior relation is still a premise. This
review does not amend Oracle guarantees, admit a construct, alter tool pins,
start production #88–#94 or accept merging draft PR #121.

## Verification and reporting

| Reviewer execution | Result | Available elapsed evidence |
| --- | --- | --- |
| New path-construction checker | Nine source ranges; seven retained bodies/1,168 instruction bytes; 16-byte dot object; 5,460 short length lists; five applications and boundary/premise checks pass | Checker reports 1.321 s |
| New initial-state checker at frozen author commit | 31 source excerpts; five process/cut/exit-state attachments and initial candidate joins pass | Checker reports 4.043 s |
| New library-origin checker at frozen author commit | Seven JSON comparisons; 79 source witnesses; 20 transform registrations pass | Reviewer wrapper measures 0.590 s |
| New composition check at final aggregate | Exact retained output; five cases and four missing-premise variants pass | Reviewer wrapper measures 0.024 s |
| New reconciliation check at final input | 34 author files match; 94 native pins unchanged; five Python parses and 26 local links pass | Reviewer wrapper measures 0.324 s |

The finite enumeration challenges the transfer; the prefix/ownership induction
is the source argument. No prior successful checker, native target, capture,
disassembler, source fetch, solver/GNATprove/Lean/full-suite run, GitHub write
or CLI-memory update was performed. `uname` and `scripts/dev.py paths` confirm
Linux x86_64. Reading ELF bytes does not execute the target.

Reviewer selected: GPT-6 Astra / Extra High, confirmed by the parent's task
assignment using the existing reviewer. Runtime setting introspection and
per-review token/monetary-cost attribution are unavailable. Review began at
11:23:22 UTC; the final checkpoint was 11:39:41 UTC, an observed interval of
979 seconds (16 minutes 19 seconds), including reading, review coordination
and report preparation. This is not native execution or isolated inference
time. No reviewer subdelegation occurred.
