# Constructing restored identifier paths within a supplied bound

2026-10-20 UTC, research #119 / #153, Round 32. This source/native transfer
closes the selected `String.concat "."` arithmetic, destination extent and
loop-storage question once a finite immutable path bound is supplied. It
bounds attempted construction and partial execution, not only successfully
returned strings. The [packet](../evidence/retained-why-path-construction-20261020/README.md)
retains exact sources, selected installed instruction bytes and a conditional
interface. It does not establish the still-separate bound on every selectable
path or complete allocator, callback, restore-table lookup or save capacity.

## Input and prefix invariant

`save_ident` (`session_itp.ml:2099–2107`) obtains the third component of
`Theory.restore_path`. An empty list selects the immutable identifier fallback;
a nonempty list is joined with exactly one dot between components. Let its
component lengths be `a_1,...,a_m`, with `m>=1`, and let

```
J = sum(a_i) + m - 1 <= R.
```

The list is finite, its strings and links remain immutable while the call is
active, and the existing faithful source/native/pending-frame behavior applies.
Since the lengths are nonnegative, **m <= R+1**, even if every component is
empty. This component bound would not follow for a zero-length separator; the
actual separator is the one-byte dot. The payload invariant comes from the
separate path-origin/state argument, not from observing the final string.

`Theory.store_path` constructs immutable list cells with append/reverse and
installs a tuple; replacement changes table bindings, not the returned list.
Once `save_ident` holds that list, collection or replacement of a weak-table
entry cannot mutate the rooted list. Identifier names have immutable record
fields. These facts use the selected source effects and exclusion of unmodeled
unchecked mutation; a type annotation alone would not exclude arbitrary native
corruption or a forged cyclic list. The separate writer proof supplies valid
finite input origins.

The actual OCaml `String.sum_lengths` (`string.ml:56–61`) is a tail loop. Before
component i, its accumulator is the sum of earlier lengths and intervening
dots. A nonfinal step adds `a_i+1`; a final step adds `a_m`. Every intermediate
addition is nonnegative and at most J. Therefore, for
**R <= 2^57-9**, all tagged-integer arithmetic is represented, the monotonicity
check succeeds and the final unchecked addition is safe. This is an induction
over all finite lists satisfying the invariant, including zero-length names;
the checker’s small enumerations only challenge the implementation of the
transfer.

The native byte allocator accepts at most **2^57-9** bytes on the selected
64-bit build (`caml_create_bytes`, literal `0x1fffffffffffff7`). J meets that
exact guard. `caml_alloc_string` computes `w=(J+8)/8` payload words and allocates
one string block, with representation size **8*(1+floor((J+8)/8))** bytes
including its header. Its length arithmetic, padding index and final-byte
padding value are represented. J=0 still needs one payload word and a header.
This bounds the requested object even when its allocation fails. Allocator
metadata, collection and physical-memory sufficiency remain their own owners.

The `unsafe_blits` loop starts at destination offset zero. Each component copy
uses source offset zero and length a_i. Each nonfinal separator copy uses length
one. By the same prefix invariant, every source/destination extent lies within
its object, offsets remain at most J, and the final position is exactly J.
There are **2m-1 memmove calls** copying **J bytes** in total. The source has no
intermediate concatenation string or list allocation. `Bytes.unsafe_to_string`
is an identity conversion; the successful result is the same destination block.

## Interrupted construction and native loop shape

The sum pass does not mutate its inputs. The destination allocated before the
copy pass is a private local and is not published until the pass returns.
`String.concat` and the copy/sum loops have no local catch. A signal-origin
`Not_found` may escape into `save_ident`'s outer fallback catch, but then the
partial destination and its construction frame are abandoned. The handler
selects `id_string`; it does not resume the copy loop or publish its partially
filled bytes. Another escaping exception unwinds the enclosing save. A nested
save uses its own destination. A normally returning pending callback preserves
the rooted input and private destination under the inherited frame/effect
contract. No assumption that allocation or every save succeeds is required for
these attempted-size and executed-prefix bounds.

The retained native bodies corroborate the exact selected source route:

- `save_ident_4262` at `0x7fb630` directly calls the selected concat body;
  its installed separator literal is the one-byte dot. Its fallback branch
  loads the identifier name after unwinding the constructor's catch frame.
- `String.concat_419` at `0x951d10` calls `sum_lengths_403`, invokes
  `caml_create_bytes` through `caml_c_call`, then calls `unsafe_blits_410`.
- The sum loop jumps from `0x951bd1` back to `0x951b44`; the copy loop jumps
  from `0x951cf9` back to `0x951be4`. Both targets follow their function's stack
  prologue. There is no additional stack frame per component.
- Each loop has one direct GC/pending poll per component. Its GC continuation
  jumps past that poll before processing the current component. This bounds
  direct loop poll sites, not the internal work of GC or its callbacks.
- `caml_blit_string` directly calls `memmove` and returns; it has no OCaml
  allocation/poll. The source's wrapper is inlined in this native body.

Only the selected bodies' instruction bytes are compared with the installed
ELF. Transfer uses the existing scoped external source/native behavior
relation; this is not a whole-binary refinement proof. The local constant stack
shape does not bound allocator/trampoline/GC/callback/libc stack use, signal
nesting or the caller's existing stack. Those resource owners remain explicit.

## Per-save and whole selected-interval charges

For at most N identifier occurrences per save and the
[accepted global save entry bound](retained-why-save-attempt-growth.md) r<=3,
there are at most **r*N** concat attempts. An empty restored
path, missing lookup or earlier failure can only reduce that number. The
fallback catch performs no second concat attempt for the same occurrence.
This uses the accepted forest/serializer occurrence and continued signal
premises; the budget is not renewed when ordinary ending begins.

With `K=R+1` and `A=8*(1+floor((R+8)/8))`, the selected construction therefore
requests at most `r*N*A` string-block bytes, visits at most `2*r*N*K` components,
calls memmove at most `r*N*(2*K-1)` times and copies at most `r*N*R` bytes.
These totals count caller requests/operations, including a failing last prefix;
allocator-internal retry/metadata and other save objects are not included.
No physical-heap or whole-process aggregate bound is inferred from this subtotal.

The packet evaluates the five retained N values at the conditional library
bound R=116,162. It exports no actual construction bound by default: the
actual finite input invariant, native/frame relation and occurrence/global-save
budget must be supplied. No full-save or whole-pipeline flag is set even then.
Complete restore-table lookup/cycle capacity and all selectable path origins
remain distinct from construction of the list returned by a lookup.

Oracle, installed tools/pins and admission remain unchanged; production
#88–#94 is unstarted and PR #121 stays draft/unmerged. Lead live model/effort
and per-agent token/cost attribution are unavailable. No target execution,
new capture/disassembly/source fetch, solver/proof or broad prior replay was
performed. Independent acceptance belongs to the aggregate Round 32 review.
