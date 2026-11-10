#!/bin/bash
# Non-root Debian 13 amd64 cloud setup. Raspberry Pi uses system APT instead.
set -euo pipefail
root=/workspace/tooling
mkdir -p "$root/apt/lists/partial" "$root/apt/cache/archives/partial" "$root/debs" "$root/otp" "$root/bin" "$root/cache"
printf '%s\n' 'deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] https://deb.debian.org/debian trixie main' > "$root/apt/sources.list"
opts=(-o "Dir::Etc::sourcelist=$root/apt/sources.list" -o Dir::Etc::sourceparts=- -o "Dir::State::lists=$root/apt/lists" -o "Dir::Cache=$root/apt/cache")
/usr/bin/apt-get "${opts[@]}" update
cd "$root/debs"
/usr/bin/apt-get "${opts[@]}" download erlang-base erlang-dev erlang-eunit erlang-crypto erlang-asn1 erlang-public-key erlang-ssl erlang-tools erlang-inets erlang-syntax-tools erlang-parsetools erlang-mnesia erlang-runtime-tools rebar3
for pkg in ./*.deb; do dpkg-deb -x "$pkg" "$root/otp"; done
cat > "$root/bin/erl" <<'SH'
#!/bin/sh
ROOTDIR=/workspace/tooling/otp/usr/lib/erlang
BINDIR=$(echo "$ROOTDIR"/erts-*/bin)
EMU=beam
PROGNAME=erl
export ROOTDIR BINDIR EMU PROGNAME
exec "$BINDIR/erlexec" "$@"
SH
chmod +x "$root/bin/erl"
ln -sf "$root/otp/usr/lib/erlang"/erts-*/bin/escript "$root/bin/escript"
ln -sf "$root/otp/usr/bin/rebar3" "$root/bin/rebar3"
export PATH="$root/bin:$PATH" REBAR_CACHE_DIR="$root/cache"
cd /workspace/Riego-Inteligente-Por-Zonas
rebar3 compile
rebar3 eunit
rebar3 release
