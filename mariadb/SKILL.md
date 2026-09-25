---
name: mariadb
description: "MariaDB and MySQL/InnoDB best practices, independent of hosting provider, with a translation table for the differences between MariaDB versions and MySQL 8. Load this skill BEFORE writing or changing anything that lives in a MariaDB or MySQL database: creating or altering tables, columns, character sets and collations, primary keys, JSON columns, indexes (composite, covering, fulltext, prefix), partitions, migrations and ALTER TABLE on live tables. Also load it when diagnosing slow queries, EXPLAIN or ANALYZE output, filesort and temporary tables, OFFSET pagination, stale statistics and histograms, optimizer_switch behaviour, deadlocks (error 1213), lock waits, gap locks, isolation levels, connection exhaustion, replication lag, or N+1 query patterns. Schema, migration, and SQL authoring tasks need these rules too, even for a one-column change or a single query."
license: MIT
metadata:
  version: "1.0.0"
  sources:
    - name: mariadb/skills (mariadb-query-optimization, last updated 2026-06-05)
      files: "references/mariadb-query-optimization.md"
    - name: planetscale/database-skills (mysql 1.0.0)
      files: "references/mysql-*"
  provenance: README.md
---

# MariaDB and MySQL/InnoDB Best Practices

Two sources merged into one skill. The `mariadb-query-optimization.md` file is written by
MariaDB for the 11.8 LTS optimizer. The `mysql-*` files are written for MySQL 8 and cover
the parts of InnoDB that MariaDB shares: clustered primary keys, composite and covering
indexes, locking, isolation, online DDL, connections, and replication. The section
"MariaDB differences" below maps the MySQL 8 syntax in those files to what MariaDB
actually supports, with the minimum MariaDB version for each.

## Pin the version first

Every rule here depends on the server version. Run `SELECT VERSION();` before advising,
or ask. Then read the two baselines against that number:

- `mariadb-query-optimization.md` assumes MariaDB 11.8 LTS. Every feature there carries a
  minimum version tag; anything tagged above the server's version is not available.
- `mysql-*.md` files assume MySQL 8.0. Anything tagged "MySQL 8.0+" needs the row in the
  differences table below before it can be used on MariaDB.

MariaDB 10.3 reached end of life on 25 May 2023 and receives no security fixes. When the
server is on 10.3, say so once, then give advice that works on 10.3 and note what an
upgrade would unlock. As of September 2026 the Community LTS lines still maintained are
10.11, 11.4, 11.8, and 12.3; 10.6 Community maintenance ended in July 2026.

## When to apply

- Writing SQL, designing or changing a schema, choosing column types and collations.
- Adding, reviewing, or removing indexes; deciding composite column order.
- Running `ALTER TABLE` on a live table or planning a migration.
- Diagnosing slow queries, reading `EXPLAIN` or `ANALYZE`, filesort, temporary tables.
- Investigating deadlocks, lock waits, gap locks, or long transactions.
- Sizing connections, pools, or `max_connections`.
- Reading from replicas, or diagnosing replication lag.

## Diagnosis order

Follow this order when a query or server is slow. Skipping ahead to indexes without the
first three steps is the most common wasted effort.

1. Confirm observability. `performance_schema` needs a config change and restart (see
   "Performance Schema (enable first)" in the MariaDB file). The slow query log
   (`SET GLOBAL slow_query_log=1`, `long_query_time`) can be turned on at runtime.
2. `EXPLAIN` the statement. On MariaDB use `ANALYZE SELECT ...` (10.1+) for real row
   counts versus estimates. `EXPLAIN ANALYZE` and `FORMAT=TREE` are MySQL 8 only.
3. Refresh statistics with `ANALYZE TABLE`. Stale estimates produce bad join orders.
4. Check predicates for functions on indexed columns, type mismatches, and `OFFSET`.
5. Check composite index column order against the query's equality and range predicates.
6. Only then add, reorder, or drop indexes, and re-run step 2 to prove the change.

## Reference index

### MariaDB optimizer

