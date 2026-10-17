import sys, importlib.util
spec = importlib.util.spec_from_file_location('gen', sys.argv[1]); gen = importlib.util.module_from_spec(spec); spec.loader.exec_module(gen)
kind = sys.argv[2]; limit = int(sys.argv[3])
f = getattr(gen, kind)
lo, hi = 1, 100000
while lo < hi:
    mid = (lo + hi + 1) // 2
    t = f(mid, 0) if kind in ('string_decls', 'scalar_decls') else f(mid)
    if len(t) <= limit: lo = mid
    else: hi = mid - 1
print(lo)
