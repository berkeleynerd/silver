# Restored-path continuation: supplied-byte bound and exact residual

2026-10-20 UTC, owner-resumed #119 / #153 Round 30, base
`0937ca4a44d012893c7c95517e990f019d1489e6`. This bounded offline source analysis
uses the accepted five fresh Linux x86_64 captures and retained source archives.
No native, compiler, solver, proof, capture or source-fetch work was performed.

The small raw-string candidates **4,275 / 3,571 / 2,317 / 419 / 384** remain
conditional on the restored-path premise in the accepted
[serializer-input result](retained-why-save-serializer-inputs.md). The source
inspection below does not establish that premise. It does establish a larger
bound on bytes of variable strings **actually supplied** to the serializer,
without assuming that restored bindings stay unchanged or that new identifiers
have noncolliding tags. The larger bound fails useful formatter headroom.

Let `M = 144115188075855863 = 2^57-9`, the maximum length of a valid string in
the retained OCaml runtime. Let `N` be the occurrence count of serialized
identifiers and `C` the accepted raw-string subtotal excluding those identifiers.
For each reached save, under the accepted valid-native-value relation and the
existing forest/attempt-growth conditions,

```
U_supplied <= C + N*M.
```

| Case / fresh PID | N | C | Larger U_supplied per save |
| --- | ---: | ---: | ---: |
| Put_Line / 17310 | 66 | 3,668 | 9,511,602,413,006,490,626 |
| Put / 17514 | 55 | 3,068 | 7,926,335,344,172,075,533 |
| First_Or_Default / 17631 | 34 | 1,983 | 4,899,916,394,579,101,325 |
| Is_Message / 17704 | 5 | 345 | 720,575,940,379,279,660 |
| Input_Is_Valid / 17869 | 6 | 298 | 864,691,128,455,135,476 |

The one whole-post-cut budget allows at most three save entries, so multiply
these values by three for the aggregate supplied-byte upper bound. No budget
is restarted at ordinary-save entry. These are mathematical integer bounds,
not values accumulated in an OCaml integer. All five exceed `M`; the first
three also exceed the native integer maximum `2^62-1`.

`save_ident` computes `n` before `fprintf … save_string n`
(`session_itp.ml:2099–2107`). It either uses the captured immutable fallback
string or calls `String.concat "."` on the restored qualified components.
Whenever the string argument is actually supplied, it is a valid represented
string and hence has length at most M. A join that fails or never returns
supplies no name argument at that call. An escaping `Not_found` may select the
fallback; that is also covered. Nested saves have their own occurrence counts
within the shared at-most-three budget.

This is **not** a bound on the attempted joined length, path-list traversal,
intermediate allocation, or work before an unsuccessful `String.concat`.
The argument does not assume a path of arbitrary length can be allocated or
successfully printed. It bounds an existing serializer interface's supplied
arguments under the same valid-value relation as the other string consumers.
It does not prove native representability of a source-derived desired output.

The [operational transfer](retained-why-save-operational-bounds.md) uses
`B = 1024*Q + 6*U + 32*Q*D` and `E = 128*Q + U`; consequently, with nonnegative
Q and D, `B+E+79 >= 7*U+79`. Every larger U above makes that lower bound exceed
the Round 30 [Format-core transfer](retained-why-save-formatter-core.md) guard
`B+E+79 <= 1000000010` (lead implementation `6319196c03`). The packet
records this explicit rejection; it does not independently validate that
separate Format-core theorem. Replacing unknown U with this conservative
supplied-byte bound therefore cannot establish useful save capacity.
This is a failure of the conservative guard, not evidence that actual output
or allocation exceeds a runtime limit.

## Exact path writers and native behavior

`Theory.restore_path` reads a private `Ident.Wid` table. The full retained
ML/interface reference census finds only the following writers of that table
(`theory.ml:472–492`):

- `store_path uc path id` calls `Wid.set` if `Wid.mem` is false. Its third
  tuple component is `List.rev (id.id_string :: path @ uc.uc_prefix)`.
- `store_theory th` likewise conditionally sets a binding, but its third
  component is always `[]`.

The table and writer closures are not exported by `theory.mli`. The similarly
named private table in `pmodule.ml` is a separate table and is not the one read
by session `save_ident`. Module/interface privacy restricts ordinary source
clients; it is not an assertion about arbitrary reflection/native corruption.
The already classified native/pending clients and trusted value behavior remain
the applicable boundary, rather than an assumed absence of callbacks.

Only the **third** component is used by `save_ident`. Library path and theory
name are ignored. Thus `store_theory`, even for a key that aliases a captured
tag, cannot itself introduce a longer printed qualified name: an empty list
selects that captured identifier's fallback. `store_path` is the remaining
potential source of an enlarged name. Its callsites are `add_symbol`, reached
by Theory declaration constructors, and the namespace walks in
`Theory.clone_export` (`:499–516,549–591,919–948`). The former supplies `path=[]`
but may have a nonempty `uc_prefix`; the latter also supplies namespace paths.

