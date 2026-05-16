# raspi-finance-haskell

A Haskell implementation of the Raspberry Pi finance application, connecting to a PostgreSQL database to query financial transaction data.

## Tech Stack

- Haskell (GHC via Stack)
- `postgresql-simple` — PostgreSQL client
- `aeson` — JSON encoding/decoding
- `lens` — Optics library

## Prerequisites

Install Stack: [haskellstack.org](https://docs.haskellstack.org/en/stable/README/)

Install dependencies:

```bash
stack install postgresql-simple aeson lens
```

## Build & Run

```bash
stack build
stack run
```

Or use the Makefile:

```bash
make
```

## Database

Connects to a PostgreSQL database. The schema and connection details are configured in the source files. Ensure a PostgreSQL instance is running and accessible before running the application.

## Related Projects

- [raspi-finance-endpoint](../raspi-finance-endpoint) — Kotlin/Spring Boot version
- [raspi-finance-endpoint-ktor](../raspi-finance-endpoint-ktor) — Ktor version
- [raspi-finance-database](../raspi-finance-database) — Database schema and migrations
