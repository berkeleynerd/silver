"""Durable local run history and cooperative leases for development commands.

History is a navigation aid, never proof authority. Only managed entrypoints
participate. Inherited flock descriptors keep resources reserved while a child
outlives its launcher; PIDs are recorded for diagnosis, not used as locks.
"""
from __future__ import annotations

from collections.abc import Callable
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
    from .platforms import CPU_LIMIT_REASON, HostLayout, cpu_budget, process_cpus
else:
    from platforms import CPU_LIMIT_REASON, HostLayout, cpu_budget, process_cpus

# Failed runs of one obligation, or of one helper and check kind, before the
# next run needs a diagnostic note. Both recurrence rules compare against it.
_RECURRENCE_BOUNDARY = 3


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
    return cpu_budget()


def _restrict_affinity(workers: int) -> tuple[dict[int, set[int]], list[int]]:
    """Restrict existing launcher threads; future threads/children inherit it."""
    if not hasattr(os, "sched_getaffinity") or not hasattr(os, "sched_setaffinity"):
        return {}, []
    selected = sorted(os.sched_getaffinity(0))[:max(1, workers)]
    saved = {}
    try:
        # Linux affinity is per-thread. Rescan until every current parent has
        # been constrained, including threads born while the first pass ran.
        while True:
            tasks = [int(path.name) for path in Path("/proc/self/task").iterdir()]
            pending = [tid for tid in tasks if tid not in saved]
            if not pending:
                break
            for tid in pending:
                try:
                    saved[tid] = os.sched_getaffinity(tid)
                    os.sched_setaffinity(tid, selected)
                except ProcessLookupError:
                    saved.pop(tid, None)
    except BaseException:
        _restore_affinity(saved)
        raise
    return saved, selected


def _restore_affinity(saved: dict[int, set[int]]) -> None:
    for tid, affinity in saved.items():
        try:
            os.sched_setaffinity(tid, affinity)
        except ProcessLookupError:
            pass


@contextmanager
def _metadata(root: Path):
    root.mkdir(parents=True, exist_ok=True)
    with (root / "metadata.lock").open("a+b") as stream:
        fcntl.flock(stream, fcntl.LOCK_EX)
        yield


def _append(path: Path, record: dict) -> None:
    record = dict(record, utc=_utc(), monotonic_ns=time.monotonic_ns())
    # Callers hold the metadata lock. Preserve an interrupted append before
    # restoring the newline boundary, so the next record cannot join its tail.
    with path.open("a+b") as stream:
        stream.seek(0, os.SEEK_END)
        if stream.tell():
            stream.seek(-1, os.SEEK_END)
            if stream.read(1) != b"\n":
                stream.seek(0)
                previous = stream.read()
                boundary = previous.rfind(b"\n") + 1
                retained = path.with_name(path.name + ".interrupted-" + uuid.uuid4().hex)
                with retained.open("xb") as fragment:
                    fragment.write(previous[boundary:])
                    fragment.flush()
                    os.fsync(fragment.fileno())
                stream.truncate(boundary)
        stream.write((_json(record) + "\n").encode("utf-8"))
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
        start["effective_reserved_workers"] = start["workers"]
        for event in events:
            if event.get("event") == "prepared":
                start.update({key: event[key] for key in ("inputs", "fingerprint", "scope", "expensive")})
            elif event.get("event") == "command":
                start.update({key: event[key] for key in ("command", "cwd") if key in event})
            elif event.get("event") == "resource-adjusted":
                start["effective_reserved_workers"] = event["effective_reserved_workers"]
                start["resource_adjustment_reason"] = event["resource_reason"]
                if "cpu_affinity" in event:
                    start["effective_cpu_affinity"] = event["cpu_affinity"]
        terminal = next((event for event in reversed(events)
                         if event.get("event") == "finished"), None)
        active = _leased(directory / "lease")
        state = "active" if active else terminal["outcome"] if terminal else "interrupted"
        result.append(dict(start, state=state, active=active, directory=str(directory),
                           events=events, finish=terminal))
    return sorted(result, key=lambda record: record["utc"])


def _same_scope(left: dict, right: dict) -> bool:
    return all(left.get(key) == right.get(key) for key in ("task", "kind", "scope"))


