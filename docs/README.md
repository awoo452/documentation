# Documentation Standard

This app uses `docs/docs.json` as the source of truth for documentation. The
JSON shape is intentionally structured so we can migrate to database columns
later without changing the content format.

## Schema

Each entry is an object with the following fields:

- `id` (string, required): Stable slug used in URLs.
- `title` (string, required)
- `summary` (string, required)
- `category` (string, required)
- `tags` (array of strings, optional)
- `audience` (array of strings, optional)
- `status` (string, optional): `draft`, `stable`, or `deprecated`.
- `updated_at` (string, required): `YYYY-MM-DD`.
- `sections` (array, required):
  - `heading` (string, optional)
  - `body` (array of strings, optional)
  - `bullets` (array of strings, optional)
  - `steps` (array of strings, optional)
  - `code` (string, optional)
- `images` (array, optional): strings or objects with `src` or `key`, plus `alt`, `caption`
- `videos` (array, optional): strings or objects with `url`, plus `caption` (YouTube URLs embed)
- `links` (array, optional): Objects with `label` and `path`.

## Rendering Rules

- `body` renders as paragraphs.
- `bullets` renders as an unordered list.
- `steps` renders as an ordered list.
- `code` renders as a code block.
- `images` render as labeled figures (fallback to `logo.png` when missing).
- `videos` render as labeled YouTube embeds when the URL matches.

### S3 Media Keys

If you want images to resolve via S3, provide a `key` (or a `src` starting with `s3://` or `s3:` and containing the key path only, not the bucket).
The app uses the same `IMAGE_PROXY_BASE_URL` / `IMAGE_PROXY_SIGNING_KEY` pattern as `s3-image-storage`, with a presigned S3 URL fallback when the proxy is not configured.

## Importing Into Search

`Docs::Importer` converts entries into `Document` records so the embedding
search endpoint can index the docs. This keeps the JSON format as the source
of truth while still enabling vector search.
