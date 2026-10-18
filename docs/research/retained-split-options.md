# Native split-wide option join

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
This joins the stock `-fsplit-wide-types` selector used by the
[literal-output RTL argument](retained-output-rtl.md) to the preceding native
components. It retains the selected Linux x86-64, generic tuning, O0, no-debug,
SysV, small-PIC and ordinary PLT configuration. It is a proposed native
invocation change; no production command or membership rule changes here.
The [offline packet](../evidence/retained-split-options-20261018/README.md)
retains sources, predecessor records, lexical inventory and arithmetic.
Source citations count literal LF. No native tool was executed.

## Semantic prefix and option storage

The option's `common.opt:3025–3030` record has `Common`, a single integer Var
and `Optimization`. It has no joined operand, alias, EnabledBy or implied
option. The ordinary option handler sets that variable and its explicit-set
bit (`opts-common.cc:1299–1331,1662–1701`). The common handler has no special
case for it (`opts.cc:3496–3504`). The O1 default table entry at `opts.cc:606`
does not raise the selected optimization level; an explicitly selected flag
is not an `-O1` request. The separate early-splitting flag remains zero.

A hash-verified search of the existing 4,929-file GCC C/C++/header/definition/
option/MD corpus finds fourteen mentions of the exact flag/option spellings.
They are its two option declarations, one default entry, the three gates in
`lower-subreg.cc`, and six lines in unselected target files. None is an Ada,
gigi, GIMPLE, SSA or `pass_expand` semantic consumer. The first selected
consumer is `pass_lower_subreg`, after expansion and virtual instantiation
(`passes.def:460–468`). The second gate additionally requires the early flag;
the last gate uses the ordinary flag. The RTL packet supplies the changed
first-pass behavior and the last pass's empty mode scan.

This lexical inventory alone is not a call-graph proof. The option machinery
also copies, saves and hashes whole option structures. Their fields and fixed
object sizes remain the same. In the selected Main descriptor there are no
per-function optimization/target attributes. Both the initial optimization
snapshot (`toplev.cc:1772–1775`) and gigi's later snapshot
(`ada/gcc-interface/trans.cc:674–682`) carry the same changed bit and its
explicit-set bit. Equality between these snapshots is preserved: all other
fields and changes remain the same. `build_optimization_node` interns using
whole-option equality and allocates only on a new distinct value
(`tree.cc:12226–12269`). The bit can change hash buckets, not the number or
size of distinct snapshots. No frontend semantic consumer is added by that
storage route. This retains the earlier frontend, gigi, GIMPLE/SSA and
`pass_expand` shape transfers, with the additional option-storage requests
below. It does not re-label an old native execution as a split-option run.

The saved explicit optimization-options vector does change: this option
adds one element (`toplev.cc:2335–2340`). The existing indexed process-shell
allowance of 48 records, 4,616 bytes including its eight-byte prefix, still
covers at most 25 pushes. The exact unindexed command otherwise has no
explicit Optimization option, so its new one-element vector uses the initial
four-record backing, 392 bytes. These are ordinary allocations, not extra
GGC tree identities.

`gnat_init_options` includes the option in its reconstructed argv
(`ada/gcc-interface/misc.cc:210–242`). `Is_Front_End_Switch` and
`Is_Internal_GCC_Switch` both reject this spelling (`ada/switch.adb:143–169`),
and `Scan_Common_Back_End_Switch` returns False without changing Ada flags
(`ada/backend_utils.adb:36–108`). `Scan_Back_End_Switches` therefore stores
it once (`ada/back_end.adb:265–289`). `Store_Compilation_Switch` adds one
table entry and one 18-character Ada String (`ada/lib.adb:1173–1190`). Its
initial 30 slots remain sufficient (`ada/lib.ads:954–960`). The argument-copy
loop also copies those 18 characters once; C argv/string copies need 19
bytes including NUL. Character payload, pointer-array backing and String
bounds descriptors are separate objects.

## Two existing invocation interfaces

The earlier exact standalone driver and the more conservative indexed
frontend interface are different components. Adding one option preserves
that distinction.

For the [exact standalone driver](retained-native-driver.md), append the
option to the thirteen-position input class. The Ada specs forward it through
`%{g*&m*&f*}` (`ada/gcc-interface/lang-specs.h:35–52`). It creates no new
input, specs function, assembler flag, response file, target default, search
path or subprocess. In particular `fsplit-wide-types` is not the distinct
`fsplit-stack` spelling used by some linker specs.

