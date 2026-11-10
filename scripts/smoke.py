#!/usr/bin/env python3
"""Run against the loopback development server, with a disposable data directory."""
import json, urllib.request, urllib.error, socket, base64, os, struct
base='http://127.0.0.1:8080'
def get(p): return urllib.request.urlopen(base+p).read()
def post(p,b):
 req=urllib.request.Request(base+p,data=json.dumps(b).encode(),headers={'Content-Type':'application/json'})
 return json.load(urllib.request.urlopen(req))
assert b'Riego Inteligente' in get('/')
assert 'active' in json.loads(get('/api/state'))
assert post('/api/programas',dict(zone=2,duration=60,priority=1))['ok']
assert post('/api/signal',dict(kind='rain',value=True))['ok']
assert json.loads(get('/api/state'))['rain']
assert post('/api/signal',dict(kind='flow',value=10))['ok']
assert json.loads(get('/api/state'))['fault']
assert b'riego_active 0' in get('/metrics')
# Real RFC6455 upgrade and server-to-client frame.
s=socket.create_connection(('127.0.0.1',8080));s.settimeout(5)
key=base64.b64encode(os.urandom(16)).decode()
s.sendall(f'GET /ws HTTP/1.1\r\nHost: 127.0.0.1:8080\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: {key}\r\nSec-WebSocket-Version: 13\r\n\r\n'.encode())
f=s.makefile('rb'); status=f.readline();assert b'101' in status
while f.readline()!=b'\r\n': pass
h=f.read(2);assert h[0]==129
n=h[1]&127
if n==126:n=struct.unpack('!H',f.read(2))[0]
elif n==127:n=struct.unpack('!Q',f.read(8))[0]
assert 'queue' in json.loads(f.read(n));s.close()
print('PASS: HTML, programs, rain, leak, metrics, WebSocket state')
