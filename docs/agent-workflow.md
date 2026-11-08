# Agent configuration and reporting

The owner approved portable model guidance, aligned host settings and concise
outcome monitoring on 2026-10-18, **erring on the side of more intelligence**.
The [project policy](../AGENTS.md#models-effort-and-delegation) defines the
workload choices and applies even when an agent has no matching global policy.
Personal global guidance can carry the same principles across repositories.
These are starting points, not measured guarantees about model quality.

The owner's 2026-11-08 clarification assigns new proof/contract design, source
correspondence, uncertain proof diagnosis, proof-memory strategy, cross-system
proof integration and critical proof review to Astra Max.
Established implementation stays Sol Extra High; routine monitoring and evidence
collection stay Sol High. Reserve Ultra for a named unresolved problem with
useful parallel investigations. Apply the
[complete-helper-contract checks](../development.md#proof-loop-and-validation)
before an expensive integrated run. Tool execution time alone does not call for
a stronger monitoring agent or restarting a productive run.

## Host defaults and profiles

Store actual client settings in the host's Codex home, not in the Silver proof
toolchain or `scripts/`. Preserve unrelated provider, credentials, permission
and environment settings. For an unclassified task, select Astra Extra High;
use explicit profiles for work with an established approach or routine scope.

Relevant `config.toml` settings:

```toml
model = "gpt-6-astra"
model_reasoning_effort = "xhigh"
plan_mode_reasoning_effort = "xhigh"

[agents]
default_subagent_model = "gpt-6-astra"
default_subagent_reasoning_effort = "xhigh"
max_concurrent_threads_per_session = 3
```

The last setting permits three subagents plus the lead. It matches this
session's four total slots; it is a host setting, not a universal project limit.
It does not reserve native proof workers or cap process memory. Read the managed
run summary and use `--jobs N` or `--workers N` for actual validation. Preserve
one writer per resolved workspace and account for dense jobs' combined memory
requirements. `--task` labels work; use `--reason` where the existing runner
workflow requires a rationale. Model usage limits are separate resource limits:
retain completed evidence and report interrupted work, without treating an
unavailable agent as a proof failure or silently selecting a weaker model.

Named profiles live beside `config.toml` as `<name>.config.toml`:

| Profile | Model | Model and Plan effort | Intended use |
| --- | --- | --- | --- |
| `proof` | `gpt-6-astra` | `max` | New proof/contract design, source correspondence, uncertain proof diagnosis, memory strategy, proof integration and critical proof review |
| `implementation` | `gpt-6.1-sol` | `xhigh` | Established implementation, debugging, proof or checkable extraction |
| `routine` | `gpt-6.1-sol` | `high` | Routine implementation, documentation, monitoring, evidence collection and coordination |

Each profile sets `model`, `model_reasoning_effort` and
`plan_mode_reasoning_effort`; for example `codex --profile implementation`.
The conservative subagent defaults remain in the base configuration. Choose
each bounded worker's model and effort explicitly under the project policy;
the profile does not turn every future delegated task into routine work.
Select `gpt-6-astra` with `max` explicitly for delegated proof-role tasks;
do not let the generic Extra High default override that role. The `proof` profile
sets both model and Plan effort to `max`, while the generic base defaults and
native worker/memory controls remain unchanged. A guidance or profile edit does
not change a running agent's model or a proof process's resource allocation.

Custom role files are optional. They must follow the same policy and ownership
rules. Project `.codex/` configuration requires a trusted checkout, and role
instructions do not supply an independent permission boundary. Host defaults,
profiles, explicit launch choices and runtime overrides are distinct: validate
the installed client's parsing and effective values before reporting what is
active. Editing a file does not change the current lead's settings by itself.

## Review and round records

Use the existing task record, rather than a new report for every action:

| Round/work | Actual or selected model/effort | Intended result | Result and review rework | Available time/token/cost evidence |
| --- | --- | --- | --- | --- |
| Named phase | Identify which settings were confirmed | Concrete obligation or behavior | Integrated result and remaining gap | Measured scope; unavailable values explicitly labelled |

The [development workflow](../development.md#goal-and-review-bookkeeping)
requires these fields in substantive round records and model/effort information
in new reviews. Evaluate progress by resolved obligations, completed behavior,
reviewed integration and reduced uncertainty. Native tool time alone is not
whole-team cost, and an agent count or document count is not a success measure.
When a child receives a focused brief, include the governing requirements and
relevant decision/evidence excerpts; widen its reading when those are insufficient.

Model and effort guidance rechecked on 2026-11-08:

- [GPT-6 Astra and supported effort](https://developers.openai.com/api/docs/models/gpt-6-astra)
- [Configuration, effort and profile files](https://learn.chatgpt.com/docs/config-file/config-reference)

Other configuration and instruction guidance checked on 2026-10-18:

- [Subagents and custom roles](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [Global and project instruction discovery](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