def _gnatprove_query(run: dict) -> bool:
    # Older queries recorded the same scope as an unselected compiler proof.
    arguments = run.get("inputs", {}).get("arguments", [])
    return (run.get("kind") == "tool-gnatprove" and run.get("workers") == 0
            and arguments[1:] in (["--help"], ["--version"], ["-h"]))


def _pending_failures(runs: list[dict], notes: list[dict], current: dict) -> dict[str, int]:
    counts: dict[str, int] = {}
    diagnosed = max((note["utc"] for note in notes if note.get("event") == "diagnostic"
                     and _same_scope(note, current)), default="")
    for run in sorted(runs, key=lambda item: item["utc"]):
        if not _same_scope(run, current) or run["utc"] <= diagnosed or _gnatprove_query(run):
            continue
        if run["state"] == "success":
            counts.clear()
        elif run["state"] == "failure":
            for key in run["finish"].get("failure_keys", []):
                counts[key] = counts.get(key, 0) + 1
    return counts


def _limit_selector(entry) -> bool:
    return isinstance(entry, str) and entry.startswith("--limit-")


def _family_scope(scope):
    """Drop the limit selectors that move with edits and refocusing; keep mode, project and units."""
    if not isinstance(scope, list):
        return scope
    family = [entry for entry in scope if not _limit_selector(entry)]
    # proof_scope adds "compiler" only when no project, unit or selector was
    # supplied. Removing the last selector must restore that same fallback.
    if len(family) == 1 and isinstance(family[0], str) and family[0].startswith("mode:"):
        family.append("compiler")
    return family


def _same_family(left: dict, right: dict) -> bool:
    return (all(left.get(key) == right.get(key) for key in ("task", "kind"))
            and _family_scope(left.get("scope")) == _family_scope(right.get("scope")))


def _failure_identities(run: dict) -> dict[str, list[str]]:
    """Read a failed run's helper identities; older or malformed records have none."""
    recorded = (run.get("finish") or {}).get("failure_identities")
    if not isinstance(recorded, dict):
        return {}
    return {identity: keys for identity, keys in recorded.items()
            if isinstance(identity, str) and isinstance(keys, list) and keys
            and all(isinstance(key, str) for key in keys)}


def _pending_helpers(runs: list[dict], notes: list[dict], current: dict) -> dict[str, dict]:
    """Count failed runs per helper identity across the reference record's family.

    A success clears only what the ledger shows it covered: every identity when
    it ran with no limit selector, otherwise those that failed in its exact scope.
    """
    diagnosed = max((note["utc"] for note in notes if note.get("event") == "diagnostic"
                     and _same_family(note, current)), default="")
    counted: dict[str, dict] = {}
    for run in sorted(runs, key=lambda item: item["utc"]):
        if not _same_family(run, current) or run["utc"] <= diagnosed or _gnatprove_query(run):
            continue
        if run["state"] == "success":
            scope = run.get("scope")
            selected = isinstance(scope, list) and any(_limit_selector(entry) for entry in scope)
            for identity in [identity for identity, entry in counted.items()
                             if not selected or scope in entry["scopes"]]:
                del counted[identity]
        elif run["state"] == "failure":
            for identity, keys in _failure_identities(run).items():
                entry = counted.setdefault(identity, dict(count=0, keys=set(), scopes=[]))
                entry["count"] += 1
                entry["keys"].update(keys)
                entry["scopes"].append(run.get("scope"))
                entry["run"] = run
    return {identity: dict(count=entry["count"], keys=sorted(entry["keys"]), run=entry["run"])
            for identity, entry in counted.items() if entry["count"] >= _RECURRENCE_BOUNDARY}


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
        if path.is_dir():
            selected.update(item for item in path.rglob("*")
                            if item.suffix == ".spark" or item.name in ("gnatprove.sarif", "gnatprove.out"))
        else:
            selected.add(path)
    return sorted(path for path in selected if path.is_file())


def _report_identity(path: Path) -> tuple | None:
    try:
        stat = path.stat()
        return (stat.st_dev, stat.st_ino, stat.st_size, stat.st_mtime_ns, stat.st_ctime_ns)
    except FileNotFoundError:
        return None


