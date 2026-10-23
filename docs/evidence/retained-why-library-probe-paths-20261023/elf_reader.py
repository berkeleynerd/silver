"""Small ELF64 little-endian reader for retained symbol/code/data identities."""
import hashlib
import struct


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


class Elf:
    def __init__(self, data):
        self.data = data
        h = struct.unpack_from("<16sHHIQQQIHHHHHH", data)
        assert h[0][:6] == b"\x7fELF\x02\x01" and h[2] == 62
        self.sections = [struct.unpack_from("<IIQQQQIIQQ", data, h[6] + i*h[11]) for i in range(h[12])]
        self.symbols = {}
        for section in self.sections:
            if section[1] != 2:
                continue
            strings = self.sections[section[6]]
            names = data[strings[4]:strings[4] + strings[5]]
            for off in range(section[4], section[4] + section[5], section[9]):
                n, info, other, index, address, size = struct.unpack_from("<IBBHQQ", data, off)
                name = names[n:names.index(0, n)].decode()
                if name:
                    self.symbols[name] = {"address": address, "bytes": size, "section_index": index, "info": info}

    def at(self, address, size):
        sections = [s for s in self.sections if s[1] != 8 and s[3] <= address and address + size <= s[3] + s[5]]
        assert len(sections) == 1, (hex(address), size)
        s = sections[0]
        offset = s[4] + address - s[3]
        return self.data[offset:offset + size]

    def function(self, name):
        symbol = self.symbols[name]
        assert symbol["bytes"] > 0
        return self.at(symbol["address"], symbol["bytes"])

    def literal(self, name):
        address = self.symbols[name]["address"]
        header = struct.unpack("<Q", self.at(address - 8, 8))[0]
        assert header & 255 == 252
        storage = (header >> 10)*8
        data = self.at(address, storage)
        length = storage - 1 - data[-1]
        assert 0 <= length < storage and data[length] == 0
        return {"address": address, "header": header, "storage_bytes": storage, "value": data[:length].decode("ascii"), "identity": identity(self.at(address - 8, storage + 8))}
