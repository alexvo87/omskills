# Bundle `agentkit-lite`: provenance, install, and update

This bundle carries two AgentKit workflow skills and one AgentKit agent so they run in
Claude Code on a machine that has no `ak` binary, no AgentKit hooks, and no other kit
skill:

- `ak:brainstorm` turns an unclear request into a four-field contract (Outcome,
  Constraints, Non-goals, Acceptance criteria) and compares approaches.
- `ak:plan` writes `plans/<YYMMDD-HHmm>-<slug>/plan.md` plus phase files.
- `fullstack-developer` executes one phase file and writes a report.

The files under `skills/` and `agents/` are upstream copies. They are changed only by
[`patch.sh`](patch.sh), which adds a "Standalone mode" section and a few fallback
sentences, so a later re-extract is repeatable. Only `README.md`, `UPSTREAM.md`,
`patch.sh`, and `install.sh` are written for this repo.

## 1. Upstream sources

| Component | Upstream | Version | Taken on | License |
|-----------|----------|---------|----------|---------|
| [`skills/ak-brainstorm/`](skills/ak-brainstorm/SKILL.md) | AgentKit (`ak` 2.18.1), `.claude/skills/ak-brainstorm/` | 2.8.2 | 2026-09-28 | MIT (frontmatter `license: MIT`) |
| [`skills/ak-plan/`](skills/ak-plan/SKILL.md) | AgentKit (`ak` 2.18.1), `.claude/skills/ak-plan/` | 2.2.2 | 2026-09-28 | MIT (frontmatter `license: MIT`) |
| [`agents/fullstack-developer.md`](agents/fullstack-developer.md) | AgentKit (`ak` 2.18.1), `.claude/agents/fullstack-developer.md` | no version field | 2026-09-28 | shipped in the same kit |

[`UPSTREAM.md`](UPSTREAM.md) records the exact source paths and the sha256 of every file
before and after the patch. The kit ships no LICENSE file next to these skills; the
`license: MIT` frontmatter field is the license statement.

### What was taken

- All 8 files of `ak-brainstorm` and all 23 files of `ak-plan`, with the same names and
  layout. The directory names stay `ak-brainstorm` and `ak-plan` because `ak-plan` points
  at `../ak-brainstorm/references/*.md` by relative path.
- `fullstack-developer.md`, unchanged apart from the patch.

### What was not taken

- The other kit skills the two skills can hand off to: `ak:cook`, `ak:scout`, `ak:fix`,
  `ak:advise`, `ak:journal`, `ak:diagram`, `ak:frontend-design`, `ak:preview`.
- The kit agents `planner`, `researcher`, `kongming`, `journal-writer`.
- The AgentKit hooks (`session-init.cjs`, which injects the `## Naming` section, plus
  `plan-format-kanban.cjs` and `cook-after-plan-reminder.cjs`) and the `ak` CLI.

### Differences from upstream

`patch.sh` changes five files, each by an anchored literal replacement:

| File | Change |
|------|--------|
| `skills/ak-plan/SKILL.md` | Appends `## Standalone mode`: naming rule `plans/<YYMMDD-HHmm>-<slug>/` and `plans/reports/<type>-<YYMMDD-HHmm>-<slug>.md`; without `ak`, write plan and phase files directly from the templates in `references/`; without `/ak:journal`, print `journal skipped: ak:journal not installed`; plan inline when `planner` is absent; never call absent skills; `--html`, `--wiki`, `--github`, `--ultra`, `--advice`, `--debate` stop with one line. Marks the `--html` bullet's `ak-preview` link "(not bundled in standalone mode)". |
| `skills/ak-plan/references/plan-organization.md` | One sentence after the `Plan dir:` rule pointing to the standalone rule, which overrides the CLI-only scaffolding rule. |
| `skills/ak-brainstorm/SKILL.md` | Appends `## Standalone mode`: never call `/ak:cook`, `/ak:scout`, `/ak:fix`, `/ak:advise`, or `kongming`; scout inline; `--advice` and `--ultra` stop with one line; skip `ak config prefs resolve` without `ak`. |
| `skills/ak-brainstorm/references/report-output-mode.md` | Report path fallback `plans/reports/brainstorm-<YYMMDD-HHmm>-<slug>.md`. |
| `agents/fullstack-developer.md` | Without `kongming`, stop and report `Status: BLOCKED` with the question. Without an injected `## Naming` section, always write the report to `plans/reports/fullstack-developer-<YYMMDD-HHmm>-<slug>.md` and end the reply with a `Status:` line. |

