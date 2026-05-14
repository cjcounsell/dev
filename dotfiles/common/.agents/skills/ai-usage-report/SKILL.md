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

To find out what was worked on during specific days:

1. **List sessions** for the target period:

   ```bash
   agentsview session list --date-from <YYYY-MM-DD> --date-to <YYYY-MM-DD> --include-automated --include-children --limit 100
   ```

2. **Categorize by project**:
   `agentsview` lists the project for each session. Group sessions by project to identify main work areas.

3. **Sample session content**:
   For the most active or representative sessions, pull the first few messages to identify the task:

   ```bash
   agentsview session messages <session_id> --limit 5
   ```

4. **Detailed model breakdown**:
   Check which models contributed most to the cost:
   ```bash
   agentsview usage daily --since <YYYY-MM-DD> --until <YYYY-MM-DD> --breakdown
   ```

## Example Report Structure

A good usage report should include:

- **Daily Cost Table**: Date, Input/Output tokens, Cost, and Models used.
- **Top Projects**: Which projects saw the most activity.
- **Activity Themes**: Qualitative summary of what was worked on (e.g., "Architecture planning in Project X", "Bug fixing in Project Y").
- **Cost Efficiency**: Observations on model usage patterns (e.g., "Shift to low-cost models for scouting").

## Troubleshooting

- If `agentsview usage` shows $0.00 unexpectedly, ensure your `agentsview` pricing is synced or use `--offline` for fallback pricing.
- If sessions are missing, run `agentsview sync` to update the local database.
