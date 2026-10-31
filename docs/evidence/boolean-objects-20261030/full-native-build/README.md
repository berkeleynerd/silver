# Matching compiler build

Issue #291, native Linux x86_64, 2026-10-30. Managed build
`20261030T214749-120a2c44c6f6` passed in 10.742 s at four workers. It compiled
the catalogue and output-profile bodies, bound and linked `silver`, and retained
the unchanged image adapter. All 143 tracked native source/script/project inputs
exactly match `598a56b969cc0f5b68de7f674ac8bd9c48b602fd`; the output-profile
body SHA-256 is `88b54a1df3e6cb1b59c482d36cd29a9f15c2506c69227fbef78c9ab93ab67ddb`.
This is the same frozen source as the two successful complete focused readers.
All 143 tracked native inputs also match the lead's integrated source/certificate
checkpoint `87dd912436e35569f12cf95be639e4a534dea978`, as separately recorded in
`integration-input-correspondence.json`.

The managed terminal check and a separate post-run check both verified all
2,561 captured native input hashes. The compressed journal retains the complete
input/tool identities and effective build command. `terminal-input-verification.json`
records both resulting executable identities, including `silver` SHA-256
`56af3bd83fcbdd257bc10655fdeb5e59c098ea861b2621103bb99c202b02491c`.
`snapshot-manifest.json` binds the tracked inputs and original two-file restoration
backups; updating its validation identity did not change either original backup.

This build precedes the complete strict native proof and its source restoration.
The build alone does not establish complete native proof, Lean correspondence or
the remaining regression scope. The duration is managed native execution, not
total team elapsed time. Selected worker: GPT-6 Astra / Extra High; runtime model
confirmation and token/cost measurements are unavailable.
