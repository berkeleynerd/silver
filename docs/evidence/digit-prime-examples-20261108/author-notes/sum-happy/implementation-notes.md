# #344 digit-sum / happy-number implementation handoff

Date: 2026-11-08. Selected subthread settings: GPT-6.1 Sol / Extra High,
as requested by the lead; live runtime model/effort confirmation is unavailable.
Host observed with `uname -a`: Linux silver, x86_64. Isolated worktree:
`tmp/digit-sum-happy-344`, branch `feat/digit-sum-happy-344`, authorization
baseline `87e18b4c3ede6efac69a5fe46178510e9f17c2fa`.

Ownership is exactly the two new sample sources. This subthread does not edit
the shared manifest, governance, compiler, library, proofs or installation and
does not build, prove, run production applications, write GitHub or push.
The lead owns integration, production checks and reviewable publication;
merge of #344 remains held for the owner. No harness goal was created.

Read: AGENTS.md, oracle.md, the Integer/arithmetic/refinement, scalar-function,
counted-loop and output rules in language.md, the applicable scalar-function
design and batch task rows, and both primary cached task.wiki pages. No language,
capacity or Oracle change is needed. Sources are actual Ada/SPARK, with only
SPARK_Mode (On), closed scalar frames, literal local initializers, full-domain
checks, earlier-only call assignments, and a single terminal return per helper.

## Exact source budgets

| Source | Bytes / 4096 | Operators / 63 | Largest expression operands / 64 |
| --- | ---: | ---: | ---: |
| rosetta_sum_digits_of_an_integer.adb | 1602 | 8 | 6 String leaves; at most 2 scalar leaves |
| rosetta_happy_numbers.adb | 1455 | 4 | 3 scalar leaves; 1 String leaf |

Sum-digits uses `mod`, `+`, `/` and five concatenations. Happy uses `mod`, `+`,
`*`, `/`. Source bytes and operator counts are reproduced in
`derivation-results.json`; operand maxima follow directly from the six-atom
output and `Total + (Digit * Digit)`. Image is one String atom and checks its
scalar argument separately; an indexed read contributes array name plus index.
The largest sum-digits scalar expressions therefore have two leaves.

## Sum digits: complete declared-domain argument

`Sum_Digits` declares N = 0..2147483647 and Base = 2..36 independently;
its result is 0..1085. Every positive number in this domain has at most 31
base-Base digits because Base >= 2 and N < 2^31. The k-th extraction takes
`Remaining mod Base` and then integer-divides Remaining by Base. Inductively
the original N is the sum of the extracted positional digits plus
Remaining * Base^k. After 31 extractions Remaining is
floor(N / Base^31) = 0. Leading zero extractions preserve the sum, including
N = 0. Thus all declared input/base combinations return the complete digit sum.

Every digit is between 0 and Base-1 <= 35. Before iteration j <= 31, at most
j-1 <= 30 digits have been added, so Total <= 30*35 = 1050. The executable
`Total <= 1050` guard is therefore true whenever its addition is required;
it never discards a digit. Admission can infer Total+Digit <= 1050+35 = 1085
without a relational guard. Division's divisor excludes zero, all remainders
are 0..35, and all actual Integer intermediates remain in range.

The driver covers all four task examples: (1,10), (1234,10), decimal 254 in
base 16 (FE), and decimal 3854 in base 16 (F0E). Both hexadecimal examples
produce 29. It also covers zero and digit/positional boundaries in bases 2
and 36, and the largest Integer in bases 2, 10, 16 and 36. Those largest-input
sums are 31, 46, 112 and 127. These 17 cases are demonstrations, not a claim
of exhaustive testing of the 35*2147483648 formal-domain product.

