---
name: postgres
description: "Postgres best practices and operations guide for Postgres running anywhere (self-hosted, container, or any managed provider). Load this skill BEFORE writing or changing anything that lives in a Postgres database: creating or altering tables and columns (including choosing column types), schema design, migrations, RLS policies, indexes, triggers, database functions, queues and scheduled jobs, vector or full-text search, bulk imports and restores. Also load it when diagnosing slow queries, high CPU, timeouts, EXPLAIN plans, connection exhaustion, locking, deadlocks, bloat, vacuum and autovacuum, XID wraparound, replication lag, WAL or checkpoint pressure, memory and OOM, backup and point-in-time recovery, PgBouncer sizing, or rows visible to the wrong user or tenant. Schema, migration, security, and SQL authoring tasks need these rules too, even for a one-column change or a single query."
license: MIT
metadata:
  version: "1.0.0"
  sources:
    - name: supabase/agent-skills (supabase-postgres-best-practices 1.1.1)
      files: "references/query-*, conn-*, security-*, schema-*, lock-*, data-*, monitor-*, advanced-*"
    - name: planetscale/database-skills (postgres 1.0.0)
      files: "references/ops-*"
  provenance: README.md
---

# Postgres Best Practices and Operations

Rules and operational guidance for Postgres, independent of hosting provider. Rule files
give a concrete incorrect-then-correct SQL rewrite with the expected impact. Operations
files explain internals and give diagnostic queries for a running database.

## When to apply

- Writing SQL, designing or changing a schema, writing a migration.
- Adding, reviewing, or removing indexes.
- Writing or tuning Row Level Security policies and privileges.
- Configuring connection limits, pooling, or PgBouncer.
- Diagnosing slow queries, lock contention, deadlocks, or connection exhaustion.
- Investigating bloat, vacuum behaviour, XID age, or long transactions.
- Operating the server: WAL and checkpoints, replication, backups and recovery,
  memory sizing, storage layout, partition lifecycle.

## Rule categories by priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Query Performance | CRITICAL | `query-` |
| 2 | Connection Management | CRITICAL | `conn-` |
| 3 | Security and RLS | CRITICAL | `security-` |
| 4 | Schema Design | HIGH | `schema-` |
| 5 | Concurrency and Locking | MEDIUM-HIGH | `lock-` |
| 6 | Data Access Patterns | MEDIUM | `data-` |
| 7 | Monitoring and Diagnostics | LOW-MEDIUM | `monitor-` |
| 8 | Advanced Features | LOW | `advanced-` |
| 9 | Operations and Internals | Situational | `ops-` |

Categories 1 to 8 are prescriptive rules: read the matching file before writing that
kind of SQL. Category 9 is for a database that is already running and needs diagnosis,
tuning, or maintenance.

## Reference index

### 1. Query Performance

| File | Purpose |
|------|---------|
| [query-missing-indexes.md](references/query-missing-indexes.md) | Add indexes on WHERE and JOIN columns |
| [query-composite-indexes.md](references/query-composite-indexes.md) | Composite indexes for multi-column queries, column order |
| [query-covering-indexes.md](references/query-covering-indexes.md) | Covering indexes with INCLUDE to avoid heap lookups |
| [query-partial-indexes.md](references/query-partial-indexes.md) | Partial indexes for filtered subsets |
| [query-index-types.md](references/query-index-types.md) | Choosing B-tree, GIN, GiST, BRIN, hash |

### 2. Connection Management

| File | Purpose |
|------|---------|
| [conn-pooling.md](references/conn-pooling.md) | Use connection pooling for all applications |
| [conn-limits.md](references/conn-limits.md) | Set appropriate connection limits |
| [conn-idle-timeout.md](references/conn-idle-timeout.md) | Idle and idle-in-transaction timeouts |
| [conn-prepared-statements.md](references/conn-prepared-statements.md) | Prepared statements behind transaction-mode poolers |

### 3. Security and RLS

| File | Purpose |
|------|---------|
| [security-rls-basics.md](references/security-rls-basics.md) | Enable RLS for multi-tenant data |
| [security-rls-performance.md](references/security-rls-performance.md) | Make RLS policies index-friendly and cheap |
| [security-privileges.md](references/security-privileges.md) | Least-privilege roles and grants |

### 4. Schema Design

| File | Purpose |
|------|---------|
| [schema-primary-keys.md](references/schema-primary-keys.md) | Primary key strategy: identity, uuid, ordering |
| [schema-data-types.md](references/schema-data-types.md) | Choosing column types |
| [schema-constraints.md](references/schema-constraints.md) | Adding constraints idempotently in migrations |
| [schema-foreign-key-indexes.md](references/schema-foreign-key-indexes.md) | Index every foreign key column |
| [schema-lowercase-identifiers.md](references/schema-lowercase-identifiers.md) | Lowercase snake_case identifiers |
| [schema-partitioning.md](references/schema-partitioning.md) | When and how to partition at design time |

### 5. Concurrency and Locking

