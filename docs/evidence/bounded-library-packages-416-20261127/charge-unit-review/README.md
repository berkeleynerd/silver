# Independent Charge_Unit proof review — 2026-11-27

Review target: primary commit `c0c3ab011a`, the ten
`ApplicationAdmissionCharge*.lean` modules, their imported control/expression
interfaces, admission callee adapter, and frozen native Charge_Unit fragment.
The reviewer did not implement these modules. Assigned category: critical
proof/source correspondence, Astra Max; live model/effort is not independently
exposed. No new proof or native run was launched for this review.

No consequential defect was found within the reviewed helper/evaluator/callee
scope. The reviewed module bytes still matched primary when checked. The
retained native fragment exactly matches Output_Profile `f91894e7a0f7088...`;
complete hashes and evidence scope are in `review-inputs.json`.

The review checked these substantive points:

- The theorem covers every native valid text and incoming Remaining in its
  subtype. Its semantic execution theorem is stronger, accepting any natural
  allowance. There is no syntax, admitted-source or successful-parse premise.
  The native output-capacity corollary reinstates the original allowance bound.
- Uninitialized local declarations preserve arbitrary prior storage. The body
  initializes Position and Accepted, and each later read follows the original
  assignment. The local typed checker verifies scope, writable storage,
  expression form and declaration types for this exact body.
- Statement sequencing, early return and plain-loop execution preserve the
  original read/advance/decrement order. In particular, a charged token advances
  the local cursor before detecting exhausted allowance. The proof observes
  Remaining and Accepted, so it does not falsely equate that private cursor
  with the model's cursor on rejection.
- The character, name, integer and quote branches have their actual callee
  arguments. Name_Is receives a span established by successful Name_After;
  skip and other lexical calls receive derived cursor bounds. The `/=` special
  case is uncharged, and the operator-byte set is exactly the native set.
- `scanStep_contract` proves each continuing branch decreases the original
  cursor measure, and `loop_total` constructs finite execution. Uniqueness then
  establishes both outputs on every return path. No fuel cutoff or acceptance
  equality is substituted for complete execution.
- `Library.reader` chooses the model result only after the complete original
  body execution has been proved uniquely equivalent to it. The library does
  not assume an independent Charge_Unit/model equality. Its admission adapter
  uses the existing command that writes Remaining and Accepted separately.

The retained final focused evidence is run `20261127T212641-fd10ff7168f9`, with
162 modules and a fresh 22,477-declaration axiom audit. That scope includes the
loop, binding and frozen candidate. It does **not** include
`ApplicationAdmissionChargeSourceChecks`, as the implementation evidence
explicitly states. The review therefore leaves the actual full-source
extraction, final admission/source integration and required native safety
evidence as separate pending gates. The fragment comparison is not a substitute
for the authoritative Lean source check, and this review is not a new kernel
replay or complete application assurance result.
