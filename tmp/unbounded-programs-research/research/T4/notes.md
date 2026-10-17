# T4 notes - empirical proof scaling beyond 4096 bytes

Scratch: /tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/research/T4
Tools: tools/gen.py (block generator), tools/run.py (single run + RSS sampler + guards), tools/seq.sh (sequential driver with host prechecks), tools/analyze.py (main.spark statistics).
Project template: program.gpr + six runtime files copied from .silver/linux-x86_64/program-jjR2SY (unchanged); main.adb = generated program.
Command (exact production options except -j8 and varied --steps/--memlimit):
  <Alire_Exec><Image_Gnatprove> -P <proj>/program.gpr -U --mode=all --report=all --warnings=continue --checks-as-errors=on --level=2 --prover=cvc5,z3,altergo --steps=S --timeout=0 --memlimit=M -j8 --no-loop-unrolling
gnatprove --help (pinned image tool): "--steps=nnn ... Use value 0 for no steps limit."; "--memlimit=nnn ... Use value 0 for no limit"; "--timeout=nnn ... Use value 0 for no timeout".

## Process handling
- First driver (task be50l51t5) used relative paths, so its cmdlines did not contain the scratch dir; it was stopped via the harness TaskStop on my own background task (no manual signal). Driver rewritten to absolute paths.
- PIDs of each run in pids.log. Prechecks in precheck.log.
- Concurrency: other tracks (T2 Lean probes ~1.5 GB, T3 flow-mode gnatprove on very large programs) ran concurrently during my runs; timings are contaminated (not benchmarks).

## Observed tool topology (ps during proj-f2-4k)
gnatprove -> gprbuild -j8 -> gnat2why -> spark_semaphore_wrapper -> gnatwhy3 (Image adapter, image-tools) -> vendor gnatwhy3 (alire gnatprove_16.1.0_82528bef) at ~100% CPU, single-threaded.
Vendor gnatwhy3 args: --timeout 0 --steps 100000 --ce-steps 0 --memlimit 1000 --prover cvc5,z3,altergo --proof per_check -j 8 --counterexample on --giant-step-rac on --rac-prover cvc5 --warn-prover cvc5 --ce-timeout 10 --entity N <model>.gnat-json
Note: counterexamples are on (level 2 default) with --ce-timeout 10: an unproved check triggers CE generation with a 10 s timeout.

## Pre-existing dense 4 KB reports re-analyzed (no new proof runs)
(see results in final summary; analyze.py on static800-retained, dynamic769-retained, dense-distributed63, program-40oTy6)
- static800 (800 length checks, 36.4 min, -j0): winning steps max 554, p99 1; all 2400 attempts Valid; mean attempt time per check rises by quartile 0.037/0.067/0.115/0.178 s -> linear context growth; total solver time ~79 s vs gnatwhy3 internal timings ~2400 s (schedule_vcs 645 s, introduce_premises 254, register_vcs 212, inline_trivial 209, simplify_formula 196, counterexamples_dependent_intros 171 ...).
- dynamic769: win steps max 10, attempt-steps max 10,200; attempt time by quartile 0.103/0.247/0.401/0.574 s; solver sum 255 s vs gnatwhy3 timings 3583 s.
- dense-distributed63 (821 checks, 53.6 min, 9.1 GB single-process HWM = gnatwhy3, user CPU 3140 s ~ wall 3219 s => single-threaded): win steps max 1239, p99 317; attempt time quartiles 0.385/0.689/0.857/1.042 s; gnatwhy3 timings 3965 s.
- program-40oTy6 (834 checks): win steps max 1340; gnatwhy3 timings 3568 s.
Conclusion at 4 KB: the dominant cost is single-threaded gnatwhy3 VC processing (per-goal transformations over the whole accumulated context), not solver search; -j has little effect; max winning steps ~1.3k << 100k budget.

## Completed runs (steps=100000, memlimit=1000, -j8 unless noted)
See results.jsonl and proj-*/result.json. All exit 0, all checks proved, no flow errors (flow messages are INEFFECTIVE warnings only), imagews dirs created transiently by the adapter and removed on status 0 (imagews_created empty for every run; the gnatwhy3 cmdline shows e.g. imagews-k7fQgN during f2-1k-s0m0).

