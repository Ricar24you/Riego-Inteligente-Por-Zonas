#!/bin/bash
# Read-only preflight. Run from a machine already connected to the authorized tailnet.
# SSH performs host key verification and uses existing authentication only.
set -euo pipefail
host=${1:-pi4@100.93.156.85}
ssh -o BatchMode=yes -o StrictHostKeyChecking=yes -o ConnectTimeout=10 "$host" 'sh -s' <<'REMOTE'
set -eu
printf 'Architecture: '; uname -m
test "$(uname -m)" = aarch64
printf 'OS: '; . /etc/os-release; printf '%s\n' "$PRETTY_NAME"
printf 'Tool locations:\n'; command -v erl rebar3 python3 curl
printf 'IANA zone: '; test -r /usr/share/zoneinfo/America/Tijuana && echo available
printf 'OTP: '; erl -noshell -eval 'io:format("~s~n",[erlang:system_info(otp_release)]),halt().'
repo_dir=/home/pi4/Riego-Inteligente-Por-Zonas
test -d "$repo_dir"
git -C "$repo_dir" status --short --branch
git -C "$repo_dir" rev-parse HEAD
REMOTE
