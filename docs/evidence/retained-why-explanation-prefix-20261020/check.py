"""Check the selected explanation-prefix route and conditional byte bounds.

This is retained source/configuration evidence, not execution of Why3 or a
native observation of Termcode.expl_prefixes. See the accompanying argument.
"""
import argparse
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SOURCE = "docs/evidence/retained-why-session-helper-source-20261019/"
DOMAIN = "docs/evidence/retained-why-fixed-session-domain-20261020/"
PRIOR = "docs/evidence/retained-why-session-save-state-20261019/"
ATOMS = "docs/evidence/retained-why-fixed-session-atoms-20261020/"
SHAPE = "docs/evidence/retained-why-session-shape-transfer-20261020/"
DRIVERS = "docs/evidence/retained-why-preparation-entry-20261018/drivers.tar.gz"
CASES = ("put-line", "put", "first-or-default", "is-message", "input-is-valid")
TOKENS = ("expl_prefixes", "add_extra_expl_prefix", "arg_extra_expl_prefix",
          "opt_extra_expl_prefix")


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def member(path, name):
    with tarfile.open(ROOT / path) as archive:
        return archive.extractfile(name).read()


def census(sources):
    return {token: [dict(member=name, line=i, text=line)
        for name, raw in sorted(sources.items())
        for i, line in enumerate(raw.decode().splitlines(), 1)
        if re.search(r"\b" + token + r"\b", line)] for token in TOKENS}


