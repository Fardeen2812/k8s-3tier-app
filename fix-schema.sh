#!/usr/bin/env bash
set -e

SCHEMA_PATH=".vscode/schemas/k8s-all-v1.22.json"
PRIMARY="https://kubernetesjsonschema.dev/v1.22.0-standalone-strict/all.json"
FALLBACK="https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.22.0-standalone-strict/all.json"

rm -f "$SCHEMA_PATH"
mkdir -p "$(dirname "$SCHEMA_PATH")"

for url in "$PRIMARY" "$FALLBACK"; do
  echo "Trying: $url"
  curl -sSL -A "Mozilla/5.0 (Macintosh; Intel Mac OS X)" -o "$SCHEMA_PATH" "$url" || true
  # first byte should be '{' (hex 7b)
  first_hex=$(head -c1 "$SCHEMA_PATH" 2>/dev/null | od -An -t x1 | tr -d ' \n')
  if [ "$first_hex" = "7b" ]; then
    echo "Looks like JSON (starts with '{')."
    break
  else
    echo "Not JSON (showing first 120 bytes):"
    head -c120 "$SCHEMA_PATH" || true
    echo "Trying next URL..."
  fi
done

# validate
if command -v jq >/dev/null 2>&1; then
  jq . "$SCHEMA_PATH" >/dev/null && echo "schema OK (jq)" || echo "schema invalid (jq)"
else
  python -m json.tool "$SCHEMA_PATH" >/dev/null && echo "schema OK (python)" || echo "schema invalid (python)"
fi

echo "Final file info:"
ls -lh "$SCHEMA_PATH"
head -c200 "$SCHEMA_PATH" | sed -n '1,6p'
