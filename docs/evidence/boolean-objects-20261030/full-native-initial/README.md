# Interrupted native attempts and bounded cache correction

Issue #291, native Linux, 2026-10-30. These two complete strict native attempts
were deliberately interrupted for the cache correction below; neither is a
successful complete proof nor a reported proof failure.

| Run | Terminal outcome | Managed duration |
| --- | --- | --- |
| `20261030T135033-a26eefd72a3a` | Interrupted | 1,716.744 s |
| `20261030T142409-b2e896030eb2` | Interrupted | 196.405 s |

The first attempt began with 20,087 entries from the earlier diagnostic cache.
The bounded correction then merged only absent files from the completed subtype
full-proof cache: 158,480 files and 267,316,677 content bytes in 207.914 s. A final
merge added 1,213 absent entries and 5,980,210 bytes in 0.739 s from the common
cache used by all three successful final native repairs (array cut, string word,
primary word). Existing entries, including newly computed results, were
preserved. All known applicable donors were inventoried before the final run
`20261030T142912-eb0b24fc2191`; source inputs and strict proof settings did not
change. That run was later interrupted; its separate
[recovery record](../full-native-interrupted/README.md) preserves that outcome. `combined-cache-correction.json` retains the donor history and both
terminal outcomes; original events and logs are retained here.

An early read-only sample found 20 of 20 current keys in the subtype donor.
The later saved sample found 19 of 20 and is recorded separately. `Value_Tail`
had already completed 602 of 602 goals at 14:15 in the first attempt; the durable
14:19 process observation was `Silver_Image_Model.Consume`. Restart progress
therefore includes previously successful sessions. These observations do not
measure aggregate cache hits or establish a controlled speed improvement.

The completed native result belongs in the separate final native record. The
retained source snapshot names the two temporarily replaced proof-worktree
files and 141 unchanged tracked inputs. Original scratch reports and caches
remain preserved.

Selected native subthread: GPT-6 Astra / Extra High. Live runtime model
confirmation and token/cost measurements are unavailable. This round repaired
the known donor inventory without weakening the proof policy.
