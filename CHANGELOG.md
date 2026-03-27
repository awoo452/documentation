# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.15] - 2026-03-27
### Changed
- Updated dependencies: rails 8.1.3, solid_queue 1.4.0, kamal 2.11.0, action_text-trix 2.1.18, json 2.19.3, bigdecimal 4.1.0, net-imap 0.6.3, net-ssh 7.3.2, pg 1.5.9.

## [0.0.14] - 2026-03-22
### Changed
- Updated dependencies to address security advisories.

## [0.0.13] - 2026-03-21
### Changed
- Standardized README sections to the shared format.

## [0.0.12] - 2026-03-21
### Changed
- Standardized changelog dates to YYYY-MM-DD.

## [0.0.11] - 2026-03-20
### Fixed
- Normalized the `.ruby-version` entry to `4.0.2` (removed the `ruby-` prefix).

## [0.0.10] - 2026-03-19
### Changed
- Refreshed Gemfile.lock via bundle update for Ruby 4.0.2.

## [0.0.9] - 2026-03-19
### Changed
- Pinned Ruby to 4.0.2 across runtime files and Gemfile.lock.

## [0.0.8] - 2026-03-19
### Removed
- Removed application CSS and stylesheet tag to keep the template backend-only.
- Removed view class attributes to keep the template backend-only.

## [0.0.7] - 2026-03-18
### Added
- Allow docs rendering to use database records via `DOCS_SOURCE=database`.
- Documented how to seed the docs database when running in JSON or database mode.
- Allow forcing JSON seeding into the documents table via `DOCS_SEED_FROM_JSON=1`.
### Changed
- Skip JSON-to-DB docs import when database mode is active.

## [0.0.6] - 2026-03-18
### Changed
- Require explicit AWS credentials before generating S3 media URLs (fallback to local assets otherwise).

## [0.0.5] - 2026-03-18
### Added
- Added image + YouTube video rendering for doc sections when media is provided.
- Added S3 image URL helpers that mirror the image proxy + presigned fallback pattern.

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
