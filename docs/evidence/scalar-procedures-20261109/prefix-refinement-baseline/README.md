# Procedure prefix refinement mismatch, 2026-11-10

Managed Linux admission-probe run `20261110T010044-1b40996e99ec` confirmed the
native/source-model mismatch found during sequential-prefix correspondence.
With `Den` ranging over `0 .. 1`, an unused procedure whose Boolean output
initializer is `N > 0 and then (1 / N) = 1` was rejected when N had mode `in`.
The same guarded expression passed after an initial `B := False`, and passed
directly in the prefix when N had mode `in out`.

The native prefix used `Context_Of(Read_Frame)` with every input counted as a
declaration. `Bare_Target` therefore excluded immutable input formals from
refinement. Ordinary body contexts count only locals as declarations and can
refine those formals. The initial semantic prefix model followed ordinary
formal refinement; its equivalence to the native prefix was not established.

The run's success means that it reproduced all three expected baseline
outcomes (2, 0, 0). It is not evidence of a repaired compiler or a completed
source bridge. The selected repair threads the actual local declaration count
through the native prefix helpers and their models, preserving the intended
pure condition grammar and full formal domains. Regression
`test_prefix_guards_refine_input_formals_like_body_guards` includes both
short-circuit directions and an unguarded rejection control.

The compressed log/events are original managed output; the script and three
Ada sources are the probe inputs. `summary.json` is a lead-authored index.
Each compressed payload was checked against its original bytes. The native
author separately confirmed the same outcomes. Full native/helper and source
checks of the repair remain pending.
