# CVC5 terminal-entry count and remaining payload contract

2026-10-20 UTC, Linux x86_64, #119 / #153; base `d19f73cb3f`.

**The candidate source admits a conditional six-entry terminal envelope for a
single execution thread, but that count does not close terminal output.** Valid
signal-point registry state, safe numeric conversions, backend thread behavior
and the saved native C++ termination handler remain separate requirements.
No complete q or weighted O is exported. This packet identifies these exact
conditions for the attempted complete CVC5 output account.

The [packet](../evidence/retained-cvc5-terminal-output-20261020/README.md) reuses
the existing source archive at `86cecd83b685f59e884094693b9a4c5c90a62e03`.
No new solver, target, native tool, capture, compiler or proof run occurred.
The [accepted output account](retained-cvc5-output-capacity.md) supplies local
formatting bounds, and the [launch interface](retained-solver-launch-profile.md)
distinguishes per-attempt SIGKILL from GNATprove's separate soft tree cleanup.

## Terminal control

`signal_handlers::install` installs SIGINT, SIGXCPU, SIGILL, SIGTERM, and,
when HAVE_SIGALTSTACK is set, SIGSEGV (`signal_handlers.cpp:245–333`). Each
sigaction has SA_SIGINFO, an empty additional mask and no SA_NODEFER.
The SIGSEGV action adds SA_ONSTACK. No SIGABRT action is installed here.

| Entry | Terminal continuation after its statistics attempt |
| --- | --- |
| SIGINT | Set that signal to SIG_DFL, then raise it |
| SIGTERM | Set that signal to SIG_DFL, then raise it |
| SIGXCPU timeout | abort |
| SIGILL | Default/re-raise; debug spin branch instead never returns |
| SIGSEGV, if installed | Default/re-raise; debug spin branch instead never returns |
| `cvc5terminate` | Restore saved terminate handler first, print, then call it |

For a single receiving thread, the normal POSIX handler-entry rule blocks the
currently handled signal until return; an inner handler inherits outer blocked
signals. Distinct signal kinds can nest, so assuming only one terminal entry
would be wrong. However each of the five installed signal kinds can enter at
most once before process termination: while its handler runs it is blocked,
and after its terminal return its disposition is already default with the
re-raised signal pending. A debug spin prevents the return without repeating
its own message. Timeout aborts. Partial/failed safe writes call abort rather
than retrying a printing owner.

This argument assumes normal POSIX semantics and successful disposition/reset
and raise behavior, no external handler reinstallation, no explicit unblocking
or nonlocal recovery (including escaping C++ unwinding from a handler), and
termination by abort/default actions. The selected source shows no explicit
mask-reset/nonlocal-recovery entry point; that lexical fact does not establish
native exception/unwind behavior. Linked services and native execution still
need the corresponding relation. A different execution thread
could receive a blocked signal concurrently, so this is explicitly a
single-thread argument, not a process-wide fact inferred from the CLI.

`cvc5terminate:218–242` restores `default_terminator` before printing. A later
standard termination call therefore does not reenter this CVC5 callback unless
another client reinstalls it. With no such reinstallation and the standard
nonreturning saved-handler contract, the callback has at most one activation.
Together, there are at most **six CVC5 terminal activations and six attempted
safe statistics dumps** under these premises. This overcounts mutually
exclusive terminal paths, rather than promising they all execute.

`install_time_limit(0)` returns before installing SIGALRM or creating the
fallback timer thread (`time_limit.cpp:79–85`). The
[parser/options account](retained-cvc5-parser-options.md) attaches that zero
option and excludes the portfolio route for the selected command family.
This does not prove that every linked backend/runtime is single-threaded.
Likewise, six activations are not six Why3 callbacks: the existing global two
save-entering callbacks/three saves/e<=2 budget is unchanged.

## What the count bounds, and what it does not

Reuse the conservative accepted per-handler direct-literal envelope
`1448+4P0`, with P0 the program basename length. It includes both build branches,
PID/address widths and mutually exclusive messages. Six activations therefore
give at most `8688+24P0` bytes of this **direct text only**. The exact selected
command uses basename cvc5, so P0=4 would give 8,784 bytes if the unchanged argv
and basename-parser relation is attached. No numerical substitution establishes
the missing signal/thread/runtime conditions.

Statistics, debug LastExceptionBuffer destruction, pre-handler assertions and
the saved C++ runtime handler's output are excluded from that direct-text term.
`CommandExecutor::printStatisticsSafe` still calls `getOptionInfo("stats")`
before visiting TermManager and solver registries (`command_executor.cpp:108–115`).
Calling a routine named Safe is not a proof that every interrupted API, map,
string, vector, numeric state or allocation is valid for that call.

The [enum argument](retained-cvc5-enum-output.md) bounds ordinary map-collapsed
spellings, but safe statistics traverse every positive bucket directly. Safe
key multiplicity must come from the histogram's producer/vector extent, not
the ordinary distinct-string count. `StatisticHistogramValue::add` changes
the vector and offset in separate operations (`statistics_value.h:169–185`);
the normal source invariant cannot simply be assumed at every native signal
instruction boundary. A valid histogram extent/key relation at signal entry
is a caller obligation even when runtime container services are trusted.

Two accepted conversion preconditions also remain concrete:

- Signed safe printing negates a negative int64 (`safe_print.cpp:48–61`), so
  INT64_MIN needs exclusion for defined source arithmetic.
- Safe double printing casts to int64 (`safe_print.cpp:109–139`), requiring a
  finite representable value and the subsequent fractional conversions' valid
  domain. `StatisticAverageValue::get` returns `d_sum/d_count`; the source type
  alone does not establish that bound at every selected signal entry.

These are not claims that a retained program reaches those bad states. They
are exact missing preconditions, so a finite activation count or normal dump
allowance cannot be promoted to a complete safe-output bound.

## Saved runtime handler and installation identity

After its own output, `cvc5terminate` calls the function returned by
`std::set_terminate` during installation. A complete account needs that exact
handler's output families, dynamic exception/type/message operands and
nonreturning behavior. General runtime correctness for valid calls does not
supply a byte count for those operands. The DEBUG branch additionally deletes
the retained LastExceptionBuffer before its message; those exception bytes
need their own bound or a justified build/entry exclusion.

The [retained identity inventory](retained-solver-identity.md) describes this
CVC5 file as an ELF executable with no dynamic section/interpreter/needed
libraries and an Ubuntu GCC 11.4.0 compiler comment. Neither that comment nor
the embedded CVC5 revision identifies or refines the exact statically linked
C++/C termination code. Substituting this host's current shared runtime or the
GNAT toolchain's different GCC sources would not close that relation. No new
source or binary identity is assumed here.

## Complete-output decision interface

The complete account must either discharge the listed single-thread/signal,
valid-state, conversion, safe-bucket and saved-runtime conditions, or derive a
prospective launcher/configuration relation excluding the relevant entries
while preserving all required outcomes. Delivered SIGKILL alone runs none of
these handlers; it cannot exclude soft cleanup or ambient entries. An exclusion
must be explicit and source/configuration justified before using it in a rule.
No launcher change is adopted by this research note.

Even if those terminal conditions are established, nonterminal diagnostics and
their repeated search-time occurrences remain with the
[diagnostic account](retained-cvc5-diagnostic-output.md). A complete finite q
requires all families together; a count of queries, handlers or registry names
does not establish it. Current admission and the Oracle remain unchanged.