| File | Purpose |
|------|---------|
| [lock-short-transactions.md](references/lock-short-transactions.md) | Keep transactions short |
| [lock-deadlock-prevention.md](references/lock-deadlock-prevention.md) | Consistent lock ordering |
| [lock-skip-locked.md](references/lock-skip-locked.md) | SKIP LOCKED for queue workers |
| [lock-advisory.md](references/lock-advisory.md) | Advisory locks for application-level mutual exclusion |

### 6. Data Access Patterns

| File | Purpose |
|------|---------|
| [data-n-plus-one.md](references/data-n-plus-one.md) | Eliminate N+1 with batch loading |
| [data-batch-inserts.md](references/data-batch-inserts.md) | Multi-row INSERT and COPY for bulk data |
| [data-pagination.md](references/data-pagination.md) | Keyset pagination instead of OFFSET |
| [data-upsert.md](references/data-upsert.md) | INSERT ... ON CONFLICT |

### 7. Monitoring and Diagnostics

| File | Purpose |
|------|---------|
| [monitor-explain-analyze.md](references/monitor-explain-analyze.md) | Reading EXPLAIN ANALYZE output |
| [monitor-pg-stat-statements.md](references/monitor-pg-stat-statements.md) | Finding expensive queries |
| [monitor-vacuum-analyze.md](references/monitor-vacuum-analyze.md) | Keeping statistics fresh |

### 8. Advanced Features

| File | Purpose |
|------|---------|
| [advanced-full-text-search.md](references/advanced-full-text-search.md) | tsvector and GIN for full-text search |
| [advanced-jsonb-indexing.md](references/advanced-jsonb-indexing.md) | Indexing JSONB columns |

### 9. Operations and Internals

| File | Purpose |
|------|---------|
| [ops-index-optimization.md](references/ops-index-optimization.md) | Unused, duplicate, and invalid indexes; bloat; HOT updates; planner tuning |
| [ops-mvcc-vacuum.md](references/ops-mvcc-vacuum.md) | MVCC, VACUUM vs VACUUM FULL, per-table autovacuum tuning |
| [ops-mvcc-transactions.md](references/ops-mvcc-transactions.md) | Isolation levels, XID wraparound, serialization errors |
| [ops-monitoring.md](references/ops-monitoring.md) | pg_stat views, blocking sessions, logging, host metrics |
| [ops-storage-layout.md](references/ops-storage-layout.md) | PGDATA layout, TOAST, fillfactor, tablespaces |
| [ops-partitioning.md](references/ops-partitioning.md) | Size thresholds, pg_partman, detach and drop lifecycle |
| [ops-pgbouncer-configuration.md](references/ops-pgbouncer-configuration.md) | Pool sizing and connection limits |
| [ops-process-architecture.md](references/ops-process-architecture.md) | Backend processes, auxiliary processes, memory risk |
| [ops-memory-management-ops.md](references/ops-memory-management-ops.md) | Shared and private memory, OS cache, OOM prevention |
| [ops-wal-operations.md](references/ops-wal-operations.md) | WAL, checkpoints, crash recovery |
| [ops-replication.md](references/ops-replication.md) | Streaming replication, slots, synchronous commit, failover |
| [ops-backup-recovery.md](references/ops-backup-recovery.md) | pg_dump, pg_basebackup, PITR, WAL archiving |

## Row Level Security on plain Postgres

The two `security-rls-*` files call `auth.uid()`, a helper that exists only on one
managed platform. On plain Postgres, have the application run
`SET LOCAL app.current_user_id = '<id>'` at the start of each transaction, and reference
it in policies as `(select current_setting('app.current_user_id', true)::uuid)`. The
`(select ...)` wrapper is what lets the planner evaluate the setting once per query
instead of once per row, so the performance rule in `security-rls-performance.md` applies
unchanged. Use `SET LOCAL`, not `SET`, so the value cannot leak across pooled connections.

## Optimization checklist

When asked to optimize an existing database, check in this order:

- Unused indexes (zero scans). Exclude unique and constraint-backing indexes, and check
  when statistics were last reset before trusting the counts.
- Duplicate indexes with identical definitions after name normalization.
- Invalid indexes left behind by failed `CREATE INDEX CONCURRENTLY`.
- Dead tuple counts and last autovacuum time per table; XID age per database.
- Audit or log tables above roughly 10 GB that could be archived.
- Tables above roughly 100 GB, or 50 GB for time-series, that are candidates for partitioning.
- Circular foreign key dependencies.
- Random UUID primary keys on very large tables.
- Connection pooling in place for OLTP workloads.

## Safety

- Always confirm with the user before dropping an index, detaching or dropping a
  partition, running `VACUUM FULL` or `REINDEX` on a production table, or any other
  destructive or blocking action. Unused-looking indexes may serve a workload not
  reflected in recent statistics.
- Back up before any schema change or bulk data change.
- Prefer `CREATE INDEX CONCURRENTLY`, `DETACH PARTITION ... CONCURRENTLY`, and
  `ADD CONSTRAINT ... NOT VALID` followed by `VALIDATE CONSTRAINT` on live tables.
