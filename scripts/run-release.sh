#!/bin/bash
# Boot the self-contained release without distributed Erlang or a cookie.
# systemd owns process lifecycle; no remote Erlang console is required.
set -euo pipefail
repo_dir=$(cd "$(dirname "$0")/.." && pwd)
release_dir="$repo_dir/_build/default/rel/riego"
# relx may omit the trailing newline; read still assigns fields at EOF.
read -r erts_version release_version < "$release_dir/releases/start_erl.data" || true
test -n "$erts_version" && test -n "$release_version"
export ROOTDIR="$release_dir"
export BINDIR="$release_dir/erts-$erts_version/bin"
export EMU=beam PROGNAME=erl
exec "$BINDIR/erlexec" -noinput +Bd +S 2:2 \
    -boot "$release_dir/releases/$release_version/start" \
    -boot_var SYSTEM_LIB_DIR "$release_dir/lib" \
    -config "${RIEGO_SYS_CONFIG:-$release_dir/releases/$release_version/sys.config}" \
    -mode embedded