def _helper_name(value) -> str | None:
    name = value.get("name") if isinstance(value, dict) else None
    return name if isinstance(name, str) and name else None


def _report_failures(paths) -> tuple[set[str], dict[str, set[str]]]:
    """Read final failures once, with the helper each producer names for them."""
    failures = set()
    identities: dict[str, set[str]] = {}

    def failed(key: str | None, helper: str | None, rule: str) -> None:
        if key:
            failures.add(key)
            if helper:
                identities.setdefault(f"{helper}:{rule}", set()).add(key)

    for path in _report_files(paths):
        try:
            report = json.loads(path.read_text())
        except (OSError, ValueError):
            continue  # Parse/tool failures remain failed runs without invented VCs.
        if not isinstance(report, dict):
            continue
        if path.suffix == ".spark":
            entities = report.get("entities")
            # GNATprove keys this table by the entity number with a leading space.
            helpers = ({str(number).strip(): _helper_name(entity) for number, entity in entities.items()}
                       if isinstance(entities, dict) else {})
            for record in _rows(report.get("proof")):
                if not isinstance(record, dict):
                    continue
                if (record.get("severity") != "info"
                        or record.get("how_proved") not in ("flow", "prover", "trivial")):
                    entity = record.get("entity")
                    failed(_obligation_key(record),
                           helpers.get(str(entity)) if type(entity) is int else None, record.get("rule"))
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
                        logical = _rows(location.get("logicalLocations"))
                        failed(key, _helper_name(logical[0]) if logical else None, rule)
    return failures, identities


def failed_identities(paths) -> dict[str, list[str]]:
    """Map each producer-named helper and check kind to the exact keys of its final failures."""
    return {identity: sorted(keys) for identity, keys in sorted(_report_failures(paths)[1].items())}


def failed_obligations(paths) -> list[str]:
    """Read final check results, deliberately ignoring individual solver attempts."""
    failures, _ = _report_failures(paths)
    return sorted(failures)


def deliberate_reductions(allocation: dict[str, dict]) -> list[str]:
    """Name the settings explicitly requested below their automatic value."""
    return sorted(name for name, entry in allocation.items()
                  if type(entry.get("requested")) is int and type(entry.get("automatic")) is int
                  and 0 < entry["requested"] < entry["automatic"])


def allocation_report(record: dict) -> str:
    """Summarize a start record's requested and actual resource settings."""
    allocation = record.get("allocation")
    if not isinstance(allocation, dict):
        return "Resource allocation: not recorded"
    parts = []
    for name, entry in sorted(allocation.items()):
        if entry.get("actual") is None:
            continue
        requested = "automatic" if entry.get("requested") is None else entry["requested"]
        automatic = "" if entry.get("automatic") is None else f" automatic={entry['automatic']}"
        parts.append(f"{name} requested={requested} actual={entry['actual']}{automatic}")
    if record.get("resource_reductions"):
        parts.append("deliberate reduction: " + ", ".join(record["resource_reductions"]))
    reason = record.get("resource_reason") or ""
    if reason.strip():
        parts.append("reason: " + reason)
    return "Resource allocation: " + "; ".join(parts)


