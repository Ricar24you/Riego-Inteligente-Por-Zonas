#!/bin/bash
# Build and test an isolated instance; never touches the user's persistent data.
set -euo pipefail
cd "$(dirname "$0")/.."
rebar3 compile
if [ "${RIEGO_RELEASE_TEST:-0}" = 1 ]; then rebar3 release; fi
# Check availability before starting, and let the OS select a free port by default.
RIEGO_TEST_PORT=$(python3 - <<'PORT'
import os,socket
requested=int(os.environ.get('RIEGO_TEST_PORT','0'))
if requested and not 1024 <= requested <= 65535: raise SystemExit('Use an unprivileged TCP port')
with socket.socket() as s:
    s.bind(('127.0.0.1',requested))
    print(s.getsockname()[1])
PORT
)
export RIEGO_TEST_PORT
run_dir=$(mktemp -d /tmp/riego-integration.XXXXXX)
export RIEGO_TEST_DATA_DIR="$run_dir/data"
export RIEGO_BASE_URL="http://127.0.0.1:$RIEGO_TEST_PORT"
server_pid=
cleanup() {
    if [ -n "$server_pid" ]; then
        kill "$server_pid" 2>/dev/null || true
        wait "$server_pid" 2>/dev/null || true
    fi
    rm -rf -- "$run_dir"
}
trap cleanup EXIT
# The VM, not the shell, parses app values. TZ is inherited at VM startup.
launch_server() {
if [ "${RIEGO_RELEASE_TEST:-0}" = 1 ]; then
    [[ "$RIEGO_TEST_PORT" =~ ^[0-9]+$ ]]
    printf '[{riego,[{port,%s},{data_dir,"%s"}]}].\n' "$RIEGO_TEST_PORT" "$RIEGO_TEST_DATA_DIR" > "$run_dir/sys.config"
    RIEGO_SYS_CONFIG="$run_dir/sys.config" bash scripts/run-release.sh > "$run_dir/server.log" 2>&1 &
else
erl -pa _build/default/lib/*/ebin -noshell -eval '
 application:load(riego),
 application:set_env(riego,data_dir,os:getenv("RIEGO_TEST_DATA_DIR")),
 application:set_env(riego,port,list_to_integer(os:getenv("RIEGO_TEST_PORT"))),
 {ok,_}=application:ensure_all_started(riego),timer:sleep(infinity).
' > "$run_dir/server.log" 2>&1 &
fi
server_pid=$!
}
wait_ready() {
ready=false
for attempt in $(seq 1 40); do
    if ! kill -0 "$server_pid" 2>/dev/null; then cat "$run_dir/server.log"; exit 1; fi
    if curl -fsS "$RIEGO_BASE_URL/api/state" > /dev/null 2>&1; then ready=true; break; fi
    sleep 0.25
done
if [ "$ready" != true ]; then cat "$run_dir/server.log"; exit 1; fi
}
launch_server
wait_ready
python3 scripts/smoke.py
if [ "${RIEGO_BROWSER_TEST:-0}" = 1 ]; then node scripts/browser.cjs; fi

# Persist a mechanical jam, then kill the entire VM without graceful shutdown.
python3 scripts/restart-check.py seed
kill -KILL "$server_pid"
wait "$server_pid" 2>/dev/null || true
server_pid=
launch_server
wait_ready
python3 scripts/restart-check.py verify
