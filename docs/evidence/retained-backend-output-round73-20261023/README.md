# R73: backend-output design for the pipe/canonical route

2026-10-23 UTC, Linux x86_64; #119 / #153. The
[source argument](../../research/retained-backend-output-route.md) and
[independent review](../../reviews/review-backend-output-route-20261023.md)
establish a symbolic output interface for the prospective adapter design:

```
q_backend(A,E) = max(2*A+72, A+E+1296)
A >= 1, E >= 1, q_backend(A,E) <= 2^31-1.
```

A is the actual adapter executable argument's byte length; E bounds its
selected exception-name family. The guard is a sufficient configuration
arithmetic condition, not a new source cap or physical-memory gate. It covers
the named argv, exception-name, helper, printf and file-extent operands.
Neither an arbitrary E=16 specialization nor actual configuration operands
are invented. The guarded symbolic function is complete at this design scope;
it does not require a not-yet-written production binary to choose A and E now.

The selected server parent produces no pending stdout/stderr bytes before
forking. Its exec-failure text and the default GNAT terminal report are the
alternative raw-file writers under the stated policy. Solver output uses the
finite pipe consumer; decisions use the control channel and canonical files.
The stronger current launch count gives 354q total raw payload, with 459q
retained conservatively. Pre-redirection process-group diagnostics remain a
separate inherited-stream contribution. Why's canonical parser still reads
at most 76 bytes per file.

The future #88 **Adapter_Backend_Emission** refinement must establish the actual
source/import/binder defaults and finalizer closure, finite exception family,
output-free owned error paths, checked child error-pipe/immediate-exit path and
closure of every inherited backend-file descriptor. Merely replacing fd1/fd2
leaves the original server output descriptor open. No production adapter,
changed invocation or closed bound for the old stock-solver file route is
claimed. The existing runtime/service trust boundary remains explicit.

The independent audit passed 1,934 checks in 0.328771 seconds, first run,
binding 16 author files, 18 providers, 23 complete source members and 31 strict
spans. Its 816 finite terminal cases support the general source argument.
Exact author/reviewer freezes are in [inputs.json](inputs.json); the new
[integration check](check.py) binds their files and unchanged native pins
without replay. [integration-result.json](integration-result.json) and
[round.json](round.json) retain exact timings and model/effort observations.

The fixed-domain control/failure interfaces and whole-rule composition remain
to be finished. #178 separately supplies the ordinary-Main typed-profile input.
Complete current-grammar coverage, checked accounting/correspondence,
useful-domain comparison and final review remain required. #119/#153 stay
In progress; production #88–#94 stays unstarted, PR #121 draft/unmerged and
the approximate estimate 85% with low confidence. Oracle, tools, admission and
the single global e<=2 allowance are unchanged.
