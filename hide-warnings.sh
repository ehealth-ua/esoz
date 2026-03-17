#!/usr/bin/env bash
# hide-warnings.sh — remove the warnings notification from the generated index.html
# Usage: ./hide-warnings.sh [path/to/index.html]

set -euo pipefail
HTML="${1:-index.html}"
[[ -f "$HTML" ]] || { echo "Error: '$HTML' not found." >&2; exit 1; }

python3 - "$HTML" << 'PYEOF'
import sys, re
path = sys.argv[1]
content = open(path).read()
# Strip any previous patch
content = re.sub(r'<script data-bpw>[^<]*</script>', '', content)
# One-liner: MutationObserver removes .page__aside-element_for_notification the moment React renders it
snippet = '<script data-bpw>new MutationObserver(function(m,o){var e=document.querySelector(".page__aside-element_for_notification");if(e){e.remove();o.disconnect();}}).observe(document.body||document.documentElement,{childList:true,subtree:true});</script>'
content = content.replace('</body>', snippet + '</body>', 1)
open(path, 'w').write(content)
print('Patched:', path)
PYEOF
