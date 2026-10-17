import re,sys,os
W=sys.argv[1]
def anchors(path):
    s=set(); counts={}
    txt=open(path,encoding='utf-8').read()
    txt=re.sub(r'```.*?```','',txt,flags=re.S)
    for m in re.finditer(r'^#{1,6}\s+(.*?)\s*$',txt,re.M):
        h=m.group(1)
        h=re.sub(r'`','',h)
        h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h)
        a=h.strip().lower()
        a=re.sub(r'[^\w\- ]','',a)
        a=a.replace(' ','-')
        n=counts.get(a,0); counts[a]=n+1
        s.add(a if n==0 else f'{a}-{n}')
    return s
files=sys.argv[2:]
for f in files:
    p=os.path.join(W,f); base=os.path.dirname(p)
    txt=open(p,encoding='utf-8').read()
    for m in re.finditer(r'\]\(([^)\s]+)\)',txt):
        t=m.group(1)
        if t.startswith('http'):
            mm=re.match(r'https://github.com/berkeleynerd/silver/blob/main/([^#]+)(#.*)?',t)
            if not mm: continue
            tp=os.path.join(W,mm.group(1)); frag=mm.group(2)
        else:
            path,_,frag=t.partition('#'); frag='#'+frag if frag else None
            tp=os.path.normpath(os.path.join(base,path)) if path else p
        ok=os.path.exists(tp)
        msg='OK'
        if not ok: msg='MISSING FILE'
        elif frag and tp.endswith('.md'):
            if frag[1:] not in anchors(tp): msg='MISSING ANCHOR'
        print(f'{msg}\t{f}\t{t}')
