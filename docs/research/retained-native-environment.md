# Effective environment for the selected native invocation

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This resolves concrete search/default inputs for the proposed native Main
launch class. The [capacity contract](retained-tool-capacity.md) remains
unfinished; the verified launcher and production option changes are unimplemented.

## Construct the child environment explicitly

The native Main launcher should construct exactly these seven entries after
Alire selects the installation, instead of copying its inherited environment:

| Entry | Declared value |
| --- | --- |
| `PATH` | Selected native `bin`, `/usr/bin`, `/bin`, in that order |
| `LC_ALL`, `LANG` | `C` |
| `TERM` | `dumb` |
| `TMPDIR` | The controlled writable temporary directory |
| `ADA_INCLUDE_PATH` | The selected native `adainclude` directory alone |
| `ADA_OBJECTS_PATH` | The selected native `adalib` directory alone |

The exact values, their lengths, directory resolution and the fixed GCC path
are configuration inputs. In this descriptor each path-list element is an
absolute path without a colon. A configuration mismatch is an infrastructure
failure, not a language-membership rejection. This is the environment **at the
GCC launch boundary**: GCC subsequently creates environment strings itself.
It is not a proposal to erase the program's runtime arguments/environment or
to use the same descriptor for GPR, binding, linking or GNATprove.

This excludes the four inherited Ada path variables except the two assigned
values, plus `GNSA_ROOT`, GCC search/compare-debug overrides, diagnostics/debug
variables and alternative temporary-directory values. One previously implicit
dependency needs explicit attention: `Osint.Update_Path` calls C `update_path`
with key `GCC` (`osint.adb:3228–3249`); `prefix.cc:94–112,185–231,248–274`
therefore consults **`GCC_ROOT`**. The GCC driver's `BINUTILS` keyed prefixes
can similarly consult **`BINUTILS_ROOT`**. Merely clearing `GCC_EXEC_PREFIX`
and `GNSA_ROOT` does not exclude these replacements. The seven-entry
environment excludes both and makes the keyed-prefix fallback use the
selected relocated prefix. This also prevents recursive `@`/`$` substitutions
from environment values. The relevant source files are retained in the
[evidence bundle](../evidence/retained-native-environment-20261018/README.md).

`Osint.Add_Default_Search_Dirs` reads the two project path-file variables,
the two Ada path lists, optional runtime selectors and default search files
(`osint.adb:462–565`). The selected Main command has no path-file/runtime
selector; each explicit Ada path list contributes one directory. Linux's
registry helper returns an empty string (`adaint.c:1653–1710`). Each missing
default search file contributes its one fallback directory. Thus this part
of initialization makes at most two source-directory additions and at most
two library-directory additions. Library entries are deduplicated after
normalization; source entries are not (`osint.adb:592–657`). The primary
directory and other invocation bookkeeping remain in the existing 6/4 table
allowances. This result does not erase their temporary normalized strings.

## Installed defaults and implicit specs

The three installed `gnat1` Sdefault wrappers pass constant Ada Strings to
`Osint.Relocate_Path`. Static ELF/disassembly inspection retained their data
addresses, bounds, exact bytes and executable digest. Applying the inspected
relocation rule (`osint.adb:954–1012,2833–2885`) to the selected absolute
executable gives, relative to the selected tool root:

```text
search prefix: lib/gcc/x86_64-pc-linux-gnu/16.1.0/
source fallback: lib/gcc/x86_64-pc-linux-gnu/16.1.0/adainclude/
object fallback: lib/gcc/x86_64-pc-linux-gnu/16.1.0/adalib/
```

Neither `ada_source_path` nor `ada_object_path` exists under that search
prefix in the retained installation. Under the explicit environment, the
second keyed relocation preserves these paths. The pre-launch configuration
check must establish those absences again, or select a descriptor that prices
the actual files. This excludes the default reader's `B+1` and
`B+1+r*prefix_length` data-file allocations; its probe-name strings remain.
Static extraction of these three constants does not establish the binary's
complete correspondence to the inspected GCC source.

