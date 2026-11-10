#!/usr/bin/env python3
"""Exercise libc/IANA TZ in fresh Erlang VMs, including both 2026 DST transitions."""
import datetime as dt
import json
import os
import subprocess

def epoch(iso):
    return int(dt.datetime.fromisoformat(iso).replace(tzinfo=dt.timezone.utc).timestamp())

def check(zone, start, points):
    pairs = [(epoch(t), expected) for t, expected in points]
    times = '[' + ','.join(str(t) for t, _ in pairs) + ']'
    expression = (f'C=#{{timezone=>local,start_hour=>{start},duration_hours=>8}},'
                  f'R=[riego_schedule:remaining(T,C)||T<-{times}],'
                  'io:format("~w",[R]),halt().')
    result = subprocess.run(['erl', '-pa', '_build/default/lib/riego/ebin',
                             '-noshell', '-eval', expression],
                            env={**os.environ, 'TZ': zone}, check=True,
                            capture_output=True, text=True, timeout=30)
    actual = json.loads(result.stdout)
    assert actual == [e for _, e in pairs], (zone, start, actual, pairs)
    print(f'PASS TZ={zone}, start={start}, {len(pairs)} boundary checks')

check('UTC', 22, [('2026-11-10T21:59:59',0),('2026-11-10T22:00:00',28800),
                 ('2026-11-11T05:59:59',1),('2026-11-11T06:00:00',0)])
check('America/Tijuana',22,[('2026-11-11T05:59:59',0),('2026-11-11T06:00:00',28800),
                          ('2026-11-11T13:59:59',1),('2026-11-11T14:00:00',0),
                          ('2026-07-02T05:00:00',28800),('2026-07-02T13:00:00',0),
                          ('2026-03-08T06:00:00',28800),('2026-03-08T13:59:59',1),
                          ('2026-03-08T14:00:00',0),('2026-11-01T05:00:00',28800),
                          ('2026-11-01T12:59:59',1),('2026-11-01T13:00:00',0)])
# Ambiguous 01:00 starts only at its first occurrence; skipped 02:00 never starts.
check('America/Tijuana',1,[('2026-11-01T08:00:00',28800),('2026-11-01T09:00:00',25200),
                         ('2026-11-01T16:00:00',0)])
check('America/Tijuana',2,[('2026-03-08T10:00:00',0),('2026-03-08T11:00:00',0)])
print('PASS: 21 checks, UTC, winter/summer, midnight, fixed 8h across DST, ambiguous/skipped starts')
