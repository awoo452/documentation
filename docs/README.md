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
- `links` (array, optional): Objects with `label` and `path`.

## Rendering Rules

- `body` renders as paragraphs.
- `bullets` renders as an unordered list.
- `steps` renders as an ordered list.
- `code` renders as a code block.

## Importing Into Search

`Docs::Importer` converts entries into `Document` records so the embedding
search endpoint can index the docs. This keeps the JSON format as the source
of truth while still enabling vector search.
