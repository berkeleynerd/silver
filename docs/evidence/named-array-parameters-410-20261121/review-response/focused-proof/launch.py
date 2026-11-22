from pathlib import Path
from datetime import datetime, timezone
import json, os, subprocess, time, uuid

review = Path(__file__).resolve().parent
session_id = str(uuid.uuid4())
command = ["/home/agent/.local/bin/claude", "--print", "--model", "claude-fable-5-2", "--effort", "max", "--safe-mode", "--strict-mcp-config", "--permission-mode", "dontAsk", "--permission-prompts", "none", "--tools", "Bash,Read,Glob,Grep,Write", "--allowedTools", "Bash,Read,Glob,Grep,Write", "--add-dir", str(review), "--add-dir", str(review.parents[1]), "--session-id", session_id, "--output-format", "stream-json", "--verbose", "--name", "Silver PR412 focused proof review"]
started = datetime.now(timezone.utc).isoformat()
tick = time.monotonic()
environment = os.environ.copy()
environment["PYTHONDONTWRITEBYTECODE"] = "1"
environment["TMPDIR"] = str(review / "scratch")
with (review / "prompt.md").open() as prompt, (review / "stream.jsonl").open("w") as output, (review / "stderr.log").open("w") as errors:
    child = subprocess.Popen(command, cwd=Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/external-review-pr412-5a4b0ad8ac/worktree'), stdin=prompt, stdout=output, stderr=errors, env=environment, start_new_session=True)
    metadata = {"started_at": started, "pid": child.pid, "pgid": child.pid, "session_id": session_id, "command": command, "worktree": '/home/canto/src/github.com/berkeleynerd/silver/tmp/external-review-pr412-5a4b0ad8ac/worktree', "selected_model": "claude-fable-5-2", "selected_effort": "max", "inherited_cpu_affinity": sorted(os.sched_getaffinity(0)), "effort_environment": {k: environment[k] for k in ("CLAUDE_EFFORT", "CLAUDE_CODE_EFFORT_LEVEL") if k in environment}}
    (review / "launch.json").write_text(json.dumps(metadata, indent=2) + "\n")
    print(json.dumps(metadata), flush=True)
    code = child.wait()
result = {"started_at": started, "finished_at": datetime.now(timezone.utc).isoformat(), "elapsed_seconds": time.monotonic()-tick, "returncode": code, "session_id": session_id}
(review / "exit.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result), flush=True)
raise SystemExit(code)
