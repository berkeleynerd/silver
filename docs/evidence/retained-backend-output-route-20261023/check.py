#!/usr/bin/env python3
"""New backend-route evidence; reads retained bytes, never executes targets."""
import hashlib
import itertools
import json
import pathlib
import re
import tarfile
import time

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
GNAT = "docs/evidence/retained-backend-output-route-20261023/gnat-runtime-sources.tar.gz"
C_NAMES = ["arraylist.c", "logging.c", "options.c", "proc.c", "queue.c",
           "readbuf.c", "request.c", "server-unix.c", "writebuf.c"]
checks = 0
archives = {}


def require(condition, label):
    global checks
    checks += 1
    if not condition:
        raise AssertionError(label)


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def dump(name, value):
    (HERE/name).write_text(json.dumps(value, indent=2, sort_keys=True)+"\n")


def load(path):
    return json.loads(path.read_text())


def member(path, name):
    if path not in archives:
        archives[path] = tarfile.open(ROOT/path)
    stream = archives[path].extractfile(name)
    require(stream is not None, f"regular member {name}")
    return stream.read()


def c_source(name):
    return member(WHY, "why3/src/server/"+name).decode()


def ada_source(name):
    return member(GNAT, "adainclude/"+name).decode()


def between(source, start, end):
    lo = source.index(start)
    hi = source.index(end, lo+1)
    require(lo < hi, f"ordered source anchors {start}")
    return source[lo:hi]