| File | Purpose |
|------|---------|
| [mariadb-query-optimization.md](references/mariadb-query-optimization.md) | Performance Schema setup, EXPLAIN and ANALYZE, leftmost prefix, covering indexes, when not to index, IGNORED indexes, sargable functions by version, generated columns instead of functional indexes, cursor pagination, histograms, optimizer_switch flags, optimizer improvements per LTS line, optimizer hints (12.0+), LIMIT ROWS EXAMINED, quick wins checklist |

### Schema design

| File | Purpose |
|------|---------|
| [mysql-primary-keys.md](references/mysql-primary-keys.md) | Clustered index consequences, sequential versus random keys, UUID in a secondary column |
| [mysql-data-types.md](references/mysql-data-types.md) | Smallest correct type, numeric sizes, VARCHAR, DATETIME versus TIMESTAMP, NOT NULL |
| [mysql-character-sets.md](references/mysql-character-sets.md) | utf8mb4 everywhere, collation choice, converting existing tables, connection charset |
| [mysql-json-column-patterns.md](references/mysql-json-column-patterns.md) | When JSON is appropriate, indexing extracted paths via generated columns, caveats |

### Indexing

| File | Purpose |
|------|---------|
| [mysql-composite-indexes.md](references/mysql-composite-indexes.md) | Leftmost prefix, equality before range, range stops further column use, redundant indexes |
| [mysql-covering-indexes.md](references/mysql-covering-indexes.md) | Index-only reads, `Using index` versus `Using index condition`, secondary indexes carry the PK |
| [mysql-fulltext-indexes.md](references/mysql-fulltext-indexes.md) | InnoDB fulltext, natural and boolean mode, when to use a search engine instead |
| [mysql-index-maintenance.md](references/mysql-index-maintenance.md) | Finding unused and duplicate indexes, write cost per index, online index builds |

### Partitioning

| File | Purpose |
|------|---------|
| [mysql-partitioning.md](references/mysql-partitioning.md) | RANGE, LIST, HASH, pruning, partition key must be in every unique key, MAXVALUE, retention by DROP PARTITION |

### Query optimization

| File | Purpose |
|------|---------|
| [mysql-explain-analysis.md](references/mysql-explain-analysis.md) | Reading type, key, rows, filtered, Extra; red flags and what to change |
| [mysql-query-optimization-pitfalls.md](references/mysql-query-optimization-pitfalls.md) | Non-sargable predicates, implicit casts, leading wildcards, OR across columns, OFFSET, SELECT *, UNION versus UNION ALL, derived table materialization |
| [mysql-n-plus-one.md](references/mysql-n-plus-one.md) | Detecting N+1 from ORMs, fixing with JOIN, IN batching, or eager loading |

### Transactions and locking

| File | Purpose |
|------|---------|
| [mysql-isolation-levels.md](references/mysql-isolation-levels.md) | REPEATABLE READ by default, when READ COMMITTED helps, per-session changes |
| [mysql-deadlocks.md](references/mysql-deadlocks.md) | Causes, reading the deadlock section of InnoDB status, consistent row order, retry on 1213 |
| [mysql-row-locking-gotchas.md](references/mysql-row-locking-gotchas.md) | Next-key and gap locks, locking more than expected, unindexed UPDATE locking whole scans |

### Operations

| File | Purpose |
|------|---------|
| [mysql-online-ddl.md](references/mysql-online-ddl.md) | INSTANT, INPLACE, COPY; forcing the algorithm so a change fails instead of copying; external migration tools |
| [mysql-connection-management.md](references/mysql-connection-management.md) | Memory per connection, sizing max_connections, pool sizing, wait_timeout |
| [mysql-replication-lag.md](references/mysql-replication-lag.md) | Why replicas lag, measuring it, read-your-writes strategies, DDL and long queries on replicas |

## MariaDB differences

The `mysql-*` files are copied from upstream unchanged apart from removed vendor
paragraphs, so they use MySQL 8 names and syntax. Translate with this table. Versions are
the minimum MariaDB release, checked against mariadb.com/docs on 2026-09-25. Where the
MariaDB file already covers a topic, the row points to its section instead of repeating it.

