#!/usr/bin/env python3
"""Produce a standalone UI for the existing Cowboy '/' route; no runtime changes."""
from pathlib import Path
root = Path(__file__).resolve().parent.parent
www = root / 'priv/www'
html = (www / 'shell.html').read_text()
html = html.replace('<link rel="stylesheet" href="/assets/app.css">', '<style>' + (www / 'app.css').read_text() + '</style>')
html = html.replace('<script src="/assets/app.js" defer></script>', '')
html = html.replace('</body>', '<script>' + (www / 'app.js').read_text() + '</script></body>')
output = root / '_build/ui/index.html'
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(html)
(www / 'index.html').write_text(html)
print(output)
