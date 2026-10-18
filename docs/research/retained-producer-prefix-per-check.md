# Fixed Why3 prefix and Per_Check configuration join

2026-10-18, Linux x86_64, research for
[#119](https://github.com/berkeleynerd/silver/issues/119).
This extends the [complete selected prefix](retained-producer-prefix-composition.md)
to the **same fresh Per_Check/no-step-parser configuration** used by the fixed
task and response transfer. The original progressive-proof evidence remains a
separate result. No installed driver, production option, Oracle rule or source
pin changes.

The [offline packet](../evidence/retained-producer-prefix-per-check-20261018/README.md)
retains a new five-case guarded capture and the failed configuration attempt
that preceded it. The endpoint remains entry to `Gnat_checks.init`, before its
body: driver loading, typing, VC construction, `Controller_itp.add_file` and
initial session construction are included; server connection, goal scheduling,
prover transformations, solvers and final response serialization are later.

## The two joins require a new launch

The old prefix uses `--proof progressive`; the
[fixed task bounds](retained-producer-fixed-paths.md) and
[response schema](retained-producer-response.md) require fresh `--proof per_check`.
The old prefix also loads the installed step-parsing drivers; the proposed
response fix suppresses step parsing through private driver files.

These are material initialization differences. `gnat_checks.ml:283–323` builds
the strategy and next-transformation table before the endpoint. Per_Check has
only `split_goal_wp_conj`; progressive mode additionally contains the disjunctive
splitter. Driver changes affect parsing, regular-expression compilation,
filenames and fresh identifiers. Even fewer parser directives or list elements
can alter sharing, tags and memoization. This record makes no allocation
domination or unchanged-count assumption between those configurations.

The new launch preserves the exact five native JSON inputs, executable and
plugin identities, `--steps 0 --timeout 0 --counterexample off`, three selected
provers, environment and `OCAMLRUNPARAM=s=256M,h=16M,M=1000`. It changes the proof
mode to `per_check` and adds `--why3-conf <private-overlay>/why3.conf`. Each case
has a new private directory with no saved session. The unused local `why3.conf`
copy is preserved for identity correspondence; the supplied extra configuration
is the explicit private path, and the installed base configuration is still
read as `gnat_config.ml:350–383` specifies.

## Correct the private import ambiguity

The first new attempt (`gc6`) exposed an error in the earlier proposed overlay's
resolution argument. `driver_lexer.mll:126–133` supplies both the importing
directory and installed driver directory to `Sysutil.resolve_from_paths`.
`sysutil.ml:261–270` filters all existing candidates and accepts **exactly one**;
it does not choose the first existing path. Both directories contained
`cvc5.gen`, so Why3 reported `AmbiguousResolve` before typing. The failed capture
is retained; it supplies no prefix completion or capacity result.

The corrected `gc7` overlay makes exactly these changes to that proposal:

- Rename the private `cvc5.gen` to `silver_cvc5_no_steps.gen`.
- Replace the single `import "cvc5.gen"` in private `cvc5_gnatprove.drv` with
  `import "silver_cvc5_no_steps.gen"`.

All six step directives remain deleted, and every transformation, printer,
answer classifier, prelude and other driver element is unchanged. Importing the
uniquely named file supplies exactly the previously proposed token content;
the name change affects source locations and initialization allocations, which
the new capture measures. Top-level driver selection is a different resolver:
`gnat_util.ml:63–106` tests the extra-configuration directory before its installed
fallback. Thus the three private top-level filenames continue to select the
intended drivers without redefining built-in provers in the extra config.

The runner derives the selected 14-file import graph and requires exactly one
existing candidate for each import before and after execution. Its new
read-only observer stops just after `open64` in `caml_sys_open`, at offset 208.
The retained disassembly shows the pathname in `rbp`, descriptor result in
`eax`, and original flags in `ebx`. Successful reads record their resolved
`/proc/<pid>/fd/<fd>` path and byte identity. Every successful regular-file read
must be pinned. Completion additionally requires the private config, all four
private driver files, and the complete selected driver closure to have opened.
The observer checks its instruction bytes, calls no inferior function and
writes no inferior data.

`Controller_itp.load_drivers` initializes all configured provers, including
unselected ones (`controller_itp.ml:114–123`). Therefore an installed driver
with step directives may also be opened for another prover. That does not
change the selected cvc5, z3 and altergo driver records. The claim is absence
of step regexps in those selected records, not in every loaded driver object.

## Transfer the complete prefix argument

The [original complete operation partition](retained-producer-prefix-composition.md#reachable-arithmetic-partition)
and its relevant-source-behavior and external runtime/library contracts remain
the premises. The new evidence independently re-establishes their numeric and
dispatch conditions under the corrected launch:

- The same 13 collection/request/settings guards protect the interval from the
  first Why3 module to the endpoint; no guard or new-thread event occurs.
  Allocation and table snapshots recompute the maximum protected allocation
  `W` and startup/static overcount `B` for this configuration.
- The same three complete semantic-count observers record every count addition
  and multiplication. Their mathematical replay replaces the old operand
  totals; it does not assume their equality.
- The native JSON files and their eleven-file import context are unchanged.
  The old 165-file configured text set plus five private files has no `infer`
  or source-location escape marker. Its line and column bounds still apply.
  Executable and plugin identities join to the prior static-image account.
- Per_Check builds a shorter fixed strategy list/table during module
  initialization; it does not apply a transformation there. The private
  drivers preserve all transformation names. Normalization, generic term
  printing, invariant inference, the server and final timing-counter update
  remain beyond the same endpoint or unselected. The new config adds no plugin,
  debug flag, saved session or selected inference attribute.

The recomputed maximum is **`W = 86,627,697` words**, with startup/static
overcount **`B = 88,823,660` words**. The three semantic observers record
**146,259 operations**, whose maximum mathematical result is **47**. Although
these count totals equal the old capture, equality is an observed result, not
the transfer premise. The five serial debugger processes took 28.325 seconds;
the managed successful run took 30.691 seconds. One earlier configuration
attempt failed before typing, as described above; no solver was executed.

With these joins, all identity, physical-container, rank, location, byte-offset
and semantic-count inequalities in the original argument use the new `W`, `B`
and observed count maximum. The packet records the exact recomputed values.
The resulting complete-prefix capacity claim remains conditional on the
documented source/runtime contracts. The checker does not mechanically prove
the source reachability partition or bound all foreign bytes and resident RAM.

## What now composes with the fixed tail

The checker joins each prefix input digest directly to the source-derived task
and record bounds. Under the existing fresh all-proved Per_Check response
premises, the common configuration now supports this single table:

| Fixed input | Terminal tasks `G` | Records `R` | Real attempts `N <= 3G` |
| --- | ---: | ---: | ---: |
| Input_Is_Valid | 1 | 1 | 3 |
| Is_Message | 3 | 1 | 9 |
| First_Or_Default | 1203 | 9 | 3609 |
| Put | 629 | 18 | 1887 |
| Put_Line | 1145 | 22 | 3435 |
| Sum over separate processes | 2981 | 51 | 8943 |

The response has `A <= 4G` reported attempt entries, `S <= 5R` statistic entries,
and container depth at most seven. The
[diagnostic-string transfer](retained-producer-diagnostic-strings.md) then gives

```text
sum B_raw <= 38,739,343 + 3111 O + 3 sum W_o + 6 sum L_o.
```

Here `O` is the total captured solver-output bytes; `W_o` and `L_o` are the
remaining warning count and byte sum. This is a common-input conditional
composition of the completed prefix and existing tail shape/byte transfer.
The capture ends before executing that tail. No scalar bound on `O`, transformed
formula sizes, solver internals, later lifetime allocations or final `.spark`
representations follows from task cardinality. Those obligations remain open.

Without a selected `StepRegexp`, the source reports `pr_steps=-1`, and existing
normalization produces `1`. That value means unavailable step statistics; it
does not mean one measured solver step. Keeping `--steps=0` preserves the
existing guard that makes step-based result classification inactive. A fresh
session excludes prior parsed counts. The response timing/duration conversions
retain their explicit environmental premise.

This closes the proof-mode and actual-driver configuration mismatches. It
establishes neither literal-output whole-pipeline capacity nor production
adoption of the private configuration.
