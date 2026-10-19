# Preserved native-checkpoint reviewer scratch

Record-only preservation on 2026-10-19 for review-a3af180047 L5/L14.
[Manifest](manifest.json) lists original workspace-relative paths, byte counts
and SHA-256 values for every member of [the archive](review-scratch.tar.gz).
All bytes were copied from existing scratch, without rerunning any probe.

The archive retains the native aggregate 92-check and driver 593-check scripts,
results and source fixtures; the binder-assembler 663-check script and results;
the frontend/binder 1,031-assertion output, author-recheck and re-extraction
outputs; and the integration freeze identity-check output. Historical scripts
retain their original worker paths and prerequisites; this is evidence
preservation, not a newly portable test harness or a new successful execution.
The frontend/binder independent harness was not found in the named scratch
folder; its output is preserved, and the report's procedure remains prose-only.

Original input/review identities and limitations are in the
[disposition](../../review-a3af180047-disposition.md). The external Claude review's
own scratchpad was not available on this host; its notes and additional probes
remain report-described evidence, not contents of this archive. No claim that
all reviewer checks are now reproducible from this archive is made.
