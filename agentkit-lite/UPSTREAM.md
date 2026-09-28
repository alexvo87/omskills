# agentkit-lite: upstream provenance

Extracted on 2026-09-28 from the AgentKit install of the project at
`/Users/tuanvta/project/tuanvta`, where `ak --version` printed `ak 2.18.1`.

| Component | Source path | Upstream version | Files |
|-----------|-------------|------------------|-------|
| `skills/ak-brainstorm/` | `/Users/tuanvta/project/tuanvta/.claude/skills/ak-brainstorm/` | `metadata.version` 2.8.2 | 8 |
| `skills/ak-plan/` | `/Users/tuanvta/project/tuanvta/.claude/skills/ak-plan/` | `metadata.version` 2.2.2 | 23 |
| `agents/fullstack-developer.md` | `/Users/tuanvta/project/tuanvta/.claude/agents/fullstack-developer.md` | shipped with ak 2.18.1 (the agent has no version field) | 1 (6621 bytes, sha256 `a7d6a328f0fd6836df00d05d2f47e6fc8fd5dce911f1a6c7815916cde1e0cb39`) |

## License

The kit ships no LICENSE file next to these skills or the agent. The `license: MIT`
field in the frontmatter of `skills/ak-brainstorm/SKILL.md` and
`skills/ak-plan/SKILL.md` is the license statement for the copied files.

## Checksums

Computed from the bundle root with
`find skills agents -type f | LC_ALL=C sort | xargs shasum -a 256`.

### Before patch

Byte-identical to the source paths above.

```
a7d6a328f0fd6836df00d05d2f47e6fc8fd5dce911f1a6c7815916cde1e0cb39  agents/fullstack-developer.md
2f48a941d7eca99197547b6a51f9a1857981f39ad07c3ac563ba99f54e637386  skills/ak-brainstorm/SKILL.md
3e0f6538acf1bd6596d7e9d7ea87fb4d67c396e493d08328834a79c87bb0dba0  skills/ak-brainstorm/references/advice-mode.md
ec3fe48404259ffd8e78ca35525da349af701ec76820f979432f1d1c9ee9bbe4  skills/ak-brainstorm/references/advisory-supervision.md
be60fc8ef30d1b2c150a0c28ddf47440c868a9d962a8f7a3bfeea4f5ea31a23b  skills/ak-brainstorm/references/brainstorm-ultra-mode.md
f8d63bfc7b5eeb35451545f8c1fc3af07bd17640aae0d86514f2f23b26eb93f0  skills/ak-brainstorm/references/html-output-mode.md
b475e1118c6ded6a975fa882421649a4aad77673befb8c28d232f54fcb6555a1  skills/ak-brainstorm/references/interview-mode.md
a4ce6cf742f8cb21b1cb4a6b8e11aa9c80d4fd107a242110bacd0bb4b1b0afea  skills/ak-brainstorm/references/report-output-mode.md
c93793ec8a0ab8d6959e030ba6c89693b9b779525ecb46bafc82ad7b8b0f0246  skills/ak-brainstorm/references/ultra-verifier-mode.md
08cb5329e7dca2367b486e965cd5278b0c252b1da2b332243dfdc2a9566771f3  skills/ak-plan/SKILL.md
294db785c7b73b3461e47a8ad14faeb4616d8138b65cc3a6f4273cb507b1e739  skills/ak-plan/references/advice-handover-plan.md
d5917f197bd88810ae1527a17bda31eb0d353b6b28a4d9bb51572e307834bbea  skills/ak-plan/references/archive-workflow.md
24aacf22c7ec193ea6e54086311e44ee1d7a037f75e220253b6e5d64ec289d7b  skills/ak-plan/references/cli-integration.md
3ed0416058ef338cc98cef1feca9aa1765a925d6b5eea96e65594981e2810573  skills/ak-plan/references/codebase-understanding.md
cf34773cc60789c7e0877b1826147f48b470c9529a9fe5fe660feb3b35fb35c8  skills/ak-plan/references/debate-mode.md
b7a6490b84b6a7e6d114cfe6463814a6ff9f60ce540aa28d9af67eb9fec97f61  skills/ak-plan/references/github-wiki-publish.md
c18e09fb2c4a4c33374e857a9eca75b20772e2e5ffdfe0ed2b90658411bb0d75  skills/ak-plan/references/html-output.md
62a7bff65a40ee03cf93633c41f2f079bec7bfb6bdc7a5a4fa8826af325491a7  skills/ak-plan/references/output-standards.md
563f7320f7fd624eb62e642e7179e4d0db250e63cb793b1ece958ee69ce911e6  skills/ak-plan/references/plan-organization.md
545c942f158960d6f57f87b4765ad129c2db23f8d18f71dea67694e7fbde7460  skills/ak-plan/references/planning-rules.md
a70bdbd87bb7845e3a412e7e9e34b1d1989375d3a8ac0d9e891c8bae3f394442  skills/ak-plan/references/post-plan-handoff.md
a91c96bd279d9f291f302c25f3b688b7315a8ea0e0a7eba6ed61b37b7238f422  skills/ak-plan/references/red-team-personas.md
5d6237ce87840a6dee7dcfc3ec3c07f7f6e34457f041fb5c98aac5c988bd87f9  skills/ak-plan/references/red-team-workflow.md
86d250efe92b74d7ee51a66bf219d867663f5e9bb258f4d87c03587d762bca04  skills/ak-plan/references/research-phase.md
754426b0395043dad301525deeb2eae3f6e9d0186c1c976f5cb2859ce07c5d7d  skills/ak-plan/references/scope-challenge.md
36b1f57deac111939e1e1215a093fc71cc693561303c82c0f941d7ee574a1860  skills/ak-plan/references/solution-design.md
9daf5d7b9da405b797a9561d6bcbeaa82447b46ac0adb1ef55194ecc3081d058  skills/ak-plan/references/task-management.md
e72119ad9689823ea104f62980404a2f78be4b81e89efb16b2ff3c73961b5197  skills/ak-plan/references/ultra-mode.md
d868ac6e03e395857186f801127b2f4b47c8aaabf5326fc2a25982804a0c113c  skills/ak-plan/references/validate-question-framework.md
0601b271af6f0e4df612c2c72d80fa91fef157ced931e8c510d96592a40815d9  skills/ak-plan/references/validate-workflow.md
5cdf4d92e655bb1ea31afff352ab13a4a393411c22b3c5d3717a7c4e1054aa38  skills/ak-plan/references/verification-roles.md
a2618fb4c55ae7c995867515151961dc8e7b3bd37098687838eec19f4416c08b  skills/ak-plan/references/workflow-modes.md
```

### After patch

State of the committed tree after `patch.sh` ran once. Only these five files differ
from the list above; every other file keeps its "Before patch" checksum.

```
e886f4d1ca970dec29d23506e211b566807355f017f3ce93f5a7ac3c400b85a1  agents/fullstack-developer.md
409ef9d08b9e27ff7f4c59beb072d80dad8f8af9ae67c80eaf405cdeadabb1cb  skills/ak-brainstorm/SKILL.md
cad4e950c3eb67a90e7f23fcf437949ac862de2835e67a5130babb20d2f67a61  skills/ak-brainstorm/references/report-output-mode.md
5c6cbf6313c8c8336c2383f321c6a59147a5ff0d247d6ff90672a8e9aef83512  skills/ak-plan/SKILL.md
f3c693851d70eb39e0bbd1e70128147d365a9ec9673b7aa7c17725b6d09581a6  skills/ak-plan/references/plan-organization.md
```
