#!/usr/bin/env python3
"""Check retained source identities and completion-message arithmetic only."""
from fractions import Fraction
import hashlib
import json
from pathlib import Path
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def check():
    sources = json.loads((HERE / 'kernel-inputs.json').read_text())
    assert sources['commit'] == '458c6079fc1d41d564c37679c8ace02cd83ee817'
    assert identity((HERE / 'kernel-source.tar.gz').read_bytes()) == {
        k:sources['archive'][k] for k in ('bytes','sha256')}
    with tarfile.open(HERE / 'kernel-source.tar.gz') as t:
        files={m.name:t.extractfile(m).read() for m in t.getmembers() if m.isfile()}
    def source_file(name):
        return files['source/'+name].decode()
    for row in sources['inputs']:
        assert identity(files['source/'+row['source_path']]) == {
            k: row[k] for k in ('bytes', 'sha256')}
    sys = source_file('kernel/sys.c')
    conversion = source_file('kernel/time/time.c')
    assert 'u64 tgutime, tgstime, utime, stime;' in sys
    assert 'r->ru_utime = ns_to_kernel_old_timeval(utime);' in sys
    assert 'ns_to_kernel_old_timeval(s64 nsec)' in conversion
    assert 'ns_to_timespec64(s64 nsec)' in conversion
    assert 'div_u64_rem(-nsec - 1, NSEC_PER_SEC, &rem) - 1' in conversion
    assert 'tv.tv_usec = (suseconds_t)ts.tv_nsec / 1000;' in conversion
    assert '-fno-strict-overflow' in source_file('Makefile')
    math64 = source_file('include/linux/math64.h')
    assert '#if BITS_PER_LONG == 64' in math64
    assert ('static inline u64 div_u64_rem(u64 dividend, u32 divisor, u32 *remainder)\n'
            '{\n\t*remainder = dividend % divisor;\n\treturn dividend / divisor;\n}') in math64
    assert '#ifdef CONFIG_64BIT\n#define BITS_PER_LONG 64' in source_file('include/asm-generic/bitsperlong.h')
    assert ('#if defined(__x86_64__) && !defined(__ILP32__)\n# define __BITS_PER_LONG 64') in source_file('arch/x86/include/uapi/asm/bitsperlong.h')
    assert '#define NSEC_PER_SEC\t1000000000L' in source_file('include/vdso/time64.h')
    assert '61\tcommon\twait4\t\t\tsys_wait4' in source_file('arch/x86/entry/syscalls/syscall_64.tbl')

    archive = ROOT / 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
    assert identity(archive.read_bytes()) == dict(bytes=1372815,
        sha256='2dd835cb251c82766ba7808f4cb2d384f91e0101468fd22d5810919072863749')
    with tarfile.open(archive) as t:
        raw = t.extractfile('why3/src/server/server-unix.c').read()
        source = raw.decode()
        assert 'len += strlen(id) + 3;' in source and 'len += 27;' in source
        assert 'len+= strlen(outfile) + 1;' in source
        assert '"F;%s;%d;%.6f;%d;%s\\n"' in source
        assert 'if (used >= len)' in source
        assert '((double) usage.ru_utime.tv_usec / 1000000.0)' in source
        assert 'exit_code = WTERMSIG(status);' in source
        assert 'exit_code = WEXITSTATUS(status);' in source

    lo, hi, billion = -(2**63), 2**63-1, 10**9
    seconds_lo, seconds_hi = lo // billion, hi // billion
    assert (seconds_lo, seconds_hi) == (-9223372037, 9223372036)
    # This rational envelope is independent of machine rounding and time samples.
    exact_upper = Fraction(seconds_hi) + Fraction(999999, 1000000)
    assert Fraction(seconds_lo) <= exact_upper < 10**10 - 1
    assert abs(seconds_lo) + 1 < 10**10 - 1
    # At this magnitude, <1 second safely covers binary64 conversion/addition
    # rounding in every standard directed mode; the argument is in the note.
    assert Fraction(2)**-19 < 1

    cases = []
    points = {lo, lo+1, -billion-1, -billion, -billion+1, -1, 0, 1,
              billion-1, billion, billion+1, hi-1, hi}
    for n in sorted(points):
        sec, rem = divmod(n, billion)
        usec = rem // 1000
        assert seconds_lo <= sec <= seconds_hi and 0 <= usec <= 999999
        text = format(float(sec) + float(usec)/1000000.0, '.6f')
        assert len(text) <= 18
        cases.append(dict(nsec=n, sec=sec, usec=usec, sample_text=text))
    # Exact decimal digit counts: 10 magnitude digits + optional minus + dot + 6.
    time_bytes = 10 + 1 + 1 + 6
    exit_bytes = len(str(255))
    fixed = len('F;;;;;\n') + 1  # five separators, F, LF and one flag byte
    assert fixed == 8 and fixed + exit_bytes + time_bytes == 29
    assert 29 + 1 <= 31  # terminating NUL fits, with one further spare byte
    assert 19 + 29 == 48 and 19 + 4 == 23
    # A general int64-seconds API would NOT imply the selected bound.
    counterexample = format(float(2**63-1), '.6f')
    assert len(counterexample) == 26 and fixed + 1 + len(counterexample) >= 31

    native = json.loads((HERE / 'native-inputs.json').read_text())
    for row in native['inputs']:
        assert identity(Path(row['path']).read_bytes()) == {
            k: row[k] for k in ('bytes','sha256')}
    libc = Path(native['inputs'][0]['path']).read_bytes()
    phoff=struct.unpack_from('<Q',libc,32)[0]
    phsize,phnum=struct.unpack_from('<HH',libc,54)
    segments=[struct.unpack_from('<IIQQQQQQ',libc,phoff+i*phsize) for i in range(phnum)]
    for body in native['bodies']:
        matches=[p for p in segments if p[0]==1 and p[3]<=body['address'] and
            body['address']+body['size']<=p[3]+p[5]]
        assert len(matches)==1
        p=matches[0];offset=p[2]+body['address']-p[3]
        assert libc[offset:offset+body['size']].hex()==body['bytes_hex']
    return dict(kernel_source_commit=sources['commit'], kernel_source_files=len(sources['inputs']),
        kernel_source_binary_attestation=False, source_archive_identity=identity(archive.read_bytes()),
        compilation_interface_premise='CONFIG_64BIT; two-complement signed wrap; modulo unsigned arithmetic; low-bit-preserving u64-to-s64 conversions',
        server_source_identity=identity(raw), seconds_min=seconds_lo, seconds_max=seconds_hi,
        microseconds_min=0,microseconds_max=999999,time_field_bytes_upper=time_bytes,
        exit_field_bytes_upper=exit_bytes,F_fixed_bytes=fixed,F_bytes_upper='id_bytes+path_bytes+29',
        F_with_19_digit_id_upper='path_bytes+48',stock_allocation_bytes='id_bytes+path_bytes+31',
        S_bytes_upper='id_bytes+3', S_allocation_upper_with_19_digit_id=23,
        capacity_guard='id_bytes+path_bytes+31 <= INT_MAX',boundary_cases=cases,
        int64_seconds_counterexample=counterexample,
        scope='Source/runtime-conditional stock completion formatting, not complete server or proxy capacity',
        complete_q=None,production_adopted=False,native_target_solver_proof_runs=0,
        predecessor_checker_replays=0)


if __name__ == '__main__':
    start=time.monotonic();result=check();path=HERE/'result.json'
    if path.exists():
        assert json.loads(path.read_text())==result
    else:
        path.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(status='pass',source_files=result['kernel_source_files'],
        boundary_cases=len(result['boundary_cases']),time_field_bytes_upper=18,
        elapsed_seconds=time.monotonic()-start)))