class ManagedRun:
    def __init__(self, host: HostLayout, kind: str, command: list[str], inputs: dict,
                 resources, workers: int | None = None, task: str = "", reason: str = "",
                 expensive: bool = False, evidence=(), failure_reports=(), failure_keys=(),
                 resource_reason: str = "",
                 allocation: dict[str, dict] | Callable[[int], dict[str, dict]] | None = None):
        if workers is not None and (type(workers) is not int or workers < 0):
            raise RunHistoryError("workers must be nonnegative or None for available CPUs")
        # A caller may resolve dependent settings only after its grant is known.
        self._allocation = allocation if callable(allocation) else {
            name: dict(entry) for name, entry in (allocation or {}).items()}
        if not callable(self._allocation) and "workers" in self._allocation:
            raise RunHistoryError("allocation must not name workers; the managed run records its grant")
        self._resource_reason = resource_reason
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
        self._affinity = {}
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
            used = sum(run["effective_reserved_workers"] for run in active)
            available = min(process_cpus(), max(0, capacity - used))
            self.workers = available if self.requested_workers is None else self.requested_workers
            if ((self.requested_workers is None and not self.workers)
                    or self.workers > available):
                raise RunHistoryError(f"worker budget unavailable ({used}/{capacity} reserved); active run(s): "
                                      + ", ".join(run["run_id"] for run in active))
            # A grant reduced by other reservations is automatic. Only an explicit
            # request below this run's automatic value is a deliberate reduction.
            supplied = self._allocation(self.workers) if callable(self._allocation) else self._allocation
            allocation = {name: dict(entry) for name, entry in supplied.items()}
            if "workers" in allocation:
                raise RunHistoryError("allocation must not name workers; the managed run records its grant")
            allocation["workers"] = {
                "requested": self.requested_workers, "automatic": available, "actual": self.workers}
            reductions = deliberate_reductions(allocation)
            proof_command = self.record["kind"] in ("prove", "tool-gnatprove", "lean")
            if proof_command and reductions and not self._resource_reason.strip():
                raise RunHistoryError(
                    "deliberate reduction below the automatic allocation needs --resource-reason: "
                    + ", ".join(f"{name} {allocation[name]['requested']} < {allocation[name]['automatic']}"
                                for name in reductions))
            self.record.update(allocation=allocation, resource_reductions=reductions,
                               resource_reason=self._resource_reason)
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
                self._affinity, affinity = _restrict_affinity(self.workers)
                self.record.update(workers=self.workers, available_cpus=capacity,
                                   cpu_limit_reason=CPU_LIMIT_REASON, cpu_affinity=affinity)
                _append(self.directory / "events.jsonl", self.record)
            except BaseException:
                _restore_affinity(self._affinity)
                self._affinity = {}
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
        notes = _read(self.root / "notes.jsonl")
        failures = _pending_failures(runs, notes, self.record)
        repeated = {key: count for key, count in failures.items() if count >= _RECURRENCE_BOUNDARY}
        helpers = _pending_helpers(runs, notes, self.record)
        if repeated or helpers:
            message = ("repeated unresolved obligations need a diagnostic note before another run: "
                       + _json({**repeated, **{identity: entry["count"] for identity, entry in helpers.items()}}))
            if helpers:
                message += "; exact locations: " + _json({identity: entry["keys"]
                                                          for identity, entry in helpers.items()})
            raise RunHistoryError(message)

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

    def _changed_failures(self) -> tuple[set[str], dict[str, set[str]]]:
        changed_reports = [path for path in _report_files(self.failure_reports)
                           if _report_identity(path) != self._report_baseline.get(str(path))]
        return _report_failures(changed_reports)

    def unresolved_obligations(self) -> list[str]:
        """Return final failures in this run's changed/new owned reports."""
        return sorted(set([*self.failure_keys, *self._changed_failures()[0]]))

    def finish(self, outcome: str = "success", returncode: int | None = None, failure_keys=(), **details) -> None:
        if self._finished:
            return
        if outcome not in ("success", "failure", "interrupted"):
            raise RunHistoryError(f"invalid run outcome: {outcome}")
        if outcome == "success" and returncode not in (0, None):
            raise RunHistoryError("a nonzero child status cannot finish successfully")
        keys, identities = [], {}
        if outcome == "failure":
            # Keys and helper identities come from one read; caller keys name no helper.
            found, named = self._changed_failures()
            keys = sorted(set([*self.failure_keys, *found, *failure_keys]))
            identities = {identity: sorted(locations) for identity, locations in named.items()}
        # Preserve reports before a later managed command replaces its output.
        copies = []
        for index, source in enumerate(self.failure_reports if outcome != "success" else ()):
            source = Path(source)
            for path in _report_files([source]):
                relative = path.relative_to(source) if source.is_dir() else Path(path.name)
                target = self.directory / "reports" / str(index) / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(path.read_bytes())
                copies.append(dict(original=str(path), retained=str(target)))
        with _metadata(self.root):
            _append(self.directory / "events.jsonl", dict(details, event="finished", run_id=self.run_id,
                outcome=outcome, returncode=returncode, duration_seconds=(time.monotonic_ns() - self._start_ns) / 1e9,
                failure_keys=keys, failure_identities=identities, evidence=_paths(self.evidence),
                retained_reports=copies))
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
            _restore_affinity(self._affinity)
            self._affinity = {}
        return False


