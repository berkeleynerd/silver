"""Retain exact local inputs and bounded source excerpts; no source fetch."""
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
ARCHIVE = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
RANGES = {
    "why3/src/session/session_itp.ml": [
        [34, 143], [272, 298], [415, 459], [590, 637], [644, 745],
        [750, 970], [1169, 1183], [1412, 1424], [1940, 2244],
    ],
    "why3/src/session/session_itp.mli": [[10, 37], [74, 92], [102, 113]],
    "why3/src/session/controller_itp.ml": [[409, 559], [578, 652]],
    "why3/src/gnat/gnat_checks.ml": [[234, 261], [283, 353], [471, 487], [598, 662], [698, 727], [741, 754], [983, 1084], [1140, 1159]],
    "why3/src/gnat/gnat_config.ml": [[692, 712]],
    "why3/src/gnat/gnat_main.ml": [[50, 166], [270, 363]],
    "why3/src/gnat/gnat_scheduler.ml": [[1, 29]],
    "why3/src/driver/call_provers.ml": [[534, 563]],
    "why3/src/driver/whyconf.ml": [[55, 105]],
    "why3/src/core/ident.ml": [[157, 173]],
    "why3/src/util/exthtbl.ml": [[43, 70]],
}
PATTERNS = {
    "session_metadata_references": r"proofAttempt_table|proofn_attempts|session_prover_ids|file_state|th_state|tn_state|pn_state|proof_state\s*<-|proof_obsolete\s*<-|proof_script\s*<-|\.prover\s*<-",
    "forest_mutations": r"session_raw_tasks|trans_table|proofn_transformations\s*<-|transf_subtasks\s*<-|theory_goals\s*<-|file_theories\s*<-|transf_args",
    "save_and_signal_roots": r"save_session|set_signal|Sys\.signal",
}


def identity(b):
    return {"bytes": len(b), "sha256": hashlib.sha256(b).hexdigest()}


def dump(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n")


def source_projection():
    excerpts, census = {}, {}
    with tarfile.open(ROOT / ARCHIVE) as archive:
        for name, ranges in RANGES.items():
            raw = archive.extractfile(name).read()
            lines = raw.decode().splitlines(keepends=True)
            excerpts[name] = {
                "full_member_identity": identity(raw),
                "ranges": [{"first": lo, "last": hi, "text": "".join(lines[lo - 1:hi])}
                           for lo, hi in ranges],
            }
        # This is a reproducible lexical census of the named owned modules,
        # not a machine-proved whole-program call graph.
        modules = [name for name in RANGES if name.endswith(".ml")]
        for category, pattern in PATTERNS.items():
            census[category] = [
                {"member": name, "line": n, "text": line}
                for name in modules
                for n, line in enumerate(archive.extractfile(name).read().decode().splitlines(), 1)
                if re.search(pattern, line)
            ]
    return excerpts, census


def main():
    paths = [ARCHIVE,
        "docs/evidence/retained-producer-driver-envelope-20261018/inputs.json",
        "docs/evidence/retained-producer-driver-envelope-20261018/result.json",
        "docs/evidence/retained-producer-driver-envelope-20261018/review.md",
        "docs/evidence/retained-why-save-entry-inputs-20261020/entry-inputs.json",
        "docs/research/retained-why-ordinary-ending-control.md",
        "docs/reviews/review-why-ordinary-ending-control-20261020.md",
        "docs/research/retained-why-save-operational-bounds.md",
        "docs/research/retained-why-save-entry-inputs.md",
        "docs/research/retained-why-fixed-session-domain.md",
        "docs/research/retained-producer-driver-envelope.md",
        "docs/evidence/retained-why-ordinary-ending-control-20261020/source-excerpts.json",
    ]
    index = json.loads((ROOT / paths[4]).read_text())
    paths += ["docs/evidence/retained-why-save-entry-inputs-20261020/" + c["path"]
              for c in index["cases"]]
    excerpts, census = source_projection()
    dump(HERE / "source-excerpts.json", excerpts)
    dump(HERE / "source-census.json", census)
    paths += [str((HERE / f).relative_to(ROOT)) for f in
              ("source-excerpts.json", "source-census.json", "transfer.py", "build_packet.py", "check.py")]
    dump(HERE / "inputs.json", {
        "base": "22c5d9274ac7fe6ab7797aef378a3bcb4b4afafe",
        "why3_revision": "9390baf120ef260547dfa14f08e11c890b203d9c",
        "files": {p: identity((ROOT / p).read_bytes()) for p in paths},
    })


if __name__ == "__main__":
    main()
