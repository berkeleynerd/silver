import re, sys, collections, json
log = sys.argv[1]
rows = []
for line in open(log):
    if not line.startswith('FAIL\t'): continue
    _, mod, name, msg = line.rstrip('\n').split('\t', 3)
    rows.append((mod, name, msg))
def cat(mod, name, msg):
    if '_unsafe_rec' in name: return 'A-artifact(compiled _unsafe_rec)'
    if name.endswith('.eq_1') or name.endswith('.eq_def'): return 'A-artifact(definitional eq lemma)'
    if 'Examples' in mod or re.search(r'accepts (L|2147483646) Silver\.|_lift\.Silver\.[A-Za-z.]*accepts L', msg) or 'example' in name.lower() and 'decide' in msg:
        return 'B-concrete example (kernel decide; holds for L >= example size)'
    if re.search(r'discharge = true\) = true|Semantics\.discharge \(_lift', msg): return 'G-Integer\'Last arithmetic (truth needs kL <= 32767)'
    if 'Output.Runtime.maxLength' in msg: return 'F-coupling with IO/argument Max_Length (separate 4096)'
    if re.search(r'Native\.ValidText|≤ 4096 →|≤ 4096 but|length value ≤ 4096|≤ 4097|ResultType', msg) and 'Nat.zero_le' not in msg:
        if re.search(r'byteAt text position - 48 ≤ 4096', msg): return 'D-small-constant side condition (digit <= L)'
        if re.search(r'\(4096 - \(Silver\.Cursor', msg): return 'D-small-constant side condition (decimal overflow with L >= 9)'
        return 'E-hard-coded literal 4096/4097 elsewhere (mechanical rename)'
    if re.search(r'Nat\.zero_le\._simp_1 (341|4096)|0 ≤ 4096|0 ≤ 341', msg): return 'C-true for all L; proof unfolded constant'
    if re.search(r'decide \((16|\d+) ≤ L\)|"silver_arguments"\.toList\)\.length ≤ L|forbiddenNames|byteAt text position - 48 ≤|\(4096 - \(Silver\.Cursor|room|staticLength \+ result\.dynamicCount \* L ≤ L', msg):
        return 'D-small-constant side condition (L >= c)'
    if 'maxBindings L = L / 12' in msg: return 'H-decide on symbolic definitional fact (rfl suffices)'
    return 'I-needs manual review'
out = collections.defaultdict(list)
for r in rows: out[cat(*r)].append(r)
for k in sorted(out):
    print(f'{len(out[k]):4d}  {k}')
json.dump({k: [list(r) for r in v] for k, v in out.items()}, open(sys.argv[2], 'w'), indent=1)
