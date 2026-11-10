#!/bin/bash
# Run on the authorized Raspberry Pi in its existing checkout.
# No package installation, privilege changes or service restarts.
set -euo pipefail
cd "$(dirname "$0")/.."
if [ "$(uname -m)" != aarch64 ]; then echo 'ARM64 Raspberry Pi required; refusing to label this host as ARM64.' >&2; exit 1; fi
if [ "$(git branch --show-current)" != codex/riego-otp ]; then echo 'Use existing branch codex/riego-otp; this script never resets the checkout.' >&2; exit 1; fi
command -v erl rebar3 python3 curl
printf 'Native architecture: '; uname -m
printf 'Checkout commit: '; git rev-parse HEAD
export TZ="${TZ:-America/Tijuana}"
rebar3 compile
rebar3 eunit
python3 scripts/timezone-checks.py
# Compiles the release natively and smoke tests an isolated instance, not user data.
RIEGO_RELEASE_TEST=1 bash scripts/integration.sh
