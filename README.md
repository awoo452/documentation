# documentation

Reference Rails app for a shared documentation format.

This app standardizes how we store, render, and search documentation across the
other Rails apps in this folder. The JSON format is the source of truth so we
can migrate into database columns later without rewriting content.

## What This App Covers

- A single JSON schema for docs (`docs/docs.json`)
- Docs index + detail pages
- Importer that flattens docs into searchable records
- Optional embeddings + pgvector search

## Documentation Standard

- Schema and rendering rules live in `docs/README.md`.
- Content lives in `docs/docs.json`.
- `db:seed` imports JSON entries into the `documents` table.
- Set `DOCS_SOURCE=database` to render docs directly from the `documents` table
  instead of JSON (defaults to `json`).
- When `DOCS_SOURCE=database`, the JSON importer is skipped during seeding.

## Prerequisites

- Ruby (see `.ruby-version` if present)
- PostgreSQL running locally
- `pgvector` extension installed in your Postgres instance (only required for embeddings)

## Setup

1. `bundle install`
2. `bin/rails db:drop db:create db:migrate`
3. `bin/rails db:seed`
4. `bin/rails embeddings:backfill` (optional)

## Seeding the Docs DB

- `bin/rails db:seed` imports `docs/docs.json` into the `documents` table.
- If you are running with `DOCS_SOURCE=database`, the importer is skipped.
  To seed from JSON anyway, run:
  `DOCS_SEED_FROM_JSON=1 bin/rails db:seed`

## Docs UI

- Visit `/docs` to browse the documentation standard and example entries.

## Document Search

This app stores document embeddings in Postgres and uses pgvector for nearest-neighbor search.

Run a search:
```
curl "http://localhost:3000/documents/search?q=your query"
```

## Notes

- Set `OPENAI_API_KEY` in your shell before generating embeddings.
- `EmbeddingService` uses the OpenAI embeddings API (`text-embedding-3-small`).
