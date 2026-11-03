# Downloading itch.io packs headlessly (free / name-your-own-price)

The itch.io web UI navigates instead of saving when the visible Download button is clicked in an automation browser, and the direct file URL is only minted via API POSTs. Use this flow from inside the game's own subdomain page.

## Procedure (browser tool, in-page JS)

1. Open `https://<user>.itch.io/<slug>` and wait for load.
2. Find the upload id: `a.download_btn[data-upload_id]` on the download page. If the game page only shows a purchase panel, go to `/<slug>/purchase` and CLICK the link "No thanks, just take me to the downloads" — it is JS-driven (its `href` equals the purchase URL; follow the click, not the href).
3. Read the CSRF token: `document.querySelector('meta[name="csrf_token"]').content`.
4. (Grant) `POST /<slug>/download_url` with urlencoded body `csrf_token=<token>&reward_id=` → JSON `{url}` (the download page). Establishes the session's download grant.
5. (Direct file) `POST /<slug>/file/<upload_id>?source=game_download` with urlencoded body `csrf_token=<token>` → JSON `{url}` = a signed Cloudflare R2 URL. **This must be a POST** — a GET of the same path returns the game page HTML, not the file.
6. The signed URL carries `X-Amz-Expires=60` — download it immediately from the shell:
   `curl -sSL -o pack.zip "$(cat /tmp/pack_url.txt)"`
   If the round-trip stalled, re-POST step 5 — each POST mints a fresh signed URL.
7. Verify with `file pack.zip` (expect "Zip archive"), then extract and inspect the layout (`Characters/gltf`, `Animations/gltf`, `Textures`).

## Pitfalls

- Never print a minted URL raw from the browser tool — long URLs are ellipsis-truncated by the output sanitizer and a truncated URL fails confusingly. Base64-encode it in-page, print in ~110-char chunks, decode in Python, write to a file, then curl.
- `/<slug>/download/<token>/<upload_id>` GET patterns 404 — the file route is the POST in step 5.
- Posting to bare `/download_url` (no slug prefix) 404s on subdomain pages — the endpoint is `/<slug>/download_url` when on `<user>.itch.io`.
- Clicking the Download button and hunting `~/Downloads` wastes time: itch navigates to `?download` / opens lightboxes instead of saving. Go straight to the POST flow.
- Staging policy: keep the zip + full extraction under `/assets/original/` (git-ignored originals); copy only the files the project actually uses into the project assets tree.
