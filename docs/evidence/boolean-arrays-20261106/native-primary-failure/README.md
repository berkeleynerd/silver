# Read_Primary_Into native failure and focused repair evidence

The original complete native run `20261106T232644-673fc5a9c06b` is still active,
with a completed `Read_Primary_Into` helper failure at `def'vc.448`. It must
remain a failed run. Other pending helpers continue unchanged; terminal logs,
reports and the original driver diagnostic will be retained here before a later
source mutation. The initial [record](record.json) and
[input comparison](input-comparison.json) identify the original snapshot.

The original source hash is
`1686b0b61da8c684ce185995621fb08bc5a6932893d2cc859a82ced9922ce4e8`.
The complete generated task, final helper session, shapes, source and managed
preflight are retained. All 144 selected native/feature source, script, project
and catalogue inputs matched at capture; the original preflight additionally
records all 2,586 native input hashes and tool identities. Already-completed
solver temporary files were absent, so the original failed solver inputs are
not claimed to have been recovered.

A separate original-path installation, `tmp/image-case-repair`, holds the
one-line Static assertion candidate on branch
`repair/boolean-primary-cut-20261107`. Its source hash is
`c1ce845a597605c152119bedc6b07f1aa3bccece5d2870addb86cd18077fffaa`.
The original canonical audit tree was not changed by these experiments. The
lead subsequently integrated the reviewed candidate at `e0d2521d5d`. At this
checkpoint all 144 selected native inputs in the candidate installation match
that integration, as the [dated comparison](candidate-integration-input-comparison.json)
records. The earlier original-input comparison remains historical: integration
now intentionally differs at `src/silver_output_profile.adb`, while the
original audit still uses its captured source.

| Focused result | Exact scope | Managed duration | Retained evidence |
| --- | --- | --- | --- |
| `20261107T031832-c8c7ca1eac6d`: passed | New `VC_ASSERT` at 3661:35 and its call precondition; 2 proof records and 2 contextual flow records | 99.713 s | [Assertion record](focused-assertion/record.json), including 57 saved SMT/PSMT inputs |
| `20261107T032305-5aa13a4739f2`: passed | Original `VC_POSTCONDITION` at 3570:28; its 4 subgoals proved, with 1 proof record and 2 contextual flow records | 77.761 s | [Postcondition record](focused-original-postcondition/record.json), including 12 freshly saved SMT/PSMT inputs |

Both checks used level 2, the ordinary three provers, 30-second prover limits,
1,000 MiB prover memory limits and two reserved workers. The assertion and
postcondition were selected separately with supported singular `--limit-line`
and the same declaration selection at 3562. The first report and its saved
inputs were retained before the second run. Archives were reopened and every
member's bytes checked against its recorded SHA-256.

These two focused passes do not establish whole-helper or complete native
assurance. A later complete-helper scoped run,
`20261107T032921-a797df49b155`, is now active with the same candidate, two
workers, ordinary proof limits and declaration selection at 3562, with no line
limiter. Its terminal result remains pending. No complete compiler rerun,
binary rebuild, application execution, staging, commit or publication was
performed by this native subthread. The lead's source integration is recorded
separately above.
The original regression binary hash remained
`c3f97c7f6477931ad01c76c3be658db06fc4c02f997a6475f921eee9a5362790`.
The lead owned the explicitly recorded Lean Shape pause and subsequent
termination; its original runner, Lake, Shape process and lease were confirmed
absent before the complete-helper experiment began.

The selected native subthread setting remains GPT-6.1 Sol / Extra High from
the original assignment; runtime setting confirmation and token/cost data are
unavailable. Independent diagnosis and any repair disposition are separate
review inputs owned by the lead.
