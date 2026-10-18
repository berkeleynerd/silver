# Selected-driver answer and warning string transfer

2026-10-18, [#119](https://github.com/berkeleynerd/silver/issues/119), Linux.
This refines the [response byte account](retained-producer-response.md) for
the selected three drivers and fresh Per_Check sessions. It uses retained
source and configuration bytes; no compiler, prover or Why3 process ran.
The [offline checker](../evidence/retained-producer-diagnostic-strings-20261018/check.py)
checks identities, the driver frontier and the displayed arithmetic.

Let `O` be the sum of captured solver-output bytes over the normal attempts
in a backend process, and `N` their number. Interrupted calls with no output
can be included with zero bytes. `A` remains the number of reported attempt
entries, including Trivial. The selected scheduling path gives

```text
N <= 3G,  A <= 4G
L_A <= 4O + 64A.
```

This is a concrete transfer to the solver-output domain. It is **not** an
absolute bound on O, or a claim that aggregate available RAM can determine
language membership. Output collection and solver representations remain
essential earlier capacity obligations.

## Answer strings

The complete selected driver/import union has four Unknown replacement rules:
the common `unknown|sat|Fail` capture; the common reason-unknown capture;
CVC5's fixed `(not unknown!)` replacement; and Alt-Ergo's empty replacement.
Every selected answer regexp consumes at least one input byte. Each replacement
copies a substring of that match or is no longer than the match it replaces.
There is no selected Failure regexp or answer-valued exit-code directive.
Valid, Invalid, timeout, memory and step-limit answers have fixed formatting.

`call_provers.ml:230–248` splits output into nonoverlapping regexp matches
and intervening model text. For output length `o`, the number of answer
segments is at most `o`; the optional signal/exit result adds at most one.
`grep` copies only the selected replacement (`:206–214`). Adjacent Unknown
answers may concatenate their strings with `" + "` (`:280–300`), but never
duplicate an original answer segment inside that concatenation. The payload
therefore has at most `o + 3o = 4o` bytes. Other reductions discard text or
replace the answer with a fixed class.

The fallback, unmatched, signaled, unrecognized and interrupted messages are
all fixed strings (`:206,262,327,351,392–400`). Including the outer answer-class
format, each fits 64 bytes. `print_prover_answer` uses no task pretty-printer
(`:150–158`). Thus a reported attempt answer fits `4o+64`; Trivial's fixed
Valid answer fits the same constant allowance. Summing proves the bound above.
Model text outside matched answer spans is still charged to O; it cannot
silently evade the input-buffer account.

For fresh nonmanual Per_Check scheduling, each leaf is scheduled with each
selected prover at most once. Parallel mode launches the selected list once;
its callback reports the first Valid result or the last completed failure.
Serial mode reschedules only after a completed failure, whose recorded state
makes `has_been_tried_by` true, and selects an untried prover next
(`gnat_checks.ml:468–485,600–641,716–725,1049–1083`). The finite strategy has no
further split below these leaves. A preparation InternalFailure has no such
completed-result feedback, so it does not create a retry loop here. Replay,
edited sessions, manual provers and unsuccessful counterexample paths require
their own account; they are not silently included in `N <= 3G`.

## Consecutive-answer warnings

The same parser can emit a warning when it discards the first of two
incompatible adjacent answers (`call_provers.ml:301–308`). Let `W_c` count
these warnings and `L_c` their total unescaped Why3 string bytes. Then

```text
W_c <= O + N
L_c <= 2O + 512*(O + N) = 514O + 512N.
```

Each warning consumes its first answer and retains its second, so their number
is bounded by the answer-segment count. Each original captured payload can
appear at most twice in warning messages: once as the retained second answer
and once when subsequently discarded, possibly after joining a chain of
Unknown answers. A newly joined chain remains at the head and is never
reintroduced as a later second answer. The inserted three-byte separators
and the fixed warning/answer-class text are covered by the deliberately loose
512 bytes per segment. There is no source-location argument at this callsite.
This is an amortized linear bound; multiplying the largest possible warning
by every warning would introduce an unnecessary quadratic output term.
`Loc.warning` uses a fresh formatter with zero box indentation and passes the
result unchanged to `Gnat_report.add_warning` when no location is supplied
(`loc.ml:187–195`, `gnat_report.ml:36–44`). There is no filename or task
pretty-printing term hidden in this call's fixed allowance.

## Other warning channels remain explicit

Write `W_o` and `L_o` for all other warning entries and their bytes. They are
not assumed zero. In particular:

- `gnat_util.set_debug_flags_gnatprove` disables unused-variable/expression,
  useless-old, abstract-axiom, missing-shape, reduction and model-parser warning
  families (`gnat_util.ml:128–152`). The fixed bodies' divergent attribute
  excludes the missing-diverges warning. Remaining typing/clone/session and
  preparation-failure routes still need their own source argument.
- `gnat_main.ml:110–114` can format an InternalFailure exception into a warning.
  Its exception text is not a prover answer and is not covered by `L_A`.
  Debug-prover-errors can also copy a complete prover output into a warning.
- The escaped debug buffer is added as one warning if nonempty before ending
  (`gnat_main.ml:272–280`). `Debug` reads inherited `WHY3DEBUG` when registering
  flags (`debug.ml:21–35`), independently of GNATprove's ordinary debug option.
  `GNATWHY3LOG` changes warning/debug routing (`gnat_main.ml:322–330`). The
  proposed selected invocation must pin these environmental controls alongside
  its command/driver configuration; debug-off cannot be inferred only from
  the absence of a command-line debug flag. This is a proposed configuration
  premise, not a claim that production already sanitizes these variables.

Forced statistics collection does not itself fill that buffer before the
warning copy: its registered printing runs at process exit
(`debug.ml:181–188`). That later buffer work still belongs to the process
capacity account and is not erased by this response-shape observation.

Combining the completed terms gives

```text
B_raw <= 15245 + 3732R + 2145G + 384A + 3075N
         + 3111O + 3W_o + 6L_o.

B_projected <= 212 + 3732R + 2601G + 3075N
               + 3087O + 3W_o + 6L_o.
```

The second expression still assumes the proposed verified answer/timing
projection; no adapter has been implemented here. For the five fixed files,
the [source bounds](retained-producer-fixed-paths.md) give `G <= 2981`,
`R <= 51`, `A <= 11924`, `N <= 8943`. Their combined response account has
the following concrete constants, retaining one base constant per response:

```text
sum B_raw       <= 38,739,343 + 3111O + 3 sum W_o + 6 sum L_o
sum B_projected <= 35,444,698 + 3087O + 3 sum W_o + 6 sum L_o.
```

Here O is summed across the five processes. These conservative sum bounds do
not imply that one array/string/object holds all five responses, or impose a
new aggregate RAM admission gate. Only O and the explicitly separated
other-warning terms remain in this response-schema transfer. Fixed
formula/context sizes, Why3 lifetime counters, solver output
and internal representations, and complete native reports remain separate
requirements. #119 is not complete.

The checker passed, including source hashes and both affine substitutions.
The parser/scheduling argument is a manual source derivation; a separate
review was requested and remains pending. No compiler/proof execution or
validation claim is inferred from this offline check.
