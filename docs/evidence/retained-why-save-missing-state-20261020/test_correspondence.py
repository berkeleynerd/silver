#!/usr/bin/env python3
"""Small raw-graph fixtures that challenge the cross-process reuse criterion."""
import struct
import unittest
from correspondence import compare_graphs


def block(fields,tag=0):return tag,len(fields),struct.pack('<'+'Q'*len(fields),*fields)


class Check(unittest.TestCase):
    def test_pointer_renaming_and_repeated_roots(self):
        a={0x100:block([3,0x200,0x200]),0x200:block([7])}
        b={0x800:block([3,0x900,0x900]),0x900:block([7])}
        self.assertEqual(compare_graphs(a,b,[(0x100,0x800),(0x100,0x800)]),{0x100:0x800,0x200:0x900})
    def test_scalar_change_rejected(self):
        with self.assertRaisesRegex(AssertionError,'immediate mismatch'):
            compare_graphs({0x100:block([3])},{0x800:block([5])},[(0x100,0x800)])
    def test_sharing_change_rejected(self):
        a={0x100:block([0x200,0x200]),0x200:block([3])}
        b={0x800:block([0x900,0xa00]),0x900:block([3]),0xa00:block([3])}
        with self.assertRaisesRegex(AssertionError,'sharing mismatch'):compare_graphs(a,b,[(0x100,0x800)])
    def test_runtime_and_changed_opaque_rejected(self):
        with self.assertRaisesRegex(AssertionError,'runtime block'):
            compare_graphs({0x100:block([3],247)},{0x800:block([3],247)},[(0x100,0x800)])
        with self.assertRaisesRegex(AssertionError,'opaque payload'):
            compare_graphs({0x100:block([3],253)},{0x800:block([5],253)},[(0x100,0x800)])
    def test_recognized_custom_ops_relocation_only(self):
        context={'symbol':'ml_z_custom_ops','old_pointer':0x1000,'new_pointer':0x2000}
        old={0x100:block([0x1000,1,0xffffffffffffffff,0],255)}
        new={0x800:block([0x2000,1,0xffffffffffffffff,0],255)}
        pairs=[]
        self.assertEqual(compare_graphs(old,new,[(0x100,0x800)],context,pairs),{0x100:0x800})
        self.assertEqual(pairs,[{'old':0x100,'new':0x800,'words':4,'symbol':'ml_z_custom_ops'}])
        with self.assertRaisesRegex(AssertionError,'unknown custom operations'):
            compare_graphs(old,old,[(0x100,0x100)])
        changed={0x800:block([0x2000,1,123,0],255)}
        with self.assertRaisesRegex(AssertionError,'changed Zarith custom data'):
            compare_graphs(old,changed,[(0x100,0x800)],context)
        wrong={0x800:block([0x3000,1,0xffffffffffffffff,0],255)}
        with self.assertRaisesRegex(AssertionError,'unrecognized custom operations'):
            compare_graphs(old,wrong,[(0x100,0x800)],context)

    def test_cycles_terminate_by_pointer_bijection(self):
        # Cycles are compared as raw graphs; no finite term claim is inferred.
        self.assertEqual(compare_graphs({0x100:block([0x100])},{0x800:block([0x800])},[(0x100,0x800)]),{0x100:0x800})


if __name__=='__main__':unittest.main()
