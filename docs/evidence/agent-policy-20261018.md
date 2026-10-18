# Model policy implementation and validation

2026-10-18, Linux x86_64. Owner-authorized workflow/configuration work; the
[portable policy](../../AGENTS.md#models-effort-and-delegation) and
[configuration guide](../agent-workflow.md) describe the resulting behavior.
The policy review target is `ffa3789a1ab7d14c2d504536a383d2ed8f5c17bb`;
later additions retain this evidence. No production or proof input changed.

The host's `/home/agent/.codex/config.toml` now selects Astra Extra High for the
lead, Plan mode and unspecified subagents, with three spawned-agent slots.
The `proof`, `implementation` and `routine` profile files implement the documented
choices. The original configuration is backed up under the host's Codex-home
`backups/model-policy-20261018T172256Z/`. Recursive comparison of parsed old/new
configuration confirmed that only the intended model, plan and agent-policy
keys changed; provider, permission, credential and other settings were preserved.
The global `AGENTS.md` carries the same stronger-default and reporting guidance.

Validation with installed `codex-cli 0.163.0`:

- TOML parsing and expected-value checks passed for the base and three profiles.
- App-server `initialize` and `config/read` confirmed the effective base model,
  model/Plan efforts and three agent settings. No thread or model turn started.
- `codex --profile NAME debug prompt-input` succeeded for all three profiles
  without a model turn. Profile values were checked separately by parsing their
  files; app-server does not accept `--profile` in this client.
- Strict loading encountered the pre-existing unrecognized
  `mcp_servers.mcp-gateway.type` field. That unrelated setting was preserved;
  normal effective-config loading passed. No strict whole-config pass is claimed.
- All 45 checked local documentation links and whitespace checks passed. Global
  plus project instructions total 15,065 bytes, below the default 32 KiB limit.

[Sanitized validation results](agent-policy-20261018.json) retain these scopes.
No Silver build, GNATprove, Lean or full-suite run was needed for these
documentation and host-setting changes. A saved configuration change and a
successful configuration query do not switch an already running lead or prove
future account/model access. No live lead switch was performed.

One independent reviewer was launched with **GPT-6 Astra, Extra High**, under a
bounded read-only task. It reviewed the exact commit, global guidance and host
TOML files and found no blocking issue. Its additional checks confirmed preserved
unrelated settings and all four official reference links. The launch selection
is known; the reviewer's runtime model/effort and total elapsed/token/cost figures
were not exposed. The lead setting was not changed or independently confirmed.

Round outcome: portable guidance, saved host defaults and selectable workload
profiles implemented; effective base settings and profile loading validated;
review identified no policy rework. CLI restrictions on strict loading/profile
queries were resolved by using supported read-only checks with narrower claims.
This is delivery evidence, not a model-quality comparison. CLI memory was
unavailable and was not updated.
