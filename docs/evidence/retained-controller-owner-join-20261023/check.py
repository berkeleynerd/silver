#!/usr/bin/env python3
"""Source/identity and finite controller-extent join; no provider/native replay."""
import hashlib
import json
from pathlib import Path
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
MAX_INT = (1 << 62) - 1
MAX_ARRAY = (1 << 54) - 1
CHECKS = 0


def require(condition, label):
    global CHECKS
    CHECKS += 1
    if not condition:
        raise AssertionError(label)


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def read(path):
    return json.loads((ROOT / path).read_text())


def extent(population):
    """No-shrink capacity recurrence plus retained initial/new/tail arrays."""
    capacity = 32
    capacities = [capacity]
    allocation_slots = capacity
    allocation_headers = 1
    for size in range(1, population + 1):
        require(0 < size <= population <= MAX_INT, "represented size increment")
        require(2 * capacity <= MAX_INT, "represented load predicate")
        if size > 2 * capacity:
            new = 2 * capacity
            require(new < MAX_ARRAY, "resize array guard")
            allocation_slots += 2 * new
            allocation_headers += 2
            capacity = new
            capacities.append(capacity)
        require(size <= 2 * capacity, "post-insertion load")
    require(capacity >= 32 and capacity & (capacity - 1) == 0, "power-two backing")
    require(population <= 2 * capacity, "capacity covers all occurrences")
    require(capacity == 32 or population > capacity, "least reachable upper backing")
    require(capacity - 1 < capacity < MAX_ARRAY, "hash-mask index and array extent")
    require(all(2 * a == b for a, b in zip(capacities, capacities[1:])), "doubling sequence")
    require(allocation_slots == 4 * capacity - 96, "cumulative geometric slots")
    require(allocation_headers == 1 + 2 * (len(capacities) - 1), "array headers")
    working_slots = 32 if capacity == 32 else capacity // 2 + 2 * capacity
    require(working_slots <= allocation_slots, "working arrays covered by allocation")
    require(8 * (allocation_slots + allocation_headers) <= MAX_INT, "backing bytes fit")
    return {"physical_cells_upper": population,
            "probe_cell_visits_per_invocation_upper": population,
            "bucket_heads_per_iteration_upper": capacity,
            "initial_buckets": 32, "capacity_upper": capacity,
            "growth_capacities": capacities,
            "load_test_operand_upper": 2 * capacity,
            "working_array_slots_upper": working_slots,
            "cumulative_array_slots_including_initial_upper": allocation_slots,
            "cumulative_array_headers_including_initial_upper": allocation_headers,
            "cumulative_backing_bytes_including_headers_upper":
                8 * (allocation_slots + allocation_headers)}


