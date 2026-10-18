#!/usr/bin/env python3
"""Copy existing evidence; never run a compiler, binder, assembler or linker."""
import argparse
import gzip
import io
import json
from pathlib import Path
import re
import tarfile

from check import analyze, digest


def archive(output, name, members):
    stream = io.BytesIO()
    with tarfile.open(fileobj=stream, mode="w") as tar:
        for key, (path, raw) in sorted(members.items()):
            info = tarfile.TarInfo(key)
            info.size = len(raw)
            info.mode = 0o644
            tar.addfile(info, io.BytesIO(raw))
    packed = gzip.compress(stream.getvalue(), mtime=0)
    (output/name).write_bytes(packed)
    return {"archive": digest(packed),
            "members": {k: {**digest(v), "original_path": str(p)} for k, (p, v) in sorted(members.items())}}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repair-installation", type=Path, required=True)
    parser.add_argument("--native-option-probe", type=Path, required=True)
    parser.add_argument("--binder-capture", type=Path, required=True)
    parser.add_argument("--binder-managed-run", type=Path, required=True)
    parser.add_argument("--gprconfig-capture", type=Path, required=True)
    parser.add_argument("--gprconfig-managed-run", type=Path, required=True)
    parser.add_argument("--compiler-capture", type=Path, required=True)
    parser.add_argument("--compiler-managed-run", type=Path, required=True)
    parser.add_argument("--gcc-ada", type=Path, required=True)
    parser.add_argument("--gcc-backend", type=Path, required=True)
    parser.add_argument("--gpr-source", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    artifacts, sources = {}, {}

    def add(mapping, key, path):
        mapping[key] = (path, path.read_bytes())

    cases = {"indexed-cr": "program-RibQE3", "indexed-lf": "program-rzfH0l", "indexed-uppercase": "program-5aNKVl"}
    install = args.repair_installation
    for case, directory in cases.items():
        workspace = install/".silver/linux-x86_64"/directory
        for file in ("main.adb", "program.gpr"):
            add(artifacts, f"cases/{case}/{file}", workspace/file)
        for file in ("main~1.ali", "b__main~1.ads", "b__main~1.adb", "b__main~1.ali", "b__main~1.o"):
            add(artifacts, f"cases/{case}/{file}", workspace/"obj"/file)
    old = args.native_option_probe/"null-proposed"
    add(artifacts, "cases/unindexed-proposed/main.adb", old/"src/main.adb")
    add(artifacts, "cases/unindexed-proposed/probe.gpr", old/"probe.gpr")
    for file in ("main.ali", "b__main.ads", "b__main.adb", "b__main.ali", "b__main.o"):
        add(artifacts, f"cases/unindexed-proposed/{file}", old/"obj"/file)
    add(artifacts, "cases/unindexed-proposed/build.stdout", old/"build.stdout")
    for file in ("run.py", "input-manifest.json", "invocation.json", "result.json", "stdout", "stderr",
                 "output/b__main~1.ads", "output/b__main~1.adb"):
        add(artifacts, "controlled-capture/"+file, args.binder_capture/file)
    for path in sorted((args.binder_capture/"temporary").glob("GPR.*/*.TMP")):
        add(artifacts, "controlled-capture/temporary/"+path.name, path)
    for file in ("events.jsonl", "native.log"):
        add(artifacts, "controlled-capture/managed/"+file, args.binder_managed_run/file)
    for file in ("run.py", "invocation.json", "result.json", "stdout", "stderr", "selected.cgpr"):
        add(artifacts, "configuration-capture/"+file, args.gprconfig_capture/file)
    for file in ("events.jsonl", "native.log"):
        add(artifacts, "configuration-capture/managed/"+file, args.gprconfig_managed_run/file)
    for file in ("run.py", "invocation.json", "result.json", "stdout", "stderr",
                 "dryrun.stdout", "dryrun.stderr"):
        add(artifacts, "compiler-capture/"+file, args.compiler_capture/file)
    compiler_invocation = json.loads((args.compiler_capture/"invocation.json").read_text())
    for file in ("b__main~1.ads", "b__main~1.adb", "b__main~1.ali", "b__main~1.o"):
        add(artifacts, "compiler-capture/output/"+file, Path(compiler_invocation["cwd"])/file)
    for file in ("events.jsonl", "native.log"):
        add(artifacts, "compiler-capture/managed/"+file, args.compiler_managed_run/file)
    adalib = install/".tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/lib/gcc/x86_64-pc-linux-gnu/16.1.0/adalib"
    knowledge = install/".tools/linux-x86_64/alire/toolchains/gprbuild_26.0.1_e3f27f25/share/gprconfig"
    for path in sorted(knowledge.rglob("*")):
        if path.is_file():
            add(artifacts, "configuration/"+str(path.relative_to(knowledge)), path)
    optional_default_search_files = {
        name: {"path": str(adalib.parent/name), "exists_at_collection": (adalib.parent/name).exists()}
        for name in ("ada_source_path", "ada_object_path")}
    assert all(not row["exists_at_collection"] for row in optional_default_search_files.values())
    for file in ["system.ads", "s-parame.ads", "s-secsta.ads", "s-stoele.ads"]:
        add(artifacts, "compiler-support/"+file, adalib.parent/"adainclude"/file)
    obj = install/".silver/linux-x86_64/program-RibQE3/obj"
    todo, seen = ["main~1.ali", "s-stalib.ali"], set()
    while todo:
        name = todo.pop()
        if name in seen:
            continue
        seen.add(name)
        path = obj/name if name == "main~1.ali" else adalib/name
        add(artifacts, "closure/"+name, path)
        raw = artifacts["closure/"+name][1]
        todo += [x.decode() for x in re.findall(rb"^[WYZ] \S+[ \t]+\S+[ \t]+(\S+)", raw, re.M)]
    ada_files = ["scng.adb", "lib-load.adb", "lib-writ.adb", "lib.adb", "sem.adb", "ali.adb", "ali.ads",
                 "ali-util.adb", "gnatbind.adb", "bindgen.adb", "osint-b.adb", "bindo-units.adb",
                 "bindo-builders.adb", "bindo-graphs.adb", "bindo-elaborators.adb", "gcc-interface/trans.cc",
                 "ali-util.ads", "table.adb", "opt.ads", "osint.adb", "namet.ads", "types.ads",
                 "libgnat/gnat.ads", "libgnat/g-dynhta.ads", "libgnat/g-dynhta.adb",
                 "namet.adb", "alloc.ads", "butil.adb", "switch-b.adb", "bindo-augmentors.adb",
                 "bindo-writers.adb", "bindo-diagnostics.adb", "bindo-validators.adb",
                 "back_end.adb", "sinput-l.adb", "sinput.adb", "gcc-interface/utils2.cc",
                 "gcc-interface/decl.cc", "exp_dbug.adb", "tbuild.adb", "fmap.adb", "fmap.ads",
                 "libgnat/s-os_lib.adb", "libgnat/s-os_lib.ads",
                 "snames.ads-tmpl", "snames.adb-tmpl", "xsnamest.adb", "bcheck.adb",
                 "uname.adb", "targparm.adb", "csets.adb", "uintp.adb", "scans.adb", "fname.adb",
                 "exp_attr.adb", "exp_tss.adb", "exp_tss.ads", "sem_util.adb", "exp_ch11.adb", "adaint.c",
                 "gcc-interface/utils.cc", "gcc-interface/misc.cc", "gcc-interface/ada-builtins.def",
                 "osint.ads", "output.adb", "output.ads", "hostparm.ads", "link.c", "Make-generated.in",
                 "libgnat/g-md5.ads", "libgnat/g-sechas.ads", "libgnat/g-sehamd.ads",
                 "libgnat/a-coinve.ads", "libgnat/a-coinve.adb",
                 "libgnat/g-table.ads", "libgnat/g-table.adb",
                 "libgnat/g-dyntab.ads", "libgnat/g-dyntab.adb",
                 "libgnat/a-textio.ads", "libgnat/a-textio.adb", "libgnat/a-tigeli.adb",
                 "libgnat/s-fileio.adb", "libgnat/s-ficobl.ads", "libgnat/i-cstrea.ads", "cstreams.c"]
    for file in ada_files:
        add(sources, "gcc/ada/"+file, args.gcc_ada/file)
    backend_files = ["cfgrtl.cc", "tree.cc", "tree-core.h", "varasm.cc", "stringpool.cc",
                     "ggc-common.cc", "ggc-page.cc", "gimple-ssa-warn-access.cc",
                     "langhooks.cc", "cgraphclones.cc", "cgraphunit.cc", "cgraph.cc", "cgraph.h",
                     "lto-cgraph.cc", "symtab.cc", "defaults.h", "common.opt", "opts.cc",
                     "builtins.def", "sync-builtins.def", "omp-builtins.def", "gtm-builtins.def",
                     "sanitizer.def", "coroutine-builtins.def", "optabs.def", "optabs-libfuncs.cc",
                     "config/i386/i386.cc", "config/i386/i386.h", "config/i386/i386-features.cc",
                     "config/i386/i386-builtins.cc", "config/i386/i386-builtins.h",
                     "config/i386/i386-builtin.def", "config/i386/att.h", "config/elfos.h", "prefix.cc"]
    for file in backend_files:
        add(sources, "gcc/"+file, args.gcc_backend/file)
    libcpp_files = ["symtab.cc", "line-map.cc"]
    for file in libcpp_files:
        add(sources, "libcpp/"+file, args.gcc_backend.parent/"libcpp"/file)
    for file in ["src/gprbind.adb", "src/gprbuild-post_compile.adb",
                 "gpr/src/gpr_build_util.adb", "gpr/src/gpr-tempdir.adb",
                 "gpr/src/gpr-util.ads", "src/gprbuild-compile.adb", "gpr/src/gpr-opt.ads",
                 "gpr/src/gpr-util.adb", "gpr/src/gpr.ads", "src/gprexch.ads", "src/gprexch.adb"]:
        add(sources, "gpr/"+file, args.gpr_source/file)
    for file in ["gpr-ali.adb", "gpr-ali.ads", "gpr-names.adb", "gpr-names.ads",
                 "gpr-osint.adb", "gpr-osint.ads", "gpr-script.adb", "gpr.adb"]:
        add(sources, "gpr/gpr/src/"+file, args.gpr_source/"gpr/src"/file)
    for file in ["silver.adb", "silver_platform.adb"]:
        add(sources, "silver/src/"+file, install/"src"/file)
    gcc_manifest = json.loads((args.gcc_ada.parents[1]/"complete-source-manifest.json").read_text())
    assert gcc_manifest["commit"] == "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
    pins = {f["path"]: f for f in gcc_manifest["files"]}
    for file in ada_files:
        assert digest(sources["gcc/ada/"+file][1]) == {k: pins[file][k] for k in ("bytes", "sha256")}
    backend_manifest = json.loads((args.gcc_backend.parent/"manifest.json").read_text())
    assert backend_manifest["commit"] == gcc_manifest["commit"]
    backend_pins = {f["path"]: f for f in backend_manifest["files"]}
    for file in backend_files:
        assert digest(sources["gcc/"+file][1]) == {k: backend_pins["gcc/"+file][k] for k in ("bytes", "sha256")}
    for file in libcpp_files:
        assert digest(sources["libcpp/"+file][1]) == {
            k: backend_pins["libcpp/"+file][k] for k in ("bytes", "sha256")}
    result = analyze({k: v for k, (_, v) in artifacts.items()},
                     {k: v for k, (_, v) in sources.items()})
    (args.output/"result.json").write_text(json.dumps(result, indent=2, sort_keys=True)+"\n")
    manifest = {"gcc_commit": gcc_manifest["commit"], "gpr_commit": "bdfb879cf03643ec8e48a09ce07b08c4a6ff0263",
                "source_identity_scope": "retained source pins, not historical binary build attestation",
                "optional_default_search_files": optional_default_search_files,
                "archives": {"sources.tar.gz": archive(args.output, "sources.tar.gz", sources),
                             "artifacts.tar.gz": archive(args.output, "artifacts.tar.gz", artifacts)}}
    (args.output/"manifest.json").write_text(json.dumps(manifest, indent=2, sort_keys=True)+"\n")
    print("Copied existing sources/artifacts only; no native tool execution.")


if __name__ == "__main__":
    main()
