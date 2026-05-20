---
name: ai-usage-report
description: Generates a comprehensive AI usage report including daily costs, model breakdown, and session-based work analysis. Uses `agentsview` for data and scans session files to categorize activity. Use when the user asks for usage statistics, cost analysis, or what they have been working on.
---

# AI Usage Report Skill

This skill provides tools to analyze and report on AI usage, cost, and activity across different agent frameworks (Pi, OpenCode, Cursor, etc.).

## Prerequisites

- `agentsview` must be installed and in the PATH.
- Access to session storage directories (configured in `agentsview`).

## Core Command

Generate a report for a specific time window:

```bash
agentsview usage daily --since <YYYY-MM-DD> --breakdown
```

## Session Analysis Strategy

### Step 1 — Get cost data

```bash
agentsview usage daily --since <YYYY-MM-DD> --breakdown
```

### Step 2 — List all sessions for the period

```bash
agentsview session list --date-from <YYYY-MM-DD> --date-to <YYYY-MM-DD> --include-automated --include-children --limit 500 2>&1 \
  | awk '{print $4, $1, $2, $3}' | sort
```

Sort by timestamp so sessions are grouped by date. Use `--cursor <token>` to paginate if the output says "More results".

### Step 3 — Sample session content per day

Fetch **all sessions** for the period, pulling the first 3 messages from each. Batch 10 sessions per shell loop to avoid excessive round-trips:

```bash
for id in "<id1>" "<id2>" ... "<id10>"; do
  echo "=== $id ==="
  agentsview session messages $id --limit 3 2>&1 | head -20
  echo ""
done
```

Do **not** skip sessions that start with `[search-mode]`, `[analyze-mode]`, or `<!-- OMO_INTERNAL_INITIATOR -->`. These automated subagent sessions often contain the actual task in the body of the first message after the mode header — and skipping them causes significant gaps in the day-by-day narrative. Read all sessions and group automated ones under the interactive session that spawned them.

Run batches in parallel where the shell allows (fire multiple loops simultaneously). Aim to cover every session ID returned in Step 2.

### Step 4 — Build the day-by-day narrative

For **every active day** in the period, write a section that includes:
- The date and total cost
- A short **Theme** label (1-5 words)
- Bullet points describing what was worked on, grounded in the actual session prompts
- Group automated subagent sessions under the interactive task that triggered them

Group closely related sessions into a single bullet rather than listing each one. Automated sessions (search-mode, analyze-mode, OMO_INTERNAL_INITIATOR) are usually background research for an interactive session happening at the same time — attribute them to that parent task rather than listing them separately.

## Example Report Structure

A complete report must include all of the following sections:

1. **Total Cost Summary** — spend, active days, token totals.
2. **Daily Cost Table** — Date, Cost, Models used.
3. **Model Breakdown** — estimated cost share and role per model.
4. **Top Projects by Activity**
5. **Week-by-Week Spend**
6. **Cost Efficiency Notes** — observations on model usage patterns.
7. **Day-by-Day Work Summary** — one section per active day, with theme + bullet points derived from sampled session prompts. This is the most important section and must not be omitted.
8. **Activity Themes Over the Period** — summary table of recurring themes and their date ranges.

## Troubleshooting

- If `agentsview usage` shows $0.00 unexpectedly, ensure your `agentsview` pricing is synced or use `--offline` for fallback pricing.
- If sessions are missing, run `agentsview sync` to update the local database.
