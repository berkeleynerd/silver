#!/usr/bin/env python3
"""Replay the finite dispatch envelope offline; preserve all capacity gaps."""
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import compose

HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]


def check_tampered_input_rejected():
    """The standalone callable must reject changed accepted driver evidence."""
    inputs = json.loads((HERE/'inputs.json').read_bytes())
    with tempfile.TemporaryDirectory(prefix='silver-driver-envelope-tamper-') as temporary:
        root = Path(temporary)
        packet = root/HERE.relative_to(REPO)
        packet.mkdir(parents=True)
        for name in ('compose.py', 'inputs.json', 'sources.tar.gz'):
            shutil.copyfile(HERE/name, packet/name)
        for path in inputs['dependencies']:
            destination = root/path
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(REPO/path, destination)
        prior_path = 'docs/evidence/retained-producer-fixed-tail-20261018/result.json'
        prior = json.loads((root/prior_path).read_bytes())
        prior['driver_dispatch']['cvc5']['printer'] = 'unreviewed-printer'
        (root/prior_path).write_text(json.dumps(prior, indent=2)+'\n')
        attempt = subprocess.run([sys.executable, str(packet/'compose.py')],
                                 cwd=root, capture_output=True, text=True)
        assert attempt.returncode != 0 and prior_path in attempt.stderr, attempt
        assert not attempt.stdout, 'tampered input emitted a composition result'


def main():
    result=compose.compose()
    subprocess.run([sys.executable,str(HERE.parent/'retained-producer-fixed-tail-20261018/check.py')],
                   cwd=REPO,check=True,stdout=subprocess.DEVNULL)
    assert result==json.loads((HERE/'result.json').read_bytes())
    check_tampered_input_rejected()
    print(json.dumps({key:result[key] for key in [
        'sum_raw_initial_tasks','sum_registered_task_upper','sum_task_driver_pair_upper',
        'sum_configured_transform_application_upper','finite_dispatch_envelope_established',
        'backend_task_printer_capacity_established','whole_pipeline_capacity_established']},indent=2))
if __name__=='__main__':main()
