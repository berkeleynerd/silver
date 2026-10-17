import json,sys,statistics
from collections import Counter
def analyze(path):
    d=json.load(open(path))
    proof=d['proof']; flow=d['flow']
    rows=[]
    for p in proof:
        # winning prover = stats keys; collect max steps/time over all attempts in tree
        best_steps=0; best_time=0.0; provers=[]
        for node in p.get('check_tree',[]):
            for pr,a in node.get('proof_attempts',{}).items():
                if a.get('result')=='Valid':
                    pass
        st=p.get('stats',{})
        for pr,s in st.items():
            best_steps=max(best_steps,s.get('max_steps',0)); best_time=max(best_time,s.get('max_time',0.0)); provers.append(pr)
        # all-attempt maxima (incl failures)
        att_steps=0; att_time=0.0; results=Counter()
        for node in p.get('check_tree',[]):
            for pr,a in node.get('proof_attempts',{}).items():
                att_steps=max(att_steps,a.get('steps',0)); att_time=max(att_time,a.get('time',0.0)); results[pr+':'+a.get('result','?')]+=1
        rows.append(dict(line=p['line'],col=p['col'],rule=p['rule'],sev=p['severity'],how=p.get('how_proved'),win_steps=best_steps,win_time=best_time,provers=provers,att_steps=att_steps,att_time=att_time,results=results,vcs=len(p.get('check_tree',[]))))
    return d,rows
def pct(xs,q):
    xs=sorted(xs); 
    if not xs: return None
    return xs[min(len(xs)-1,int(q*len(xs)))]
def summary(path):
    d,rows=analyze(path)
    sev=Counter(r['sev'] for r in rows)
    unproved=[r for r in rows if r['sev']!='info']
    how=Counter(r['how'] for r in rows)
    rules=Counter(r['rule'] for r in rows)
    prov=Counter(p for r in rows for p in r['provers'])
    res=Counter()
    for r in rows: res.update(r['results'])
    ws=[r['win_steps'] for r in rows if r['how']=='prover']
    wt=[r['win_time'] for r in rows if r['how']=='prover']
    at=[r['att_time'] for r in rows]
    ast=[r['att_steps'] for r in rows]
    out=dict(checks=len(rows),flow=len(d['flow']),flow_sev=dict(Counter(f['severity'] for f in d['flow'])),severity=dict(sev),unproved=[(r['line'],r['col'],r['rule'],r['sev']) for r in unproved][:20],how=dict(how),rules=dict(rules.most_common(12)),winning_prover=dict(prov),attempt_results=dict(res),
      win_steps=dict(max=max(ws) if ws else None,p50=pct(ws,.5),p90=pct(ws,.9),p99=pct(ws,.99),mean=round(statistics.mean(ws),1) if ws else None),
      win_time=dict(max=max(wt) if wt else None,p50=pct(wt,.5),p90=pct(wt,.9),p99=pct(wt,.99),sum=round(sum(wt),1)),
      attempt_time=dict(max=max(at),p50=pct(at,.5),p90=pct(at,.9),sum=round(sum(at),1)),attempt_steps_max=max(ast),
      vcs_total=sum(r['vcs'] for r in rows),stop_reason=d.get('stop_reason'),timings=d.get('timings'))
    # context growth: compare by quartile of line/position
    rr=sorted([r for r in rows if r['how']=='prover'],key=lambda r:(r['line'],r['col']))
    q=[]
    n=len(rr)
    for i in range(4):
        part=rr[i*n//4:(i+1)*n//4]
        if part: q.append(dict(quartile=i+1,n=len(part),mean_win_steps=round(statistics.mean(x['win_steps'] for x in part),1),max_win_steps=max(x['win_steps'] for x in part),mean_att_time=round(statistics.mean(x['att_time'] for x in part),3),max_att_time=round(max(x['att_time'] for x in part),3)))
    out['by_position_quartile']=q
    return out
if __name__=='__main__':
    for p in sys.argv[1:]:
        print(p); print(json.dumps(summary(p),indent=1,default=str))
