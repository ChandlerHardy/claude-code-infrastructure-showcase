---
name: ralph-local
description: Run an iterative AI development loop using isolated subagents. Use when user says ralph, ralph loop, iterate, loop, run ralph, start ralph, or wants to repeatedly run an AI agent against a task until tests pass or a goal is met. Combines the reliability of the shell ralph loop with the convenience of staying in Claude Code.
---

# Ralph Local — Iterative Subagent Loop

## Purpose

Run an isolated, iterative development loop inside Claude Code. Each iteration launches a fresh `general-purpose` Task subagent that works on the task, commits when done, and returns a summary. The parent session checks completion between iterations and reports progress.

This replaces both:
- The marketplace `ralph-loop` plugin (buggy: unbound vars, XML tag issues, fragile YAML parsing)
- The shell `ralph.sh` script (reliable but requires leaving Claude Code)

## When to Use

- User wants to iterate on a task until tests pass
- User wants to run a prompt repeatedly with AI fixing its own output
- User says "ralph", "ralph loop", "iterate on this", "loop until done"
- User has a PROMPT.md or describes a task to iterate on

## Parameters to Gather

Before starting, determine these from the user (ask if not provided):

| Parameter | Default | Description |
|-----------|---------|-------------|
| **Prompt source** | `PROMPT.md` in cwd | File path or inline text describing the task |
| **Max iterations** | `5` | Safety cap on loop iterations |
| **Test command** | `npm test` | Command to verify completion between iterations |
| **Working directory** | Current cwd | Where the subagent should work |

## Execution Steps

### 1. Read the Prompt

Read the prompt source (file or use inline text). If a file path is given, read it. If no PROMPT.md exists and no inline prompt was given, ask the user for the task description.

### 2. Run the Loop

For each iteration (1 through max_iterations):

**a) Launch a Task subagent** with `subagent_type: "general-purpose"` and this prompt template:

```
You are iteration {N} of {MAX} in a Ralph Loop working in {WORKING_DIR}.

## Your Task

{PROMPT_CONTENTS}

## Rules

1. First, check `git log --oneline -10` to see what previous iterations have done.
2. Run the verification command to see current state: {TEST_COMMAND}
3. Analyze failures or remaining work. Fix issues, write code, add tests.
4. Run the verification command again to confirm your changes work.
5. If all tests pass and the task is complete, commit your work:
   - Stage specific files (not `git add .`)
   - Write a clear commit message describing what you did
   - End your response with: RALPH_STATUS: COMPLETE
6. If tests still fail or work remains, commit partial progress and end with: RALPH_STATUS: INCOMPLETE
7. Do NOT use promise tags, XML markers, or special shell syntax.
8. Do NOT amend previous commits — always create new commits.
9. You have access to all tools including Task (to spawn sub-agents for exploration or research) and Skill (to invoke project skills). Use them when it makes sense — don't do everything manually.
```

**b) Check the subagent result.** After the subagent returns:

1. Check if the result contains `RALPH_STATUS: COMPLETE`
2. Run the test command in the parent session via Bash: `{TEST_COMMAND} 2>&1 | tail -30`
3. Check the exit code

**c) Report progress** to the user:

```
## Iteration {N}/{MAX}

**Status:** {COMPLETE or INCOMPLETE}
**Test result:** {PASS or FAIL — include last few lines}
**Summary:** {Brief summary from subagent output}
```

**d) Decide whether to continue:**

- If `RALPH_STATUS: COMPLETE` AND tests pass → Stop the loop, declare success
- If max iterations reached → Stop the loop, report final state
- Otherwise → Continue to next iteration

### 3. Final Report

After the loop ends, provide a summary:

```
## Ralph Loop Complete

**Iterations used:** {N} of {MAX}
**Final status:** {SUCCESS or MAX_ITERATIONS_REACHED}
**Test result:** {PASS or FAIL}
**Commits made:** (list from `git log --oneline` showing new commits)
```

## Important Notes

- **Subagent isolation**: Each iteration runs in a fresh Task subagent. This protects the parent session's context window from bloat.
- **No hooks or XML tags**: Completion is detected by checking the subagent output string and running the test command. No `<promise>` tags, no stop hooks, no YAML parsing.
- **Git-based handoff**: Iterations communicate through git commits. Each subagent checks `git log` to see what previous iterations did.
- **Parent session stays lean**: The parent only reads subagent summaries and test output, not the full work.
- **Always create new commits**: Never amend. Each iteration's work gets its own commit for traceability.

## Edge Cases

- **No test command**: If the user doesn't have tests, use `echo "no tests configured"` as the test command and rely on `RALPH_STATUS` from the subagent only.
- **Subagent fails to commit**: Check `git status` — if there are uncommitted changes, note this in the progress report and let the next iteration handle it.
- **All iterations used but not complete**: Report honestly. Show what was accomplished and what remains. Do not start extra iterations beyond the max.

## Example Usage

User: "Run ralph on PROMPT.md with max 3 iterations, test with `pytest`"

Response flow:
1. Read PROMPT.md
2. Iteration 1: Launch subagent → works on task → commits → tests fail
3. Report: "Iteration 1/3 — INCOMPLETE, 2 tests failing"
4. Iteration 2: Launch subagent → fixes failures → commits → tests pass
5. Report: "Iteration 2/3 — COMPLETE, all tests pass"
6. Final: "Ralph Loop Complete — 2 of 3 iterations, SUCCESS"
