#!/usr/bin/env python3
import json
from pathlib import Path
import tempfile
import unittest
import missing_state as ms
import replay_missing
from test_missing_state import fixture, api
from correspondence import identity


class Check(unittest.TestCase):
    def test_standalone_extension_replay(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d);case=root/'case';capture=case/'capture';capture.mkdir(parents=True)
            memory,session,_=fixture(capture)
            # These are prior accepted observer outputs, already present before
            # the extension in a real capture.
            session.store.raw(session.roots['session'])
            session.save('session-root.json',session.roots)
            session.save('session-symbols.json',{'checks':{name:{'address':session.address(name)} for name in ms.SYMBOLS}})
            (root/'plan.json').write_text(json.dumps({'session_observer':{'limits':api.DEFAULT_LIMITS},
                'inputs':[{'cwd':str(case)}], 'file_identities':{
                    str(root/'missing_state.py'):identity(Path(ms.__file__)),
                    str(root/'session_observer.py'):identity(Path(api.__file__))}}))
            self.assertTrue(ms.collect(session,{},'fixture')['complete']);session.store.close()
            result=replay_missing.replay(capture)
            self.assertTrue(result['complete']);self.assertIn('save-missing-state.json',result['byte_equal_files'])
            self.assertEqual(result['old_observer_replays'],0)


if __name__=='__main__':unittest.main()