`Wid.set` is `Ephemeron.K1.Make.replace`, despite the informal "bind once"
comment in `weakhtbl.ml`. Equality compares `S.tag k1 == S.tag k2`, not physical
key pointers (`weakhtbl.ml:66–85`). `Ident.id_register` increments a native
counter to assign a tag (`ident.ml:187–192`). A proof that later physical
identifiers differ from captured ones therefore needs either tag noncollision
or a bound covering the payloads of tag-aliasing registrations. No bound on
whole-preparation identifier growth is introduced here.

Strong reachability and table reachability are also distinct. Under faithful
GC behavior the retained session fields keep their original identifiers alive.
This alone does not preserve an ephemeron-table lookup: `resize` publishes
`h.data <- ndata` before copying the old buckets (`ephemeron.ml:195–211`). An
interruption can expose a prefix of the copy and hide a still-live key. The
ordinary `mem` implementation has no catch converting a signal exception into
false (`:336–347`), but a genuinely missing entry in that partial array yields
false. Replacement itself unsets data, sets the key and then sets new data
(`:546–549`); interruption is not transactional rollback.

Loss alone is safe for the small candidate when it merely selects the fallback.
The problematic step is a later `store_path` supplying a longer binding, or
an older lookup candidate exposed by mutation. This round does not assume
that the observed first binding exhausts every future selectable value.

## Selected source frontier

Several suspected paths can be separated using exact source:

| Path | Established source fact / remaining boundary |
| --- | --- |
| `Driver.update_task` | Uses `Task.use_export`, `Task.add_tdecl` and `Theory.clone_meta` (`driver.ml:330–369`), not Theory declaration/namespace insertion. It separates and restores the goal declaration. |
| Task construction and export | `Task.add_decl`, `Task.add_tdecl`, `Task.use_export` build task values. `Task.clone_export` selects the `Theory.clone_theory` traversal with `flat_tdecl`, not `Theory.clone_export`'s path-registering namespace walk (`task.ml:148–200`, `theory.ml:897–959`). Reusing a goal symbol in a rebuilt task does not itself register a path. |
| Driver loading | The driver export helper creates/closes a theory at driver load time (`driver.ml:232–247`). The selected fresh captures occur after loading. This is distinct from each later `prepare_task` call. |
| Literal transform initialization | The selected `eliminate_literal` environment transform calls `Env.read_theory env ["int"] "Int"` and the corresponding real lookup (`eliminate_literal.ml:193–228`). `Env.read_library` can parse/load on a memo miss (`env.ml:191–222`). A stopped cache snapshot or a normal hit cannot exclude an interrupted miss. |
| Algebraic elimination | Its selected implementation can call `Theory.tuple_theory` (`eliminate_algebraic.ml:470–487`). A tuple-theory memo miss constructs/registers type and constructor paths before closing the theory (`theory.ml:1047–1055`). |
| Conditional encoding | The selected encoder uses registered flag-dependent helpers (`encoding.ml:51–76,106–137`). The fixed driver directive list alone is not a complete indirect-callback proof. A lexical absence of `create_theory` in a transform module does not discharge helper/library registration effects. |

These facts narrow the next boundary to the selected `store_path` payloads.
They do not claim an exhaustive no-registration theorem for all selected
transform helpers, lazy libraries, result/error routes or native callbacks.
The task/driver evidence and accepted callback classifications are reused;
old observer, binder, alpha or native evidence was not replayed.

## Remaining obligations and next bounded step

To recover the useful small U, or a moderately larger U that passes the
formatter guard, the next source step should bound the third components of
all later selected `store_path` registrations. Start with the int/real lazy
library dependency closure and the tuple-theory constructor, then close the
selected encoding/helper dispatch. This can either:

1. Establish that registrations cannot target any serialized captured tag,
   joining physical-ID separation to a whole-interval tag-noncollision bound;
   or
2. Bound every possible registered qualified component list, including its
   identifier string, namespace prefix, dot count and any tag alias. This
   avoids using an unproved freshness claim.

A preservation argument must also cover all initially selectable bindings,
weak clearing, partial ephemeron resize and possible replacement. It may allow
loss-to-fallback; it must not infer map preservation from live session fields.
If a larger payload bound R is established for all relevant successful path
registrations and retained selectable values, the same occurrence arithmetic
can use `max(fallback_i, R_i)` instead of M. Bounding the construction itself
still requires joined-length arithmetic, list traversal and allocation proof.

Per the lead's Round 30 boundary, the fixed-library parser/name-generation
audit is deferred rather than expanded here. The
[packet](../evidence/retained-why-restored-path-continuation-20261020/README.md)
freezes the concrete source findings, the larger supplied-byte calculation,
negative headroom result and exact residual. Oracle, admission, pins,
production code and issue statuses are unchanged; combined independent review
and integration remain lead-owned.