| Where it appears | MySQL 8 in the file | On MariaDB | Since |
|------------------|---------------------|------------|-------|
| explain-analysis | `EXPLAIN ANALYZE`, `FORMAT=TREE` | `ANALYZE SELECT ...`, `ANALYZE FORMAT=JSON SELECT ...`. See "Reading EXPLAIN" in the MariaDB file | 10.1 |
| explain-analysis | `filtered` column in plain `EXPLAIN` | `EXPLAIN EXTENDED`, `EXPLAIN FORMAT=JSON`, or `ANALYZE` (`r_filtered`) | 10.0 |
| explain-analysis | `EXPLAIN FOR CONNECTION` | `SHOW EXPLAIN FOR <thread_id>`; `EXPLAIN FOR CONNECTION`, `SHOW EXPLAIN FORMAT=JSON`, and `SHOW ANALYZE` | 10.0; 10.9 |
| character-sets | `utf8mb4_0900_ai_ci`, `utf8mb4_0900_as_cs` | Accepted from 11.4.5 as aliases for `utf8mb4_uca1400_nopad_ai_ci` and `_nopad_as_cs`. Before that use `utf8mb4_uca1400_ai_ci` (10.10) or `utf8mb4_unicode_520_ci`; `utf8mb4_bin` for exact matching | 11.4.5 |
| index-maintenance | `ALTER INDEX ... INVISIBLE` | `ALTER TABLE t ALTER INDEX idx IGNORED`. See "Ignored Indexes" in the MariaDB file. No equivalent on 10.3: test by dropping on a replica or copy | 10.6 |
| index-maintenance, n-plus-one | `sys` schema views | `sys` schema ships from 10.6. On 10.3 query `performance_schema.table_io_waits_summary_by_index_usage` directly | 10.6 |
| query-optimization-pitfalls | Functional index `((UPPER(name)))` | Not supported (MDEV-35853). Index a generated column instead; see "Functional Indexes: Use a Generated Column" in the MariaDB file. Before 11.8 the optimizer does not match the expression in `WHERE`, so filter on the generated column by name | 10.2 |
| query-optimization-pitfalls | "functions on indexed columns kill the index" | Still true on 10.x. See "Functions on Indexed Columns" in the MariaDB file for what became sargable in 11.1, 11.3, and 11.8 | 11.1 |
| composite-indexes | Descending index parts `(a ASC, b DESC)` | `DESC` parsed and ignored before 10.8; real descending parts from 10.8; `MIN()`/`MAX()` on descending indexes from 11.4 | 10.8 |
| json-column-patterns | Native `JSON` type | `JSON` is an alias for `LONGTEXT COLLATE utf8mb4_bin`. `CHECK (JSON_VALID(col))` is added automatically from 10.4.3; on 10.3 add it yourself | 10.2.7 |
| json-column-patterns | `->` and `->>` operators | Added in 13.1 (MDEV-13594). On every earlier version use `JSON_EXTRACT(col, '$.k')`, `JSON_UNQUOTE(JSON_EXTRACT(...))`, or `JSON_VALUE(col, '$.k')` | 13.1 |
| json-column-patterns | Multi-valued indexes on JSON arrays | Not in any released version (MDEV-25848, planned 13.3). Normalize array elements into a child table | — |
| online-ddl | `ALGORITHM=INSTANT` for add, drop, rename column | Instant `ADD COLUMN` as last column 10.3.2; `ALGORITHM=INSTANT` and `NOCOPY` keywords 10.3.7; `ADD COLUMN` at any position, `DROP COLUMN`, column reorder 10.4; column rename is metadata-only. Extending `VARCHAR` is instant only while the length stays under 256 bytes; 10.4.3 relaxes this depending on row format | 10.3.2 |
| deadlocks | `performance_schema.data_locks`, `data_lock_waits` | `information_schema.INNODB_LOCKS`, `INNODB_LOCK_WAITS`, `INNODB_TRX`; `SHOW ENGINE INNODB STATUS`; `innodb_print_all_deadlocks=ON` (dynamic) to log every deadlock | 10.0 |
| isolation-levels | `@@transaction_isolation` | `@@tx_isolation` on 10.x. 11.1.1 added `transaction_isolation` as the system variable and deprecated `tx_isolation`, which still works | 10.0 |
| row-locking-gotchas | `SELECT ... FOR SHARE` | Not supported (MDEV-17514). Use `SELECT ... LOCK IN SHARE MODE`. `WAIT n` / `NOWAIT` on locking reads 10.3; `SKIP LOCKED` 10.6 | 10.0 |
| replication-lag | `WAIT_FOR_EXECUTED_GTID_SET()`, `@@gtid_executed` | `MASTER_GTID_WAIT('<gtid>', timeout)`, `@@gtid_slave_pos`, `@@gtid_current_pos`, `@@gtid_binlog_pos`. MariaDB GTID is `domain-server-seq` and is not compatible with MySQL GTID | 10.0 |
| replication-lag | `replica_parallel_workers`, `LOGICAL_CLOCK` | `slave_parallel_threads=N` (10.0.5) with `slave_parallel_mode` (10.1.3; `optimistic` is the default from 10.5.1, `conservative` before) | 10.0.5 |
| replication-lag | `SHOW REPLICA STATUS` | `SHOW SLAVE STATUS`; `REPLICA` accepted as a synonym from 10.5.1. Lag column is `Seconds_Behind_Master` | 10.0 |
| connection-management, n-plus-one, index-maintenance | `performance_schema` on by default | Off by default on every MariaDB version; see "Performance Schema (enable first)" in the MariaDB file | — |

