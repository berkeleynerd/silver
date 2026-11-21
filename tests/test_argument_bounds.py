"""The owned argument wrapper preserves bytes and returns canonical String bounds."""
from __future__ import annotations

from pathlib import Path
import subprocess
import tempfile
import unittest

from scripts.platforms import alire_command, native_layout, tool_environment

ROOT = Path(__file__).resolve().parents[1]
RUNTIME_SOURCE = ROOT / "src"


class ArgumentBoundsTests(unittest.TestCase):
    def test_total_default_normalization(self) -> None:
        host = native_layout()
        with tempfile.TemporaryDirectory(prefix="silver-argument-bounds-") as temporary:
            directory = Path(temporary).resolve()
            (directory / "probe.gpr").write_text(f'''project Probe is
   for Source_Dirs use (".", "{RUNTIME_SOURCE}");
   for Source_Files use ("argument_bounds.adb", "silver_arguments.ads",
     "silver_arguments.adb", "silver_runtime.ads", "silver_output_libc.ads",
     "silver_io.ads", "silver_io.adb");
   for Main use ("argument_bounds.adb");
   for Object_Dir use "obj";
   for Exec_Dir use ".";
   package Compiler is
      for Default_Switches ("Ada") use ("-gnat2022", "-gnata", "-gnato");
   end Compiler;
end Probe;
''')
            (directory / "argument_bounds.adb").write_text('''with Silver_Arguments;
procedure Argument_Bounds is
   procedure Check (Default, Expected : String) is
      Value : constant String := Silver_Arguments.First_Or_Default (Default);
   begin
      pragma Assert (Value'First = 1);
      pragma Assert (Value = Expected);
   end Check;
   Shifted : constant String (100 .. 102) := "Ada";
   High : constant String (Positive'Last - 2 .. Positive'Last) := "end";
   Empty_High : constant String (Positive'Last .. Positive'Last - 1) := "";
   Empty_Negative : constant String (-5 .. -6) := "";
   Maximum : constant String (100 .. 4195) := (others => 'x');
   Oversize : constant String (100 .. 4196) := (others => 'x');
   Invalid : constant String (10 .. 10) := (others => Character'Val (9));
begin
   Check (Shifted, "Ada");
   Check (High, "end");
   Check (Empty_High, "");
   Check (Empty_Negative, "");
   Check (Maximum, Maximum);
   Check (Oversize, "");
   Check (Invalid, "");
end Argument_Bounds;
''')
            built = subprocess.run(
                alire_command(host, "exec", "--", "gprbuild", "-P",
                              directory / "probe.gpr", "-p", "-j1"),
                cwd=host.context, env=tool_environment(host),
                capture_output=True, text=True, timeout=120)
            self.assertEqual(built.returncode, 0, built.stdout + built.stderr)
            run = subprocess.run([directory / "argument_bounds"],
                                 capture_output=True, timeout=10)
            self.assertEqual(run.returncode, 0, run.stderr)
            self.assertEqual(run.stdout, b"")
            self.assertEqual(run.stderr, b"")


if __name__ == "__main__":
    unittest.main()
