set auto-load off
set language c
python
import gdb, json
for name in ["why__types__why_node_id", "why__types__why_node_list", "why__atree__node_list_tables__extended_index", "why__atree__node_list_tables__elements_type"]:
    try:
        t=gdb.lookup_type(name)
        print(name, str(t), t.sizeof)
        try: print("range", t.range())
        except Exception as e: print("range unavailable", str(e))
        for f in t.fields():
            print(f.name, str(f.type), getattr(f,"bitpos",None))
            if f.name == "ea":
                print("array range", f.type.range())
    except Exception as e: print(name, str(e))
exec(open("/tmp/silver-producer-counter-plan-20261018/raw_snapshot_v2.py").read())
print(json.dumps(raw_layout()))
end