def check():
    inputs = read(str((HERE / "inputs.json").relative_to(ROOT)))
    for path, expected in inputs["providers"].items():
        require(identity((ROOT / path).read_bytes()) == expected, path)

    sources = {}
    spans = read(str((HERE / "source-ranges.json").relative_to(ROOT)))
    for archive in dict.fromkeys(row["archive"] for row in spans):
        with tarfile.open(ROOT / archive) as retained:
            for row in (r for r in spans if r["archive"] == archive):
                data = retained.extractfile(row["member"]).read()
                require(identity(data) == row["identity"], row["member"])
                sources[row["member"].split("/", 1)[1]] = data.decode()
                lines = data.splitlines(keepends=True)
                for span in row["ranges"]:
                    lo, hi = span["start"], span["end"]
                    require(1 <= lo <= hi <= len(lines), span["label"] + " range")
                    require(identity(b"".join(lines[lo - 1:hi])) == span["identity"],
                            span["label"] + " bytes")

    # These anchors attach the reviewed clauses; they are not a parser or proof
    # of exception safety. Exact complete member identities are checked above.
    anchors = {
        "src/gnat/gnat_checks.ml": [
            "t := S.remove x !t", "GoalSet.remove check_rec.to_be_scheduled goal;\n     [goal]",
            "if Gnat_config.parallel = 1 && Gnat_config.manual_prover = None",
            "List.iter (fun p -> schedule_goal_with_prover ~callback c g p) provers"],
        "src/gnat/gnat_scheduler.ml": ["let blocking = true", "while f () do ()",
                                               "with Exit -> ending ()"],
        "src/session/controller_itp.ml": [
            "controller_running_proof_attempts = Hpan.create 17",
            "let scheduled_proof_attempts : sched_pa_rec Queue.t = Queue.create ()",
            "(Call_provers.prover_call,tasks_prog_rec) Hashtbl.t =\n  Hashtbl.create 17",
            "let number_of_running_provers = ref 0",
            "Hashtbl.replace prover_tasks_in_progress call pa",
            "Hashtbl.remove prover_tasks_in_progress ptp.tp_call;",
            "let spa = Queue.pop scheduled_proof_attempts in",
            "Queue.add spa scheduled_proof_attempts;\n  callback panid Scheduled;\n  run_idle_handler ()"],
        "src/driver/call_provers.ml": [
            "let gen_id =\n  let x = ref 0 in\n  fun () ->\n    incr x;\n    !x",
            "let saved_data : (int, save_data) Hashtbl.t = Hashtbl.create 17",
            "let result_buffer : (server_id, prover_update) Hashtbl.t = Hashtbl.create 17",
            "Hashtbl.add saved_data id save;", "Hashtbl.remove saved_data id;",
            "Hashtbl.add result_buffer id x", "if element = ProverStarted && blocking then",
            "Hashtbl.clear result_buffer;\n  !q"],
        "src/driver/prove_client.ml": ["raise (InvalidAnswer s)",
                                              'if s = "" then [] else'],
        "src/util/exthtbl.ml": ["module M = Hashtbl.Make(X)\n  include M"],
        "src/util/wstdlib.ml": ["let equal (x : int) y = x = y", "let hash  (x : int) = x"],
        "stdlib/hashtbl.ml": ["let s = power_2_above 16 initial_size",
            "let ndata_tail = Array.make nsize Empty", "let nsize = osize * 2",
            "let inplace = not (ongoing_traversal h)",
            "h.size > Array.length h.data lsl 1", "land (Array.length h.data - 1)"],
        "stdlib/queue.ml": ["length = 0;", "let cell = Cons {", "next = Nil",
                                    "q.length <- q.length - 1", "fold f accu next"],
        "stdlib/set.ml": ["type t = Empty | Node of {l:t; v:elt; r:t; h:int}",
                                  "let rec remove x = function"],
        "stdlib/sys.ml.in": ["let max_array_length = max_wosize ()"],
        "runtime/caml/mlvalues.h": ["#define Max_long (((intnat)1 << (8 * sizeof(value) - 2)) - 1)",
                                           "#define Max_wosize (((intnat)1 << 54) - 1)"],
    }
    for path, needles in anchors.items():
        for needle in needles:
            require(needle in sources[path], path + ": " + needle)

    ev = "docs/evidence/"
    current = read(ev + "retained-current-protocol-join-20261023/result.json")
    cuts = read(ev + "retained-parallel-logging-prefix-20261020/cut-projection.json")
    combined = read(ev + "retained-combined-parallel-startup-20261020/projection.json")["domains"]
    canonical = {r["case"]: r for r in read(ev + "retained-why-canonical-json-input-20261023/result.json")["cases"]}
    retained = read(ev + "retained-adapter-protocol-storage-20261020/result.json")
    retained_cases = {r["case"]: r for r in retained["cases"]}
    rows = []
    for row in current["cases"]:
        name = row["case"]
        cut = cuts[name]
        roots = cut["fixed_root_map"]
        goals = [r["goal"] for r in roots]
        g, n = len(roots), 3 * len(roots)
        c0 = cut["session_counters"]["next_proofAttemptID"]
        require(len(set(goals)) == g == row["registered_roots"], name + " complete unique roots")
        require(g == combined[name]["registered_root_count"], name + " combined registration")
        require(cut["session_counters"] == combined[name]["session_counters"], name + " initial counters")
        require(c0 == canonical[name]["A0"], name + " initial attempt relation")
        require(cut["captured_pid"] == row["j12_pid"] == canonical[name]["j12_pid"] == combined[name]["original_pid"], name + " exact cut PID")
        require(all(0 <= goal < cut["session_counters"]["next_proofNodeID"] for goal in goals), name + " represented root IDs")
        require(n == row["parallel_wire_entries_upper"], name + " current owner interface")
        require(n + 2 == row["broader_preparation_episodes_upper"] == canonical[name]["N"], name + " broader Q retained")
        require(n <= retained_cases[name]["run_entries"], name + " old protocol envelope retained")
        require(c0 + n <= canonical[name]["A"] <= MAX_INT, name + " counter bound within broader session extent")
        require(g + 2 <= MAX_INT and n <= MAX_INT and 2 * n <= MAX_INT, name + " scalar extents")
        one, responses = extent(n), extent(2 * n)
        rows.append({"case": name, "j12_pid": cut["captured_pid"],
                     "registered_roots": g, "run_entries_upper": n,
                     "interrupt_entries_upper": n, "queue_population_upper": n,
                     "request_ID_initial": 0, "request_ID_upper": n,
                     "initial_attempt_counter": c0, "attempt_counter_upper": c0 + n,
                     "running_counter_initial_and_upper": 0,
                     "goal_remaining_counter_range": [0, 3],
                     "saved_data_live_call_Hpan_each": one,
                     "result_buffer": responses,
                     "retained_protocol_run_entries_upper": retained_cases[name]["run_entries"],
                     "other_owner_Q_unchanged": canonical[name]["N"]})
    require(sum(r["run_entries_upper"] for r in rows) == current["current_wire_entries_upper"] == 354,
            "current total")
    require(sum(r["retained_protocol_run_entries_upper"] for r in rows) == retained["total_attempts_upper"] == 459,
            "retained total")
    require(retained["response_records_upper"] == 918, "retained response bound")
    require([r["saved_data_live_call_Hpan_each"]["capacity_upper"] for r in rows] == [128, 64, 64, 32, 32],
            "independent fixed capacity rows")
    require([r["result_buffer"]["capacity_upper"] for r in rows] == [256, 128, 128, 32, 32],
            "independent response capacity rows")
    return {"status": "pass", "checks": CHECKS, "base_commit": inputs["base_commit"],
            "providers_checked": len(inputs["providers"]), "source_members_checked": len(spans),
            "source_ranges_checked": sum(len(r["ranges"]) for r in spans), "cases": rows,
            "controller_owner_join_under_existing_guard": True,
            "arbitrary_resumed_resource_failure_preservation_claimed": False,
            "result_buffer_S_F_stream_premise_retained": True,
            "controller_SIGINT_save_entries_under_selected_mask": 0,
            "global_escape_budget": 2, "global_save_entering_callbacks_upper": 2,
            "global_saves_upper": 3, "global_budget_renewed": False,
            "source_native_relation_reused": True, "new_trusted_primitive_added": False,
            "actual_launcher_mask_refinement_established": False,
            "native_runs": 0, "provider_replays": 0, "whole_capacity_rule_complete": False}


if __name__ == "__main__":
    start = time.perf_counter()
    result = check()
    result["elapsed_seconds"] = time.perf_counter() - start
    (HERE / "result.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({k: v for k, v in result.items() if k != "cases"}, indent=2))
