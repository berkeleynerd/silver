# Selected native driver option and argument containers

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
This joins the [native environment and path descriptor](retained-native-environment.md)
to GCC's option and command containers. It uses the existing driver-only query
and [pre-Main witness](retained-native-expansion.md#executed-null-class-gcc-setup-witness);
no compiler was rerun. The [offline bundle](../evidence/retained-native-driver-20261018/README.md)
pins the additional sources and checks the arithmetic against both retained
argument observations. The source/tool correspondence premise remains necessary.

## One concrete command class

The descriptor invokes the installed C GCC driver, with exactly these thirteen
argv positions, including the executable:

```text
gcc -c -x ada -gnatA -gnat2022 -gnata -gnato -gnatx
    -Wno-free-nonheap-object -gnatec=CONFIG -gnatem=MAP SOURCE
```

SOURCE is an absolute filename ending in `main.adb`; CONFIG and MAP are the
priced naming-only configuration and one-unit map. All path spellings remain
subject to the earlier descriptor. There is no inherited option or response
file: none of these arguments begins with `@`. The C driver's language hook
only adds `-shared-libgcc` for `.m` or `.mi` inputs, so it adds nothing here
(`c/gccspec.cc:28–107`). This result is not a bound for GPR's own argv, binder
compilation, the link driver, or GNATprove's different native invocations.

The installed ELF's retained configure string has no `--with-specs` or
explicit CPU/architecture/tune/TLS default. `configure.ac:1080–1086` therefore
selects empty CONFIGURE_SPECS. For x86_64-pc-linux-gnu, `config.gcc:4109–4126,
4226–4227` selects generic CPU and x86-64 architecture. The ten
OPTION_DEFAULT_SPECS templates insert at most one tune/CPU, one architecture
and one TLS switch: each first insertion suppresses the remaining alternatives
(`i386.h:660–671`). Here there is no TLS default, so exactly `-mtune=generic`
and `-march=x86-64` are added. This agrees with both retained child argv lists.
The recorded configuration string corroborates this source specialization;
it does not independently prove complete source/binary equivalence.

The six driver self-spec entries contribute no switch. The target and configure
entries are empty; no dump-final, OpenMP, OpenACC, transaction or multiflags
option is selected (`gcc.cc:1370–1394`). GOMP's `gt` helper still runs with its
single argument `1` and returns null; it must not be excluded merely because
OpenMP is disabled (`:11121–11142`). Likewise the later assembler debug helper
runs because `gnat*` matches `g*`; debug-level-gt(0) returns null, so the dwarf
helpers are not reached. The installed dumpspecs retains the exact selected
named specs and the empty self/sysroot/startfile-prefix specs.

## Option and argv requests

Decoding initially requests argc records. The sole expanding decoder branch,
diagnostics-plain-output, is absent; pruning does not increase their number
(`opts-common.cc:1030–1127`). LP64 gives 96 bytes per cl_decoded_option from
its declared fields (`opts.h:252–294`). The original request is at most
**13 × 96 = 1,248 bytes**. Each of the two default insertions decodes one
option with one dummy program name, requesting 192 bytes plus a 16-byte
temporary pointer vector (`gcc.cc:5968–6031`). Their templates contain one
VALUE substitution. The chosen six/seven-byte defaults make the resulting
template shorter; size_t subtraction wraps as defined unsigned arithmetic,
and the complete positive allocation size equals the mathematical substituted
length plus NUL. No input-derived repetition enters this substitution.

The driver retains nine original switches: `-x ada` selects the language
without being saved, and SOURCE is the sole infile. Two defaults bring the
switch count to **11**. All selected switches have a joined or absent operand,
so save_switch allocates no separate operand array. Both switch and infile
arrays start at sixteen records; the sentinel requests still fit, and their
doubling branches are not reached (`gcc.cc:3851–3915,5630–5634,6030–6031`).
switchstr is 24 bytes on this ABI, infile 32: their requests are **384 and
512 bytes**. The output-filename pointer array has one 8-byte entry and the
explicit-link-file array one byte (`:9014–9020`).

The selected Ada spec has this output decomposition:

| Frontend contribution | Positions |
| --- | ---: |
| gnat1 and -quiet | 2 |
| selected warning option | 1 |
| -dumpbase/value and -dumpbase-ext/value | 4 |
| seven gnat options | 7 |
| tune and architecture | 2 |
| source filename | 1 |
| -o and temporary assembly filename | 2 |
| Total | 19 |

There is no explicit output/dump directory, extension override, compare-debug,
optimization, library-search, plugin, wrapper, pipe or response-file option.
The `%1` cc1 branch selects cc1_cpu, whose native-detection conditions are false.
invoke_as appends a pipe marker and newline. Without `-pipe`, the newline
removes the marker before execution, then clears the vector. The assembler
has five positions: `as --64 -o main.o TEMP.s`. The final link spec's `!c`
condition is false; no link command or linker-spec include executes.

argbuf therefore needs at most **20 pointers**, counting either the transient
pipe marker or execution's terminating null. vec::create reserves ten entries;
the first growth doubles to twenty (`vec.cc:150–169`). LP64's 8-byte vector
prefix gives one largest **168-byte** backing object. The earlier 21-position
frontend allowance is a looser sufficient bound, still valid. Each spec-function
context needs at most one argument, so its separately initialized vectors stay
at ten entries, 88 bytes apiece. The selected specs have no `@` argument group.
execute has one two-pointer command record per invocation, **16 bytes**;
there are exactly two execution-count increments on the successful route.
These are bounds on individual objects and actual counters, not a sum of RAM.

## Spec parsing and strings

The selected named-spec graph is acyclic: Ada uses cc1 → cc1_cpu, and
invoke_as → asm_options → asm_debug_option and asm. asm_final's split-dwarf
branch and link_command's linking branch are not selected. Three spec functions
are reached: GOMP gt, Ada dumps, and assembler debug-level-gt. None calls
another spec function. Their argument strings and function names come from
fixed specs; dynamic dump output is already escaped. Source paths supplied by
`%i`, generated temporary names and options supplied by give_switch are copied
as data, not reparsed as specs (`gcc.cc:6160–6182,6579–6585,7681–7723`).

The earlier signed-int quote/dump bound, `6P+37 <= INT_MAX`, covers dump output
and its NUL. Complete source/config/map arguments need at most `P+8` characters,
including the leading `-` of `-gnatec=`/`-gnatem=`. These strings and the fixed
spec fragments need their NUL and save_string's signed len+1 headroom. The
retained named-spec maximum is 2,901 characters; the Ada source template is
smaller. Thus a sufficient local string condition is
`max(2902, P+9, 6P+37) <= INT_MAX`, together with the earlier per-object
obstack/path conditions. Spec-function processing saves an unfinished obstack
object size into int; that object is no larger than a selected argument, so
this condition also covers that narrowing. There is no source-text-length
multiplier in this driver command class.

The generic environment envelope now explicitly charges four bytes per quoted
switch field for a separator, two quotes and its leading hyphen. This raises
its conservative example from 20,221 to **20,242 bytes**, and the joined
obstack request from 22,863 to **22,887 bytes**. The actual eleven-switch route
is smaller than either envelope; the correction makes the stated 21-field
calculation self-contained. The seven initial entries remain independent.

Independent source review of this component at `456db16b4a`, including the
earlier quote/dump arithmetic, found no material correction. It corrected
the C-hook citation above. Later relocation/multilib/process additions below
are outside that frozen review.

## Relocation, multilib and common process storage

The relocation helper has its own signed-int boundary. Let P bound each
complete raw/resolved executable, compiled-in bin prefix and target prefix
used at that call. With an absolute executable, its PATH-search branch is
skipped. Each split path has at most P directory components; its pointer
array requests at most `8*(P+2)` bytes and each copied component at most P+1.
The returned relative prefix contains at most P executable-directory bytes,
three bytes per removed bin-prefix component, P target-prefix bytes and NUL.
Thus **`5P+1 <= INT_MAX`** suffices for its signed needed_len accumulator,
directory counts including num_dirs+2, and component save_string's len+1.
The individual pointer request must also fit PTRDIFF_MAX. At P=222 these
requests are at most **1,792 / 223 / 1,111 bytes**, respectively
(`libiberty/make-relative-prefix.c:118–199,231–402`). Canonical-path production
is still an external/configuration input to P; this argument does not bound
arbitrary symlink expansion by the raw spelling alone.

Multilib handling consumes only the configured strings, not source contents.
The retained selected strings have lengths 84 (selection), 16 (matches),
3 (defaults), 7 (options), and zero (exclusions/reuse/extra). Building their
obstack strings makes no partial object longer than 85 bytes including NUL
(`gcc.cc:8438–8488`). There is one default `m64` and two match pairs. Hence
mdswitches requests one 16-byte record, its copied default four bytes, the
temporary match array two 24-byte records, and the retained match array
`(1+11)*24 = 288` bytes (`:9603–9759,9909–9949`). No original switch is m32
or m64, so only the default contributes a retained match. Recursive used_arg
calls encounter the already allocated array and cannot re-enter initialization.
All remaining scans are through the fixed strings with int/unsigned lengths
at most 84.

The selected directory remains null, with `../lib64` and `x86_64-linux-gnu`
copies of nine and seventeen bytes. The x86 common target uses the default
compute_multilib hook, which returns its input unchanged; no second directory
search is needed (`gcc.cc:10089–10171`, `common/common-target.def`,
`common/common-targhooks.cc:96–108`, `common/config/i386/i386-common.cc`).
This recovers the earlier six/nineteen candidate descriptor without treating
an observed search list as a general result for every installation.

Each execute call creates a fresh pex object and passes one command with
PEX_LAST, no output/error filename and no timing request. Therefore the common
PEX layer uses stdin/stdout/stderr, creates no pipeline temporary file or
remove-list entry, and records one child. Its signed count and number_waited
stay at most one; its two separate PID/status arrays each request four bytes
on Linux. pex_obj is 144 bytes on LP64 and the driver's local status array
four bytes (`libiberty/pex-common.h:54–95`, `pex-common.c:53–80,182–350,
518–540`; `gcc.cc:3438–3488`). The two commands have independent objects, so
their counts do not accumulate in a shared backing array. The Unix exec/wait
backend and libc/OS launch machinery retain their own platform assumptions;
this is the common PEX storage bound, not a new claim about those dependencies.

## Remaining joins

This closes selected option counts, argument-vector growth, the named-spec
dispatch, relocation arithmetic, selected multilib arrays and common PEX
storage above. It does not price every canonicalization, platform process-spawn
or diagnostic object. Those remaining objects,
production launcher realization, frontend/backend consumers, assembler,
binder and linker still need composition. In particular no whole-program
capacity predicate or enlarged admission follows from this component.
