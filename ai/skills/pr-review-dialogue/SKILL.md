---
name: pr-review-dialogue
description: Independent second-AI review of a freshly created GitHub PR followed by an author-reviewer dialogue. Use after creating a PR, when asked to review the PR we just created or to get a second opinion. Local only, never posts to GitHub.
---

Run an adversarial review of the current PR by spawning a fresh `pr-reviewer` subagent, then debate its findings as the PR author. The review, the debate, and its resolutions are recorded locally. Nothing is ever posted to GitHub.

## Hard rules

- You are the PR author. The `pr-reviewer` subagent is the reviewer. Keep the roles separate.
- `gh` is read-only in this workflow. Never run `gh pr comment`, `gh pr review`, `gh pr edit`, or any `gh api` mutation.
- Never commit or push without an explicit yes from the user in this session, even if earlier permission was given for other work.
- The dialogue record lives in `~/.claude/pr-reviews/`, never inside the PR's repository.

## Workflow

### 1. Locate the PR

Use the PR number if the user gave one; otherwise resolve the current branch with `gh pr view --json number,title,url,headRefName,baseRefName,isDraft`. Capture the repo with `gh repo view --json nameWithOwner`. If no PR resolves, stop: tell the user, show `gh pr list` output, and ask which PR to review. If the checked-out branch is not the PR head branch, stop and say which branch or repo to switch to; the review needs local file access to the code under review.

### 2. Preflight

Run `git status --porcelain`. If the tree is dirty, ask the user whether to continue anyway, stash first, or abort; never stash on your own. Measure the diff with `gh pr diff <n> | wc -l`; above roughly 3000 lines, use large-diff mode: the spawn prompt adds a hint to prioritize highest-risk files and correctness over style, and the reviewer must state its coverage limits in the verdict, which the final report repeats.

### 3. Spawn the reviewer with clean context

Launch the `pr-reviewer` subagent (Agent tool, synchronous). The spawn prompt contains ONLY the repo's absolute path, the PR number, and nameWithOwner, plus the large-diff hint when applicable. Do not include the diff, the PR body, or any characterization of the change. The reviewer fetches everything itself; an author-curated summary would defeat the independent review.

### 4. Record round 1

Create `~/.claude/pr-reviews/` if needed. Instantiate `[skill-root]/references/review-file-template.md` as `~/.claude/pr-reviews/<owner>-<repo>-pr<number>.md` (slashes in nameWithOwner become hyphens). If the file already exists from an earlier run, append a new dated `## Session` block instead of overwriting. Record the reviewer's findings verbatim.

If the reviewer's output does not match the output contract, ask once via SendMessage to restate in the required format; if still malformed, save what exists to the review file, stop, and tell the user.

### 5. Dialogue, capped at 3 rounds

1. For each open finding, independently verify the claim against the actual code before responding. Draft exactly one response per finding: `ACCEPT F<i>: <planned fix>` or `REBUT F<i>: <evidence>`. Rebuttals must cite code, not preference.
2. Append your responses to the review file, then send them to the reviewer in one SendMessage.
3. The reviewer answers each rebutted finding with `WITHDRAWN` or `SUSTAINED`. Record verbatim.
4. Resolve state: ACCEPT resolves as accepted; REBUT plus WITHDRAWN resolves as rebutted; REBUT plus SUSTAINED stays open.
5. No open findings: exit the loop. Open findings after round 3: mark each DISPUTED with both final positions captured. Disputed findings are never silently dropped and never unilaterally fixed; they go to the user.
6. Next round, argue only still-open findings and bring new evidence; restating a prior argument is not a round.

If SendMessage is unavailable, fall back to spawning a fresh `pr-reviewer` per round with the review file path as its memory, and note in the record that rounds were stateless.

### 6. Apply accepted fixes

Fix each accepted finding in the repo. Run the narrowest cheap check available (lint, typecheck, or the touched test file). If a fix breaks the check and the repair is not trivial, downgrade that finding to disputed with a note. Fill in the Resolutions table and Verdict in the review file.

### 7. Report and permission gate

Show the user the condensed report only:

- One-line verdict: Approve, Approve after fixes, or Needs your decision.
- Per finding: ID, severity, one-line summary, and resolution (Accepted, fixed in file; Rebutted, winning argument in one line; Disputed, both positions in one line each).
- The path to the full dialogue file.

If the reviewer found nothing, this is the fast path: short review file, verdict Approve, no fixes, no gate. Otherwise ask one explicit question: whether to commit and push the applied fixes. Make clear nothing is committed yet. Any answer that is not a clear yes leaves the working tree exactly as it is. Present disputed findings for a ruling; a ruling can convert one into an accepted fix, which then joins the same gate.
