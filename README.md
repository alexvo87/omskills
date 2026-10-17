# omskills

A curated set of agent skills for Claude Code and other agents that support the
`SKILL.md` convention. Each skill vendors rule files from a well-maintained upstream
project, keeps them byte-identical, and adds its own index and provenance notes.

## Skills

| Skill | What it covers | Upstream | Files |
|-------|----------------|----------|-------|
| [`rust`](rust/) | Idiomatic, fast, and safe Rust for API services and core processing: ownership, errors, async on Tokio, serde, types, memory, unsafe, testing, observability, project layout, lints. Current for Rust 1.96 and the 2024 edition. | [leonardomso/rust-skills](https://github.com/leonardomso/rust-skills) | 265 rules in 26 categories |
| [`rust-unsafe`](rust-unsafe/) | Unsafe Rust and FFI: raw pointers, `NonNull`, `MaybeUninit`, memory layout and `repr`, unions, panic safety, `SAFETY` comments, manual `Send`/`Sync`, and the C boundary (extern blocks, exports, strings, callbacks, opaque handles, raw fds). 47 rules in 7 groups with bad and good examples, moved from Rust 2021 to 2024 syntax by a scripted patch documented in its README. Deeper companion to the seven `unsafe-` rules of `rust`. | [actionbook/rust-skills](https://github.com/actionbook/rust-skills) `unsafe-checker`, translated from [rust-coding-guidelines-zh](https://github.com/Rust-Coding-Guidelines/rust-coding-guidelines-zh) | 47 rules in 7 groups |
| [`postgres`](postgres/) | Postgres best practices and operations, independent of hosting provider: query performance, connections, RLS, schema design, locking, data access, monitoring, and server operations. | [supabase/agent-skills](https://github.com/supabase/agent-skills), [planetscale/database-skills](https://github.com/planetscale/database-skills) | 43 reference files |
| [`mariadb`](mariadb/) | MariaDB and MySQL/InnoDB best practices, independent of hosting provider: EXPLAIN and ANALYZE, indexing, pagination, histograms, optimizer switches, schema design, JSON, partitioning, locking and deadlocks, online DDL, connections, replication lag. Includes a MySQL 8 to MariaDB translation table with minimum versions. Two vendor paragraphs are stripped by a scripted step documented in its README. | [mariadb/skills](https://github.com/mariadb/skills), [planetscale/database-skills](https://github.com/planetscale/database-skills) | 19 reference files |
| [`agentkit-lite`](agentkit-lite/) | Workflow skills that run without the AgentKit CLI or the rest of the kit: `ak:brainstorm` (four-field delivery contract), `ak:plan` (plan and phase files), and the `fullstack-developer` agent. Portability changes are applied by a scripted patch. Not supported standalone: `--html`, `--wiki`, `--github`, `--ultra`, `--advice`, `--debate`, journaling, `ak plan` indexing; see its [README](agentkit-lite/README.md). | AgentKit `ak` 2.18.1 (ak-brainstorm 2.8.2, ak-plan 2.2.2) | 31 skill files plus one agent |

## Install

Skills are directories. Point your agent's skill location at a skill directory, or
symlink it in.

Claude Code, user scope (available in every project):

```bash
git clone git@github.com:alexvo87/omskills.git ~/omskills
ln -s ~/omskills/rust     ~/.claude/skills/rust
ln -s ~/omskills/rust-unsafe ~/.claude/skills/rust-unsafe
ln -s ~/omskills/postgres ~/.claude/skills/postgres
ln -s ~/omskills/mariadb  ~/.claude/skills/mariadb
```

Claude Code, project scope (checked in with the repo):

```bash
ln -s ../../path/to/omskills/rust .claude/skills/rust
```

`agentkit-lite` is two skills plus an agent, so it installs with its own script
(add `--project` for `./.claude`, `--uninstall` to remove its symlinks):

```bash
sh ~/omskills/agentkit-lite/install.sh
```

Symlinks mean a `git pull` in the clone updates the installed skill. New skills appear
in the catalog at the next session; invoke with `/rust`, `/postgres`, or `/mariadb`, or let the agent
activate them from the `description` in each `SKILL.md`.

## Layout

Every vendored rule skill follows the same shape (`agentkit-lite` is the exception: it
holds two skills plus one agent, a `patch.sh`, an `install.sh`, and `UPSTREAM.md` in place
of `LICENSE-<source>`; `rust-unsafe` adds a `patch.sh` that moves the vendored examples to
Rust 2024, so its `references/` equal upstream plus that patch; see their own READMEs):

```
<skill>/
├── SKILL.md          # frontmatter + index; written for this repo
├── README.md         # provenance: upstream repo, commit, what was taken, update steps
├── LICENSE-<source>  # upstream license, one per source
└── references/       # upstream files, copied byte for byte
```

`SKILL.md` is the only file the agent reads first. It lists every reference file with a
one-line summary so the agent opens just the few that match the code at hand. The
`references/` files are never edited by hand; each skill's `README.md` documents the
exact upstream commit and a repeatable procedure to pull updates and verify links.

## Updating from upstream

See the `README.md` inside each skill. The procedure is the same everywhere: sparse-clone
the upstream repo, diff against `references/`, copy changed files, regenerate the index,
run the link and byte-identity checks, and record the new commit.

## License

Each skill's `references/` files keep their upstream license, stored next to the skill as
`LICENSE-<source>`, except `agentkit-lite`, whose upstream ships no license file and whose
`license: MIT` frontmatter field is the license statement (recorded in its `UPSTREAM.md`). `rust-unsafe` stores the MIT license of the original Chinese guidelines; its direct upstream
(actionbook) ships only a `license: MIT` metadata field, recorded in its README. All current upstreams are MIT. The `SKILL.md` and `README.md` files
written for this repo are MIT as well.
