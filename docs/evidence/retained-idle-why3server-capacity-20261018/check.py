#!/usr/bin/env python3
"""Replay source identities and local startup arithmetic; executes no native tool."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile


PIN = "9390baf120ef260547dfa14f08e11c890b203d9c"


def body(source, name):
    match = re.search(r"\n[^\n]*\b" + name + r"\s*\([^;]*?\)\s*\{", source)
    assert match, name
    end = source.index("\n}", match.end())
    return source[match.end():end]


def layout(fields):
    cursor, alignment = 0, 1
    for size, align in fields:
        cursor = (cursor + align - 1) // align * align
        cursor += size
        alignment = max(alignment, align)
    return (cursor + alignment - 1) // alignment * alignment


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    packet = Path(__file__).resolve().parent
    manifest = json.loads((packet / "source-manifest.json").read_text())
    assert manifest["why3_revision"] == PIN
    archive = packet / "sources.tar.gz"
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == manifest["bundle_sha256"]
    sources = {}
    with tarfile.open(archive) as tar:
        assert sorted(tar.getnames()) == sorted(row["path"] for row in manifest["files"])
        for row in manifest["files"]:
            data = tar.extractfile(row["path"]).read()
            assert len(data) == row["bytes"]
            assert hashlib.sha256(data).hexdigest() == row["sha256"]
            sources[row["path"]] = data.decode()

    def why3(file):
        return sources["why3/src/server/" + file]

    server = why3("server-unix.c")
    startup = body(server, "server_init_listening")
    assert startup.count("malloc(") == 1
    assert startup.count("strdup(socketname)") == 2
    for call in ("init_request_queue();", "clients = init_list(parallel);",
                 "poll_len = 2 + parallel;", "init_process_list();",
                 "setup_child_pipe();", "set_sigterm_handler();",
                 "add_to_poll_list(server_sock, POLLIN);"):
        assert startup.count(call) == 1, call
    assert "listen(server_sock, parallel*2)" in startup
    assert "strlen(filen) + 1 > unix_path_max()" in startup
    assert "memcpy(addr.sun_path, filen, strlen(filen) + 1);" in startup
    assert "return getcwd(NULL, 0);" in body(server, "get_cur_dir")
    assert "add_to_poll_list(cpipe[0], POLLIN);" in body(server, "setup_child_pipe")
    assert "if (poll_num == poll_len)" in body(server, "add_to_poll_list")
    assert "queue = init_queue(100);" in body(why3("request.c"), "init_request_queue")
    assert len(re.findall(r"\bmalloc\s*\(", body(why3("queue.c"), "init_queue"))) == 2
    assert len(re.findall(r"\bmalloc\s*\(", body(why3("arraylist.c"), "init_list"))) == 3
    assert "processes = init_list(parallel);" in body(why3("proc.c"), "init_process_list")
    assert "parallel = strtol(optarg, NULL, 10);" in why3("options.c")
    assert "bool logging = false;" in why3("options.c")
    assert "if (logging)" in body(why3("logging.c"), "init_logging")
    assert "queue_is_empty (queue)" in body(server, "schedule_new_jobs")
    assert "poll(poll_list, poll_num, -1)" in body(server, "main")

    # Declaration anchors accompany independently written ABI field arithmetic.
    for declaration in ("void** data;", "unsigned int pointer;",
                        "unsigned int len;", "unsigned int capacity;"):
        assert declaration in why3("queue.h")
    for declaration in ("int* key;", "void** data;", "int len;", "int capacity;"):
        assert declaration in why3("arraylist.h")
    poll_header = sources["linux-headers/sys/poll.h"]
    assert "int fd;" in poll_header
    assert "short int events;" in poll_header and "short int revents;" in poll_header
    assert "typedef unsigned long int nfds_t;" in poll_header
    assert "char sun_path[108];" in sources["linux-headers/sys/un.h"]
    assert "typedef unsigned short int sa_family_t;" in sources["linux-headers/bits/sockaddr.h"]
    sigset = sources["linux-headers/bits/types/__sigset_t.h"]
    assert "(1024 / (8 * sizeof (unsigned long int)))" in sigset
    assert "unsigned long int __val[_SIGSET_NWORDS];" in sigset
    action = sources["linux-headers/bits/sigaction.h"]
    assert "__sigset_t sa_mask;" in action and "int sa_flags;" in action
    assert "void (*sa_restorer) (void);" in action
    assert "lib/why3server$(EXE): $(SERVER_O)\n\t$(CC) -Wall -o $@ $^" in sources["why3/Makefile.in"]

    pointer, integer, short = (8, 8), (4, 4), (2, 2)
    queue = layout([pointer, integer, integer, integer])
    arraylist = layout([pointer, pointer, integer, integer])
    poll = layout([integer, short, short])
    sockaddr = layout([short, (108, 1)])
    sigaction = layout([pointer, (128, 8), integer, pointer])
    assert (queue, arraylist, poll, sockaddr, sigaction) == (24, 24, 8, 110, 152)
    fixed_bytes = queue + 100 * 8 + 2 * arraylist + 2 * poll
    worker_bytes = 2 * (4 + 8) + poll
    j_max = (2**31 - 1) // 2
    assert j_max + 2 <= 2**31 - 1 and j_max * 2 <= 2**31 - 1
    assert 8 * (j_max + 2) < 2**63 - 1
    assert (fixed_bytes, worker_bytes) == (888, 32)
    result = {
        "why3_revision": PIN,
        "source_files_checked": len(sources),
        "selected_ABI": "Linux x86_64 LP64 with ordinary System V field layout",
        "queue_header_bytes": queue,
        "queue_initial_capacity": 100,
        "queue_backing_bytes": 800,
        "list_header_bytes": arraylist,
        "list_backings_each": ["4*J", "8*J"],
        "poll_record_bytes": poll,
        "poll_capacity": "J+2",
        "idle_poll_count": 2,
        "sockaddr_un_bytes": sockaddr,
        "socket_basename_max_bytes": 107,
        "sigaction_bytes": sigaction,
        "direct_malloc_calls": 2 + 2*3 + 1,
        "direct_malloc_raw_bytes": "888+32*J",
        "individual_malloc_request_max": "max(800,8*(J+2))",
        "worker_representation_max": j_max,
        "largest_malloc_at_worker_representation_max": 8*(j_max+2),
        "strdup_result_requests": ["S+1", "S+1"],
        "getcwd_result_bytes": "C+1; internal libc requests use the existing external resource premise",
        "scope": "conditional idle startup and explicit server-owned C storage; not whole producer/libc/kernel capacity",
        "native_runs": 0,
        "solver_runs": 0,
        "lean_builds": 0,
    }
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