| Driver dimension | Before | With the option |
| --- | ---: | ---: |
| Input argv positions, including executable | 13 | 14 |
| Initial 96-byte decoded-option records | 1,248 bytes | 1,344 bytes |
| Retained switches after two target defaults | 11 | 12 |
| Switch / input-array capacities | 16 / 16 | 16 / 16 |
| Frontend argv positions | 19 | 20 |
| Transient pipe marker or terminating null included | 20 | 21 |
| Argument-vector capacity / bytes | 20 / 168 | 30 / 248 |
| Multilib retained-match backing | 288 bytes | 312 bytes |
| Assembler argv positions / executions | 5 / 2 | 5 / 2 |

The argument vector grows 10→20→30; above sixteen slots GCC grows by 3/2,
not by doubling (`vec.cc:150–169`). The multilib request is
`(1+n_switches)*24`; the new option matches no configured multilib selector.
The other driver path, relocation, fixed-spec, function-context and process
objects retain their previously derived bounds. The exact
COLLECT_GCC_OPTIONS value gains 21 bytes: one separator, two quote characters
and the 18-byte option (`gcc.cc:5640–5715`). Its final NUL was already charged.
The earlier conservative 21-field environment envelope remains sufficient
because the actual retained switch count is now twelve. Its largest fixed
argument remains the 24-character warning option; the existing path/quote
conditions are unchanged.

For the current **indexed** process shell, use its existing 24-position
allowance, now 25. This is an envelope, not a recorded exact invocation.
The resulting individual requests are:

| Indexed frontend object | With the option |
| --- | ---: |
| Original argv pointers, including sentinel | 208 bytes |
| Initial/pruned decoded arrays, each | 2,400 bytes |
| Reconstructed GNAT C argv, including sentinel | 408 bytes |
| Ada argument pointers, at most 49 entries | 784 bytes |
| Saved Optimization-vector backing | 4,616 bytes |

The Ada pointer element is the selected 16-byte unconstrained-String pointer;
C pointers are eight bytes. The `max(24,P+8)` maximum argument spelling and
all process-shell path inequalities stay unchanged. Diagnostic options,
file-cache defaults, frontend search choices and the successful cleanup path
are unaffected by this flag.

## ALI, binder and output headers

`lib-writ.adb:1212–1217` writes exactly one extra line:

```text
A -fsplit-wide-types
```

It is 20 bytes before LF and 21 with LF. Therefore every previous complete
native Main ALI bound receives **+21 bytes**, every A-record count receives
+1, and the maximum A-record length remains the warning record's 26 bytes
before LF. The unindexed combined descriptor changes eight A records to nine
and 108 bytes to 129; the indexed descriptor changes nine records to ten.
For the null binder's 378-byte complete-ALI envelope this gives 399 bytes, or
400 including its reader's EOF byte. These are deltas to the matching
predecessor class, not new bounds on all nonnull ALIs.

No other native ALI field changes because the added switch changes no Ada
flag or source-token checksum. The source/dependency/unit/invocation data,
restrictions and binder-generated Ada source read projection are preserved.
GPRbuild's DW/W scans ignore A lines, so their table populations are unchanged
while their raw buffers gain 21. Gprbind's A scan gains one argument String:
its null-case ten strings total 110 payload bytes, still at most 24 each; its
initial 1,000-entry Args backing still suffices. Its version/unit/name,
with/dependency and source-file table populations are unchanged.

**The flag propagates into binder compilation.** Gprbind removes `-gnat*`,
`-I*` and `--RTS=*` arguments, then appends the remaining options to its compiler
vector (`gprbind.adb:865–943`). It therefore forwards this one. The former
binder-object execution is not an execution under the changed option, and
its default RTL/object identities cannot be silently reused. A selected-option
fixed binder compile/object reconciliation, or an explicit separately justified
binder-command descriptor, is still required. The generated binder Ada code
and its path/location transfer remain usable inputs to that check.

No additional command-line header is emitted in native assembly: the selected
`flag_record_gcc_switches` and `flag_verbose_asm` remain zero, so the two
option-string output branches at `toplev.cc:731–756` stay inactive. `.file`,
version `.ident`, function symbol names and ELF target flags retain their
existing derivations; changed machine text is covered by the RTL packet.
The compiler option adds no linker command argument by itself in the selected
compile-only driver, and it is not a source-level linker pragma.

GNATprove remains a separate invocation descriptor. This native-only selector
must not be added to a shared project switch list and then presumed absent
from the producer. The proposed launcher must realize the native/producer
separation already required by `-gnatx` and the warning option. This packet
performs no producer option change and claims no new producer witness.

## Composition status

The source-prefix and stated driver/frontend/ALI deltas are closed within
their predecessor premises. The exact split-option native witness and binder
object/configuration reconciliation, complete native lifetime/storage joins,
assembler/link closure and producer conjunction remain open. No whole-capacity
or production-admission result follows from this component.
