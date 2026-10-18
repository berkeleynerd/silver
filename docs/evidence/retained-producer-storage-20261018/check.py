#!/usr/bin/env python3
"""Check source identities and local append arithmetic without large allocations."""
import argparse
import hashlib
import json
from pathlib import Path

RANGES = {
    'libgnat/a-contai.ads': [(16, 28)],
    'libgnat/a-coinve.ads': [(409, 432)],
    'libgnat/a-coinve.adb': [(214, 248), (297, 315), (1200, 1283),
                            (1330, 1396), (1498, 1591), (2467, 2494), (2890, 2935)],
    'libgnat/a-cdlili.ads': [(269, 289)],
    'libgnat/a-cdlili.adb': [(114, 171), (763, 813), (865, 906)],
}


def transition(first, demand):
    limit = 2**30
    assert 1 <= demand <= limit
    capacity = 1 << (demand - 1).bit_length()
    last = first - 1 + demand
    dst_last = first - 1 + capacity
    assert capacity <= limit
    assert -2**31 <= first - 1 <= last <= 2**31-1
    assert -2**31 <= dst_last <= 2**31-1
    assert -1 <= last - first <= limit - 1
    assert last - first + 1 == demand
    if capacity > 1:
        assert capacity // 2 <= (2**31-1)//2
        assert 2 * (capacity // 2) == capacity < 2**31
    return dict(first=first, demand=demand, capacity=capacity, last=last,
                allocated_last=dst_last, backbone_bytes=8+8*capacity,
                conservative_two_backbone_bytes=16+16*capacity)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ada', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[3]
    old = json.loads((root / 'docs/evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json').read_text())
    assert old['commit'] == '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
    expected = {r['path']: r for r in old['files']}
    records, excerpts = [], ['# Pinned producer storage sources\n\nLF line numbering.\n']
    for name, ranges in RANGES.items():
        data = (args.ada / name).read_bytes()
        digest = hashlib.sha256(data).hexdigest()
        assert digest == expected[name]['sha256']
        assert len(data) == expected[name]['bytes']
        records.append(dict(path=name, bytes=len(data), sha256=digest))
        lines = data.decode().split('\n')
        for start, end in ranges:
            excerpts.append(f'\n## {name}:{start}–{end}\n\n```text\n')
            excerpts.extend(f'{i}: {lines[i-1]}'.rstrip()+'\n' for i in range(start, end+1))
            excerpts.append('```\n')
    cases = sorted({1,2,3,2**30} | {2**k+delta for k in range(1,30) for delta in (-1,0,1)})
    rows = [transition(first,d) for first in (0,2**30) for d in cases]
    result = dict(source_commit=old['commit'], sources=records, transitions=rows,
                  maximum_usable_nodes=2**30-1, maximum_lists=2**30,
                  sufficient_total_retained_elements=2**31-1,
                  retained_link_bytes_at_count_limit=24*(2**31-1),
                  scope='local append/growth arithmetic, not caller coverage or whole-tool capacity')
    assert result['retained_link_bytes_at_count_limit'] < 2**63
    args.output.mkdir(parents=True,exist_ok=True)
    (args.output/'checks.json').write_text(json.dumps(result,indent=2)+'\n')
    (args.output/'source-excerpts.md').write_text(''.join(excerpts))
    print(f'Verified {len(records)} pinned files and {len(rows)} boundary transitions')


if __name__ == '__main__':
    main()
