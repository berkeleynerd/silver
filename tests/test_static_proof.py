"""Static proof annotations must still generate GNATprove obligations."""
from __future__ import annotations

import json
from pathlib import Path
import subprocess
import tempfile
import unittest

from scripts.platforms import alire_command, native_layout, tool_environment


class StaticProofTests(unittest.TestCase):
    def test_false_static_contract_is_rejected_by_real_gnatprove(self) -> None:
        host = native_layout()
        with tempfile.TemporaryDirectory(prefix="silver-static-proof-") as directory:
            root = Path(directory)
            (root / "probe.gpr").write_text('''project Probe is
   for Source_Dirs use (".");
   for Object_Dir use "obj";
   package Compiler is
      for Default_Switches ("Ada") use ("-gnat2022", "-gnata", "-gnato");
   end Compiler;
end Probe;
''')
            (root / "static_probe.ads").write_text('''package Static_Probe with SPARK_Mode => On is
   function Echo (Value : Boolean) return Boolean
     with Post => (Static => Echo'Result = Value);
end Static_Probe;
''')
            (root / "static_probe.adb").write_text('''package body Static_Probe with SPARK_Mode => On is
   function Echo (Value : Boolean) return Boolean is (not Value);
end Static_Probe;
''')
            result = subprocess.run(
                alire_command(host, "exec", "--", "gnatprove", "-P", root / "probe.gpr",
                              "--mode=all", "--report=all", "--checks-as-errors=on", "-j1"),
                cwd=host.context, env=tool_environment(host),
                capture_output=True, text=True, timeout=120)
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
            report = json.loads((root / "obj/gnatprove/static_probe.spark").read_text())
            failures = [record for record in report["proof"]
                        if record["rule"] == "VC_POSTCONDITION" and record["severity"] != "info"]
            self.assertTrue(failures, result.stdout + result.stderr)
            self.assertEqual(report["skip_proof"], [])
            self.assertEqual(report["pragma_assume"], [])


if __name__ == "__main__":
    unittest.main()
