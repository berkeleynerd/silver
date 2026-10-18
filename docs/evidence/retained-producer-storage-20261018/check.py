#!/usr/bin/env python3
"""Check source identities and local append arithmetic without large allocations."""
import argparse
import hashlib
import json
import re
import tarfile
from pathlib import Path

RANGES = {
    'libgnat/a-contai.ads': [(16, 28)],
    'libgnat/a-coinve.ads': [(409, 432)],
    'libgnat/a-coinve.adb': [(214, 248), (297, 315), (1200, 1283),
                            (1330, 1396), (1498, 1591), (2467, 2494), (2890, 2935)],
    'libgnat/a-cdlili.ads': [(269, 289)],
    'libgnat/a-cdlili.adb': [(114, 171), (763, 813), (865, 906)],
    'libgnat/a-cohama.adb': [(628, 644)],
    'libgnat/a-chtgke.adb': [(148, 199)],
    'libgnat/a-chtgop.adb': [(49, 132), (613, 623), (677, 836)],
    'libgnat/a-coprnu.ads': [(30, 51)],
    'libgnat/a-coprnu.adb': [(32, 59)],
    'libgnat/a-textio.ads': [(80, 84), (675, 690)],
    'libgnat/a-textio.adb': [(170, 207), (1109, 1143), (1255, 1330), (2048, 2078)],
}

SPARK = {
    'src/utils/outputs.adb': ('6a729fa922f882458ef3bd33fb8000407f22f58bd79ab1a71d2d0ea8d427bbb2', [(47, 59), (73, 119)]),
    'src/utils/outputs.ads': ('3f88827c01180e657de92414ed804027e5b6db74dd3088997fb91ec16e4cc912', [(31, 68)]),
    'src/why/gnat2why-driver.adb': ('b3a37440a935dd9e4c8840c41807b0894a4ad710c63ceb9d344a3db804ebe304', [(1204, 1215)]),
    'src/why/xgen/why-atree-to_json.adb-tmpl': ('634f218e59e225ced82095a509f1e074a5681d5143e71f2a32dd886f3882465e', [(56, 90), (113, 157)]),
    'src/why/xgen/xtree_why_ast.adb': ('65277b8c3d31fbd9eac3da32ae562a660cf9f174878bf2a9e3f10c7be2d63af7', [(169, 230)]),
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
            assert 1 <= start <= end <= len(lines), (name,start,end,len(lines))
            excerpts.append(f'\n## {name}:{start}–{end}\n\n```text\n')
            excerpts.extend(f'{i}: {lines[i-1]}'.rstrip()+'\n' for i in range(start, end+1))
            excerpts.append('```\n')
    spark_records = []
    source_archive = root / 'docs/evidence/unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz'
    with tarfile.open(source_archive) as archive:
        for name, (digest, ranges) in SPARK.items():
            data = archive.extractfile('spark-source/' + name).read()
            assert hashlib.sha256(data).hexdigest() == digest
            spark_records.append(dict(path=name, bytes=len(data), sha256=digest))
            lines = data.decode().split('\n')
            for start, end in ranges:
                assert 1 <= start <= end <= len(lines)
                excerpts.append(f'\n## spark/{name}:{start}–{end}\n\n```text\n')
                excerpts.extend(f'{i}: {lines[i-1]}'.rstrip()+'\n' for i in range(start, end+1))
                excerpts.append('```\n')
    cases = sorted({1,2,3,2**30} | {2**k+delta for k in range(1,30) for delta in (-1,0,1)})
    rows = [transition(first,d) for first in (0,2**30) for d in cases]
    prime_text = (args.ada/'libgnat/a-coprnu.ads').read_text()
    values = re.search(r'Primes : constant Primes_Type :=\s*\[(.*?)\];',prime_text,re.S).group(1)
    primes = [int(x) for x in re.findall(r'\d+',values)]
    assert len(primes) == 28 and sorted(set(primes)) == primes
    safe_prime = max(p for p in primes if p <= 2**31-1)
    assert safe_prime == 1610612741
    assert next(p for p in primes if p > safe_prime) == 3221225473
    assert next(p for p in primes if p >= 2**30) == safe_prime
    result = dict(source_commit=old['commit'], sources=records, transitions=rows,
                  maximum_usable_nodes=2**30-1, maximum_lists=2**30,
                  sufficient_total_retained_elements=2**31-1,
                  retained_link_bytes_at_count_limit=24*(2**31-1),
                  standard_hash_maximum_safe_request=safe_prime,
                  standard_hash_next_rounded_capacity=3221225473,
                  standard_hash_bucket_bytes_at_safe_capacity=8*safe_prime,
                  spark_candidate_commit='42554fc241fcd1fdf08d3a2feccb3f86912acbc0',
                  spark_sources=spark_records,
                  maximum_json_quoted_actual_length=(2**31-3)//2,
                  maximum_json_body_characters_per_file=2**31-2,
                  scope='local append/growth arithmetic, not caller coverage or whole-tool capacity')
    quoted = result['maximum_json_quoted_actual_length']
    assert quoted == 1073741822
    assert 2*quoted+2 <= 2**31-1 < 2*(quoted+1)+2
    body = result['maximum_json_body_characters_per_file']
    assert 1+body == 2**31-1 and 1+(body+1) > 2**31-1
    assert result['retained_link_bytes_at_count_limit'] < 2**63
    args.output.mkdir(parents=True,exist_ok=True)
    (args.output/'checks.json').write_text(json.dumps(result,indent=2)+'\n')
    (args.output/'source-excerpts.md').write_text(''.join(excerpts))
    print(f'Verified {len(records)} GCC and {len(spark_records)} SPARK files, {len(rows)} boundary transitions and output arithmetic')


if __name__ == '__main__':
    main()
