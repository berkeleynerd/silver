# Fixed Why3 prefix semantic occurrence counts

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
The five fixed-library prefixes have no signed-integer overflow at the three
arithmetic sites that construct cached free-variable multiplicities and their
occurrence totals. A guarded observation retained **146,259 operand pairs**;
the largest mathematical result is **47**, against the signed OCaml limit
`2^62-1`. This closes the particular gap in the
[allocation-only dimensions argument](retained-producer-prefix-gc.md#physical-containers-and-the-remaining-semantic-gap)
under that record's fixed-context and source-correspondence premises. It is a
selected arithmetic component, not whole-prefix or whole-pipeline capacity.

## Why these counts matter

The cached `bv_vars : int Mvs.t` values count unfolded free-variable occurrences,
including delayed substitutions. Their values cannot be bounded just by the
number of physical term nodes: a shared DAG may encode many more occurrences.
They also cannot be treated like deliberately modular hashes.

Some consumers inspect only map support. `Mvs.union` retains `Some 0`, and
`Mvs.map` keeps its keys, so a wrapped count need not erase a key. But other
selected typing/VC constructors inspect the count itself:

| Consumer | Semantic use |
| --- | --- |
| `term.ml:1688–1713` | The two let simplifiers omit a binding when `t_v_occurs = 0`. A false zero can leave the formerly bound variable free. |
| `vc.ml:274–285`; `expr.ml:601,660` | Prefix VC/pure-expression construction calls those let simplifiers. They are not confined to later optional prover strategies. |
| `expr.ml:560–568`; `ity.ml:1523,1529`; `pdecl.ml:524` | A zero occurrence count is a precondition for recognizing or rewriting a defining postcondition. |
| `expr.ml:999`; `pmodule.ml:1133–1138` | Positive occurrence checks enforce loop-invariant and mutable-type-refinement restrictions. |

This identifies a missing assurance premise; it does not claim overflow in the
delivered inputs. The guarded capture below establishes small exact values for
those fixed prefixes.

## Complete selected count arithmetic

All cached count values originate in `t_vars`: a variable has count one, an
empty occurrence set has no entry, and other terms combine those maps.
Closing binders removes bound keys (`term.ml:608–624,785–795`). Delayed
substitution combines/multiplies counts (`:765–778`), while type/variable
renaming carries their values unchanged (`:1103–1111`). `t_freevars` is the
same addition helper (`:1465`). The public interface keeps term construction
private and the bound/branch/quantifier representations abstract
(`term.mli:120–143`); callers cannot directly write `bv_vars`. The retained implementation scan finds no
external `t_v_count` callback; its selected count-consuming caller is
`t_v_occurs`, whose accumulator starts at zero. Thus the count arithmetic
requiring a no-wrap argument consists of these sites:

| Operation | Source | Installed observation point | Tagged operands |
| --- | --- | --- | --- |
| Map-count addition | `term.ml:604`, `vars_union` callback | `camlWhy3__Term__fun_13836 + 25`, static `0x576559` | RBX, RDI |
| Substitution multiplication | `term.ml:623–624`, `add_nt_vars` callback | `camlWhy3__Term__fun_13856`, static `0x576810` | Closure field 2 at RBX+16, RAX |
| Occurrence accumulator addition | `term.ml:1454–1455`, matching-variable branch | `camlWhy3__Term__fun_15307 + 9`, static `0x57e319` | RAX, RDI |

The installed closures use unchecked `lea`/`imul` arithmetic. The multiplier's
entry is before its operand untagging, and the occurrence breakpoint is after
the variable-equality branch but before the addition. The packet retains the
static disassembly and independently extracted ELF instruction bytes. Installed
debug line numbering differs at the occurrence callback (1462 rather than
1455); the join uses the symbol, closure construction and instructions, under
the existing relevant-behavior source premise.

At each breakpoint, the observer reads the raw tagged operands, checks the
low-bit tag, decodes their signed 63-bit values into Python integers and writes
the two decoded operands as little-endian signed 64-bit words. Python computes
the mathematical sum/product and stops before the machine arithmetic if either
operand is negative or the result exceeds `2^62-1`. Every hit is retained;
the offline checker recomputes all values, counts, minima and maxima.
No inferior function call, register write or data-field modification occurs.

This gives a first-overflow argument rather than merely inspecting final
counts. Before a hypothetical first overflow, the source seeds and previous
checked operations establish nonnegative exact operands. That next operation
is one of the guarded sites and has its mathematical result checked before
execution. No such violation occurs in the complete selected prefix.

## Results and transfer

| Input | Map additions / maximum | Products / maximum | Occurrence additions / maximum |
| --- | ---: | ---: | ---: |
| Put_Line | 15,327 / 30 | 16,165 / 24 | 8,649 / 29 |
| Put | 14,843 / 30 | 14,222 / 24 | 8,510 / 29 |
| First_Or_Default | 13,705 / 47 | 2,924 / 46 | 8,419 / 32 |
| Input_Is_Valid | 12,385 / 30 | 1,770 / 24 | 7,686 / 29 |
| Is_Message | 12,284 / 30 | 1,721 / 24 | 7,649 / 29 |

The exact configuration remains `OCAMLRUNPARAM=s=256M,h=16M,M=1000`, with the
same executable, fixed JSON/configuration bytes, imports/plugins, relative
filenames and fresh sessions. The isolated capture root replaces `gc4` by
`gc5` with identical pathname component lengths and equality relationships.
The existing thirteen collection/request/settings guards remain active from
the first Why3 module through entry to `Gnat_checks.init`. Every case reaches
that endpoint without protected collection, new threads or child processes.
It therefore includes typing, VC construction, session population, shapes and
checksums, and stops before server connection or prover scheduling.

All five allocation snapshots, GC statistics, resource fractions and
remembered-table occupancies equal their earlier retained counterparts.
The complete fixed-context source projection and no-collection argument,
including ordinary allocation/OS contracts, transfer the same arithmetic
operations and operand values. Equal input bytes or small sampled programs
alone would not establish that transfer. This result adds no variable-source
RAM gate and makes no claim for later transformations or solver arithmetic.

The [offline packet](../evidence/retained-producer-prefix-counts-20261018/README.md)
retains the successful managed run `20261018T133533-614e2bd1c3dd`, using one
worker and five serial processes. It took **31.1862 seconds** including
preflight/orchestration; debugger invocations totaled **29.1564 seconds**.
It ran once to answer the newly identified count question. The earlier
allocation evidence and stopped diagnostics remain unchanged. No full native
audit, Lean build or test suite was run.

The checker sets `semantic_free_variable_multiplicity_bound_established` true
for this selected context. Complete-prefix and whole-pipeline flags remain
false: the three-site result must still be composed with the complete relevant
operation inventory and other process components. In particular, this is not
a claim that every integer operation in Why3 has a fresh-allocation witness.
