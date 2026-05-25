---
name: feature-consensus
description: Runs PM-Designer multi-agent debate protocol to reach consensus
  on feature specs before implementation. Use before implementing any new screen
  or significant feature.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: feature-development
  rounds: "10"
  agents: pm-reviewer,designer-reviewer
---

# Feature Consensus Protocol

Before implementing any screen or significant feature, run this protocol to ensure both PM/UX and Design perspectives are aligned.

## When to Use

- Before implementing a new screen
- Before implementing a significant new feature
- Before refactoring an existing screen that changes behavior

## When NOT to Use

- Bug fixes that don't change behavior
- Code refactoring that doesn't change UX or UI
- Test additions for existing features
- Minor text or copy changes

## Protocol

### Step 1: Prepare the Feature Brief

Write a concise feature brief that includes:
- What is being built (1-2 sentences)
- Which screen/tab it belongs to
- Which personas it serves
- Any known constraints or open questions

### Step 2: Launch Facilitator Task Agent

Launch a `general` Task agent with the following prompt structure:

```
You are a debate facilitator. Your job is to run a PM-Designer consensus
protocol for the following feature:

[FEATURE BRIEF]

## Protocol

Run up to 10 rounds of debate between PM and Designer reviewers.

### Round 1: PM Review
Launch @pm-reviewer agent with the feature brief.
Collect their review and verdict.

### Round 2: Designer Review
Launch @designer-reviewer agent with the feature brief AND the PM's review.
Collect their review and verdict.

### Subsequent Rounds (if needed):
- If Designer OBJECTs: pass Designer's objections to @pm-reviewer for response
- If PM OBJECTs to Designer's suggestions: pass back to @designer-reviewer
- Continue alternating until both AGREE or 10 rounds reached

### Termination Conditions:
1. BOTH reviewers output AGREE → Consensus reached. Stop.
2. Round 10 reached → Return last state with "CONSENSUS_NOT_REACHED"
3. 3 consecutive rounds with no change in objections → Stalemate. Return "STALEMATE"

### Output Format (return to main context):

If consensus reached:
---
## Consensus: [Feature Name]
### Agreed Specification
[The final specification both reviewers agreed on]
### PM Concerns Addressed
[List of PM objections that were resolved]
### Designer Concerns Addressed
[List of Designer objections that were resolved]
---

If no consensus:
---
## No Consensus: [Feature Name]
### Current State
[Latest specification]
### Remaining PM Objections
[Unresolved PM concerns]
### Remaining Designer Objections
[Unresolved Designer concerns]
### Recommendation: ASK_USER
---
```

### Step 3: Handle the Result

**If consensus reached**: Use the agreed specification to implement the feature.

**If no consensus**: Present the remaining disagreements to the user and ask for a decision. Do NOT proceed with implementation until the user resolves the conflict.

## Example Usage

```
User: "Implement the home screen hero card"

Agent:
1. Loads this skill: skill({ name: "feature-consensus" })
2. Prepares brief: "Hero card on HomeTab showing today's #1 post with thumbnail, title, and recommend count. Casual viewer persona. P0 priority."
3. Launches facilitator Task agent
4. Receives consensus spec
5. Implements based on agreed spec
```

## Notes

- Each reviewer agent reads ONLY their own document (PRODUCT_PLAN.md or DESIGN.md)
- Each agent runs in a fresh independent context
- The facilitator passes outputs between agents but does not influence the debate
- The main implementation context receives ONLY the final result, not the debate history
- This protocol costs extra tokens but produces higher quality, more consistent features
