"""Conservative touched-path audit for the retained 3.0 (quilt) source.

Both unified header endpoints and Index candidates are included after the
series' -p strip count.
The retained series has no options, hence the quilt default is -p1. Explicit
-pN is supported for controls; other options/header formats fail closed.
This inventories paths; it does not apply patches or prove hunk semantics.
"""
import re

SAFE_PATH=re.compile(r'[A-Za-z0-9_@+.,/-]+\Z')
HUNK=re.compile(r'@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@(?:.*)\Z')
STAMP=re.compile(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}(?:\.\d+)? [+-]\d{4}\Z')

def series_entries(text):
    entries=[]
    for lineno,line in enumerate(text.splitlines(),1):
        body=line.split('#',1)[0].strip()
        if not body:continue
        parts=body.split()
        assert 1<=len(parts)<=2,('unsupported series entry',lineno,line)
        path=parts[0]
        assert SAFE_PATH.fullmatch(path) and not path.startswith('/')
        assert all(p not in ('','..','.') for p in path.split('/'))
        strip=1
        if len(parts)==2:
            m=re.fullmatch(r'-p(\d+)',parts[1])
            assert m,('unsupported series option',lineno,line)
            strip=int(m[1])
        entries.append({'member':'debian/patches/'+path,'series_line':lineno,'strip_components':strip,'options':parts[1:]})
    return entries

def endpoint(header,strip):
    assert header.startswith(('--- ','+++ '))
    value=header[4:]
    fields=value.split('\t')
    assert len(fields)<=2 and (len(fields)==1 or STAMP.fullmatch(fields[1])),('unsupported timestamp/header',header)
    path=fields[0]
    assert SAFE_PATH.fullmatch(path),('unsupported path form',header)
    if path=='/dev/null':return None
    assert not path.startswith('/'),('absolute path',header)
    parts=path.split('/')
    assert all(p not in ('','..','.') for p in parts) and len(parts)>strip,('invalid stripped path',header,strip)
    return '/'.join(parts[strip:])

def patch_paths(text,strip):
    assert strip>=0
    lines=text.splitlines();i=0;pairs=[];indexes=[];hunks=0
    # Conservative header census, not a hunk interpreter. Header-looking
    # hunk text may add candidates; it cannot remove a real target. This
    # avoids inferring patched-file identity from imperfect hunk formatting.
    while i<len(lines):
        line=lines[i]
        if line.startswith('--- '):
            assert i+1<len(lines) and lines[i+1].startswith('+++ '),('unpaired old header',i+1)
            old,new=endpoint(line,strip),endpoint(lines[i+1],strip)
            assert old is not None or new is not None
            pairs.append({'old_line':i+1,'old_header':line,'new_header':lines[i+1],'old_path':old,'new_path':new})
            i+=2;continue
        if line.startswith('Index: '):
            path=endpoint('--- '+line[7:],strip)
            assert path is not None
            indexes.append({'line':i+1,'header':line,'path':path})
        if line.startswith('@@'):
            assert HUNK.fullmatch(line),('unsupported hunk header',i+1,line)
            hunks+=1
        assert not re.fullmatch(r'\d+(?:,\d+)?[acd](?:\d+(?:,\d+)?)?',line),('unsupported normal/ed diff',i+1,line)
        assert not line.startswith(('+++ ','*** ','GIT binary patch','Binary files ','rename from ','rename to ','copy from ','copy to ')),('unsupported patch form',i+1,line)
        i+=1
    assert pairs and hunks,('no unified patch headers/hunks',len(pairs),hunks)
    paths={p for pair in pairs for k in ('old_path','new_path') if (p:=pair[k]) is not None}
    paths.update(row['path'] for row in indexes)
    return {'header_pairs':pairs,'index_candidates':indexes,'patched_paths':sorted(paths)}

def controls():
    results=[]
    # Non-a/b prefixes and old-only deletion must both hit selected source.
    examples=[('nonstandard_prefix',1,'--- glibc-upstream.orig/string/strdup.c\n+++ glibc-upstream/string/strdup.c\n@@ -1 +1 @@\n-old\n+new\n',['string/strdup.c']),('deleted_old_endpoint',1,'--- glibc-2.38/string/strdup.c\n+++ /dev/null\n@@ -1 +0,0 @@\n-old\n',['string/strdup.c']),('p0_creation',0,'--- /dev/null\n+++ string/strdup.c\n@@ -0,0 +1 @@\n+new\n',['string/strdup.c']),('p2_rename',2,'--- old/tree/string/strdup.c\n+++ new/tree/string/renamed.c\n@@ -1 +1 @@\n-old\n+new\n',['string/renamed.c','string/strdup.c']),('header_like_hunk_content',1,'--- old/string/strdup.c\n+++ new/string/strdup.c\n@@ -1 +1 @@\n--- fake/old.c\n+++ fake/new.c\n',['new.c','old.c','string/strdup.c']),('index_candidate',1,'Index: alternate/string/strdup.c\n--- old/other.c\n+++ new/other.c\n@@ -1 +1 @@\n-old\n+new\n',['other.c','string/strdup.c'])]
    for name,strip,text,expected in examples:
        actual=patch_paths(text,strip)['patched_paths'];assert actual==expected
        results.append({'name':name,'expected_paths':expected,'status':'pass'})
    assert [r['strip_components'] for r in series_entries('a.patch\nb.patch -p0\nc.patch -p2 # control\n')]==[1,0,2]
    results.append({'name':'series_default_and_explicit_strip','status':'pass'})
    bad=[('unsupported_series_option',lambda:series_entries('a.patch -R')),
         ('quoted_header',lambda:patch_paths('--- "old/a b"\n+++ new/a\n@@ -1 +1 @@\n-x\n+y\n',1)),
         ('absolute_header',lambda:patch_paths('--- /host/a\n+++ new/a\n@@ -1 +1 @@\n-x\n+y\n',1)),
         ('unpaired_header',lambda:patch_paths('+++ new/a\n',1)),
         ('context_diff',lambda:patch_paths('*** old/a\n--- new/a\n',1)),
         ('binary_patch',lambda:patch_paths('GIT binary patch\n',1)),
         ('normal_diff',lambda:patch_paths('1c1\n< old\n---\n> new\n',1)),
         ('overstripped_header',lambda:patch_paths('--- a\n+++ b\n@@ -1 +1 @@\n-x\n+y\n',1))]
    for name,call in bad:
        try:call()
        except AssertionError:results.append({'name':name,'status':'rejected_as_expected'})
        else:raise AssertionError(('unsupported control accepted',name))
    return results
