"""Durable local run history and cooperative leases for development commands.

History is a navigation aid, never proof authority. Only managed entrypoints
participate. Inherited flock descriptors keep resources reserved while a child
outlives its launcher; PIDs are recorded for diagnosis, not used as locks.
"""
from __future__ import annotations

from contextlib import contextmanager
from datetime import datetime, timezone
import fcntl
import hashlib
import json
import os
from pathlib import Path
import socket
import subprocess
import time
import uuid

if __package__:
    from .platforms import HostLayout
else:
    from platforms import HostLayout


class RunHistoryError(RuntimeError):
    """A managed operation could not safely start, or its history is unreadable."""


def _utc() -> str:
    return datetime.now(timezone.utc).isoformat()


def _json(value) -> str:
    return json.dumps(value, sort_keys=True, default=str, separators=(",", ":"))


def registry(host: HostLayout) -> Path:
    result = subprocess.run(
        ["git", "-C", str(host.root), "rev-parse", "--path-format=absolute", "--git-common-dir"],
        capture_output=True, text=True, check=False)
    if result.returncode == 0:
        machine = hashlib.sha256(socket.gethostname().encode()).hexdigest()[:16]
        return Path(result.stdout.strip()).resolve() / "silver-runs" / host.key / machine
    return host.artifacts / "run-history"


def available_cpus() -> int:
    try:
        return max(1, len(os.sched_getaffinity(0)))
    except (AttributeError, OSError):
        return max(1, os.cpu_count() or 1)


@contextmanager
def _metadata(root: Path):
    root.mkdir(parents=True, exist_ok=True)
    with (root / "metadata.lock").open("a+b") as stream:
        fcntl.flock(stream, fcntl.LOCK_EX)
        yield


def _append(path: Path, record: dict) -> None:
    record = dict(record, utc=_utc(), monotonic_ns=time.monotonic_ns())
    with path.open("a", encoding="utf-8") as stream:
        stream.write(_json(record) + "\n")
        stream.flush()
        os.fsync(stream.fileno())


def _read(path: Path) -> list[dict]:
    if not path.exists():
        return []
    records = []
    lines = path.read_text().splitlines(keepends=True)
    for index, line in enumerate(lines):
        # A complete newline terminates each committed journal record.
        if index == len(lines) - 1 and not line.endswith("\n"):
            break
        try:
            records.append(json.loads(line))
        except (ValueError, TypeError) as error:
            raise RunHistoryError(f"unreadable run history: {path}: {error}") from error
    return records


def _leased(path: Path) -> bool:
    with path.open("a+b") as stream:
        try:
            fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return True
    return False


def _runs(root: Path) -> list[dict]:
    result = []
    for directory in sorted(root.glob("runs/*")):
        events = _read(directory / "events.jsonl")
        if not events:
            continue
        start = dict(events[0])
        for event in events:
            if event.get("event") == "prepared":
                start.update({key: event[key] for key in ("inputs", "fingerprint", "scope", "expensive")})
        terminal = next((event for event in reversed(events)
                         if event.get("event") == "finished"), None)
        active = _leased(directory / "lease")
        state = "active" if active else terminal["outcome"] if terminal else "interrupted"
        result.append(dict(start, state=state, active=active, directory=str(directory),
                           events=events, finish=terminal))
    return sorted(result, key=lambda record: record["utc"])


def _same_scope(left: dict, right: dict) -> bool:
    return all(left.get(key) == right.get(key) for key in ("task", "kind", "scope"))


def _pending_failures(runs: list[dict], notes: list[dict], current: dict) -> dict[str, int]:
    counts: dict[str, int] = {}
    diagnosed = max((note["utc"] for note in notes if note.get("event") == "diagnostic"
                     and _same_scope(note, current)), default="")
    for run in sorted(runs, key=lambda item: item["utc"]):
        if not _same_scope(run, current) or run["utc"] <= diagnosed:
            continue
        if run["state"] == "success":
            counts.clear()
        elif run["state"] == "failure":
            for key in run["finish"].get("failure_keys", []):
                counts[key] = counts.get(key, 0) + 1
    return counts


