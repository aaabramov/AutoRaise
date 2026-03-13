#!/usr/bin/env bash
#
# Checks (and optionally fixes) GPL-3.0 license headers in source files.
#
# Usage:
#   ./scripts/check-license-headers.sh          # check only
#   ./scripts/check-license-headers.sh --fix    # add missing headers

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIX=false
[[ "${1:-}" == "--fix" ]] && FIX=true

read -r -d '' HEADER << 'EOF' || true
/*
 * AutoRaise - Copyright (C) 2026 aaabramov
 * Some pieces of the code are based on
 * sbmpost by sbmpost as part of https://github.com/sbmpost/AutoRaise
 * metamove by jmgao as part of XFree86
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
EOF

NEEDLE="AutoRaise - Copyright (C) 2026 aaabramov"
failed=0

for file in "$REPO_ROOT"/*.h "$REPO_ROOT"/*.mm; do
    [[ -f "$file" ]] || continue
    if ! head -5 "$file" | grep -q "$NEEDLE"; then
        if $FIX; then
            # Strip any existing license block (starts with /* and ends with */)
            if head -1 "$file" | grep -q '^/\*$'; then
                # Find the closing */ line number and strip it
                end_line=$(grep -n '^ \*/$' "$file" | head -1 | cut -d: -f1)
                if [[ -n "$end_line" ]]; then
                    tail -n +"$((end_line + 1))" "$file" > "$file.tmp"
                    # Remove leading blank lines
                    sed -i '' '/./,$!d' "$file.tmp"
                    printf '%s\n\n' "$HEADER" | cat - "$file.tmp" > "$file"
                    rm "$file.tmp"
                fi
            else
                # No existing header — prepend
                printf '%s\n\n' "$HEADER" | cat - "$file" > "$file.tmp"
                mv "$file.tmp" "$file"
            fi
            echo "FIXED: $(basename "$file")"
        else
            echo "MISSING: $(basename "$file")"
            failed=1
        fi
    else
        echo "OK: $(basename "$file")"
    fi
done

if [[ $failed -ne 0 ]]; then
    echo ""
    echo "Run with --fix to add missing headers."
    exit 1
fi
