#!/usr/bin/env python3
"""Run against the loopback development server, with a disposable data directory."""
import json, urllib.request, urllib.error, urllib.parse, socket, base64, os, struct
base=os.environ.get('RIEGO_BASE_URL','http://127.0.0.1:8080').rstrip('/')
endpoint=urllib.parse.urlparse(base)
def get(p): return urllib.request.urlopen(base+p).read()
def post(p,b):
 req=urllib.request.Request(base+p,data=json.dumps(b).encode(),headers={'Content-Type':'application/json'})
 return json.load(urllib.request.urlopen(req))
assert b'AgroFlow IoT' in get('/')
assert b'--green:#006948' in get('/')
assert b'/api/programas' in get('/')
assert 'active' in json.loads(get('/api/state'))
assert post('/api/programas',dict(zone=2,duration=60,priority=1))['ok']
assert post('/api/signal',dict(kind='rain',value=True))['ok']
assert json.loads(get('/api/state'))['rain']
assert post('/api/signal',dict(kind='flow',value=10))['ok']
assert json.loads(get('/api/state'))['fault']
assert b'riego_active 0' in get('/metrics')
assert json.loads(get('/api/state'))['schedule']['timezone_name']
assert post('/api/signal',dict(kind='stuck',value=1))['ok']
snapshot=json.loads(get('/api/state'))
assert not snapshot['pump'] and snapshot['flow_lps']==0
assert snapshot['valves'][0]['physical']=='stuck_open'
assert snapshot['valves'][0]['commanded']=='closed'
assert b'riego_stuck_open 1' in get('/metrics')
assert b'riego_pump_on 0' in get('/metrics')
try:
 post('/api/signal',dict(kind='reset',value=True))
 raise AssertionError('Reset must require mechanical repair')
except urllib.error.HTTPError as e:
 assert e.code==422 and json.load(e)['error']=='repair_required'
assert post('/api/signal',dict(kind='repair',value=1))['ok']
assert json.loads(get('/api/state'))['fault']
assert post('/api/signal',dict(kind='reset',value=True))['ok']
assert not json.loads(get('/api/state'))['fault']
# Real RFC6455 upgrade and server-to-client frame.
s=socket.create_connection((endpoint.hostname,endpoint.port or 80));s.settimeout(5)
key=base64.b64encode(os.urandom(16)).decode()
s.sendall(f'GET /ws HTTP/1.1\r\nHost: {endpoint.netloc}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: {key}\r\nSec-WebSocket-Version: 13\r\n\r\n'.encode())
f=s.makefile('rb'); status=f.readline();assert b'101' in status
while f.readline()!=b'\r\n': pass
h=f.read(2);assert h[0]==129
n=h[1]&127
if n==126:n=struct.unpack('!H',f.read(2))[0]
elif n==127:n=struct.unpack('!Q',f.read(8))[0]
assert 'queue' in json.loads(f.read(n));s.close()
print('PASS: HTML, programs, rain, leak, metrics, stuck-open interlock/repair, local schedule, WebSocket state')
