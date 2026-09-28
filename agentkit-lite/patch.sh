#!/usr/bin/env bash
# Apply the agentkit-lite portability patches to a fresh copy of the upstream files.
#
# Usage: patch.sh <bundle-root>
#   <bundle-root> contains skills/ak-brainstorm/, skills/ak-plan/, and
#   agents/fullstack-developer.md copied byte for byte from an AgentKit install.
#
# Run it exactly once on a fresh copy. Every patch is an anchored literal string
# replacement. Before anything is written, each anchor must occur exactly once and
# its inserted text must be absent; otherwise the script exits 1 naming the file and
# the anchor, and no file is changed. A second run on a patched tree therefore fails
# on the first anchor, which the first run consumed.
set -euo pipefail

if [ "$#" -ne 1 ] || [ ! -d "$1" ]; then
  echo "usage: $0 <bundle-root>" >&2
  exit 2
fi

python3 - "$1" <<'PY'
import os
import sys

root = sys.argv[1]

UNSUPPORTED_LINE = "`<flag> is not supported in the agentkit-lite standalone bundle`"

PLAN_STANDALONE = """

## Standalone mode

This section applies when the skill runs from the `agentkit-lite` bundle, without
the AgentKit CLI, its hooks, or the other kit skills and agents. Where it conflicts
with another section or reference of this skill, this section wins.

- **Naming:** when no `## Naming` section was injected into the session, the plan
  directory is `plans/<YYMMDD-HHmm>-<kebab-slug>/` under the project root (the git
  root, else the working directory), and reports go to
  `plans/reports/<type>-<YYMMDD-HHmm>-<slug>.md`. Take the stamp from
  `date +%y%m%d-%H%M`.
- **No `ak` CLI:** when `command -v ak` finds nothing, skip every `ak plan` and
  `ak journal` call, including their `--help`, and create `plan.md` and each
  `phase-NN-<name>.md` directly with the file-write capability. Use the `plan.md`
  frontmatter from `references/output-standards.md` and the canonical phase
  template in `references/cli-integration.md`. Direct Markdown scaffolding is the
  supported path here; the CLI-only rule in `references/plan-organization.md` does
  not apply.
- **Journal:** when `/ak:journal` is not in the skill catalog, skip the
  `ak config prefs resolve` call, print `journal skipped: ak:journal not installed`,
  and stop.
- **Agents:** when the `planner` agent is absent, perform the planning inline. Do
  the same for `researcher` work.
- **Sibling skills:** never invoke an absent skill (`/ak:cook`, `/ak:scout`,
  `/ak:journal`, `ak:diagram`, `ak:frontend-design`). Do the scout step inline with
  native file search and skip the rest. When `/ak:cook` is absent, the handoff names
  the bundled `fullstack-developer` agent as the way to execute a phase.
- **Unsupported flags:** `--html`, `--wiki`, `--github`, `--ultra`, `--advice`, and
  `--debate` are not supported in the standalone bundle. When one is passed, stop
  before reading references or writing any file and print one line:
  """ + UNSUPPORTED_LINE + """, with the flag filled in.
"""

BRAINSTORM_STANDALONE = """

## Standalone mode

This section applies when the skill runs from the `agentkit-lite` bundle, without
the AgentKit CLI, its hooks, or the other kit skills and agents. Where it conflicts
with another section or reference of this skill, this section wins.

- Never invoke the skills and agents the bundle does not ship: `/ak:cook`,
  `/ak:scout`, `/ak:fix`, `/ak:advise`, and the `kongming` agent, even where the
  flow above names them. `/ak:plan` is bundled and stays the planning handoff; for
  a diagnosed bug, report the recommended fix instead of handing off to `/ak:fix`.
- Do the scout step inline with native file search and read tools.
- `--advice`, `--ultra`, and `--html` are not supported in the standalone bundle. When one is
  passed, stop before loading its reference and print one line:
  """ + UNSUPPORTED_LINE + """, with the flag filled in.
- When `command -v ak` finds nothing, skip every `ak config prefs resolve` call and
  use the defaults.
"""

NAMING_FALLBACK_PLAN = (
    "\nWithout an injected `## Naming` section, or when the `ak` CLI is absent, follow\n"
    "`## Standalone mode` in this skill's `SKILL.md`; it sets the plan directory and\n"
    "overrides the CLI-only rule under \"Plan Creation Via CLI\" below."
)

