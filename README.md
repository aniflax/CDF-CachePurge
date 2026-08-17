# Cloudflare-s-cache-purge

A tiny, dependency-free shell script to purge the Cloudflare edge cache for **any** Cloudflare-managed website.

Paste the script into any project, add two lines of config, and run it whenever the edge is serving stale content. Works on macOS and Linux (uses only `curl` and `grep`).

## Why you'd use it

Cloudflare caches your site's pages at the "edge" (servers near your visitors) for speed. After you deploy new content, Cloudflare can keep serving the **old cached copy**. This script sends Cloudflare's "purge everything" command so visitors immediately see the latest version.

Use it when:

- A deploy "sticks" and visitors still see old content.
- You changed HTML or `/public` assets (favicon, images, etc.) and want the change visible instantly.
- You need SEO or content changes to be visible right away.

## How it works

1. Reads `CF_API_TOKEN` and (optionally) `CF_ZONE_ID` / `CF_ZONE` from a local `.deploy.env` file.
2. If only the domain (`CF_ZONE`) is given, it automatically looks up the Cloudflare zone ID via the API — no manual lookup needed.
3. Calls the Cloudflare API `purge_cache` endpoint with `purge_everything: true`.
4. Prints Cloudflare's JSON response — you're done.

## Setup

### 1. Get an API token

1. Go to [dash.cloudflare.com](https://dash.cloudflare.com) → profile icon → **My Profile** → **API Tokens**.
2. Click **Create Custom Token** (the "Purge cache" template may not appear on all accounts).
3. Set:
   - **Permissions:** Zone → **Cache Purge** → **Purge**
   - **Zone Resources:** Include → **Specific zone** → your domain (or "All zones")
4. Create the token and **copy it immediately** (shown only once).

### 2. Create `.deploy.env`

Put the file **next to the script**. It is gitignored so your secrets are never committed.

```bash
CF_API_TOKEN=your_token_here      # required — needs Cache Purge permission
CF_ZONE_ID=your_zone_id_here      # option A — your zone ID (fast path)
# CF_ZONE=yourdomain.com          # option B — OR just the domain; the script finds the zone ID automatically
```

> **Zone ID:** dash.cloudflare.com → your domain → **Overview** → right sidebar → **Zone ID**.

### 3. Run it

```bash
./purge-cache.sh
```

**Success** looks like:

```json
{"errors":[],"messages":[],"result":{"id":"...","ttl":0},"success":true}
```

## Configuration reference

| Variable        | Required | Description                                                             |
| --------------- | -------- | ----------------------------------------------------------------------- |
| `CF_API_TOKEN`  | yes      | Cloudflare API token with **Cache Purge** permission                    |
| `CF_ZONE_ID`    | no*      | Your zone ID. Set this for the fast path (no lookup call)               |
| `CF_ZONE`       | no*      | Domain name (e.g. `example.com`). Used only if `CF_ZONE_ID` is unset    |

\* Set **either** `CF_ZONE_ID` (fast) **or** `CF_ZONE` (auto-lookup). `CF_API_TOKEN` is always required.

## Troubleshooting

| Error | Cause |
| ----- | ----- |
| `set CF_API_TOKEN in .deploy.env` | Token missing — add it to `.deploy.env` |
| `set CF_ZONE (domain) or CF_ZONE_ID in .deploy.env` | Neither zone config is set |
| Authentication error / HTTP 403 | Token is wrong, inactive, or missing the Cache Purge permission |
| Zone not found / HTTP 404 | Zone ID is wrong, or the token isn't scoped to that domain |

## Security

- `.deploy.env` contains secrets — **never commit it**. Add `.deploy.env` to your `.gitignore`.
- If a token is ever exposed (e.g. pasted into a chat), regenerate it in the Cloudflare dashboard.
- The script only ever *purges* cache — it cannot modify your site or DNS.

## License

[MIT](LICENSE)