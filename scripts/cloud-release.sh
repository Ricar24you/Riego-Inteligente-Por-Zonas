#!/bin/bash
# Preserve the existing command while using the cookie-free release launcher.
set -euo pipefail
exec bash "$(dirname "$0")/run-release.sh"