NAMING_FALLBACK_BRAINSTORM = (
    "\n  Without an injected `## Naming` section, use\n"
    "  `plans/reports/brainstorm-<YYMMDD-HHmm>-<slug>.md` under the project root,\n"
    "  the same standalone rule the bundled `ak-plan` skill applies."
)

PATCHES = [
    # (file relative to bundle root, anchor, replacement)
    (
        "skills/ak-plan/SKILL.md",
        "`../ak-preview/references/html-skill-composition.md` (activates",
        "`../ak-preview/references/html-skill-composition.md` (not bundled in standalone mode) (activates",
    ),
    (
        "skills/ak-plan/SKILL.md",
        "- `references/advice-handover-plan.md` — Handover plan contract for downstream executor models under --advice\n",
        "- `references/advice-handover-plan.md` — Handover plan contract for downstream executor models under --advice\n"
        + PLAN_STANDALONE,
    ),
    (
        "skills/ak-plan/references/plan-organization.md",
        "Use `Plan dir:` from `## Naming` section injected by hooks. This is the full computed path.",
        "Use `Plan dir:` from `## Naming` section injected by hooks. This is the full computed path."
        + NAMING_FALLBACK_PLAN,
    ),
    (
        "skills/ak-brainstorm/SKILL.md",
        "**Bug path:** opening intent frame -> scout and debug -> solution brainstorm when\nneeded -> `/ak:fix`.\n",
        "**Bug path:** opening intent frame -> scout and debug -> solution brainstorm when\nneeded -> `/ak:fix`.\n"
        + BRAINSTORM_STANDALONE,
    ),
    (
        "skills/ak-brainstorm/references/report-output-mode.md",
        "— or the injected `Report:` path from the `## Naming` section when\n  the runtime provides one.",
        "— or the injected `Report:` path from the `## Naming` section when\n  the runtime provides one."
        + NAMING_FALLBACK_BRAINSTORM,
    ),
    (
        "agents/fullstack-developer.md",
        "It advises only; you own the implementation.",
        "It advises only; you own the implementation. When the `kongming` agent is not"
        " available, stop and report `Status: BLOCKED` with the specific question instead.",
    ),
    (
        "agents/fullstack-developer.md",
        "Use the naming pattern from the `## Naming` section injected by hooks. The pattern includes full path and computed date.",
        "Use the naming pattern from the `## Naming` section injected by hooks. The pattern includes full path and computed date."
        "\n\nWhen no `## Naming` section was injected, always write the Phase Implementation"
        " Report from \"Output Format\" to `plans/reports/fullstack-developer-<YYMMDD-HHmm>-<slug>.md`"
        " under the project root, taking the stamp from `date +%y%m%d-%H%M`, even when the caller"
        " only asks for a reply. Return the same report in the reply, give the report path, and end"
        " the reply with one line: `Status: DONE`, `Status: PARTIAL`, or `Status: BLOCKED`.",
    ),
]


def fail(path, anchor, reason):
    shown = anchor if len(anchor) <= 100 else anchor[:97] + "..."
    sys.stderr.write("patch.sh: %s: %s\n  anchor: %r\n" % (path, reason, shown))
    sys.exit(1)


contents = {}
for rel, anchor, replacement in PATCHES:
    path = os.path.join(root, rel)
    if rel not in contents:
        if not os.path.isfile(path):
            fail(rel, anchor, "file not found")
        with open(path, "r", encoding="utf-8", newline="") as fh:
            contents[rel] = fh.read()
    text = contents[rel]
    count = text.count(anchor)
    if count != 1:
        fail(rel, anchor, "anchor found %d times, expected exactly 1" % count)
    inserted = replacement.replace(anchor, "", 1) if anchor in replacement else replacement
    if inserted and inserted in text:
        fail(rel, anchor, "patch text already present; run on a fresh copy")
    contents[rel] = text.replace(anchor, replacement, 1)

for rel, text in contents.items():
    with open(os.path.join(root, rel), "w", encoding="utf-8", newline="") as fh:
        fh.write(text)
    print("patched %s" % rel)
PY
