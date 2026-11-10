#!/usr/bin/env python3
"""Offline HTML/asset and JavaScript syntax checks (no server/data mutations)."""
import ctypes as c
import ctypes.util
from html.parser import HTMLParser
from pathlib import Path

root = Path(__file__).resolve().parent.parent
class Document(HTMLParser):
    def __init__(self):
        super().__init__(); self.ids = []; self.assets = []
    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if 'id' in a: self.ids.append(a['id'])
        for key in ['src', 'href']:
            if a.get(key, '').startswith('/assets/'):
                self.assets.append(a[key].removeprefix('/assets/'))
p = Document(); p.feed((root/'priv/www/shell.html').read_text())
assert len(p.ids) == len(set(p.ids)), 'Duplicate HTML IDs'
assert sorted(p.assets) == ['app.css','app.js']
for asset in p.assets: assert (root/'priv/www'/asset).is_file()
print('PASS: unique HTML IDs and local CSS/JS assets')
lib = ctypes.util.find_library('javascriptcoregtk-4.1')
if not lib: raise SystemExit('SKIP: JavaScriptCore unavailable; run node --check priv/www/app.js')
j = c.CDLL(lib)
j.JSGlobalContextCreate.argtypes = [c.c_void_p]; j.JSGlobalContextCreate.restype = c.c_void_p
j.JSStringCreateWithUTF8CString.argtypes = [c.c_char_p]; j.JSStringCreateWithUTF8CString.restype = c.c_void_p
j.JSCheckScriptSyntax.argtypes = [c.c_void_p,c.c_void_p,c.c_void_p,c.c_int,c.POINTER(c.c_void_p)]; j.JSCheckScriptSyntax.restype = c.c_bool
j.JSStringRelease.argtypes = [c.c_void_p]
j.JSGlobalContextRelease.argtypes = [c.c_void_p]
ctx = j.JSGlobalContextCreate(None)
try:
    for path in ['priv/www/app.js','scripts/browser.cjs']:
        text = j.JSStringCreateWithUTF8CString((root/path).read_bytes())
        try:
            exception = c.c_void_p()
            assert j.JSCheckScriptSyntax(ctx,text,None,1,c.byref(exception)), f'Invalid JavaScript: {path}'
            print(f'PASS: JavaScript syntax {path}')
        finally: j.JSStringRelease(text)
finally: j.JSGlobalContextRelease(ctx)
