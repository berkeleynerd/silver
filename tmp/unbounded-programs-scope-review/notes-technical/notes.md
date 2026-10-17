# Technical-soundness review notes (read-only)

Inputs read: docs/unbounded-programs.md, roadmap/session-memory diff, issues A-H, oracle.md, AGENTS.md,
development.md, language.md (:380-400, :495-520, :690-805), README.md (:170-215, :300-345), src/silver.adb,
src/silver_platform.ads/.adb, src/silver_libc.ads, src/silver_libraries.ads, src/silver_library_reports.adb:1200-1220,
scripts/bootstrap.py:200-245, scripts/check_evidence.py:55-90, tests/test_samples.py:1-60,
proof/Silver/Current.lean:150-329, docs/trusted-boundary.md:60-95,146-175, docs/assurance.md:799-830,
catalogue keys, research T1/T3/T4/T5 notes, T4 fit, evidence JSON, producer source
(configuration.adb Set_Level_Timeout_Steps_Provers; why3 gnat_checks.ml schedule_goal; controller_itp.ml queue).
Pinned gnatprove --help checked.

Key evidence:
- bootstrap.py runtime_source_configuration only embeds library bytes; per-program -U proof + Check_Proof_Evidence audits library reports.
- language.md:773,784; assurance.md:821; README:183; development.md:219-220 make library/Main proof per compile mandatory.
- tests/test_samples.py pins --level=2, steps 100000, memlimit 1000, -j0, why3session limits; audits library reports per program.
- trusted-boundary.md:171-176: runtime Spawn reports status 1 for exec failure; signals -> non 0..255 -> 3.
- Tool commands run through libc system() with Alire_Exec prefix (sh -> alr exec -> gnatprove).
- Silver_Platform.Max_File_Length 16 MiB; silver.adb:300-305 explicit check -> status 3.
- T1: Natural'Last-1 report storage => envelope S <= 587,402; producer node counter 2^31-1.
- T4: 25-52 node ids per source byte => counter overflow near 40-80 MB source.
- T3: List cap ~50M elsif arms, ~44 GB RAM; table.adb unchecked growth.
- why3 controller: FIFO queue, max running = -j; interrupt only on Valid of the same goal.
