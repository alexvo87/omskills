# omskills

A curated set of agent skills for Claude Code and other agents that support the
`SKILL.md` convention. Each skill vendors rule files from a well-maintained upstream
project, keeps them byte-identical, and adds its own index and provenance notes.

## Skills

| Skill | What it covers | Upstream | Files |
|-------|----------------|----------|-------|
| [`rust`](rust/) | Idiomatic, fast, and safe Rust for API services and core processing: ownership, errors, async on Tokio, serde, types, memory, unsafe, testing, observability, project layout, lints. Current for Rust 1.96 and the 2024 edition. | [leonardomso/rust-skills](https://github.com/leonardomso/rust-skills) | 265 rules in 26 categories |
| [`postgres`](postgres/) | Postgres best practices and operations, independent of hosting provider: query performance, connections, RLS, schema design, locking, data access, monitoring, and server operations. | [supabase/agent-skills](https://github.com/supabase/agent-skills), [planetscale/database-skills](https://github.com/planetscale/database-skills) | 43 reference files |

## Install

Skills are directories. Point your agent's skill location at a skill directory, or
symlink it in.

Claude Code, user scope (available in every project):

```bash
git clone git@github.com:alexvo87/omskills.git ~/omskills
ln -s ~/omskills/rust     ~/.claude/skills/rust
ln -s ~/omskills/postgres ~/.claude/skills/postgres
```

Claude Code, project scope (checked in with the repo):

```bash
ln -s ../../path/to/omskills/rust .claude/skills/rust
```

Symlinks mean a `git pull` in the clone updates the installed skill. New skills appear
in the catalog at the next session; invoke with `/rust` or `/postgres`, or let the agent
activate them from the `description` in each `SKILL.md`.

## Layout

Every skill follows the same shape:

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
`LICENSE-<source>`. All current upstreams are MIT. The `SKILL.md` and `README.md` files
written for this repo are MIT as well.
