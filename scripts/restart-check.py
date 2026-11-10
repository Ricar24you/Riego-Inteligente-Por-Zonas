#!/usr/bin/env python3
"""Cold-VM persistence check, only for integration.sh's disposable instance."""
import json
import os
import sys
import urllib.request
base=os.environ['RIEGO_BASE_URL']
if sys.argv[1]=='seed':
    request=urllib.request.Request(base+'/api/signal',data=b'{"kind":"stuck","value":1}',
                                   headers={'Content-Type':'application/json'})
    assert json.load(urllib.request.urlopen(request))['ok']
else:
    state=json.load(urllib.request.urlopen(base+'/api/state'))
    assert state['stuck']==[1] and state['fault']
    assert not state['pump'] and state['flow_lps']==0
    assert state['valves'][0]['physical']=='stuck_open'
    assert state['valves'][0]['commanded']=='closed'
    assert state['active']==[] and any(j['zone']==2 for j in state['queue'])
    print('PASS: cold VM after SIGKILL preserves jam, queue, closed command and inhibited pump')