## 2. Install and uninstall

`install.sh` is POSIX sh and idempotent. It symlinks `skills/ak-brainstorm`,
`skills/ak-plan`, and `agents/fullstack-developer.md` into the Claude Code config
directory, so a `git pull` in the clone updates the installed copy. It never overwrites
an existing entry that is not already its own symlink; it names the entry and exits 1
without changing anything.

```bash
git clone git@github.com:alexvo87/omskills.git ~/omskills

# User scope: ${CLAUDE_CONFIG_DIR:-~/.claude}/skills and /agents
sh ~/omskills/agentkit-lite/install.sh

# Project scope: ./.claude/skills and ./.claude/agents of the current directory
cd /path/to/project && sh ~/omskills/agentkit-lite/install.sh --project

# Remove only the symlinks that point into this bundle (add --project for project scope)
sh ~/omskills/agentkit-lite/install.sh --uninstall
```

Start a new Claude Code session after installing. The catalog lists the skills by their
directory names `ak-brainstorm` and `ak-plan`; `/ak:brainstorm` and `/ak:plan` both
resolve to them.

**Reading the reference files.** Claude Code follows the symlinks, so the skills'
`references/*.md` live at the clone path, outside the project. Claude Code asks for
permission before reading them; in non-interactive `claude -p` runs the reads are
denied and `ak:plan` falls back to a guessed plan format. Approve the reads, or give the
session access to the clone, for example `claude --add-dir ~/omskills/agentkit-lite`
(verified), or the matching `permissions.additionalDirectories` entry in
`settings.json` (not verified here).

### What works and what is reduced

| Dependency | Used by | Standalone behavior |
|------------|---------|---------------------|
| `ak plan create / archive / reindex`, `ak journal create` | plan | Skipped. Plan files are written directly under `plans/<YYMMDD-HHmm>-<slug>/`; they are the source of truth anyway. No `plans.db` index, no `ak plan` status toggles, no archive. |
| `ak config prefs resolve --json` (journal opt-out) | plan, brainstorm | Skipped; defaults apply. |
| `## Naming` section from `hooks/session-init.cjs` | plan, brainstorm `--report`, fullstack agent | Replaced by the standalone naming rule in each file. |
| `/ak:cook`, `/ak:scout`, `/ak:fix`, `/ak:journal`, `ak:diagram`, `ak:frontend-design` | plan, brainstorm | Never invoked. Scouting is done inline with file search; the journal step prints `journal skipped: ak:journal not installed`; the plan handoff names the `fullstack-developer` agent instead of `/ak:cook`. |
| `../ak-preview/references/html-*.md` | plan `--html`, brainstorm `--html` | Not bundled. `ak:plan --html` and `ak:brainstorm --html` stop with one line. |
| `planner`, `researcher`, `kongming`, `journal-writer` agents | plan modes, brainstorm `--advice`, fullstack escalation | Planning and research run inline. `ak:plan --ultra/--advice/--debate` and `ak:brainstorm --advice/--ultra/--html` stop with one line. The agent reports `Status: BLOCKED` instead of escalating to `kongming`. |
| `--wiki`, `--github` | plan | Stop with one line. |
| Hooks `plan-format-kanban.cjs`, `cook-after-plan-reminder.cjs` | plan | Not bundled; they only lint and remind. |

Expected to work without further changes: `ak:brainstorm` with no flag, `--ask`,
`--report`, `--yagni`; `ak:plan` modes `--fast`, `--hard`, `--deep`, `--parallel`,
`--two` (research and planning inline), `--tdd`, `--no-tasks`, `--yagni`, and the
`validate` and `red-team` subcommands. The standalone test exercised `ak:brainstorm`
with no flag, `ak:plan --fast --no-tasks`, `ak:plan --html`, and the agent; the rest
is untested.

The agent declares `model: sonnet` and grants `Task(kongming)`. With no `kongming`
agent installed, Claude Code still lists and runs `fullstack-developer`; the grant is
ignored.

### Name collision with a full AgentKit install

