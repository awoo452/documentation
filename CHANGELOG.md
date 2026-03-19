# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.4] - 2026-03-18
### Added
- Added a `publicly_visible` flag to documents for basic public gating.
- Added a server-side docs index search that filters the JSON-backed entries.

## [0.0.3] - 2026-03-17
### Fixed
- Moved `ApplicationSystemTestCase` to the test root so system specs can `require "application_system_test_case"` in CI.

## [0.0.2] - 2026-03-17
### Fixed
- Added a rack-test system test harness and a docs index smoke test so CI system tests have runnable coverage.
- Fixed RuboCop array literal spacing in the docs app and schema snapshots.

## [0.0.1] - 2026-03-17
### Added
- Added documentation standard files in `docs/` with a shared JSON schema.
- Added docs index and show pages backed by `docs/docs.json`.
- Added docs store and importer services to read JSON entries and populate searchable records.
- Added documentation UI styling and layout.
- Added README guidance for documentation usage and optional embeddings search.
- Skips docs import during seeding when the `documents` table is missing, with a warning to run migrations.
- Updated CI to run tests against a pgvector-enabled Postgres service.
- Updated `Gemfile.lock` to include the missing pg checksum so CI bundler runs in frozen mode.
