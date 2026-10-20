# Fixed-forest SV6 shape insertion and untruncated byte transfer

2026-10-20, Linux x86_64, research [#119](https://github.com/berkeleynerd/silver/issues/119)
and [#153](https://github.com/berkeleynerd/silver/issues/153). This supplies the
per-save **J and L** inputs requested by the accepted
[ordinary-ending transfer](retained-why-ordinary-ending-control.md), using the
five retained logical forests and their saved fully opened occurrence counts.
It does not establish complete save, identifier-counter or pipeline capacity.
Independent review is required before integration acceptance.

| Forest | PID | B, imported | G | J, insertion calls | L, Shape-buffer bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 3085 | 41,946 | 65 | 15,925 | 3,201,881,878,432 |
| Put | 3323 | 33,252 | 54 | 13,230 | 2,479,444,040,182 |
| First_Or_Default | 3470 | 10,195 | 33 | 2,541 | 175,587,716,265 |
| Is_Message | 3568 | 744 | 4 | 220 | 5,940,181,716 |
| Input_Is_Valid | 97103 | 966 | 5 | 315 | 9,657,138,162 |

These deliberately loose L values include a quadratic repeated-quote suffix
allowance at each fresh printer. They are not measured output sizes. Each
process passes the stated alpha, suffix, individual-string and `3*L` string
guards. That arithmetic fact does not prove every formatter, container,
allocation or serialization representation sufficient.

The [packet](../evidence/retained-why-session-shape-transfer-20261020/README.md)
pins source excerpts, the five atom files and exact saved certificates, and
retains executable mathematical bounds. Atom input is frozen at
`0ec7f4b5082830501f51764bfd4652d157c31104`. The four new forests retain their
pre-scheduling registration phase; Input_Is_Valid retains its distinct prior
first-inline phase. The source result uses the accepted logical preservation
interface; it does not identify their auxiliary states or counters across
those phases. No graph opening, successful binder/alpha computation, native
capture or tool execution was repeated.

## Inputs and premises

The fixed-forest input is
[`c285194f00`, review `759d0fa110`](retained-why-fixed-session-domain.md).
The ordinary-ending source input is `f4425cc0b0`, review `a4dd3013d9`, integrated
as `1935f9d1aa`. Its selected one-worker, fresh Per_Check, CE-off, non-replay
configuration, later-entry attachment, private printer/frame and valid finite
representation requirements remain premises. Its catch ledger supplies the
no-retry and no-return-to-an-interrupted-Buffer facts. This packet neither
reproves those inputs nor silently asserts that their configuration is joined
at every later entry.

For each task `t` in one exact forest let:

- `D_t` be its saved proposition occurrence list, including every chain
  proposition, rather than only the normally selected local declarations.
- `T_t` be the sum of saved `opened_term_occurrences` over `D_t`; repeated
  occurrences and formulas are charged repeatedly.
- `B_t` be the corresponding sum of `opened_binder_occurrences`.
- `W` be the maximum sum of structural pattern occurrences in the branches
  of a stored reachable `Tcase`, or zero if there is none.
- `M` be the maximum original identifier name byte length in the complete
  typed closure; `C` the maximum supported constant-output byte bound below.

The atom traversal covers the saved proposition roots, all term/pattern edges,
binder variables, triggers and deferred substitution terms. It records typed
identifiers/constants and attribute unions. Its extraction/representation
argument is a separate reviewed dependency, not proved merely by this
packet's hash match. The join compares its copied certificate with the original
saved certificate and preserves each APn visit. An unsupported numeric layout,
constant kind or incomplete typed closure leaves L unknown in the executable
interface. There are no such unsupported inputs in the five supplied files.
All five certificates have only non-detached APn visits with saved task keys.
The finite-input join requires this property and rejects a detached-visit
input; it is not a generic loader for arbitrary future session forests.

Opening substitutes existing terms and fresh variables, preserves original
identifier strings (`ident.ml:209–215`), and structurally renames patterns
(`term.ml:139–188,739–831`). Thus every opened constant/name belongs to the
typed closure or is a fresh clone of its original name. Every opened `Tcase`
inherits a stored branch-pattern structure. The conservative bounds are

```
Q_t = T_t * W              total emitted pattern-node occurrences
P_t = T_t + Q_t            identifier-printing calls, as well as output nodes
A_t = B_t + Q_t            alpha-renaming calls
```

Each opened term could be a `Tcase`, so multiplying by W overcounts safely.
Each non-pattern alpha call corresponds to an opened bound variable; each
pattern alpha call is at a Pvar/Pas occurrence, with only the left Por arm
used for alpha renaming. Charging all Q_t patterns avoids requiring any
distinct-variable argument. All five actual closures have no patterns and
no `Tcase`, so their Q_t is zero. Generic pattern arithmetic is an interface
for a future complete typed input, not an observation of a pattern-bearing
captured forest.

## J: each source insertion continuation at most once

`Gshape.t_bound_shape_task` (`termcode.ml:601–628`) creates a fresh printer,
alpha counter and map. Under the accepted catch-sensitive `Task.local_decls`
argument, its selected declarations form an ordered subset of D_t. It calls
`Shape.t_shape` once per selected proposition, catches `ShapeTooLong`, obtains
buffer contents, clears, and calls `add_and_prepend` once. Empty shapes may
skip insertion. It then calls `add_and_prepend` exactly once for the explanation,
replacing an empty explanation by the eleven-byte `empty_shape`.

`add_shape` has one miss continuation, not a retry loop
(`termcode.ml:571–582`). The accepted interrupted-save ledger permits partial
global writes and spurious misses, but no extra insertion call from this
source occurrence. Nested saves are counted separately by the ordinary-ending
transfer. Therefore

```
J = sum over APn visits v of (length(D_task(v)) + 1).
```

Neither dictionary equality nor the number of distinct output shapes is used.
The bound survives emptied, partially updated or inconsistent shape tables;
it does not prove those tables consistent or their scalar `n` safe.

## L: complete output, including both suffix families

Each term/pattern output node emits at most one tag byte and at most one
identifier/constant atom (`termcode.ml:415–506`). Tquant includes its full
body and trigger traversal; Por emits both patterns. The formula certificate
counts the fully opened term walk, without the 1,024-byte cutoff. A caught
`ShapeTooLong` shortens that walk. Other accepted receiving catches do not
restart a term or pattern walk. In particular, counting distinct graph nodes
instead would be unsound.

For names, `ident_v5` may miss the alpha/name map even for a previously seen
identifier. Charge each call, not merely each distinct identifier. `decoded`
returns a substring for a nonword notation, of length at most M; for SNword it
calls `id_unique` on the **original** identifier string (`termcode.ml:358–380`).
The fresh printer uses identity sanitizers and an empty blacklist. Cache hits
return one of the already bounded strings. Alpha strings come from a counter
starting at -1, incremented at most A_t times, so `digits(A_t)` overbounds
their length, including the zero corner case.

It is insufficient to argue that only decimal suffixes can occur because
`decoded` calls `id_unique` only for SNword. The mixfix decoder catches
`Not_found` from `String.index_from` and selects SNword (`ident.ml:120`); an
interrupted outer decode can take that fallback while a later `find_unique`
decode of the same original text succeeds as nonword. `find_unique` then
selects **repeated quote** suffixes (`ident.ml:233–256`). This result covers
both families, even if a tighter input-specific exclusion could be proved.

Here is a bound that does not require transactional index writes. Number the
at most P_t calls that reach `find_unique`, starting at one. The printer's
indices table is private; the nested save has another fresh printer. Each
call reaches at most two `Hstr.replace` sites. Thus at the start of call k
at most `2*(k-1)` distinct key strings have been introduced. Existing keys,
copies during resizing and partial publication cannot introduce a third
source key. This uses the retained scalar-container/native representation
contract; arbitrary memory corruption is not admitted.

Let I_0=0 bound every stored nonnegative index. A successful original-key
lookup starts at at most `I_(k-1)+1`. For positive indices the candidate names
`name ^ decimal(index)` and `name ^ quotes(index)` are injective within each
family and disjoint across families. Even if a caught decode changes the
family between tests, different increasing indices cannot use the same
occupied key. `advance` therefore passes at most `2*(k-1)` occupied indices;
`retreat` only decreases its index. A `Not_found` fallback produces the
original name, with a final zero write. Hence every attempted/stored index
and successful output has the conservative bound

```
I_k <= I_(k-1) + 2*k
I = P_t * (P_t + 1)
N_t = M + max(I, digits(I))
```

Caught exceptions after the base-index write can leave it advanced without
installing the candidate name. The recurrence explicitly allows this; it
does not assume the old index is restored. Its scalar guard includes `I+1`
to cover a successor operation. An exception outside these catches either
shortens the walk or escapes; it does not create another private-printer call.

For constants, SV6 uses `Common.const_v2` (`termcode.ml:220–228,401–408`):

- An integer emits its signed decimal byte string. The retained BigInt /
  Big_int_Z / Z aliases select `ml_z_format` with `%d`: base ten, width zero,
  no alternate prefix and a minus only for a negative value. The atom packet
  supplies exact immediate or validated Zarith integer values and lengths.
- A real emits signed decimal significand, `.p`, signed decimal pow2, `e`,
  signed decimal pow5: the three component lengths plus **three** bytes.
- A string of n bytes emits at most `4*n+2` bytes: each input byte escapes to
  at most four bytes and the result has two quotes (`constant.ml:50–73`).

The constant formatter is fresh, has only text and fixed punctuation in these
arms, and flushes without a newline; its destination is `Buffer.add_substring`
(`format.ml:632–637,665–676,992–1007`). No break/indent token is introduced.
This bounds all bytes it can append before a failure or the following shape
check, under the existing formatter/native effect and representation contracts.
It is not a proof of every formatter queue, internal decimal temporary or
allocation capacity. All actual constants are integers. Put_Line and Put each
have three heap Zarith values, using at most two 64-bit limbs, with maximum
value 18,446,744,073,709,551,616 and maximum decimal length twenty; the other
forests' constants are immediate integers of at most four decimal bytes.
No real/string occurrence is claimed for these captures.

With `H_t = max(N_t, digits(A_t), C)`, export

```
L_t = P_t * (1 + H_t)
L = sum over APn visits v of L_task(v).
```

Every source append event is charged even when its output is later cleared,
discarded, or interleaved with a nested save. The private printer/formatter
does not alias a nested save's locals. The accepted no-resumption argument
handles shared Buffer mutation and counts the nested save separately. Under
its joined protocol, position after the first save-owned clear is at most
`(1+k)*L`, k<=2. The arithmetic `3*L` guard passes for each forest. Entry buffer
position/backing, allocation growth, dictionary counters and all other
representation conditions remain separate.

## Explanation bytes are a separate interface

SV6's explanation is inserted directly into the dictionary; it is **never
appended to Shape.shape_buffer** (`termcode.ml:625–626`). J includes this call;
L does not include its bytes. This is the Shape-buffer L required by the
accepted ordinary-ending transfer, not a bound for all dictionary or XML text.

`t_attr_copy` unions source and replacement attributes
(`term.ml:654–659,739–778`). A maximum over individual stored nodes would miss
that union. Instead let U be the union of all reachable term attributes and
all proposition-identifier attributes. Fresh terms start empty; opening and
substitution copy/union attributes from this closure and do not create new
attribute strings. The atom packet records U's cardinality u and summed byte
length s. Let p be an established finite length of `expl_prefixes` at the save.
Each prefix visits each attribute once and removes a prefix without increasing
length. A returned list therefore has at most p*u labels and p*s payload bytes.
`search_attrs` returns one such list, or catches Exit and returns empty;
goal/root fallback selects a proposition-name list. It does not concatenate
lists from multiple successful formula nodes. `concat_expls` adds at most
`2*p*u+1` punctuation bytes. A safe direct-insertion bound is

```
E_one(p) = max(11, p * (s + 2*u) + 1)
E_save(p) = G * E_one(p).
```

The source initializes p=2 but exposes an extra-prefix setter. The five
captures do not establish the actual mutable prefix configuration. Therefore
the executable export leaves p and E unknown by default; it does not silently
use two. Neither J nor Shape-buffer L depends on that missing value. This
explicit outstanding representation/configuration input prevents promotion
to complete-save or explanation-serialization capacity.
Even when p is supplied, numeric E requires the complete typed attribute
closure above. The executable export checks the typed-closure/coverage flags
and leaves E unknown when they fail; numeric-constant completeness is a
separate requirement for L.

## Verification and remaining obligations

The focused check revalidates 23 exact source ranges, input hashes, copied
occurrence certificates, name/attribute/decimal lengths, repeated-visit joins
and the separate mathematical guards. Six small regressions exercise real
punctuation, all-byte escaping, pattern/visit multiplicity, unsupported atoms,
unknown explanation configuration and a failing representation guard. They
are checks of the executable interface, not replacements for this source
argument or the atom extraction review.

Source identity remains the accepted relevant-behavior relation for Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`, OCaml
`8eb41f72ded84df884c3671734c947f612091f84`, and retained Zarith 1.14 source.
No new installed-byte correspondence, native/helper capacity, diagnostic
identifier allowance, saved-artifact consistency, whole counter, all-pair
driver preparation, solver/result/report or current-grammar theorem follows.
The later-entry configuration and representation joins are still required.

Selected author setting: GPT-6 Astra / Extra High; runtime confirmation and
token/cost evidence unavailable. The packet records elapsed/check time and
the exact review inputs. Parent owns integration and durable session memory;
no CLI-memory or GitHub update is claimed here.