The skill names keep the `ak:` prefix and the directory names `ak-brainstorm` and
`ak-plan`, the same as AgentKit's. Observed in Claude Code 2.1.283: when two skill
directories with the same name are visible, the catalog shows one entry and loads one
copy without any warning. In the test, a project-scope `.claude/skills/ak-plan` won
over an `--add-dir` copy in both arrangements; with the full kit in the project,
`/ak:plan --html` ran the kit version instead of stopping. Precedence between user
scope and project scope was not tested. Before installing full AgentKit on a machine
that has this bundle, run `install.sh --uninstall` (and `--uninstall --project` where
it was installed per project).

## 3. Updating from upstream

Rule: never edit files under `skills/` or `agents/` by hand. Take fresh upstream copies,
run `patch.sh`, and diff, so the next update stays repeatable. Run on a machine with an
AgentKit install; `SRC` is that install's `.claude` directory.

### Step 1. Copy the upstream files into a scratch directory

```bash
cd skills/agentkit-lite
SRC=/path/to/agentkit-project/.claude
ak --version
grep -m1 '^  version:' "$SRC/skills/ak-brainstorm/SKILL.md" "$SRC/skills/ak-plan/SKILL.md"

TMP=$(mktemp -d)
mkdir -p "$TMP/skills" "$TMP/agents"
cp -R "$SRC/skills/ak-brainstorm" "$SRC/skills/ak-plan" "$TMP/skills/"
cp "$SRC/agents/fullstack-developer.md" "$TMP/agents/"
find "$TMP" -name .DS_Store -delete
```

### Step 2. See what changed upstream

```bash
(cd "$TMP" && find skills agents -type f | LC_ALL=C sort | xargs shasum -a 256) > "$TMP/before.sha"
awk '/^### Before patch/{f=1} /^### After patch/{f=0} f && /^[0-9a-f]{64}  /' UPSTREAM.md \
  | diff - "$TMP/before.sha" && echo "upstream unchanged"
```

If it prints `upstream unchanged`, stop here. Otherwise the diff lists added, removed,
and changed files. Review each changed file with `diff <path> "$TMP/<path>"`; for the
five patched files that diff also shows the patch additions, which is expected.

### Step 3. Patch and replace

```bash
bash patch.sh "$TMP"
```

On `anchor found 0 times` the upstream wording moved: open the named file in `$TMP`,
update that anchor and its replacement in `patch.sh`, and start again from Step 1 with
a new `$TMP` (the script refuses a half-patched tree). Then replace the bundle copy:

```bash
rm -r skills agents
cp -R "$TMP/skills" "$TMP/agents" .
```

### Step 4. Check

```bash
# 31 skill files (8 + 23) unless upstream added or removed files
find skills -type f | wc -l

# A fresh copy plus patch.sh reproduces the bundle exactly (prints nothing)
FRESH=$(mktemp -d); mkdir -p "$FRESH/skills" "$FRESH/agents"
cp -R "$SRC/skills/ak-brainstorm" "$SRC/skills/ak-plan" "$FRESH/skills/"
cp "$SRC/agents/fullstack-developer.md" "$FRESH/agents/"
find "$FRESH" -name .DS_Store -delete
bash patch.sh "$FRESH" > /dev/null && diff -r "$FRESH/skills" skills && diff -r "$FRESH/agents" agents

# One Standalone mode section per skill, and the ak-preview link is marked
grep -c 'Standalone mode' skills/ak-plan/SKILL.md skills/ak-brainstorm/SKILL.md
grep -n 'ak-preview' skills/ak-plan/SKILL.md

# Every ak-brainstorm reference that ak-plan points at exists
grep -oh 'ak-brainstorm/references/[a-z0-9-]*\.md' skills/ak-plan/SKILL.md skills/ak-plan/references/*.md \
  | sort -u | while read -r l; do [ -f "skills/$l" ] || echo "MISSING: $l"; done

# Installer syntax
sh -n install.sh && bash -n patch.sh
```

### Step 5. Record

- Update the version and date columns in section 1 and the `ak --version` line in
  `UPSTREAM.md`.
- Regenerate both checksum lists in `UPSTREAM.md`: "Before patch" from
  `$TMP/before.sha`, "After patch" from the files that differ after Step 3.
- Remove the scratch directories: `rm -rf "$TMP" "$FRESH"`.