The expectation oracle converts each number to a base string (Python format
for bases 2, 10, 16; unbounded divmod conversion otherwise), round-trips the
spelling with Python `int`, then sums character values. It has no fixed
31-iteration bound or executable addition guard. Its results agree with the
bounded algorithm on 147507 pairs: every number 0..4096, every representable
base power +/-1, and the largest 101 Integers, for every base 2..36.
The analytical argument above, rather than that selected finite check,
establishes loop and guard sufficiency throughout the declared domain.

## Happy: complete declared-domain and search arguments

`Sum_Squared_Digits` and `Is_Happy` both admit every N = 0..999. The digit
helper returns 0..243. Three decimal extractions consume every permitted
number, including zero and leading zeros. Each digit is 0..9 and its square
is 0..81. Before any of the three additions Total <= 2*81 = 162, so the
static guard always permits the required addition and the result is <= 243.
No update is skipped to obtain safety. All arithmetic is within Integer.

Write f for the exact digit-square transformation. For any admitted initial
x0, the first image x1=f(x0) enters S={0,...,243}, and f maps S into S because
it is a subset of the helper's domain. Also f(1)=1, so 1 is absorbing.
The source computes exactly x1,...,x244. If 1 occurs anywhere among these,
the last value is 1 and the function returns True. If none is 1, all 244
images lie in S without 1, a set of only 243 states; two images repeat.
Determinism then traps the future in that already-seen non-1 cycle, so 1
cannot first appear later. Hence checking x244=1 is exactly the unbounded
happy-number definition throughout 0..999. The first transformation into S
is explicitly included in the 244 transformations; it is not assumed that
the initial input already lies in S. Zero is an additional false control.

Main scans every positive integer 1..31 in order and prints a value only when
the exact predicate is true. An independent oracle uses decimal strings to
sum squares and a set to detect cycles, stopping at 1 or a repeat, with no
fixed transformation count. It finds exactly 1,7,10,13,19,23,28,31 in the
complete prefix 1..31, establishing that the output is precisely the first
eight and that 31 is a sufficient search endpoint, not an arbitrary cutoff.
There are no extra output lines for controls.

The script exhaustively compares the three-step digit helper against the
string-square oracle on all 1000 helper inputs and compares the 244-step
classification against cycle detection on all 1000 Is_Happy inputs. All
comparisons pass; 142 inputs in 0..999 are happy. Retained unhappy controls
are 0,2,3,4,8,20,30,42,999, with cycle paths in derivation-results.json.
Main also implicitly exercises the unhappy values in its complete prefix
by excluding them from output. Its primary output has exactly eight lines.

## Admission and deliverables

The permitted existing binary is:
`/home/canto/src/github.com/berkeleynerd/silver/tmp/scalar-functions-298/.silver/linux-x86_64/compiler/bin/silver`.
Read-only `check` calls against the absolute paths of both final source files
each exited 0 with the exact output `Accepted: silver.\n` on their first try.
`admission.json` retains command/output/status and source/binary identities.
No source changed after admission. No proof/build/runtime result is claimed.
Production proof/build/execution and full application report audits remain
the lead's responsibility over these same source bytes.

Scratch artifacts, all outside committed production inputs:

- `tmp/manifest-entries.json`: exact two-element proposed manifest array,
  including every helper in application_functions.
- `tmp/derive_expectations.py`: independent expectation and comparison script.
- `tmp/derivation-results.json`: counts, cases, source hashes and unhappy paths.
- `tmp/sum-digits-expected.stdout`, `tmp/happy-numbers-expected.stdout`:
  exact independently expected stdout, including Ada Integer'Image spaces.
- `tmp/admission.json`: read-only admission record.

`git diff --check` passed before staging. Only the two owned source files are
to be committed, with `Refs #344`; the lead will integrate the proposed manifest.
Scratch is preserved. No CLI recall update was attempted by this subthread.

Final owned-source commit: `24bfbc92a03e65d059ca4edd1128d714550fa9d8`
(`Add callable digit sum and happy-number examples`, `Refs #344`).
The postcommit worktree has only untracked `tmp/`; both committed sources match
the admitted bytes and `git diff --check` still passes.
