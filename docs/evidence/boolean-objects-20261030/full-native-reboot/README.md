# Native proof recovery after host reboot

Issue #291, native Linux, 2026-10-30. Run `20261030T185133-160271e45fa1`
was interrupted without a `finished` event. The host boot time is 19:37 UTC;
its original log and journal remain intact. The exact end time and exit code
are unknown. This interruption is not a successful complete proof.

Before restarting, all 2,561 preflight hashes were rechecked, as were all 143
checkpoint source/script/project inputs and the two original source backups.
All 143 checkpoint inputs also match integration commit `59cfd9c3dc55c843686c5d5d07df120afbde20e6`.
The interrupted run's complete available artifact inventory contains 2,534
files: 2,164 are byte-identical to the previously retained recovery snapshot;
the remaining 370 files (37,434,825 bytes) were copied and byte-verified in
its local `supplemental-reboot-recovery/`. The compressed snapshot index and
`recovery.json` identify both locations without duplicating the earlier
1.887 GB snapshot. The populated proof cache remains at its original path.

Replacement `20261030T194142-1f663fdf10c2` was launched detached as PID 1389,
with four managed workers. Its captured input/tool record and effective command
are identical to the interrupted run. It uses the full strict managed proof
route, including complete report and provenance auditing; no source, proof
policy or cache tuning changed. The companion detached terminal helper
retains complete reports and the 143 frozen inputs, checks terminal hashes and
successful auditing, then restores only the two temporary source replacements.
The replacement subsequently failed on two exact checks; see
[the terminal failure packet](../full-native-failed-194142/README.md).
The helper retained the failure and correctly left the source frozen.
Complete native assurance and restoration remain outstanding.

Selected recovery worker: GPT-6 Astra / Extra High; runtime confirmation and
token/cost measurements are unavailable. This round recovered the frozen
validation without changing the implementation. Elapsed native proof time and
check totals will be reported from the eventual terminal record.