def derive():
    with tarfile.open(ROOT / SOURCE / "sources.tar.gz") as archive:
        sources = {m.name: archive.extractfile(m).read() for m in archive
                   if m.isfile() and m.name.startswith("why3/")
                   and m.name.endswith((".ml", ".mli", ".mll", ".mly"))}
    source_manifest = json.loads((ROOT / SOURCE / "source-identities.json").read_text())
    for name, raw in sources.items():
        assert identity(raw) == source_manifest["members"][name]["identity"], name
    uses = census(sources)
    assert {r["member"] for r in uses["expl_prefixes"]} == {
        "why3/src/session/termcode.ml"}
    assert {r["member"] for r in uses["add_extra_expl_prefix"]} == {
        "why3/src/session/termcode.ml", "why3/src/session/termcode.mli"}
    wrapper_users = {r["member"] for token in ("arg_extra_expl_prefix", "opt_extra_expl_prefix")
                     for r in uses[token]} - {
        "why3/src/session/termcode.ml", "why3/src/session/termcode.mli"}
    assert wrapper_users == {"why3/src/ide/why3ide.ml", "why3/src/ide/why3web.ml",
                             "why3/src/tools/why3prove.ml"}
    termcode = sources["why3/src/session/termcode.ml"].decode()
    config = sources["why3/src/gnat/gnat_config.ml"].decode()
    util = sources["why3/src/gnat/gnat_util.ml"].decode()
    assert 'let expl_prefixes = ref ["expl:";"infer:"]' in termcode
    assert 'let add_extra_expl_prefix s = expl_prefixes := s :: !expl_prefixes' in termcode
    assert 'Arg.parse options set_filename usage_msg' in config
    assert 'extra_expl_prefix' not in config and 'extra-expl-prefix' not in config
    assert 'let builtin_provers = ["altergo"; "colibri"; "cvc5"; "z3"]' in config
    assert '~load_plugins:(not builtin_provers_only)' in config
    assert 'List.iter (Plugin.load ~dirs) ["gnat_json"; "ada_terms"]' in util
    assert '"plugin", PLUGIN;' in sources["why3/src/driver/driver_lexer.mll"].decode()
    assert '| PLUGIN STRING STRING { Plugin ($2,$3) }' in sources["why3/src/driver/driver_parser.mly"].decode()

    common = DOMAIN + "capture-common.tar.gz"
    prior = PRIOR + "capture.tar.gz"
    plans = [json.loads(member(a, "plan.json")) for a in (common, prior)]
    resolutions = [json.loads(member(a, "driver-resolution.json")) for a in (common, prior)]
    with tarfile.open(ROOT / DRIVERS) as archive:
        retained_drivers = {Path(m.name).name: archive.extractfile(m).read()
                            for m in archive if m.isfile()}
    driver_rows = []
    for group, (archive, plan, resolution) in enumerate(zip((common, prior), plans, resolutions)):
        assert set(plan["selected_driver_closure"].values()) == set(resolution)
        for path, row in sorted(resolution.items()):
            name = Path(path).name
            raw = (member(archive, "overlay/" + name) if "/overlay/" in path
                   else retained_drivers[name])
            assert identity(raw) == row["identity"] == plan["file_identities"][path], path
            # Stronger than a parsed no-Plugin test: the literal token is absent
            # even in comments/strings throughout every selected import file.
            assert re.search(rb"\bplugin\b", raw, re.IGNORECASE) is None, path
            for imp in row["imports"]:
                assert len(imp["candidates"]) == 1
                assert imp["candidates"][0] in resolution
            driver_rows.append(dict(group=group, name=name, identity=identity(raw),
                                    plugin_token_absent=True))
        assert member(archive, "overlay/why3.conf") == b"[main]\nmagic = 14\n"

    spec = importlib.util.spec_from_file_location("retained_shape_transfer", ROOT / SHAPE / "transfer.py")
    shape = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(shape)
    rows = []
    for case in CASES:
        group = int(case == "input-is-valid")
        archive = prior if group else DOMAIN + "capture-" + case + ".tar.gz"
        process_member = case.replace("-", "_") + "/capture/process.json"
        process = json.loads(member(archive, process_member))
        argv = process["argv"]
        assert argv.count("--prover") == 1
        provers = argv[argv.index("--prover") + 1].split(",")
        assert provers == ["cvc5", "z3", "altergo"]
        assert not any("extra-expl-prefix" in a for a in argv)
        assert "--replay" not in argv and "--prepare-shared" not in argv
        assert any(i["argv"] == argv for i in plans[group]["inputs"])
        atoms = json.loads(gzip.decompress((ROOT / ATOMS / (case + "-atoms.json.gz")).read_bytes()))
        bound = shape.derive(atoms, explanation_prefix_count=2)
        assert bound["explanation"]["typed_attribute_closure_established"] is True
        without_p = shape.derive(atoms)
        assert without_p["explanation"]["per_insertion_bytes_upper"] is None
        incomplete = dict(atoms, typed_graph_complete=False)
        assert shape.derive(incomplete, explanation_prefix_count=2)["explanation"]["per_insertion_bytes_upper"] is None
        rows.append(dict(case=case, pid=process["pid"], selected_provers=provers,
                         G=bound["G"], explanation=bound["explanation"],
                         actual_native_prefix_observed=False,
                         prefix_two_under_selected_source_and_preservation_premises=True))

    return dict(status="pass", why3_ocaml_source_members=len(sources), census=uses,
                selected_driver_files=driver_rows, rows=rows,
                source_route_checked=True, direct_native_prefix_observation=False,
                source_native_behavior_premise_discharged=False,
                complete_save_capacity_established=False,
                whole_pipeline_capacity_established=False,
                native_executions=0, graph_openings=0, binder_replays=0,
                checks="retained hashes, complete corpus use census, selected argv/driver joins, existing E(p) arithmetic")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    started = time.monotonic()
    for name, expected in json.loads((HERE / "inputs.json").read_text()).items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    result = derive()
    if args.write:
        (HERE / "result.json").write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    else:
        assert result == json.loads((HERE / "result.json").read_text())
    print(json.dumps(dict(status=result["status"], forests=len(result["rows"]),
                         source_members=result["why3_ocaml_source_members"],
                         elapsed_seconds=time.monotonic() - started,
                         complete_save_capacity_established=False), indent=2))


if __name__ == "__main__":
    main()