def _paths(paths) -> list[dict[str, str]]:
    return [{"original": str(path), "resolved": str(Path(path).resolve())} for path in paths]


def _overlap(left: str, right: str) -> bool:
    a, b = Path(left), Path(right)
    return a == b or a.is_relative_to(b) or b.is_relative_to(a)


def _obligation_key(record: dict) -> str | None:
    rule, file = record.get("rule"), record.get("file")
    if not isinstance(rule, str) or not isinstance(file, str):
        return None
    return f"{file}:{record.get('line', 0)}:{record.get('col', 0)}:{rule}"


def _rows(value) -> list:
    return value if isinstance(value, list) else []


def _report_files(paths) -> list[Path]:
    selected = set()
    for source in paths:
        path = Path(source)
        selected.update(path.glob("*.spark") if path.is_dir() else [path])
        if path.is_dir():
            selected.update([path / "gnatprove.sarif", path / "gnatprove.out"])
    return sorted(path for path in selected if path.is_file())


def _report_identity(path: Path) -> tuple | None:
    try:
        stat = path.stat()
        return (stat.st_dev, stat.st_ino, stat.st_size, stat.st_mtime_ns, stat.st_ctime_ns)
    except FileNotFoundError:
        return None


def failed_obligations(paths) -> list[str]:
    """Read final check results, deliberately ignoring individual solver attempts."""
    failures = set()
    for path in _report_files(paths):
        try:
            report = json.loads(path.read_text())
        except (OSError, ValueError):
            continue  # Parse/tool failures remain failed runs without invented VCs.
        if not isinstance(report, dict):
            continue
        if path.suffix == ".spark":
            for record in _rows(report.get("proof")):
                if not isinstance(record, dict):
                    continue
                if (record.get("severity") != "info"
                        or record.get("how_proved") not in ("flow", "prover", "trivial")):
                    key = _obligation_key(record)
                    if key:
                        failures.add(key)
        elif path.suffix == ".sarif":
            for run in _rows(report.get("runs")):
                if not isinstance(run, dict):
                    continue
                for result in _rows(run.get("results")):
                    if not isinstance(result, dict):
                        continue
                    rule = result.get("ruleId", "")
                    if not isinstance(rule, str) or not rule.startswith("VC_") or result.get("kind") in ("pass", "informational"):
                        continue
                    for location in _rows(result.get("locations")):
                        if not isinstance(location, dict):
                            continue
                        physical = location.get("physicalLocation", {})
                        if not isinstance(physical, dict):
                            continue
                        region = physical.get("region", {})
                        artifact = physical.get("artifactLocation", {})
                        if not isinstance(region, dict) or not isinstance(artifact, dict):
                            continue
                        key = _obligation_key(dict(rule=rule,
                            file=artifact.get("uri"),
                            line=region.get("startLine", 0), col=region.get("startColumn", 0)))
                        if key:
                            failures.add(key)
    return sorted(failures)


