#!/bin/bash
# Cloud home is read-only. Keep the generated runtime cookie outside Git.
set -euo pipefail
cd /workspace/Riego-Inteligente-Por-Zonas
python3 - <<'PY'
import os, secrets
p='/workspace/tooling/release.vm.args'
if not os.path.exists(p):
    fd=os.open(p,os.O_WRONLY|os.O_CREAT|os.O_EXCL,0o600)
    with os.fdopen(fd,'w') as f:
        f.write('-sname riego_cloud\n+S 2:2\n-setcookie '+secrets.token_hex(32)+'\n')
PY
export VMARGS_PATH=/workspace/tooling/release.vm.args
exec _build/default/rel/riego/bin/riego foreground
