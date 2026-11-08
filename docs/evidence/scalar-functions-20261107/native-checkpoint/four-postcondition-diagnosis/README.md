# Four native postcondition failures

Independent review commit `93968a970dc749a2efd333d8905180e8541fa8cd`, integrated
as `b9a557ad9a`, diagnoses failed complete run
`20261108T040128-2651963b8574` on native source `560144172c`.
[DIAGNOSIS.md](DIAGNOSIS.md) records the exact failures and full-domain witness.
The original failed run remains under [warning-cleanup](../warning-cleanup/).

The coordinator independently compared all 103 regular archive members with the
reviewer's retained originals, and verified the archive length and SHA256 before
copying it here. [index.json](index.json) lists every member's hash and length.
The archive hash is
`8e778022d872a81092910454bc9c6f23fc5ad790209fea593b2833307f530df1`.
This is diagnostic evidence, not a successful native audit or a source repair.

The reviewed `Parameter_Frame` entry guard is separate source commit
`b8365c0606e0d2e185e89a73264b10cf72530e06`. Its single focused native run
`20261108T084757-1036cb8a0958` exited successfully; the native owner retains the
complete evidence separately. Source integration and the other three repairs
remain outstanding, as do complete native and Lean/source audits.
