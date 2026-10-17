# T3 — Hard (non-resource) limits in the pinned toolchain and OS

Scratch: /tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/research/T3
Date: 2026-10-17. Host: Linux 7.0.14 x86_64, 22 CPUs, 31 GB RAM, no swap, 8 MiB soft stack, hard stack unlimited.
Tools: pinned GNAT 16.1.0 (gnat_native_16.1.0_9f74f58a) gcc/gnat1; image gnatprove
(.silver/linux-x86_64/image-tools/bin/gnatprove, GNATprove 16.1 / why3 / cvc5 / Z3 4.15.4 / Alt-Ergo 2.6.1).
Source reading: GCC frontend at gcc-mirror 6afcc4f6 (releases/gcc-16.1.0, the same tag the
2026-10-16 frontend review used; fetched into gnatsrc/), producer spark2014 fsf-16 42554fc2 and its why3
submodule (retained at tmp/review-capacity-343c2f8/tmp/producer-source). Source-to-binary identity is NOT
attested: every source-derived statement below is "source-reasoned + observed" where a probe exists,
otherwise "source-reasoned only".

Harness: scripts/probe.sh (gcc -c [-gnatc|-O0] -gnat2022 -gnata -gnato main.adb with the six runtime
files copied from program-jjR2SY), scripts/gp.sh (production gnatprove flags, image gnatprove, PATH =
image-tools/bin:gnat bin:gprbuild bin, no alr exec, so no write under the root checkout), scripts/gp2.sh
(raw gnatprove flags), scripts/run.py (wall time, max child RSS; PIDs appended to each case's pids.txt).
Generators: gen_line.py, gen_ident.py, gen_sid.py, gen_nest.py, gen_big.py. Logs: batch1.log
(gnatc 100k nesting), batch2.log (gnatprove check/flow scaling), batch3.log (full -O0 backend).

Deviation recorded: four tiny `--mode=all` gnatprove runs on trivial programs (null body, 4096-char
identifier, overflow probe), each <= 8 s / 130 MB, to observe the effective prover limits written in
why3session.xml and the per-check JSON. No proof of any large program was run.

## 1. GNAT frontend

### 1.1 Physical line length — HARD (tool_hard_limit)
Source: scng.adb Check_End_Of_Line (gnatsrc/scng.adb:129-190), hostparm.ads:43-44
(Max_Line_Length = Column_Number'Last - 1 = 32766), types.ads:181 (Column_Number range 0 .. 32767).
Two checks: Len > 32766 -> "this line is too long" (non-fatal error), and, only when Len >= 4096 bytes,
a tab-expanded column walk (HT advances to next multiple of 8, +1) that raises Unrecoverable_Error
with "this line is longer than 32766 characters" once Col > 32766.
Observed (gcc -gnatc, p/line_*):
- 32765 bytes (spaces, comment, identifier-free line, string literal, numeric literal), with LF, CRLF,
  CR or no terminator: accepted.
- 32766 bytes: rejected "this line is longer than 32766 characters" (any terminator).
- 32767: both messages.
- Tab expansion: `procedure Main is begin null; end Main;` (39 bytes) + tabs: 4130-byte line accepted,
  4131-byte line rejected (expanded width 41+8*(L-40) > 32766 exactly at L = 4131). A 4096-byte all-tab
  line is rejected; 4095 tabs accepted. Lines < 4096 bytes are never tab-checked (max width 8*4095 = 32760).
=> Exact rule: for every physical line (terminators LF, CR, CRLF), the HT-expanded width
   (tabs to next multiple-of-8 column) must be <= 32765. This subsumes the byte bound 32765.
   Not reachable under the current 4096-byte source rule (a 4096-byte line has no room for program text
   if it is all tabs), reachable immediately when the source bound rises above 4096.

### 1.2 Identifier length — HARD (tool_hard_limit); GNAT BUG box, not a diagnostic
Observed (p/id_*, p/sid_*): identifiers of 4096 characters are accepted in every tested role
(object declaration, assignment target/use, constant, String object passed to Put_Line, for-loop
parameter) by gcc -gnatc, full gcc -c, gnatprove --mode=check, --mode=flow and --mode=all (tiny).
4097 characters fail in every role and mode with:
  "Name buffer overflow; Max_Length = 4096" + "GNAT BUG DETECTED ... Program_Error namet.adb:141 explicit raise"
Source: namet.ads:144 `type Bounded_String (Max_Length : Natural := 2**12)`; namet.adb:132-145 raises
Program_Error on overflow. Some frontend path uses a default-capacity Bounded_String for a name.
Warning messages naming a 4096-char identifier are emitted in full (4159-char line), no truncation fault.
=> Rule needed once identifiers can exceed 4096: identifier length <= 4096 characters. This is an
   independent fifth "4096" domain (coincides numerically with today's source bound).

### 1.3 String and numeric literals
32765-byte line containing a ~32700-char string literal or numeric literal (value 7 with leading zeros):
accepted by -gnatc and full compile. Their limit is the line rule (literals cannot span lines).
No separate cap observed. (Silver's own literal value scope 0..4096 is a language policy, not a tool limit.)

### 1.4 Total source size — HARD near 2 GiB (tool_hard_limit)
Source: types.ads:148 Text_Ptr range -4 .. Int'Last; all source buffers of one compilation share the
Source_Ptr space with 4 KiB alignment (types.ads:190, sinput-l.adb:224-233); osint.adb Read_Source_File
`Len : Integer; -- assume no more than 2 gigabytes of source`, `Len := Integer (File_Length (FD))`.
Observed (comment-line padding, p/big_*):
- 10 MB: 0.09 s, 34 MB; 100 MB: 0.30 s, 124 MB (gnatc); 100 MB full -O0 -g: 0.3 s, 138 MB, debug line
  1,250,006 recorded correctly.
- 2,130,706,432 bytes (2^31 - 2^24): accepted, 10.5 s, 2.16 GB RSS.
- 2,147,483,647 (2^31 - 1): gnat1 SIGSEGV, "malloc(): corrupted top size" (rc -11), 0.5 s.
- 2,147,483,648 (2^31): gnat1 spins forever at 21 MB RSS (gdb: sinput.original_location <- errout.error_msg
  <- scn.scanner.scan <- scn.initialize_scanner <- frontend); terminated by me after ~250 s via its own
  timeout wrapper.
=> Non-resource failure modes (heap corruption, infinite loop) above ~2^31 - (other units). A source-length
   rule is unavoidable; the largest tested-safe value is 2^31 - 2^24 = 2,130,706,432 bytes. (Exact boundary
   not bisected: each probe writes a 2 GB file.)

### 1.5 Fixed table capacities (types.ads:313-363) — HARD in principle, unreachable in practice
Node_Id 0 .. 1,999,999,999; List_Id, Elist_Id, Elmt_Id, Name_Id, String_Id, Ureal each 100,000,000 values;
Uint table 1.5e9. table.adb grows tables without checking the Id subtype; overflow therefore raises
Constraint_Error (bug box) or worse depending on how gnat1 was built (not observed).
Reachability within a 2 GiB source: e.g. `Put ("");` is 8 bytes and creates one String_Id and one list, so
~800 MB of such statements reaches 1e8. But: (a) sequence analysis is quadratic in time (see 1.6: 100k
output statements 36 s, 1M > 1200 s), so 1e8 statements need ~1e7 s (months) of gnatc time; (b) elsif
chains are linear (100k branches 2.19 s, 88 MB => ~880 B/branch) but 50M branches need ~44 GB RAM before the
List cap; (c) gnat2why flow on 8k output statements already needs 1.06 GB/470 s, superlinear. On this host
every route exhausts memory or time long before any 1e8 cap. On a much larger host the List/String caps are
the first non-resource failure. Classification: tool_hard_limit, source-reasoned only, not probed.
Option: a derived source bound that makes every cap unreachable (e.g. S <= 2^26 bytes = 64 MiB keeps every
per-byte entity count below 1e8 if each entity consumes >= 1 source byte — unproved assumption about
internally created lists/strings), or accept as a documented tool premise.

### 1.6 Nesting and counts — resource only (stack/memory/time), no hard caps found
gcc -gnatc (gcc driver raises gnat1's soft stack; observed 100k parens pass under 8 MiB rlimit):
| construct | 1k | 10k | 100k | 1M |
| parens | 0.04 s | 0.03 s | 0.22 s / 79 MB | 300k & 1M: Storage_Error stack overflow (bug box) at default; 1M passes with ulimit -s unlimited (0.98 s, 575 MB) |
| nested if | 0.07 s | 2.29 s | 237.8 s / 114 MB | |
| nested for loops | 0.08 s | 4.20 s | (batch1, pending) | |
| elsif chain | 0.05 s | 0.16 s | 2.19 s / 88 MB (2.9 MB src) | |
| declarations | 0.02 s | 0.07 s | 1.08 s / 75 MB (2.3 MB src) | |
| assignments X := 1; | 0.03 s | 0.29 s | 30.9 s / 55 MB | |
| Put_Line ("hello world"); | | | 36.1 s / 119 MB | (pending, timeout 1200 s) |
| X & X & ... (one expr) | 0.03 s | 0.71 s | 88.4 s / 36 MB | |
| X + X + ... (one expr) | 0.04 s | 1.29 s | 160.2 s / 91 MB | |
Quadratic time in statement-sequence length, nesting depth and expression length; memory modest.
Stack overflow manifests as "GNAT BUG DETECTED ... Storage_Error stack overflow" — a resource failure that
looks like a tool bug; fixed by a larger stack.

## 2. gnatprove --mode=check / --mode=flow (production flags otherwise)
| program | size | check | flow |
| 8k assignments | 64 KB | 1.3 s / 25 MB | 3.1 s / 200 MB |
| 32k assignments | 256 KB | 6.6 s / 31 MB | 14.2 s / 1.06 GB |
| 128k assignments | 1.0 MB | 87.4 s / 58 MB | 136 s / 4.43 GB |
| 2k Put_Line | 72 KB | 1.1 s | 22.9 s / 283 MB |
| 8k Put_Line | 288 KB | 1.6 s | 470 s / 1.06 GB |
| 32k Put_Line | 1.15 MB | 7.0 s / 57 MB | (pending, 3600 s cap) |
| elsif 2.4k / 9k | 66 / 251 KB | 1.0 / 1.1 s | (pending) |
| nested if 3k / 12k | 66 / 264 KB | 1.3 s / STACK OVERFLOW at 8 MiB (passes 6.6 s with unlimited stack) | |
| nested loop 2k / 8k | 69 / 279 KB | 1.8 s / STACK OVERFLOW at 8 MiB (passes 13.6 s unlimited) | |
| parens 10k / 100k | 21 / 205 KB | 1.0 s / STACK OVERFLOW at 8 MiB (passes 1.2 s unlimited; flow 1.2 s) | |
| decls 3k / 12k | 65 / 265 KB | 1.0 / 1.1 s | |
gnat2why does NOT get the gcc-driver stack increase: it inherits the caller's RLIMIT_STACK. No size/count
error other than stack overflow observed. Flow memory and time grow superlinearly (Put_Line ~ n^2.2).

## 3. GNATprove / Why3 / prover limit semantics
Source: producer src/gnatprove/configuration.adb:2343-2500; why3/src/gnat/gnat_config.ml:577-660,
gnat_checks.ml:1049-1080, 714-725, gnat_expl.ml:657-675, gnat_report.ml:168-183; why3/src/server/server-unix.c:358-380.
- --level=2 sets provers cvc5,z3,altergo, steps 0, timeout 5 s, memlimit 1000 MB, counterexamples on.
  Explicit --timeout (string-detected) and --steps override. --memlimit=0 is indistinguishable from
  "absent" (`if CL_Switches.Memlimit = 0 then null;`), so with any --level the per-prover memlimit can never
  be removed. OBSERVED: --level=2 --memlimit=0 -> why3session memlimit="1000"; --level=2 --memlimit=5000 ->
  "5000"; no --level + --memlimit=0 -> memlimit="0". (p/mem_*). The trivial-goal attempt always records 1000.
- memlimit is enforced by why3server as RLIMIT_AS (address space) on each prover process; timelimit as
  RLIMIT_CPU. 0 means not set (server-unix.c:358-372). Stack is inherited.
- --steps=0: gnatwhy3 gets no step limit (set_steps ignores t <= 0). --timeout=0: no time limit.
  With all three at 0 an unprovable VC runs forever (non-termination = time exhaustion).
- Steps conversion (gnat_config.ml:589-596): cvc5 raw = 15000 + 35*s; z3 raw = 450000 + 800*s; alt-ergo raw = s.
  OBSERVED steplimits for s = 100000: 3,515,000 / 80,450,000 / 100,000.
  Z3 4.15.4 `rlimit=` wraps modulo 2^32: rlimit=4294967297 behaves like rlimit=1 (unknown, rlimit-count 16).
  => --steps must be <= 5,368,146 (raw 4,294,966,800) or Z3 silently gets a tiny limit. Hard knob limit.
  cvc5 --rlimit accepts up to 2^64-1 (parse error beyond); alt-ergo --steps-bound up to 2^62-1;
  gnatprove --steps is an Ada Integer (<= 2^31-1).
- Prover scheduling (gnat_checks.ml:1049-1080): with parallel > 1 (-j0 => Number_Of_CPUs = 22 here), all
  selected provers are launched concurrently for each goal and the others are interrupted when one returns
  Valid; with -j1 provers are tried one after another (first untried prover), so an unlimited first prover
  would block the rest. OBSERVED: each of the three provers has 41 attempts in a tiny run with -j0.
- --proof=per_check (default) | per_path | progressive, with :lazy|:all; no built-in limit escalation;
  --replay reuses recorded limits (gnat_checks.ml:1237 compute_replay_limit_from_pas).
- Result classification (gnat_expl.ml:662-675): Timeout -> Limit{timeout}, OutOfMemory -> Limit{memory},
  StepLimitExceeded -> Limit{step}; Unknown/Invalid/Failure/HighFailure (prover crash or signal, e.g. the
  observed CVC5 "High failure (signaled)") -> Gave_up, the same bucket as a genuine "unknown".
  The per-check JSON in obj/gnatprove/<unit>.spark has "unproved_status": {"status": "unknown"|"gave_up"|
  "limit", "time", "steps", "memory"} and per-prover "check_tree" results ("Unknown\n(sat)",
  "Step limit\nexceeded", "High failure", ...). OBSERVED for a real overflow with --steps=1.
  => Silver can distinguish resource-limited/crashed proof attempts from a prover verdict only by reading
  these fields; HighFailure must be read from check_tree text, not unproved_status.
- Counterexamples with --level=2 and timeout 0: CE_Timeout = Max_CE_Timeout = 10 s (configuration.ads:72);
  only affects unproved checks.
- No fixed count limits on VCs, sessions or report size were found in the inspected code; JSON is parsed
  recursively (GNATCOLL) — deep nesting would be stack, not a cap (not probed).

## 4. GCC back end (full gcc -c -O0, as gprbuild uses no -O)
| program | size | time / RSS |
| 10k parens | 21 KB | 0.17 s / 44 MB |
| 10k nested if | 220 KB | 4.9 s / 51 MB |
| 10k nested loops | 349 KB | 44.8 s / 1.45 GB |
| 10k elsif | 279 KB | 24.2 s / 127 MB |
| 10k decls | 219 KB | 0.31 s / 57 MB; 100k decls 2.3 MB: 4.4 s / 232 MB |
| 10k / 32k / 128k assignments | 80 KB / 256 KB / 1.0 MB | 0.57 s / 3.6 s / 60.7 s, 191 MB |
| 8k / 32k Put_Line | 288 KB / 1.15 MB | 9.5 s / 211 MB; 244.6 s / 737 MB (~n^2.3) |
| 128k Put_Line | 4.6 MB | (pending, 3600 s cap) |
| 100 MB comments + 1 stmt, -g | | 0.3 s / 138 MB; DWARF line 1,250,006 correct |
No hard errors; superlinear time/memory only.

## 5. OS (Linux 7.0.14)
- MAX_ARG_STRLEN = PAGE_SIZE*32 = 131072 (/usr/include/linux/binfmts.h:15): OBSERVED execve of a
  131071-byte argument succeeds, 131072 fails E2BIG. MAX_ARG_STRINGS 0x7FFFFFFF.
- ARG_MAX: getconf 2,097,152 (= 8 MiB stack / 4; dynamic), linux/limits.h legacy 131072. 30 x 100 KB args fail E2BIG.
- PATH_MAX 4096, NAME_MAX 255 (path/workspace domain, not program size).
- ulimit: stack 8192 KiB soft / unlimited hard; file size, data, AS unlimited; open files 1,048,576.
- GNAT runtime: Ada.Command_Line.Argument of 131071 bytes and an 8x concatenation (1,048,568 bytes) work
  even under a 1 MiB stack (p/argrt).
- Ada String index type is Positive: any String value or concatenation length is <= 2^31-1
  (inherited_semantics, not a tool limit).
=> An unbounded language String/argument domain meets the OS only at invocation: a longer argument cannot be
   delivered (caller's execve fails). That is environmental; no program-side rule is needed beyond the Ada
   Integer'Last bound on String lengths.

## Final results appended (13:40 UTC)
- gnatc 100k nested for loops: killed by its 1800 s timeout (> 1800 s; 10k took 4.2 s => ~quadratic+).
- gnatc 1M Put_Line statements (36 MB): killed by 1200 s timeout (100k took 36 s => quadratic).
- gnatc 1M elsif branches (29.9 MB): 25.3 s / 657 MB (linear). 1M declarations (23.9 MB): 10.2 s / 517 MB.
- gnatprove flow: elsif 2.4k 5.3 s / 347 MB; 9k 56.9 s / 3.96 GB. decls 3k 22 s / 135 MB; 12k 510 s / 474 MB.
  Put_Line 32k flow: stopped by me at ~354 s with gnat2why at 3.93 GB RSS (not completed).
- gnatprove flow stack (8 MiB): nested loops 250/500/1000 pass (1.6/2.7/5.5 s); 2000 and 8000 fail with
  Storage_Error; nested if 3000 and 12000 fail. With ulimit -s unlimited: loops 2000 pass 23 s / 484 MB,
  8000 pass 573 s / 6.54 GB. check mode: if 12000 and loops 8000 pass with unlimited stack (6.6 s, 13.6 s).
  Current Silver (<= 143 nested loops at 4096 bytes) is far below the 8 MiB flow threshold (1000..2000).
- full -O0 128k Put_Line (4.6 MB): stopped by me at 1338 s with gnat1 at 1.87 GB (32k took 245 s).
- Processes signalled by me: timeout wrappers 63883 (2 GiB probe), 70502 (32k flow), 68461 (128k full);
  each wrapper forwarded TERM to its own process group. Other gnatprove runs seen on the host
  (alr exec ... pid 74536+) belong to another agent and were not touched.
- No files created outside this scratch directory; no program-*/imagews-* directories created.