class ManagedRun:
    def __init__(self, host: HostLayout, kind: str, command: list[str], inputs: dict,
                 resources, workers: int | None = None, task: str = "", reason: str = "",
                 expensive: bool = False, evidence=(), failure_reports=(), failure_keys=()):
        if workers is not None and (type(workers) is not int or workers < 0):
            raise RunHistoryError("workers must be nonnegative or None for available CPUs")
        self.host, self.root = host, registry(host)
        self.run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S") + "-" + uuid.uuid4().hex[:12]
        self.directory = self.root / "runs" / self.run_id
        self.workers = 0
        self.requested_workers = workers
        self.evidence, self.failure_reports = list(evidence), list(failure_reports)
        self.failure_keys = list(failure_keys)
        self._lease = None
        self._finished = False
        self._start_ns = 0
        self._report_baseline = {}
        # Callers include stable configuration in inputs. Generated cold output
        # names are excluded; the actual argv is retained independently below.
        fingerprint = hashlib.sha256(_json(dict(kind=kind, inputs=inputs)).encode()).hexdigest()
        self.record = dict(event="started", schema=1, run_id=self.run_id, kind=kind,
                           command=command, inputs=inputs, fingerprint=fingerprint,
                           host=host.key, machine=socket.gethostname(), pid=os.getpid(),
                           worktree=_paths([host.root])[0], resources=_paths(resources),
                           requested_workers=workers, task=task, scope=inputs.get("scope", kind),
                           reason=reason, expensive=expensive, evidence=_paths(evidence))

    @property
    def pass_fds(self) -> tuple[int, ...]:
        return (self._lease.fileno(),) if self._lease is not None else ()

    def __enter__(self):
        with _metadata(self.root):
            runs = _runs(self.root)
            active = [run for run in runs if run["active"]]
            conflicts = [run["run_id"] for run in active
                         if any(_overlap(a["resolved"], b["resolved"])
                                for a in self.record["resources"] for b in run["resources"])]
            if conflicts:
                raise RunHistoryError("resources are held by active run(s): " + ", ".join(conflicts))
            capacity = available_cpus()
            used = sum(run["workers"] for run in active)
            self.workers = max(0, capacity - used) if self.requested_workers is None else self.requested_workers
            if ((self.requested_workers is None and not self.workers)
                    or self.workers > max(0, capacity - used)):
                raise RunHistoryError(f"worker budget unavailable ({used}/{capacity} reserved); active run(s): "
                                      + ", ".join(run["run_id"] for run in active))
            self.record["fingerprint"] = hashlib.sha256(_json(dict(
                kind=self.record["kind"], inputs=self.record["inputs"], workers=self.workers)).encode()).hexdigest()
            self._check_policy(runs)
            self.directory.mkdir(parents=True)
            try:
                self._lease = (self.directory / "lease").open("a+b")
                fcntl.flock(self._lease, fcntl.LOCK_EX | fcntl.LOCK_NB)
                self._start_ns = time.monotonic_ns()
                self._report_baseline = {str(path): _report_identity(path)
                                         for path in _report_files(self.failure_reports)}
                self.record.update(workers=self.workers, available_cpus=capacity)
                _append(self.directory / "events.jsonl", self.record)
            except BaseException:
                if self._lease is not None:
                    self._lease.close()
                    self._lease = None
                raise
        return self

    def _check_policy(self, runs: list[dict]) -> None:
        if self.record["expensive"] and not self.record["reason"].strip():
            previous = next((run for run in reversed(runs) if run["state"] == "success"
                             and run["fingerprint"] == self.record["fingerprint"]), None)
            if previous:
                raise RunHistoryError("identical expensive run already succeeded: " + previous["run_id"]
                                      + "; supply --reason to repeat it")
        failures = _pending_failures(runs, _read(self.root / "notes.jsonl"), self.record)
        repeated = {key: count for key, count in failures.items() if count >= 3}
        if repeated:
            raise RunHistoryError("repeated unresolved obligations need a diagnostic note before another run: "
                                  + _json(repeated))

    def prepare(self, inputs: dict, expensive: bool = False) -> None:
        """Bind preflight identities while holding the lease, before any proof."""
        if self._lease is None or self._finished:
            raise RunHistoryError("prepare requires an active run")
        fingerprint = hashlib.sha256(_json(dict(kind=self.record["kind"], inputs=inputs,
                                                workers=self.workers)).encode()).hexdigest()
        self.record.update(inputs=inputs, scope=inputs.get("scope", self.record["kind"]),
                           fingerprint=fingerprint, expensive=expensive)
        with _metadata(self.root):
            _append(self.directory / "events.jsonl", dict(event="prepared", run_id=self.run_id,
                **{key: self.record[key] for key in ("inputs", "scope", "fingerprint", "expensive")}))
            self._check_policy(_runs(self.root))

    def event(self, event_name: str, **details) -> None:
        if event_name in ("started", "finished"):
            raise RunHistoryError("reserved run event name")
        with _metadata(self.root):
            _append(self.directory / "events.jsonl", dict(details, event=event_name, run_id=self.run_id))

    def finish(self, outcome: str = "success", returncode: int | None = None, failure_keys=(), **details) -> None:
        if self._finished:
            return
        if outcome not in ("success", "failure", "interrupted"):
            raise RunHistoryError(f"invalid run outcome: {outcome}")
        if outcome == "success" and returncode not in (0, None):
            raise RunHistoryError("a nonzero child status cannot finish successfully")
        changed_reports = [path for path in _report_files(self.failure_reports)
                           if _report_identity(path) != self._report_baseline.get(str(path))]
        keys = sorted(set([*self.failure_keys, *failure_keys,
                          *failed_obligations(changed_reports)])) if outcome == "failure" else []
        # Preserve reports before a later managed command replaces its output.
        copies = []
        for index, source in enumerate(self.failure_reports if outcome != "success" else ()):
            source = Path(source)
            paths = [*source.glob("*.spark"), source / "gnatprove.sarif", source / "gnatprove.out"] if source.is_dir() else [source]
            for path in paths:
                if path.is_file():
                    target = self.directory / "reports" / str(index) / path.name
                    target.parent.mkdir(parents=True, exist_ok=True)
                    target.write_bytes(path.read_bytes())
                    copies.append(dict(original=str(path), retained=str(target)))
        with _metadata(self.root):
            _append(self.directory / "events.jsonl", dict(details, event="finished", run_id=self.run_id,
                outcome=outcome, returncode=returncode, duration_seconds=(time.monotonic_ns() - self._start_ns) / 1e9,
                failure_keys=keys, evidence=_paths(self.evidence), retained_reports=copies))
        self._finished = True

    def __exit__(self, exception_type, exception, traceback):
        try:
            if exception is None:
                self.finish()
            else:
                interrupted = isinstance(exception, (KeyboardInterrupt, SystemExit))
                returncode = getattr(exception, "returncode", None)
                if returncode is not None and returncode < 0:
                    interrupted = True
                self.finish("interrupted" if interrupted else "failure", returncode=returncode,
                            error=f"{type(exception).__name__}: {exception}")
        finally:
            # Never LOCK_UN: a live child can share this open file description.
            if self._lease is not None:
                self._lease.close()
                self._lease = None
        return False


