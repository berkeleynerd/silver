#!/usr/bin/env python3
"""Independent frozen-source/extent audit. Executes no reviewed/provider code."""
from collections import defaultdict
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import subprocess
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = "32576dd5d6b195f7e69669a63248ac30e6e9e333"
FREEZE = "e5ae9e7122a090900680bc327f6eea85f5b20869"
AUTHOR = "docs/evidence/retained-controller-owner-join-20261023/"
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
OCAML = "docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz"
OCAML_PREFIX = "ocaml-8eb41f72ded84df884c3671734c947f612091f84/"
CHECKS = 0


def require(value, label):
    global CHECKS
    CHECKS += 1
    if not value:
        raise AssertionError(label)


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def read_json(path):
    return json.loads((ROOT / path).read_bytes())


def git(*args):
    return subprocess.check_output(["git", "-C", str(ROOT), *args])


def capacity(m):
    # Direct least-power-of-two formula, independent of the author recurrence.
    half_ceiling = (m + 1) // 2
    return max(32, 1 << (max(1, half_ceiling) - 1).bit_length())


def main():
    started = datetime.now(timezone.utc)
    clock = time.perf_counter()
    frozen = git("diff", "--name-only", BASE, FREEZE).decode().splitlines()
    require(len(frozen) == 8, "eight author additions")
    files = {}
    for path in frozen:
        data = (ROOT / path).read_bytes()
        require(data == git("show", f"{FREEZE}:{path}"), f"exact author freeze: {path}")
        files[path] = identity(data)
    providers = read_json(AUTHOR + "inputs.json")["providers"]
    for path, expected in providers.items():
        data = (ROOT / path).read_bytes()
        require(identity(data) == expected, f"retained input identity: {path}")
        files[path] = identity(data)

    # No author/predecessor checker is imported or executed. The manifest is
    # identity metadata; its assertions are not accepted as semantic proofs.
    sources = {}
    archive_members = {}
    for archive in (WHY, OCAML):
        with tarfile.open(ROOT / archive) as retained:
            for item in retained.getmembers():
                if item.isfile():
                    archive_members[(archive, item.name)] = retained.extractfile(item).read()
    source_ranges = read_json(AUTHOR + "source-ranges.json")
    for row in source_ranges:
        data = archive_members[row["archive"], row["member"]]
        require(identity(data) == row["identity"], row["member"])
        lines = data.splitlines(keepends=True)
        for span in row["ranges"]:
            require(identity(b"".join(lines[span["start"] - 1:span["end"]])) == span["identity"], span["label"])

    anchors = []

    def ordered(member, lo, hi, label, *needles):
        archive = WHY if member.startswith("why3/") else OCAML
        data = archive_members[archive, member]
        sources[member] = identity(data)
        excerpt = b"".join(data.splitlines(keepends=True)[lo - 1:hi])
        text = excerpt.decode()
        at = 0
        for needle in needles:
            found = text.find(needle, at)
            require(found >= at, label + ": " + needle)
            at = found + len(needle)
        anchors.append({"label": label, "archive": archive, "member": member,
                        "first_line": lo, "last_line": hi,
                        "identity": identity(excerpt), "ordered_anchors": list(needles)})

    wc = "why3/src/gnat/gnat_checks.ml"
    ct = "why3/src/session/controller_itp.ml"
    cp = "why3/src/driver/call_provers.ml"
    pc = "why3/src/driver/prove_client.ml"
    gm = "why3/src/gnat/gnat_main.ml"
    hs = OCAML_PREFIX + "stdlib/hashtbl.ml"
    ordered(wc, 272, 280, "consume before singleton return",
            "let goal = GoalSet.choose", "GoalSet.remove check_rec.to_be_scheduled goal;", "[goal]")
    ordered(wc, 618, 642, "parallel excludes reinsertion; full split excludes clones",
            "Gnat_config.parallel = 1", "GoalSet.add check_rec.to_be_scheduled goal;",
            "if is_full_split_goal", "further_split", "List.iter (add_clone goal)")
    ordered(wc, 1049, 1084, "remaining protected; only Done forwards; one prover traversal",
            "let remaining = ref (List.length provers)", "if Gnat_config.logging then Logging.log",
            "if !remaining = 0 then ()", "Controller_itp.Done pr", "remaining := !remaining - 1",
            "C.interrupt_proof_attempts_for_goal c g", "remaining := 0", "| _ -> ()",
            "List.iter (fun p -> schedule_goal_with_prover ~callback c g p) provers")
    ordered(ct, 124, 136, "controller Hpan starts empty", "controller_running_proof_attempts = Hpan.create 17")
    ordered(ct, 307, 334, "queue, live table and running counter start empty/zero",
            "Queue.create ()", "let prover_tasks_in_progress", "Hashtbl.create 17", "let number_of_running_provers = ref 0")
    ordered(ct, 429, 440, "initial live record is not started; fresh replace precedes Sys_error catch",
            "let call = Driver.prove_task", "tp_started  = false", "Hashtbl.replace prover_tasks_in_progress call pa", "with Sys_error")
    ordered(ct, 448, 491, "receive and dispatch; guarded decrements; lookup-only exception pattern",
            "Call_provers.get_new_results ~blocking:S.blocking", "List.iter", "match Hashtbl.find",
            "| Call_provers.ProverStarted", "incr number_of_running_provers", "tp_started = true",
            "| Call_provers.ProverFinished", "Hashtbl.remove prover_tasks_in_progress",
            "if ptp.tp_started then decr", "ptp.tp_callback (Done res)",
            "| Call_provers.ProverInterrupted", "Hashtbl.remove prover_tasks_in_progress",
            "if ptp.tp_started then decr", "ptp.tp_callback (Interrupted)",
            "| Call_provers.InternalFailure", "Hashtbl.remove prover_tasks_in_progress",
            "if ptp.tp_started then decr", "ptp.tp_callback (InternalFailure", "| exception Not_found -> ()")
    ordered(ct, 517, 536, "pop consumes owner before build and failure callback",
            "if S.blocking ||", "S.multiplier * !session_max_tasks", "Queue.pop scheduled_proof_attempts",
            "build_prover_call spa", "with e when", "spa.spa_callback (InternalFailure e)", "with Queue.Empty")
    ordered(ct, 560, 576, "cancellation traverses live table then clear/rebuilds survivors",
            "Hashtbl.iter", "Call_provers.interrupt_call", "Queue.fold", "x.spa_callback Interrupted",
            "Queue.clear scheduled_proof_attempts", "Queue.add x scheduled_proof_attempts")
    ordered(ct, 592, 617, "Scheduled only adds controller Hpan; terminal statuses remove",
            "| Scheduled ->", "Hpan.add c.controller_running_proof_attempts", "| Done res ->",
            "Hpan.remove c.controller_running_proof_attempts", "| InternalFailure _ ->",
            "Hpan.remove c.controller_running_proof_attempts", "callback panid s")
    ordered(ct, 641, 652, "graft then one enqueue/Scheduled/idle",
            "let panid = graft_proof_attempt", "Queue.add spa scheduled_proof_attempts",
            "callback panid Scheduled", "run_idle_handler ()")
    ordered(cp, 460, 474, "fresh private request IDs and saved-data table",
            "let x = ref 0", "incr x", "!x", "let saved_data", "Hashtbl.create 17")
    ordered(cp, 478, 498, "F removes saved owner before cleanup/parse",
            "Finished", "Hashtbl.find saved_data id", "Hashtbl.remove saved_data id",
            "Sys.remove save.vc_file", "parse_prover_run", "| Started id", "List.map handle_answer")
    ordered(cp, 507, 532, "one ID and saved insertion before send; orphan possible",
            "gen_id ()", "actualcommand", "Hashtbl.add saved_data id save", "send_request", "id")
    ordered(cp, 541, 560, "physical S/F add; blocking filters S; clear before returning list",
            "Hashtbl.create 17", "List.iter", "Hashtbl.add result_buffer id x",
            "fetch_new_results ~blocking", "Hashtbl.iter", "if element = ProverStarted && blocking then",
            "q := (ServerCall key, element) :: !q", "Hashtbl.clear result_buffer", "!q")
    ordered("why3/src/driver/driver.ml", 456, 494, "single driver call maps returned ID to ServerCall",
            "Call_provers.call_on_buffer", "Buffer.reset buf", "ServerCall res", "let prove_task", "prove_task_prepared")
    ordered(cp, 604, 618, "buffer call offers file once", "Buffer.output_buffer", "call_on_file")
    ordered(pc, 64, 73, "send advances byte position, not call owner", "Unix.write_substring", "write (pointer + written)")
    ordered(pc, 195, 216, "empty read returns no answers", 'if s = "" then [] else', "Buffer.clear recv_buf", "read_lines blocking")
    ordered(pc, 230, 250, "malformed answers fail; read map has no replay handler",
            "int_of_string id", "float_of_string", "Int64.of_string", "raise (InvalidAnswer s)", "let read_answers", "List.map read_answer")
    ordered("why3/src/gnat/gnat_scheduler.ml", 1, 28, "blocking synchronous idle; timeout catches only Exit",
            "let blocking = true", "while f () do ()", "let main_loop ending", "Some f -> if f ()", "with Exit -> ending ()")
    ordered(gm, 331, 360, "registration before scheduling before timeout; outer failures are terminal",
            "gnatwhy3.register_vcs", "gnatwhy3.schedule_vcs", "Gnat_scheduler.main_loop", "| Out_of_memory as e -> raise e", "Gnat_util.abort_with_message")
    ordered("why3/src/session/session_itp.ml", 620, 675, "session table differs from controller table; one constructor per graft",
            "proofAttempt_table = Hint.create 97", "let add_proof_attempt", "gen_proofAttemptID session",
            "let graft_proof_attempt", "Hint.replace s.proofAttempt_table", "with Not_found ->", "add_proof_attempt")
    ordered(hs, 68, 82, "constructor rounds 17 to 32; clear adds no cell",
            "power_2_above", "power_2_above 16 initial_size", "Array.make s Empty", "h.size <- 0", "Array.fill")
    ordered(hs, 115, 151, "rehash reuses cells outside traversal and holds old/new/tail arrays",
            "let ndata_tail = Array.make nsize Empty", "if inplace then cell", "else Cons", "let nidx = indexfun key",
            "insert_bucket next", "let odata = h.data", "let nsize = osize * 2",
            "let ndata = Array.make nsize Empty", "not (ongoing_traversal h)", "h.data <- ndata", "insert_all_buckets")
    ordered(hs, 354, 362, "functor mask/add/growth", "land (Array.length h.data - 1)", "Cons{key; data; next=",
            "h.size <- h.size + 1", "h.size > Array.length h.data lsl 1")
    ordered(hs, 502, 529, "polymorphic mask/add/remove", "land (Array.length h.data - 1)", "let add", "Cons{key; data; next=",
            "h.size <- h.size + 1", "h.size > Array.length h.data lsl 1", "compare k key = 0", "h.size <- h.size - 1")
    ordered(hs, 581, 595, "replace adds only on miss", "| Empty ->", "true", "compare k key = 0", "false", "let replace h",
            "if replace_bucket", "h.data.(i) <- Cons", "h.size <- h.size + 1")
    ordered(OCAML_PREFIX + "stdlib/queue.ml", 71, 80, "queue removal publishes before owner return",
            "clear q", "content", "q.length <- q.length - 1", "q.first <- next", "content")
    ordered(OCAML_PREFIX + "stdlib/queue.ml", 126, 134, "fold snapshots next before callback", "Cons { content; next }", "f accu content", "fold f accu next")

    # Exhaust all insertion-count/population/capacity states through the largest
    # finite bound, allowing arbitrary removes/clear between inserts. Each cap's
    # reachable populations form 0..maximum after removal closure. This checks
    # the arithmetic abstraction, not OCaml exception or container semantics.
    frontier = {32: 0}
    states = 1
    maximum_capacity = {0: 32}
    for used in range(1, 307):
        nxt = defaultdict(int)
        for backing, high in frontier.items():
            for population in range(high + 1):
                inserted = population + 1
                after = backing * (2 if inserted > 2 * backing else 1)
                nxt[after] = max(nxt[after], inserted)
        frontier = dict(nxt)
        states += sum(high + 1 for high in frontier.values())
        require(max(frontier) == capacity(used), f"all deletion histories at {used} insertions")
        require(all(high <= used and high <= 2 * b for b, high in frontier.items()), f"physical population at {used}")
        maximum_capacity[used] = max(frontier)
    for k in range(4):
        require(sum(range(k)) == k * (k - 1) // 2 <= 3, f"interrupt owner triangular bound {k}")

    cut_path = "docs/evidence/retained-parallel-logging-prefix-20261020/cut-projection.json"
    cuts = read_json(cut_path)
    reported = {r["case"]: r for r in read_json(AUTHOR + "result.json")["cases"]}
    cases = []
    expected = [("put_line", 51, 14), ("put", 42, 12), ("first_or_default", 22, 10),
                ("is_message", 2, 1), ("input_is_valid", 1, 3)]
    names = list(reported)
    require(names == [r[0] for r in expected], "five named domains in retained order")
    for name, wanted_g, wanted_c0 in expected:
        root_map = cuts[name]["fixed_root_map"]
        g = len({r["goal"] for r in root_map})
        c0 = cuts[name]["session_counters"]["next_proofAttemptID"]
        require(g == len(root_map) == wanted_g and c0 == wanted_c0, name + " independent registration/counter projection")
        n = 3 * g
        row = {"case": name, "g": g, "n": n, "two_n": 2 * n, "c0": c0, "c0_plus_n": c0 + n, "classes": []}
        for m, key in [(n, "saved_data_live_call_Hpan_each"), (2 * n, "result_buffer")]:
            b = capacity(m)
            stages = list(range(5, b.bit_length()))
            arrays = [32] + [size for exponent in stages[1:] for size in (2 ** exponent, 2 ** exponent)]
            slots = sum(arrays)
            headers = len(arrays)
            working = 32 if b == 32 else b // 2 + 2 * b
            require(maximum_capacity[m] == b, name + key + " deletion-history bound")
            require(slots == 4 * b - 96 and headers == 1 + 2 * (b.bit_length() - 6), name + key + " geometric allocation")
            require(m <= 2 * b and (b == 32 or m > b), name + key + " least power")
            require(max(m, c0 + n, 2 * b, slots, 8 * (slots + headers)) < 2 ** 62, name + key + " signed63 intermediates")
            require(b < 2 ** 54 - 1, name + key + " strict resize limit")
            for value in (-(2 ** 62), -1, 0, 1, 2 ** 62 - 1):
                require(0 <= (value & (b - 1)) < b, name + key + " finite signed-hash mask checks")
            calculated = {"physical_cells_upper": m, "capacity_upper": b,
                          "probe_cell_visits_per_invocation_upper": m,
                          "bucket_heads_per_iteration_upper": b,
                          "load_test_operand_upper": 2 * b,
                          "working_array_slots_upper": working,
                          "cumulative_array_slots_including_initial_upper": slots,
                          "cumulative_array_headers_including_initial_upper": headers,
                          "cumulative_backing_bytes_including_headers_upper": 8 * (slots + headers)}
            for field, value in calculated.items():
                require(reported[name][key][field] == value, name + key + field)
            row["classes"].append({"table_class": key, **calculated})
        require(reported[name]["running_counter_initial_and_upper"] == 0, name + " reported running counter")
        require(reported[name]["attempt_counter_upper"] == c0 + n, name + " reported session counter")
        cases.append(row)

    manifest = {"reviewed_freeze": FREEZE, "published_base": BASE,
                "files": files, "source_members": sources, "source_audit_ranges": anchors,
                "audit_script": identity(Path(__file__).read_bytes())}
    (HERE / "inputs.json").write_text(json.dumps(manifest, indent=2) + "\n")
    result = {"status": "pass", "reviewed_freeze": FREEZE, "checks": CHECKS,
              "author_files_compared_to_commit": len(frozen), "retained_provider_identities": len(providers),
              "author_source_member_identities": len(source_ranges),
              "independent_source_anchor_groups": len(anchors),
              "arithmetic_abstract_states": states, "arithmetic_maximum_insertions": 306,
              "cases": cases, "platform": platform.platform(),
              "started_utc": started.isoformat(), "elapsed_seconds": time.perf_counter() - clock,
              "author_checker_runs": 0, "predecessor_checker_runs": 0, "native_target_runs": 0,
              "source_semantics_machine_proved": False, "whole_capacity_rule_complete": False}
    (HERE / "result.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({k: v for k, v in result.items() if k != "cases"}, indent=2))


if __name__ == "__main__":
    main()
