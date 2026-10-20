"""Focused source/hash/algebra check; no graph, binder or alpha replay."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import platform
import tarfile
import time

from transfer import derive

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
ATOM_PACKET = "docs/evidence/retained-why-fixed-session-atoms-20261020/"
CASES = ("put-line", "put", "first-or-default", "is-message", "input-is-valid")


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--atoms-root", type=Path, default=ROOT / ATOM_PACKET)
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    started = time.monotonic()
    inputs = json.loads((HERE / "inputs.json").read_text())
    for name, expected in inputs.items():
        path = args.atoms_root / name[len(ATOM_PACKET):] if name.startswith(ATOM_PACKET) else ROOT / name
        assert identity(path.read_bytes()) == expected, name
    witnesses = json.loads((HERE / "source-witnesses.json").read_text())
    for witness in witnesses:
        if "archive" in witness:
            with tarfile.open(ROOT / witness["archive"], "r:gz") as archive:
                raw = archive.extractfile(witness["member"]).read()
        else:
            raw = (ROOT / witness["path"]).read_bytes()
        assert identity(raw) == witness["member_identity"]
        lines = raw.decode().splitlines(keepends=True)
        text = "".join(lines[witness["first"] - 1:witness["last"]])
        assert text == witness["text"], witness["label"]
        assert all(anchor in text for anchor in witness["anchors"]), witness["label"]
    rows = []
    for case in CASES:
        atoms = json.loads(gzip.decompress((args.atoms_root / f"{case}-atoms.json.gz").read_bytes()))
        assert atoms["case"].replace("_", "-") == case
        provenance = atoms["provenance"]
        raw = (ROOT / provenance["occurrence_certificate"]).read_bytes()
        assert identity(raw) == provenance["occurrence_certificate_identity"]
        saved = json.loads(raw)
        cert = saved.get("full_certificate", saved)
        assert atoms["saved_occurrence_certificate"] == cert
        # Check derived string/attribute summary fields without walking raw terms.
        assert atoms["original_name_bytes_max"] == max(
            (len(bytes.fromhex(i["name_hex"])) for i in atoms["identifiers"].values()), default=0)
        for i in atoms["identifiers"].values():
            assert len(bytes.fromhex(i["name_hex"])) == i["length"]
        attrs = atoms["attributes"]
        union = atoms["shape_attribute_union"]
        assert len(set(union["pointers"])) == union["count"]
        assert sum(attrs[str(p)]["bytes"] for p in union["pointers"]) == union["sum_bytes"]
        assert set(union["pointers"]) == (set(atoms["term_attribute_union"]) |
                                           set(atoms["proposition_identifier_attribute_union"]))
        for attr in attrs.values():
            assert len(bytes.fromhex(attr["hex"])) == attr["bytes"]
        for c in atoms["constants"].values():
            if c["kind"] in ("int", "real"):
                for part in c["parts"]:
                    if part.get("decimal_bytes") is not None:
                        assert len(str(int(part["value"]))) == part["decimal_bytes"]
        row = derive(atoms)
        assert row["typed_atom_join_established"]
        assert all(row["numerical_guards"].values())
        assert all(atoms[k] == 0 for k in ("native_executions", "session_replays",
                                          "binder_recomputations", "alpha_replays"))
        rows.append(row)
    result = dict(status="pass", platform=platform.platform(), source_ranges=len(witnesses),
        input_identities=len(inputs), forests=len(rows),
        table=[{k: row[k] for k in ("case", "B_imported", "G", "J", "L")} for row in rows],
        checks="source excerpts, exact atom/certificate joins, byte summaries and mathematical guards",
        native_executions=0, session_replays=0, binder_recomputations=0, alpha_replays=0,
        complete_save_capacity_established=False, whole_pipeline_capacity_established=False,
        elapsed_seconds=time.monotonic() - started)
    if args.write:
        (HERE / "bounds.json").write_text(json.dumps(rows, indent=2, sort_keys=True) + "\n")
        (HERE / "check-result.json").write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    else:
        assert rows == json.loads((HERE / "bounds.json").read_text())
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