def status(host: HostLayout, task: str = "") -> dict:
    root = registry(host)
    with _metadata(root):
        runs = _runs(root)
        notes = _read(root / "notes.jsonl")
        reserved_workers = sum(run["workers"] for run in runs if run["active"])
        if task:
            runs = [run for run in runs if run.get("task") == task]
            notes = [note for note in notes if note.get("task") == task]
        return dict(registry=str(root), host=host.key, machine=socket.gethostname(),
                    runs=runs, notes=notes, available_cpus=available_cpus(),
                    reserved_workers=reserved_workers)


def diagnose(host: HostLayout, run_id: str, summary: str, next_step: str) -> dict:
    if not summary.strip() or not next_step.strip():
        raise RunHistoryError("diagnosis requires a summary and next step")
    root = registry(host)
    with _metadata(root):
        run = next((run for run in _runs(root) if run["run_id"] == run_id), None)
        if run is None:
            raise RunHistoryError(f"unknown run: {run_id}")
        note = dict(event="diagnostic", run_id=run_id, task=run["task"], kind=run["kind"],
                    scope=run["scope"], summary=summary, next_step=next_step)
        _append(root / "notes.jsonl", note)
        return note


def checkpoint(host: HostLayout, task: str, summary: str, next_check: str) -> dict:
    if not task.strip() or not summary.strip() or not next_check.strip():
        raise RunHistoryError("checkpoint requires task, summary and next check")
    root = registry(host)
    with _metadata(root):
        note = dict(event="checkpoint", task=task, summary=summary, next_check=next_check,
                    worktree=str(host.root))
        _append(root / "notes.jsonl", note)
        return note
