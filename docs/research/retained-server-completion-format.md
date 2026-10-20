# Stock server completion-message capacity

2026-10-20 UTC; bounded #119 / #153 research on Linux x86_64.

Under the selected Linux CPU-accounting and C-locale formatting interfaces,
the stock Why3 completion line has at most `D+P+29` bytes including LF, where
D is the request-ID text length and P the output-path text length. Its allocated
`D+P+31` bytes include sufficient NUL space. A positive no-wrap OCaml request ID
uses at most 19 digits, giving `B_F <= P+48`. This discharges the variable-time
term of the proposed outcome interface at that conditional scope. It does not
complete server/proxy storage, prove a request counter cannot wrap, or supply P.

The [packet](../evidence/retained-server-completion-format-20261020/README.md)
retains exact source and native-interface inputs, arithmetic and boundary checks.
The original time observation is preserved. No synthetic timestamp, extra time
limit, tool patch or production configuration change is introduced.

## Source/runtime interface and its limits

The observed host reports Linux 7.0.14 x86_64. The retained upstream stable tag
`v7.0.14` resolves to commit
`458c6079fc1d41d564c37679c8ace02cd83ee817`. Its complete selected source files
are pinned in the packet. This is an exact upstream source identity, not an
attestation that the running kernel was built from that tree. The transfer
assumes the selected trusted OS implements the retained wait4/getrusage
representation behavior. A matching release string alone does not prove it.

The retained libc SHA-256 is
`85e64f97e348786a8fb4d9f3d52fec289e2fb86bba20f0731dfe61990525e0f7`.
Its inspected `wait3` at 0x11ca90 preserves the rusage pointer, supplies pid=-1,
and enters `wait4` at 0x11cab0. That wrapper invokes its cancellation/syscall
helper with syscall 61; the pinned x86_64 syscall table assigns 61 to wait4.
The ordinary single-thread helper path at 0xa03e0 executes that syscall without
rewriting the returned rusage fields. This is retained native interface evidence;
the ordinary faithful syscall/libc-service and selected server-source
correspondence premises remain. No kernel binary proof is claimed.

The formatting interface is ordinary finite binary64 arithmetic and C-locale
`snprintf` with `%.6f`, no grouping flag, standard precision/rounding semantics,
and the selected wait-status macros. Other locales, interposed functions,
malformed service returns or arbitrary time64-seconds implementations do not
inherit this result. Those are explicit interface boundaries, not program
admission restrictions or newly adopted production behavior.

## CPU-time representation derivation

In `kernel/exit.c`, `kernel_wait4` enables WEXITED; successful child-status
paths call `getrusage(p, RUSAGE_BOTH, ...)`, and the wait4 syscall copies that
rusage to the caller. In `kernel/sys.c:1846–1930`, `utime` is u64 and
`ru_utime` is assigned only through `ns_to_kernel_old_timeval(utime)`.
The conversion in `kernel/time/time.c:465–475` takes **s64**, not u64.
The argument must therefore include the full signed range; treating all
returned CPU times as nonnegative would miss that conversion.

For every signed input n in [-2^63,2^63-1], `ns_to_timespec64` at lines 518–538
computes floor division by 10^9, with remainder in [0,999999999]. The positive,
zero and negative branches cover the entire range. The retained
`include/linux/math64.h:10–30` selects direct unsigned `/` and `%` in
`div_u64_rem` when `BITS_PER_LONG == 64`; retained
`include/asm-generic/bitsperlong.h:8–12` supplies that branch under the selected
`CONFIG_64BIT` interface. The selected x86_64 non-ILP32 UAPI width is retained
separately. No installed build configuration is attested by those source files.

The compilation-interface premise includes two's-complement signed wrap for
`-n-1`, modulo-2^64 unsigned arithmetic, and low-bit-preserving u64-to-s64
conversion, both at the function argument and when the negative unsigned
quotient expression is assigned to signed `time64_t`. The pinned Makefile
line 1107 supplies `-fno-strict-overflow`; finding that flag alone does not prove
the selected compiler's semantics or the running kernel's compilation. Under
the stated premise, the minimum-input `-n-1` yields 2^63-1 as the quotient
numerator, and the negative quotient expression yields the signed floor.
The resulting limits are:

```
-9,223,372,037 <= tv_sec <= 9,223,372,036
0 <= tv_usec <= 999,999
```

The microsecond bound follows from dividing the nonnegative nanosecond remainder
by 1000. It holds irrespective of earlier unsigned accounting wrap; this is a
representation bound, not a theorem that a wrapped value is faithful elapsed
CPU time. No new duration policy is inferred from it.

The server computes `(double)tv_sec + (double)tv_usec / 1000000.0` at
`server-unix.c:477–479`. Both integer conversions are exact in binary64.
The division and addition remain finite and, even allowing a conservative
one-second total rounding envelope, have magnitude below 10^10-1. At magnitude
below 2^34, one representable spacing is at most 2^-19; every standard directed
rounding mode fits that much looser envelope. Rounding to six decimals cannot
cross 10^10. Thus the format uses at most ten magnitude digits, one optional
minus, one decimal point and six fractional digits: **18 bytes**. Signed zero
also fits. This argument does not assume short-running solver observations.

## Wire and allocation composition

`send_msg_to_client` at source lines 434–459 allocates D+P+31 and formats:

```
F;id;exitcode;time;flag;outfile\n
```

The fixed text including one flag byte is eight bytes. The selected status
extraction yields WEXITSTATUS in [0,255], WTERMSIG in [0,127], or the default 1;
each uses at most three decimal bytes. Hence actual output is at most
`D+P+8+3+18 = D+P+29`, and its NUL fits with one additional spare byte. The
source comment's claimed per-field 13-byte allowance is not the proof; the
actual aggregate allocation is sufficient under the derived interface bound.

Require the computable caller guard `D+P+31 <= INT_MAX` before native allocation
arithmetic. This stronger bound also prevents size_t wrap on selected x86_64 and
keeps the successful snprintf count representable as int. Service/format failure
does not establish successful completion: the retained source's comparison
aborts on an overlong or negative snprintf result under its unsigned comparison.

Started messages use D+3 payload bytes and D+4 allocated bytes. With D<=19 the
allocation is at most 23. Queued cancellation's empty-path F is shorter than the
normal bound and retains its distinct semantics. The proxy may replace the
filename only after its publication gate; its outgoing bound uses the replacement
P, preserving the original numeric/time fields. Native queue object layouts,
aggregate pending counts, allocation success and eventual delivery remain
separate. `Prove_client.read_answer` accepts the finite signed decimal time
without overflowing binary64; this does not change the warning/outcome policy.

A generic signed64-seconds rusage contract would not suffice: formatting
`double(INT64_MAX)` yields 26 time bytes, and even exit zero exceeds the stock
allocation. That counterexample is retained to prevent substituting an arbitrary
time API for the selected nanosecond-derived interface.

The ordinary raw-file/output, wrapper launch, logging/parallel prefix, native
refinement, complete grammar and whole-rule accounting/composition obligations
remain. The two-callback/three-save/e<=2 allowance is still global per process.