def status(host: HostLayout, task: str = "") -> dict:
    root = registry(host)
    with _metadata(root):
        runs = _runs(root)
        notes = _read(root / "notes.jsonl")
        reserved_workers = sum(run["effective_reserved_workers"] for run in runs if run["active"])
        if task:
            runs = [run for run in runs if run.get("task") == task]
            notes = [note for note in notes if note.get("task") == task]
        scopes = {_json([run["task"], run["kind"], run["scope"]]): run for run in runs}
        diagnostics_required = []
        for scope in scopes.values():
            repeated = {key: count for key, count in _pending_failures(runs, notes, scope).items()
                        if count >= _RECURRENCE_BOUNDARY}
            if repeated:
                latest = next(run for run in reversed(runs) if _same_scope(run, scope)
                              and run["state"] == "failure"
                              and repeated.keys() & set(run["finish"].get("failure_keys", [])))
                diagnostics_required.append(dict(task=scope["task"], kind=scope["kind"],
                    scope=scope["scope"], run_id=latest["run_id"], failure_counts=repeated))
        # Helper recurrences follow, in the order their families first appear;
        # only families with a failed run naming a helper are evaluated.
        families, named = {}, set()
        for run in runs:
            family = _json([run["task"], run["kind"], _family_scope(run["scope"])])
            families.setdefault(family, run)
            if run["state"] == "failure" and _failure_identities(run):
                named.add(family)
        for family, reference in families.items():
            pending = _pending_helpers(runs, notes, reference) if family in named else {}
            if pending:
                latest = max((entry["run"] for entry in pending.values()), key=lambda run: run["utc"])
                diagnostics_required.append(dict(task=reference["task"], kind=reference["kind"],
                    scope=latest["scope"], run_id=latest["run_id"],
                    failure_counts={identity: entry["count"] for identity, entry in pending.items()},
                    failure_locations={identity: entry["keys"] for identity, entry in pending.items()}))
        return dict(registry=str(root), host=host.key, machine=socket.gethostname(),
                    runs=runs, notes=notes, available_cpus=available_cpus(),
                    reserved_workers=reserved_workers, diagnostics_required=diagnostics_required)


def adjust_resources(host: HostLayout, run_id: str, effective_reserved_workers: int,
                     reason: str, cpu_affinity=None) -> dict:
    """Record an operator-applied live limit without rewriting launch history.

    The caller applies and verifies the OS restriction first. This event only
    updates cooperative accounting; it does not retune an already-running tool.
    """
    if (type(effective_reserved_workers) is not int or effective_reserved_workers < 0
            or not reason.strip()):
        raise RunHistoryError("resource adjustment requires nonnegative workers and a reason")
    affinity = None if cpu_affinity is None else sorted(set(cpu_affinity))
    if affinity is not None and (not affinity or any(type(cpu) is not int or cpu < 0 for cpu in affinity)
                                 or effective_reserved_workers > len(affinity)):
        raise RunHistoryError("resource adjustment exceeds its CPU affinity")
    root = registry(host)
    with _metadata(root):
        runs = _runs(root)
        run = next((run for run in runs if run["run_id"] == run_id), None)
        if run is None or not run["active"]:
            raise RunHistoryError(f"resource adjustment requires an active run: {run_id}")
        used = sum(item["effective_reserved_workers"] for item in runs
                   if item["active"] and item["run_id"] != run_id)
        capacity = available_cpus()
        if effective_reserved_workers + used > capacity:
            raise RunHistoryError(f"worker budget unavailable ({used}/{capacity} reserved)")
        note = dict(event="resource-adjusted", run_id=run_id,
                    previous_effective_reserved_workers=run["effective_reserved_workers"],
                    effective_reserved_workers=effective_reserved_workers, resource_reason=reason)
        if affinity is not None:
            note["cpu_affinity"] = affinity
        _append(Path(run["directory"]) / "events.jsonl", note)
        return note


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
