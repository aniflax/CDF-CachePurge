#!/usr/bin/env bash
#
# Universal Cloudflare cache purger — drop into ANY project and it works.
#
# Run after any deploy that changes HTML or /public assets (or standalone
# whenever the edge is serving stale content). Reads secrets from .deploy.env
# (gitignored — never commit it).
#
# Per-project setup — create .deploy.env next to this script with either:
#
#   CF_API_TOKEN=your_token            (required — needs Cache Purge permission)
#   CF_ZONE_ID=your_zone_id            (option A — set this if you know it)
#   CF_ZONE=example.com                (option B — OR set the domain; the
#                                        script looks up the zone ID itself)
#
set -euo pipefail
cd "$(dirname "$0")"
[ -f .deploy.env ] && . ./.deploy.env
: "${CF_API_TOKEN:?set CF_API_TOKEN in .deploy.env}"

if [ -z "${CF_ZONE_ID:-}" ]; then
  : "${CF_ZONE:?set CF_ZONE (domain) or CF_ZONE_ID in .deploy.env}"
  CF_ZONE_ID=$(curl -fsS -H "Authorization: Bearer ${CF_API_TOKEN}" \
    "https://api.cloudflare.com/client/v4/zones?name=${CF_ZONE}" \
    | grep -oE '"id":"[0-9a-f]+"' | head -1 | cut -d'"' -f4)
fi

curl -fsS -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/purge_cache" \
  -H "Authorization: Bearer ${CF_API_TOKEN}" -H "Content-Type: application/json" \
  -d '{"purge_everything":true}'
echo