## Unlimited-option semantics (f2-1k-s0m0: --steps=0 --memlimit=0)
Accepted; all 18 Main checks proved; 10 s. Observed vendor gnatwhy3 argv: "--timeout 0 --steps 0 --ce-steps 0 --memlimit 1000 ...", provers launched with the no-step command lines (e.g. "z3 -smt2 -st smt.arith.solver 6 file", "cvc5 --prenex-quant=none --stats-internal file", "alt-ergo --max-split 5 --disable-weaks file").
=> --steps=0 really means "no step limit" (provers run without rlimit/steps-bound).
=> --memlimit=0 together with --level=2 does NOT remove the prover memory limit: gnatwhy3 still receives --memlimit 1000 (level-2 default). Matches docs/expression-headroom.md:135-137.

## Explicit memlimit pass-through (f2-1k-m16000: --memlimit=16000)
gnatwhy3 argv "--memlimit 16000"; step normalization visible: z3 "rlimit 80450000" and alt-ergo "--steps-bound 100000" for --steps=100000. So an explicit large memlimit is honored; only 0 is replaced by the level-2 default 1000.

## Key results (see fit-interim.txt / final fit.txt)
- All 15 completed proof runs (F1 0.57-32.5 KB, F2 0.85-8 KB, F3 1-4 KB, plus unlimited/memlimit smokes) proved every check. No unproved check, no crash, no hard error, no 'unknown'-only result.
- f1-32k (32,461 bytes, 1,011 statements, 126 Main checks): 1,453 s, 5.15 GiB tree peak (gnatwhy3 2.60, alt-ergo 0.905 GiB vs 1000 MB prover memlimit). Z3 proved all (max 1,021 steps); CVC5 Valid on all (max 29,445 steps); alt-ergo had 8 "High failure (unrecognized prover answer)" + 1 "High failure (signaled)" (at f1-16k: 1 signaled) -> a losing prover already fails at 32 KB, plausibly at its fixed 1000 MB memlimit; masked by Z3/CVC5.
- f3-4k (multi-line dense 662 String copies, 4,096 bytes): 1,377 s, gnatwhy3 5.86 GiB (plateau within ~90-270 s of start), solver time sum only 51 s; schedule_vcs 400 s, introduce_premises 163 s, inline_trivial 136 s ... Memory exponent 2k->4k ~1.99, time ~1.92.

## f2-16k (16,279 bytes, 931 statements, 348 Main checks)
3,330 s; all proved; gnatwhy3 4.31 GiB, tree 4.86 GiB; Z3 won all at 1 step; max attempt steps 54,409 (losing prover); 1 CVC5 + 1 alt-ergo "High failure (signaled)" masked by Z3.

## f3-8k-memprobe (8,188 bytes, 1,344 dense String copies; NOT admitted: >4096 bytes)
Stopped by my 14 GiB tree guard at 263 s (exit -15 = my SIGTERM; not a proof failure). gnatwhy3 RSS climbed ~50 MB/s: 3.1 GiB@30s, 6.3@90s, 9.1@150s, 12.2@220s, 14.0@258s, still rising. Projection (f3 memory exponent 1.98, 5.86 GiB at 4 KB): ~23 GiB at 8 KB, ~90 GiB at 16 KB; time ~5,000 s at 8 KB.
RETAINED ROOT-CHECKOUT ARTIFACT: /home/canto/src/github.com/berkeleynerd/silver/.silver/linux-x86_64/imagews-n5nSxf (17,238,137-byte original.gnat-json) - the Image adapter retains its workspace when the vendor run does not return 0 (trusted-boundary.md:234-242). Not deleted (no authority to modify the root checkout). All other runs: no imagews dir persisted (imagews-before.txt vs imagews-after.txt differ only by this one).

## Image adapter node-id field
src/silver_image_model.ads:5 Original_Node_Id range 0 .. 2_147_483_647; overflow -> Failed -> Invalid_Model (silver_image_model.adb:355-360). Observed max node id 217,003 (f1-32k, 9.0 MB model) and 427,951 (f3-8k, 17.2 MB model) => ~25-52 ids per source byte; 2^31 would need ~40-80 MB source and a >100 GB model, so gnatwhy3 memory is exhausted long before. Fixed but practically unreachable cap; could be widened to the 63-bit Byte_Count.

## Final exponents (fit.txt; log-log least squares over runs >=1.5 KB)
F1: wall 1.82, gnatwhy3 mem 1.00, max per-check attempt time 1.79, max attempt steps 1.47, report 0.98, checks 1.00
F2: wall 1.99, mem 1.43, max attempt time 0.86, max attempt steps 1.75, report 0.97, checks 0.98
F3: wall 1.92, mem 1.98, max attempt time 0.40, max attempt steps 1.69, report 1.04, checks 1.05
Escalation (--steps=1000000 / 0) was not triggered: no unproved check in any completed run.