GCC has an additional implicit-input route even without `-specs=`:
`driver::set_up_specs` searches for `specs` and separately checks a target
override path (`gcc.cc:8522–8545`). The selected installation must retain
built-in specs and no readable override at either route. No inherited `-B`,
specs, plugin, runtime/target, debug or optimization option belongs to the
[selected command class](retained-native-expansion.md#combined-native-option-descriptor).
The compiler launcher must check its actual argument vector and generated
configuration/map files before forwarding that class. The present driver-only
probe corroborates built-in specs for this installation; it does not implement
that check or prove the transitive GCC specs interpreter's capacity.

### Exact initial specs candidates for this descriptor

The initial search is smaller than the final library search. At that point
`process_command` has inserted two startfile-prefix records: the relocated
`lib/gcc/` prefix and the target's `lib/` prefix. Inherited search variables,
`-B` and a sysroot override are absent. Relocation succeeds, so the
unrelocated-prefix fallback is not selected
(`gcc.cc:4844–4909,4911–5008,5535–5588`). `set_multilib_dir` runs only at the
end of `set_up_specs`, after both implicit specs reads (`:8733–8735`). Its
multilib and multiarch pointers are still null during the first search.

Write `E` for the driver's raw relocated `lib/gcc/` prefix, `H` for
`x86_64-pc-linux-gnu/`, `V` for `16.1.0/`, and
`D = E + H + V + "../../../../" + H`. Under the selected prefix descriptor,
the four first-search filenames and separate override are:

```text
E + H + V + "specs"
E + "specs"
D + "lib/" + H + V + "specs"
D + "lib/specs"
E + H + "specs"                 (separate override)
```

Both prefix records have `require_machine_suffix=0`, so `for_each_path`
visits the versioned path and base path once each (`:2820–2978`). The fifth
path uses `just_machine_suffix` because this is not an accelerator compiler.
There is no explicit user-specs record. Excluding readable files at these
five paths therefore closes the **two initial implicit specs readers** for
this selected descriptor. It does not establish that arbitrary built-in spec
functions cannot read other inputs, nor cover another invocation class.

The retained [metadata-only observation](../evidence/retained-native-environment-20261018/path-configuration.json)
finds all five paths absent, using `lstat` and `access`, with no GCC or child
process. The observation describes that installation at its recorded time.
Production must establish the same selected configuration before launch under
the existing stable-workspace premise; the research checker is not that
implementation. Unexpected specs require a different justified descriptor or
a configuration-failure report.

The post-spec path enumeration can also be reconstructed exactly from those
prefixes. It has two program-prefix records and five library-prefix records;
four library records use the OS-multilib suffix. The selected suffixes are
`H+V`, `x86_64-linux-gnu/`, and `../lib64/`, with no nontrivial `multilib_dir`.
Each program prefix produces three candidates. The library enumeration
produces three per prefix, then the four unmodified OS-prefix candidates:
**6 program and 19 library candidates**. This reconstructs every retained
`-print-search-dirs` spelling, in order. It supports the configuration-specific
counts used below; they are not estimated from which directories exist.

### Individual path and temporary-name arithmetic

`add_prefix` stores the prefix length in signed `int`; `find_a_file` stores
the basename and executable-suffix lengths in signed `int`
(`gcc.cc:3059–3103,3161–3189`). On this Linux path the executable suffix is
empty. Let `M` bound each prefix length, `S` the longest suffix produced by
the selected iteration, and `N` each probe basename. Before any narrowing,
require `M <= INT_MAX` and `N <= INT_MAX`. The individual search-buffer
request is exactly bounded by

```text
K = M + S + N + 1 <= PTRDIFF_MAX.
```

The expression in `for_each_path` uses `size_t` arithmetic. Each callback
writes a prefix, one suffix, the basename and NUL into that same buffer.
The selected suffixes only shorten on the second pass. Prefix records are
linked objects, without a growing aggregate byte-offset field. This check
does not sum unrelated allocations or limit their aggregate address span.
The separate specs override allocates its own
`len(E) + len(H) + 6` bytes. The configured descriptor gives `M=190`, `S=27`,
`N=5`: **223 bytes** for the path buffer and **153 bytes** for the override.
The longest priced non-NUL spelling remains 222 characters.

For temporary assembly names, let `T` bound the selected temporary-directory
base before the separator that `choose_tmpdir` always appends. This includes
an existing trailing separator if present; do not normalize it away in the
arithmetic. `choose_tmpdir` narrows `strlen(base)` to `unsigned int` and
allocates `T+2`, so require `T <= UINT_MAX-2`. For the selected default `cc`
prefix, six random characters and `.s` suffix, `make_temp_file_with_prefix`
allocates **`T+12` bytes** including NUL. Its individual lengths and GCC's
stored complete filename length narrow to signed `int`; the sufficient
condition is `T+11 <= INT_MAX`, together with `T+12 <= PTRDIFF_MAX`
(`make-temp-file.c:116–174,197–250`; `gcc.cc:6547–6551`). This accounts for
the real local counters and individual object, not a bound on the number
of independent temporary files.

The concrete selected `TMPDIR` has 52 bytes. Under the Linux descriptor whose
`P_tmpdir` is `/tmp`, the source fallbacks `/var/tmp`, `/tmp` and `.` are
shorter; `TMP` and `TEMP` are absent from the exact environment. Consequently
the two individual requests are **54 and 64 bytes**. A descriptor for a
different configured fallback must price it explicitly. These lengths hold
even if the temporary-directory choice falls back; they do not promise that
file creation succeeds or that a fallback preserves the operational workspace.
Physical storage/permission failures retain their separate outcomes.

The [offline path checker](../evidence/retained-native-environment-20261018/check-paths.py)
reuses the ten retained complete sources and original driver-only logs. It
reconciles the five-file metadata capture, both path enumerations, and the
individual-object inequalities. No new compiler, assembler, linker or proof
execution is involved. Remaining driver work includes the full selected
spec-interpreter/option-container transfers and other late paths; these local
path and temporary-name results do not complete driver or program capacity.

## Driver-created strings and complete path spellings

Clearing inherited `GCC_EXEC_PREFIX` does not imply that the frontend will see
it absent. GCC derives and sets a relocation prefix from its executable
(`gcc.cc:4844–4905`). It also creates `COLLECT_GCC`, quoted
`COLLECT_GCC_OPTIONS`, and later search-list strings. The latter construction
can occur in `maybe_run_linker` even with `-c`, before the link spec excludes
actual linking (`:2994–3031,5637–5715,8743–8772,9220–9320`). The empty explicit
assembler-option vector returns before creating `COLLECT_AS_OPTIONS`
(`:6125–6147`). Keep driver-created strings in the capacity account.

The current fixed installation's search descriptor contains six program-path
candidates and nineteen library-path candidates, including paths which do
not currently exist. Directory-existence filtering only removes entries from
the emitted environment lists. These are **configuration-specific** counts,
not constants justified for every GCC installation. Bind them to the selected
prefix/spec/target descriptor before using the following local arithmetic.

Let `P >= 26` bound complete raw, normalized and resolved paths, including
all declared probe spellings and temporary names. For this descriptor the
individual `COMPILER_PATH=` and `LIBRARY_PATH=` objects, including terminating
NUL, fit respectively within `14+6*(P+1)` and `14+19*(P+1)` bytes. The existing
command-class derivation supplies at most 21 retained argument fields, each
at most `P+7` characters. Quoting an apostrophe can expand it to four bytes.
Including delimiters, the key/NUL and a separate optional dumpdir pair gives
the sufficient individual-object bound

```text
COLLECT_GCC_OPTIONS bytes <= 20 + 21*(4*(P+7)+3) + 4*P+14.
```

The [individual-obstack transfer](retained-backend-obstacks.md) now bounds the
chunk requests for these strings as well. Other driver objects and cumulative
work retain their separate accounts. `TMPDIR` selection likewise
still creates its separator/NUL copy and the `ccXXXXXX.s` name
(`libiberty/make-temp-file.c:116–174,197–238`); use actual complete spellings
in `P`. If the requested temporary directory becomes unavailable, the source
has fallback directories. Either price those fallbacks or treat loss of the
declared environment as an operational failure; do not silently assume the
temporary name stays in the requested directory.

The retained candidate-path calculation reaches **222 characters** in this
installation, while the selected executable paths are shorter. Consequently
the earlier `P=200` sample calculations remain illustrative component
evaluations; they are not a complete descriptor for this installation.
The launcher must derive the path bound from all applicable raw spellings,
including probes, rather than only from canonical existing filenames. This
222 value is not a universal path limit or an admitted-source restriction.
Uninventoried late paths still need composition.

## Focused evidence and remaining work

Managed run `20261018T063601-938bdebc01d5` made five GCC **driver-only** queries
and three static disassemblies in an isolated workspace in 2.429 seconds.
All returned zero.
No frontend, assembler, linker, prover or Lean process ran. GCC `-###` printed
19 frontend argv positions and five assembler positions, below the selected
21-position frontend allowance. It reported built-in specs; the separate
specs query returned the unresolved basename `specs`. The compiler was not
asked to parse the fixture source/configuration. Its 234-byte configuration
fixture is therefore not a capture of GPR's 244-byte generated configuration.

The exact initial environment contains 567 bytes including keys, separators
and NULs. The printed generated values have lengths 481 (`COMPILER_PATH`),
910 (`LIBRARY_PATH`) and 247 (`COLLECT_GCC_OPTIONS`). At the captured candidate
bound `P=222`, the last local bound is 20,221 bytes. These are retained
configuration observations plus conditional source arithmetic; no RAM sum or
whole-program capacity result follows from them.

The offline checker reconciles 23 retained run/input/log files, ten pinned
complete sources, the exact environment, command shapes and arithmetic.
An independent source review rechecked the environment exclusions, keyed
relocation, installed defaults, both implicit-specs routes and local quoting
arithmetic; it found no material defect under the stated premises.
Before production adoption, complete the verified-SPARK launcher/configuration
realization and remaining driver/spec/late-path allocator joins. GNATprove
needs a separate descriptor: in particular its producer analysis requires
`WHY3DEBUG` empty/absent and `GNATWHY3LOG` absent to preserve the recorded
diagnostic behavior. This native experiment does not validate producer launch,
generated GPR input checking, general backend capacity or automatic discharge.
