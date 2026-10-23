#!/usr/bin/env python3
"""Independent retained-byte/source/arithmetic review; runs no provider script."""
import argparse
import hashlib
import json
import platform
import re
import subprocess
import tarfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR = ROOT / "docs/evidence/retained-precut-failure-capacity-20261023"
FREEZE = "07e63b97f3623b2405172433ae093ce894defd23"
OCAML = "ocaml-8eb41f72ded84df884c3671734c947f612091f84/"
ARCHIVES = {
    "g": "docs/evidence/retained-server-libc-storage-20261020/glibc_2.43.orig.tar.xz",
    "o": "docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz",
    "w": "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz",
}
EXTRA = [
    ("g", "glibc-2.43/elf/dl-deps.c", 185, 210),
    ("g", "glibc-2.43/elf/dl-deps.c", 418, 430),
    ("g", "glibc-2.43/elf/dl-deps.c", 458, 470),
    ("g", "glibc-2.43/elf/dl-deps.c", 560, 574),
    ("g", "glibc-2.43/elf/dl-hwcaps.c", 95, 106),
    ("g", "glibc-2.43/elf/dl-hwcaps.c", 184, 198),
    ("g", "glibc-2.43/elf/dl-close.c", 350, 366),
    ("g", "glibc-2.43/elf/dl-exception.c", 36, 52),
    ("g", "glibc-2.43/elf/dl-exception.c", 81, 102),
    ("g", "glibc-2.43/elf/dl-open.c", 920, 943),
    ("g", "glibc-2.43/elf/dl-load.c", 2179, 2186),
    ("g", "glibc-2.43/elf/dl-reloc.c", 372, 405),
    ("g", "glibc-2.43/sysdeps/x86_64/dl-cet.c", 184, 258),
    ("g", "glibc-2.43/sysdeps/x86_64/dl-machine.h", 683, 717),
    ("g", "glibc-2.43/sysdeps/x86/dl-prop.h", 43, 64),
    ("o", OCAML + "stdlib/camlinternalFormat.ml", 1370, 1377),
    ("o", OCAML + "stdlib/camlinternalFormat.ml", 1933, 1953),
    ("o", OCAML + "stdlib/printf.ml", 34, 41),
    ("o", OCAML + "stdlib/string.ml", 116, 124),
    ("w", "why3/src/parser/typing.ml", 1566, 1580),
    ("w", "why3/src/parser/typing.ml", 1675, 1712),
    ("w", "why3/src/mlw/pmodule.ml", 1040, 1066),
    ("w", "why3/src/mlw/expr.ml", 697, 703),
    ("w", "why3/src/mlw/expr.ml", 719, 729),
]
COUNT = 0


def require(ok, label):
    global COUNT
    COUNT += 1
    if not ok:
        raise AssertionError(label)