def main():
    start = time.monotonic()
    inputs = load(HERE/"inputs.json")
    for path, expected in inputs.items():
        require(identity((ROOT/path).read_bytes()) == expected, f"input {path}")
    rows = load(HERE/"source-ranges.json")
    witnesses = []
    for row in rows:
        data = member(row["archive"], row["member"])
        require(identity(data) == row["identity"], f"complete member {row['member']}")
        lines = data.decode().splitlines(keepends=True)
        witnesses.append(f"## {row['archive']} :: {row['member']}\n")
        for span in row["ranges"]:
            lo, hi = span["start"], span["end"]
            require(1 <= lo <= hi <= len(lines), "strict source range")
            text = "".join(lines[lo-1:hi])
            require(identity(text.encode()) == span["identity"], "strict excerpt identity")
            witnesses.append(f"### Lines {lo}–{hi}\n\n```text\n{text}```\n")
    (HERE/"source-witnesses.md").write_text("# Backend-route source witnesses\n\n"+"\n".join(witnesses))
    runtime_inputs = load(HERE/"runtime-inputs.json")
    for row in runtime_inputs["source_members"]:
        require(identity(member(GNAT, row["member"])) == row["identity"], "copied installed runtime member")

    corpus = {name: c_source(name) for name in C_NAMES}
    pattern = re.compile(r"\b(?:printf|fprintf|vfprintf|puts|fputs|putchar|fputc|perror|fwrite|write|snprintf|exit|_exit|atexit|on_exit|fflush|fopen|fclose|setbuf|setvbuf|print_request|dup2|fork|execvp)\s*\(|\b(?:constructor|destructor)\b")
    census = []
    for name, source in corpus.items():
        census.append({"member": "why3/src/server/"+name,
                       "identity": identity(source.encode()),
                       "sites": [{"line": n, "text": line} for n, line in enumerate(source.splitlines(), 1) if pattern.search(line)]})
        require(not re.search(r"\b(?:atexit|on_exit)\s*\(|\b(?:constructor|destructor)\b", source), f"no selected source exit registration {name}")
    require(sum(len(re.findall(r"\bprint_request\s*\(", s)) for s in corpus.values()) == 1, "print_request only definition in selected C units")
    server = corpus["server-unix.c"]
    child = between(server, "pid_t create_process(", "void write_to_client(")
    require("close(" not in child, "original outfile alias not closed in child")
    require(child.index("setpgid(") < child.index("dup2(outfile, 1)") < child.index("execvp("), "group/redirect/exec order")
    require(child.index("dup2(outfile, 1)") < child.index("dup2(outfile, 2)"), "both standard output descriptors replaced")
    require(child.count("fprintf(") == 2 and child.count("perror(") == 1, "complete direct child stdio sites")
    require(server.count("fprintf(") == 2 and server.count("perror(") == 1, "no other server stdio writer")
    main_body = server[server.index("int main("):]
    require(main_body.index("parse_options(") < main_body.index("server_init_listening("), "valid options before initialization/forks")
    require("bool logging = false;" in corpus["options.c"], "server log default disabled")
    logging = corpus["logging.c"]
    require(logging.count("if (logging)") == 3, "all three log functions guarded")
    require(logging.count("exit(1);") == 1, "disabled-log shutdown terminates without text")
    run = between(server, "void run_request (", "void handle_queue_remove(")
    require(run.index("open_temp_file(") < run.index("create_process(") < run.index("close(out_descr)"), "parent close follows fork and does not close child alias")
    dump("server-writer-census.json", {"selected_units": census,
                                     "scope": "Selected nine Unix-server C source units; dependency/native contracts remain explicit in author argument."})

    launch = load(ROOT/"docs/evidence/retained-adapter-launch-output-20261020/result.json")
    require(launch["error_string_max"] == 49, "accepted libc error payload")
    require(launch["exec_diagnostic_fixed_bytes"] == 23 and launch["group_diagnostic_fixed_bytes"] == 38, "accepted exact direct formats")

    lch = ada_source("a-elchha.adb")
    excdata = ada_source("a-exexda.adb")
    exspec = ada_source("a-except.ads")
    stalib = ada_source("s-stalib.ads")
    standard = ada_source("s-stalib.adb")
    soft = ada_source("s-soflin.adb")
    traces = ada_source("a-exextr.adb")
    stderr = ada_source("a-except.adb")
    params = ada_source("s-parame.ads")
    require("Default_Exception_Msg_Max_Length : constant := 200;" in params, "default message storage")
    require("Exception_Msg_Max_Length : constant := SP.Default_Exception_Msg_Max_Length;" in exspec, "message bound attachment")
    require("Max_Tracebacks : constant := 50;" in exspec, "traceback field bound")
    require("Msg : String (1 .. Exception_Msg_Max_Length);" in exspec, "message backing")
    require("Natural'Min (Message'Length, Exception_Msg_Max_Length)" in excdata, "string-message truncation")
    require("and then Excep.Msg_Length < Exception_Msg_Max_Length" in excdata, "C-message truncation")
    require("Exception_Trace : Exception_Trace_Kind := RM_Convention;" in stalib, "default trace mode")
    require("Global_Action : Exception_Action := null;" in traces and "Global_Unhandled_Action : Exception_Action := null;" in traces, "default hooks null")
    require("Raise_Hook_Initialized : Boolean := False;" in traces, "default raise hook disabled")
    require(lch.index("   System.Standard_Library.Adafinal;") < lch.index("   if Exception_Trace /= RM_Convention then"), "finalization precedes own diagnostic")
    require("Runtime_Finalized := True;\n         System.Soft_Links.Adafinal.all;" in standard, "flag set before finalization callback")
    require("Finalize_Library_Objects.all;" in soft and "Task_Termination_Handler.all" in soft, "both finalization hooks exposed")
    require('pragma Import (C, Unhandled_Terminate, "__gnat_unhandled_terminate");' in lch, "native termination interface explicit")
    require('pragma Import (C, Put_Char_Stderr, "put_char_stderr");' in stderr, "native character sink explicit")
    require("if S (J) /= ASCII.CR then" in stderr, "character sink no output expansion")
    require("Nobuf : String (1 .. 0);" in lch, "streaming zero-length buffer")
    require("if Info'Length = 0 then\n         To_Stderr (S);" in excdata, "streaming append bypasses length accumulation")
    require("if Info'Length = 0 then\n         To_Stderr (C);" in excdata, "streaming character bypasses counter")
    require("Append_Info_Untailored_Exception_Information (Except, Nobuf, Ptr);" in lch, "untailored terminal branch")

    literals = ["Execution terminated by abort of environment task",
                "Execution terminated by unhandled exception", "Execution of ",
                " terminated by unhandled exception", "raised ", " : "]
    for literal in literals:
        require('"'+literal+'"' in lch, f"exact terminal literal {literal}")
    named = {}
    for field in ["BEI_Name_Header", "BEI_Msg_Header", "BEI_PID_Header", "BETB_Header", "LDAD_Header"]:
        match = re.search(r'\b'+field+r'\s*: constant String := "([^"]*)";', excdata)
        require(match is not None, f"runtime literal {field}")
        named[field] = match.group(1)
    abort = len(literals[0])+2
    no_trace_constant = 1+len("raised ")+len(" : ")+200+1
    heading_with_argv_constant = 1+len(literals[2])+len(literals[3])+1
    heading_without_argv = 1+len(literals[1])+1
    basic_constant = len(named["BEI_Name_Header"])+len(named["BEI_Msg_Header"])+200+1+len(named["BEI_PID_Header"])+15
    traceback = len(named["LDAD_Header"])+19+len(named["BETB_Header"])+1+50*19+1
    constant = heading_with_argv_constant+basic_constant+traceback
    require((abort, no_trace_constant, heading_with_argv_constant, heading_without_argv,
             basic_constant, traceback, constant) == (51, 212, 49, 45, 231, 1016, 1296), "exact terminal branch arithmetic")
    names = re.findall(r'\b(?:Constraint_Error_Name|Program_Error_Name|Storage_Error_Name|Tasking_Error_Name|Abort_Signal_Name|Numeric_Error_Name)\s*: constant String := "([^"]*)"', stalib)
    require(len(names) == 6 and max(map(len, names)) == 16, "standard-only conditional name family")
    dump("terminal-output.json", {"message_bytes_upper": 200, "tracebacks_upper": 50,
                                  "literal_lengths": {s: len(s) for s in literals},
                                  "abort_bytes": abort, "no_traceback_constant": no_trace_constant,
                                  "heading_with_argv_constant": heading_with_argv_constant,
                                  "heading_without_argv_bytes": heading_without_argv,
                                  "basic_information_constant": basic_constant,
                                  "untailored_traceback_bytes_upper": traceback,
                                  "terminal_formula": "A+E+1296", "standard_name_family": names,
                                  "standard_only_E": 16, "standard_only_origin_closure_established": False})

    # Finite boundary corroboration of the symbolic inequalities, not a
    # universal source proof or an actual choice of configuration operands.
    imax, offmax = 2**31-1, 2**63-1
    configurations = []
    for a, e in [(1, 1), (1, 16), (256, 16), ((imax-72)//2, 1),
                 (1, imax-1297), (1, imax-1296), ((imax-72)//2+1, 1)]:
        q = max(2*a+72, a+e+constant)
        accepted = a >= 1 and e >= 1 and q <= imax
        if accepted:
            require(a <= imax and e+1 <= imax, "argv/name metadata operands")
            require(e+231 <= imax and e+1247 <= imax, "conservative helper maxima")
            require(q <= offmax and 2*a+72 <= imax, "off_t and direct printf length")
            for count, message_len in itertools.product(range(51), [0, 1, 200]):
                exact_basic = len("raised ")+e+len(" : ")+message_len+1+len("PID: ")+10+1
                exact_trace = (14+18+1+31+1+count*18+max(0,count-1)+1) if count else 0
                observed_bound = max(abort, e+12+message_len, a+49+exact_basic+exact_trace)
                require(observed_bound <= a+e+constant, "branch envelope for byte/count boundaries")
        configurations.append({"A": a, "E": e, "q": q, "sufficient_guard_pass": accepted})
    require([r["sufficient_guard_pass"] for r in configurations] == [True]*5+[False]*2, "exact sufficient guard boundary cases")
    # The second failure is an actual duplicate-alias counterexample, not a
    # claim about which descriptors a future implementation has used.
    aliases = []
    for old_fd in (3, 7, 37):
        before = {0: "stdin", 1: "backend", 2: "backend", old_fd: "backend"}
        only_dup = {**before, 1: "pipe", 2: "pipe"}
        require(only_dup[old_fd] == "backend", "dup2 alone leaves raw alias")
        closed = {fd: target for fd, target in only_dup.items() if fd in (0,1,2)}
        require("backend" not in closed.values(), "allowlisted child descriptor graph has no backend writer")
        aliases.append({"original_outfile_fd": old_fd, "initial": before,
                        "stdout_stderr_replaced_only": only_dup, "after_complete_alias_closure": closed})
    dump("guard-and-alias-check.json", {"role": "finite boundary/model corroboration; no actual descriptor manipulation",
                                       "configurations": configurations, "alias_models": aliases})
    current = load(ROOT/"docs/evidence/retained-current-protocol-join-20261023/result.json")
    current_count = sum(r["parallel_wire_entries_upper"] for r in current["cases"])
    retained_count = sum(r["retained_protocol_entries_upper"] for r in current["cases"])
    require(current_count == current["current_wire_entries_upper"] == 354, "accepted current launch count")
    require(retained_count == current["retained_protocol_entries_upper"] == 459, "retained conservative count")
    dump("projection.json", {"status": "conditional source-attached design interface",
                            "q_backend_formula": "max(2*A+72,A+E+1296)",
                            "actual_A": None, "actual_E": None, "actual_numeric_q_backend": None,
                            "sufficient_guard": "A>=1 and E>=1 and q_backend(A,E)<=2147483647",
                            "signed_off_t_max": offmax, "inherited_parent_stdio_payload": 0,
                            "inherited_setpgid_stdout_formula": "A+87",
                            "selected_solver_pipe_contribution_to_backend_file": 0,
                            "optional_raw_logging_selected": False,
                            "canonical_file_upper": 76, "control_decision_upper": 64,
                            "current_launch_entries_upper": current_count,
                            "retained_protocol_entries_upper": retained_count,
                            "current_cumulative_raw_payload_formula": "354*q_backend(A,E)",
                            "retained_cumulative_raw_payload_formula": "459*q_backend(A,E)",
                            "production_refinement_certificate": "Adapter_Backend_Emission",
                            "production_refinement_established": False,
                            "old_stock_solver_file_q_closed": False,
                            "whole_process_capacity_established": False,
                            "new_trusted_capacity_premise": False,
                            "global_e_upper": 2, "save_entering_callbacks_upper": 2,
                            "saves_upper": 3, "budget_renewed": False})
    result = {"status": "passed", "checks": checks, "provider_files": len(inputs),
              "source_members": len(rows), "strict_ranges": sum(len(r["ranges"]) for r in rows),
              "server_source_units": len(corpus), "runtime_source_members": len(runtime_inputs["source_members"]),
              "elapsed_seconds": round(time.monotonic()-start, 6),
              "target_runs": 0, "predecessor_checker_runs": 0,
              "compiler_solver_proof_capture_runs": 0, "disassembler_runs": 0}
    dump("result.json", result)
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
