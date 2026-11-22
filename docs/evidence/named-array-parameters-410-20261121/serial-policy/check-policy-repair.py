from pathlib import Path
import shutil
import sys
import tempfile
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(root))
from tests.test_samples import SupportedSampleTests

saved = Path(__file__).parent / "hello_world"
fixtures = Path(__file__).parent / "policy-fixtures"
fixtures.mkdir(exist_ok=True)
check = SupportedSampleTests()
check.assert_application_proof_policy(saved / "gnatprove.sarif", output=True)
for case in ("wrong_step_limit", "no_external_attempt", "undone_only"):
    with tempfile.TemporaryDirectory(dir=fixtures) as directory:
        fixture = Path(directory) / "report"
        shutil.copytree(saved, fixture)
        for path in fixture.rglob("why3session.xml"):
            tree = ET.parse(path)
            if case == "wrong_step_limit":
                for prover in tree.getroot().findall("prover"):
                    if prover.get("name") != "Trivial":
                        prover.set("steplimit", "10000")
            elif case == "undone_only":
                for proof in tree.iter("proof"):
                    for child in list(proof):
                        proof.remove(child)
                    ET.SubElement(proof, "undone")
            else:
                for parent in tree.iter():
                    for child in list(parent):
                        if child.tag == "proof":
                            parent.remove(child)
            tree.write(path)
        with check.assertRaises(AssertionError):
            check.assert_application_proof_policy(fixture / "gnatprove.sarif", output=True)
print("PASS: retained serial proof accepted; wrong step limit, declaration-only and undone-only sessions rejected.")
