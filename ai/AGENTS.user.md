# User Preferences

## Writing style

- Never use the em dash character (—) in any text you produce: chat responses, code, comments, commit messages, PR titles and bodies, docs, and UI copy. Rewrite with a comma, colon, parentheses, or separate sentences instead.

## Module member ordering

- Applies only when the language imposes no ordering structure of its own (TypeScript is the main case). When the language or an established codebase convention enforces an order, follow that instead.
- Order module members by export status first: exported members before internal ones. Within each group, use usage order: callers above the helpers they call, things used first declared first.
- Keep a type next to the function that uses it when the type is exported or appears in the function's signature. Types used only internally go after all the functions.
- Test files follow the same ordering: test cases come first, in the order they run, and helper functions go after all the tests, at the end of the file. Fixture constants stay above the tests that use them when lint or evaluation order requires it.

## Code comments

- In JavaScript and TypeScript, never write a block comment or JSDoc on a single line (`/** like this */`). Open the comment on its own line, put the content on the lines between, and close it on its own line.
- CSS keeps its usual one-line `/* */` comments, since CSS has no line-comment syntax.

## Commit messages

@rules/commit-messages.md

## Pull request descriptions

- Write PR descriptions as prose paragraphs centered on the why: motivation, context, constraints, tradeoffs, and anything a reviewer needs that the diff cannot show. Summarize the what in a sentence or two; the diff already shows the details.
- Do not enumerate implementation details as bullet lists. Link lists (Linear, Figma, Depends on, Closes) and test tables are fine.
- Keep them short. A few tight paragraphs beat an exhaustive changelog.
- Calibration examples in getcircuit/web-apps: PRs 5000 and 4997 are good (why-first prose); PRs 4861 and 4896 are bad (implementation-detail bullet lists).