def ident(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def read_input(name):
    if name.startswith("git:"):
        _, commit, path = name.split(":", 2)
        return subprocess.check_output(["git", "show", commit + ":" + path], cwd=ROOT)
    return (ROOT / name).read_bytes()


def core(b, e):
    l = b + e
    return {"B": b, "E": e, "L": l,
            "sentinel": l + 79 <= 1_000_000_010,
            "scan": (3 * e + 1) * (1_000_000_011 + l) + l + 79 <= 2**62 - 1,
            "index": 4 * (3 * e + 2) + 2 <= 2**62 - 1}


def arithmetic(p, u, n=467):
    k = 723 + 12 * max(467, u + 256, 4 * p + 2048, n)
    c = 8 * k + 65536
    r = c * sum(2**i for i in range(5))
    a = c * sum(4**i for i in range(5))
    x = 4 * (r + p + 1024)
    b, e = 6 * x + 576, 2 * x + 522
    cm = 8 * (723 + 12 * max(467, p + 51, n)) + 65536
    private, standard = core(a + p + 1024, 9936), core(b, e)
    channel = b + 70 * (e + 2) + 2 * r + 253
    return {"P": p, "U": u, "K": k, "C": c,
            "rendered_bytes": r, "aggregate_private_bytes": a,
            "abort_payload_sum_X": x,
            "marker_rendered_bytes": 15 * cm + 1024,
            "marker_private_aggregate_bytes": 85 * cm + 1024,
            "private_core": private, "standard_core": standard,
            "channel_offered_bytes": channel,
            "all_scalar_guards": all(private[key] and standard[key]
                for key in ("sentinel", "scan", "index")) and channel <= 2**63 - 1}


def project():
    # Bind every authored input and every authored packet file to the review freeze.
    freeze_files = [ROOT / "docs/research/retained-precut-failure-capacity.md"]
    freeze_files += sorted(AUTHOR.glob("*"))
    review_inputs = {}
    for path in freeze_files:
        if not path.is_file():
            continue
        rel = str(path.relative_to(ROOT))
        frozen = subprocess.check_output(["git", "show", FREEZE + ":" + rel], cwd=ROOT)
        require(path.read_bytes() == frozen, "author freeze: " + rel)
        review_inputs[rel] = ident(frozen)
    for name, expected in json.loads((AUTHOR / "inputs.json").read_text()).items():
        require(ident(read_input(name)) == expected, "provider identity: " + name)
        review_inputs[name] = expected

    archive_paths = set(ARCHIVES.values())
    archive_paths.add("docs/evidence/retained-producer-import-context-20261018/sources.tar.gz")
    archives = {name: tarfile.open(ROOT / name) for name in archive_paths}
    try:
        author_spans = json.loads((AUTHOR / "source-witnesses.json").read_text())
        for row in author_spans:
            data = archives[row["archive"]].extractfile(row["member"]).read()
            # Provider coordinates use decoded str.splitlines (including FF).
            text = "".join(data.decode().splitlines(keepends=True)[row["start"]-1:row["end"]]).encode()
            require(ident(data) == row["member_identity"], "author source identity")
            require(ident(text) == row["span_identity"] and text.decode() == row["text"],
                    "author exact source span")
        extra = []
        for kind, member, start, end in EXTRA:
            data = archives[ARCHIVES[kind]].extractfile(member).read()
            lines = data.decode().splitlines(keepends=True)
            require(1 <= start <= end <= len(lines), "supplementary span: " + member)
            text = "".join(lines[start-1:end]).encode()
            extra.append({"archive": ARCHIVES[kind], "member": member,
                          "start": start, "end": end, "member_identity": ident(data),
                          "span_identity": ident(text), "text": text.decode()})

        libraries = []
        for row in json.loads((ROOT / "docs/evidence/retained-why-report-path-inputs-20261023/library-projection.json").read_text()):
            data = archives["docs/evidence/retained-producer-import-context-20261018/sources.tar.gz"].extractfile(row["member"]).read()
            require(ident(data) == row["identity"], "complete library: " + row["member"])
            words = re.findall(rb"(?<![A-Za-z_0-9'])[A-Za-z_][A-Za-z_0-9']*", data)
            operators = re.findall(rb"[!$%&*+./:<=>?@^|~\\-]+", data)
            word_max = max(map(len, words), default=0)
            op_max = max(map(len, operators), default=0)
            # Include the one-time source proposition -> abstract 'lemma routine.
            require(word_max + 6 <= 467 and op_max + 16 <= 467, "original head envelope")
            libraries.append({"member": row["member"], "word_candidate_maximum": word_max,
                              "operator_run_maximum_including_comments": op_max})
    finally:
        for archive in archives.values():
            archive.close()

    # Inspect the full Debian patch corpus for the supplementary loader files too.
    selected = {row["member"].split("/", 1)[1] for row in extra if row["archive"] == ARCHIVES["g"]}
    patch_hits = []
    with tarfile.open(ROOT / "docs/evidence/retained-server-libc-storage-20261020/glibc_2.43-2ubuntu2.4.debian.tar.xz") as patches:
        for member in patches.getmembers():
            if not member.isfile() or "/patches/" not in member.name:
                continue
            data = patches.extractfile(member).read()
            targets = set(x.decode() for x in re.findall(rb"^\+\+\+\s+(?:b/)?([^\t\r\n ]+)", data, re.M))
            if selected & targets:
                patch_hits.append({"member": member.name, "identity": ident(data),
                                   "selected_targets": sorted(selected & targets), "text": data.decode()})

    author = json.loads((AUTHOR / "result.json").read_text())
    rows = {}
    for name, operands in author["operands"].items():
        require(operands["P_actual_joined"] is None and operands["client_cwd_bytes"] is None,
                "no implicit actual cwd/path attachment")
        row = arithmetic(180, operands["raw_json_string_maximum_U"])
        example = author["examples_only_not_actual_path_attachment"][name]
        require(all(example[k] == v for k, v in row.items()), "independent arithmetic: " + name)
        require(row["all_scalar_guards"], "conditional example guard")
        rows[name] = row
    require(author["global_e_upper"] == 2 and author["save_entering_callbacks_upper"] == 2
            and author["saves_upper"] == 3 and not author["renewed_failure_budget"], "global budget unchanged")
    require(not author["Ptree_serializer_provider_joined"] and not author["whole_process_capacity_established"],
            "pending serializer/composition explicitly preserved")
    require(author["raw_ptree_maximum_string_payload"] + 6 <= 467, "Ptree binder plus lemma suffix")
    require(sum(2**i for i in range(5)) == 31 and sum(4**i for i in range(5)) == 341,
            "separate geometric sums")
    require(sum(2**i for i in range(4)) == 15 and sum(4**i for i in range(4)) == 85,
            "marker geometric sums")
    # Universal affine inequality: D=2K+22680; C=8K+65536.
    # C-3D = 2K-2504 >= 0 for every K>=723+12*467=6327.
    require(2 * (723 + 12 * 467) - 2504 >= 0, "scalar-child 3D <= C")
    require(8 * 3 + 72 <= 32 * 3, "Dynlink conservative 8C+72D <= 32C")
    require(arithmetic(416, 0)["marker_rendered_bytes"] == 1743304,
            "marker at upper small-path boundary")
    require(arithmetic(417, 0)["marker_rendered_bytes"] > 1743304,
            "small-path value is conditional, not a universal constant")
    return {"inputs.json": review_inputs, "supplementary-source.json": extra,
            "supplementary-loader-patches.json": patch_hits,
            "library-head-check.json": libraries,
            "result.json": {"status": "pass", "reviewed_commit": FREEZE,
                "independent_arithmetic": rows, "source_semantics_machine_proved": False,
                "scalar_child_return": "D=2*K+22680; 3*D<=C for K>=6327",
                "dynlink_private_majorant": "8*C+72*D<=32*C",
                "native_runs": 0, "provider_checker_runs": 0,
                "actual_path_joined": False, "Ptree_serializers_joined": False,
                "whole_process_capacity_established": False}}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    started = time.monotonic()
    for name, data in project().items():
        if args.write:
            (HERE / name).write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
        else:
            require(json.loads((HERE / name).read_text()) == data, "retained review projection: " + name)
    record = {"status": "pass", "checks": COUNT, "elapsed_seconds": time.monotonic()-started,
              "host": platform.platform(), "selected_model": "gpt-6-astra", "selected_effort": "xhigh",
              "runtime_confirmed_model_effort": None, "isolated_token_cost_telemetry": None,
              "native_runs": 0, "provider_checker_runs": 0}
    print(json.dumps(record, indent=2))
    if args.write:
        (HERE / "round.json").write_text(json.dumps(record, indent=2) + "\n")


if __name__ == "__main__":
    main()
