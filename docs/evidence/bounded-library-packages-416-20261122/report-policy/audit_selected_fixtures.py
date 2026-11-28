from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(root))
from scripts.check_evidence import audit_reports

for name, locals in (("package-selected-policy-probe", False),
                     ("package-selected-local-policy-probe", True)):
    inventory = dict(
        name="Audit_State", assigned=True,
        functions=("Read", "Ignore"),
        procedures={"Produce": ("Answer",), "Depend": (), "Reset": (), "Replace": ()},
        formals={"Produce": (("Answer", "out"), ("Unread", "in")),
                 "Depend": (("Value", "in out"), ("Drop", "in")),
                 "Reset": (), "Replace": (), "Read": (),
                 "Ignore": (("Unused", "in"),)},
        states=("Stored", "Never", "Flag"),
        writes={"Produce": (), "Depend": (), "Reset": ("Stored", "Flag"),
                "Replace": ("Stored",)},
    )
    if locals:
        inventory["procedures"]["Local_Warnings"] = ()
        inventory["formals"]["Local_Warnings"] = ()
        inventory["writes"]["Local_Warnings"] = ("Stored", "Flag")
    report_dir = root / "tmp" / name / "out/obj/explore/indexed/gnatprove"
    print(name, audit_reports(report_dir, {"main", "audit_state"},
                             application_kind="assigned", application_package=inventory,
                             indexed_main=True, indexed_packages=True))
