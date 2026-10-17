import re, sys, os, json
root = sys.argv[1]
mods = {}
for f in os.listdir(os.path.join(root, 'Silver')):
    if f.endswith('.lean'):
        name = 'Silver.' + f[:-5]
        with open(os.path.join(root, 'Silver', f), encoding='utf-8') as h:
            head = []
            for line in h:
                s = line.strip()
                if s.startswith('namespace') or s.startswith('def ') or s.startswith('theorem'):
                    break
                head.append(s)
        imps = []
        for s in head:
            m = re.match(r'^(?:public\s+)?(?:meta\s+)?import\s+(?:all\s+)?(\S+)', s)
            if m and m.group(1).startswith('Silver.'):
                imps.append(m.group(1))
        mods[name] = imps
def closure(start):
    seen = set(); stack = [start]
    while stack:
        m = stack.pop()
        if m in seen: continue
        seen.add(m)
        stack.extend(mods.get(m, []))
    return seen
out = {}
for target in sys.argv[2:]:
    c = closure(target)
    out[target] = sorted(c)
    print(target, len(c))
json.dump({'mods': mods, 'closures': out}, open(sys.argv[2].replace('.','_') + '.json' if False else '/tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/research/T2/imports.json','w'), indent=1)