Two facts that the MariaDB file states more broadly than the docs:

- "Functions on Indexed Columns" says `UPPER()` on any case-insensitive collation is sargable
  from 11.3. The docs limit `sargable_casefold` to `UPPER()` and `UCASE()` on
  `utf8mb3_general_ci` or `utf8mb4_general_ci`; `LOWER()` is not covered (MDEV-31955).
- "Histogram Statistics" gives the 10.4 defaults. On 10.3, `histogram_size` is 0,
  `optimizer_use_condition_selectivity` is 1, and `use_stat_tables` is `never`, so
  histograms are neither collected nor consulted. Set all three, then run
  `ANALYZE TABLE t PERSISTENT FOR ALL;`. A plain `ANALYZE TABLE` on 10.3 refreshes InnoDB
  index statistics only.

Old-style hints that replace the 12.x optimizer hints on 10.x: `STRAIGHT_JOIN`,
`USE INDEX`, `FORCE INDEX`, `IGNORE INDEX` (optionally `FOR JOIN | ORDER BY | GROUP BY`),
and session `optimizer_switch`.

## Optimization checklist

When asked to optimize an existing database, check in this order:

- `performance_schema` and slow query log status; nothing else is trustworthy without them.
- Top statements by total time from `events_statements_summary_by_digest` or `pt-query-digest`
  over the slow log.
- Unused indexes with zero reads since the last restart. Exclude unique and foreign key
  indexes, and check uptime before trusting the counts.
- Duplicate and redundant indexes: any index that is a leftmost prefix of another.
- Tables whose statistics are stale or missing histograms after bulk loads.
- Random UUID or other non-monotonic primary keys on large InnoDB tables.
- Tables using `utf8` (utf8mb3) or mixed collations across join columns, which block index use.
- `OFFSET` pagination and `SELECT *` in hot queries.
- Tables above roughly 50 million rows that filter by time and could be partitioned.
- Long-running transactions in `INNODB_TRX` and lock waits in `INNODB_LOCK_WAITS`.
- Connection count against `max_connections`, and whether a pool sits in front of the server.

## Safety

- Always confirm with the user before dropping an index, dropping a partition, running
  `ALTER TABLE` with `ALGORITHM=COPY` on a production table, `OPTIMIZE TABLE`, or any
  other destructive or blocking action. An index that looks unused may serve a monthly job.
- Back up before any schema change or bulk data change.
- Force the algorithm and lock level on live `ALTER TABLE` so an unsupported change fails
  loudly instead of copying the table: `ALGORITHM=INSTANT` or `ALGORITHM=INPLACE, LOCK=NONE`.
  Test on a replica or a copy first.
- Wrap bulk deletes and updates in bounded batches by primary key range to keep
  transactions short and replication lag low.
