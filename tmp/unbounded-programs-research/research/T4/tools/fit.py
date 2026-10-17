import json,math,os,sys
S='/tmp/claude-1000/-home-canto-src-github-com-berkeleynerd-silver/958e8e62-f068-47ab-93b6-19b171d068b8/scratchpad/research/T4'
fams={'f1':['f1-1k','f1-2k','f1-4k','f1-8k','f1-16k','f1-32k'],'f2':['f2-1k','f2-2k','f2-4k','f2-8k','f2-16k'],'f3':['f3-1k','f3-2k','f3-4k']}
def fit(xs,ys):
    lx=[math.log(x) for x in xs];ly=[math.log(max(y,1e-9)) for y in ys];n=len(xs)
    mx=sum(lx)/n;my=sum(ly)/n
    b=sum((a-mx)*(c-my) for a,c in zip(lx,ly))/sum((a-mx)**2 for a in lx)
    return round(b,2)
for f,names in fams.items():
    rows=[]
    for n in names:
        p=f'{S}/proj-{n}/result.json'
        if not os.path.exists(p):continue
        r=json.load(open(p))
        if 'report' not in r or r.get('stopped'):continue
        rep=r['report']
        rows.append(dict(n=n,b=r['source_bytes'],st=r['statements'],ch=rep['checks'],wall=r['wall_s'],g3mem=r['peak_by_comm'].get('gnatwhy3',0),tree=r['peak_tree_rss_gib'],maxatt=rep['attempt_time']['max'],attsteps=rep['attempt_steps_max'],winmax=rep['win_steps']['max'],rep=r['report_bytes']))
    print(f)
    for x in rows:print('  ',x)
    big=[x for x in rows if x['b']>=1500]
    if len(big)>=2:
        xs=[x['b'] for x in big]
        print('   exponents (>=1.5KB): wall',fit(xs,[x['wall'] for x in big]),'gnatwhy3_mem',fit(xs,[x['g3mem'] for x in big]),'max_attempt_time',fit(xs,[x['maxatt'] for x in big]),'max_attempt_steps',fit(xs,[x['attsteps'] for x in big]),'report',fit(xs,[x['rep'] for x in big]),'checks',fit(xs,[x['ch'] for x in big]))
