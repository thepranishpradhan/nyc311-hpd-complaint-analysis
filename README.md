# NYC 311 HPD Complaint Resolution Analysis

An independent business-analyst portfolio project examining resolution times for NYC Housing Preservation & Development (HPD) complaints, using a 405-ticket sample pulled from NYC Open Data. The project moves through cleaning, SQL analysis, requirements documentation, a current-state process map, a data-supported recommendation, and an interactive Power BI dashboard - the same sequence a real BA engagement would follow, applied here to public data as a self-directed exercise.

**Portfolio disclosure:** this project uses publicly available NYC Open Data and was not commissioned, sponsored, or reviewed by NYC HPD or any other organization. Stakeholder roles, decision rights, and recommendations throughout are illustrative.

## The sample

405 closed HPD complaint tickets, created within narrow, same-hour extraction windows across April 1–3, 2024 (135 tickets per day, all created between 10:00–10:59 AM). This is a bounded sample chosen to demonstrate the analytical method, not a representative full-day or full-year view of HPD complaint volume - that constraint is documented explicitly in the BRD and carried through every downstream document.

## Repo structure

```
data/           raw and cleaned CSV files
notebooks/      Phase 1 cleaning notebook + Phase 2 Postgres loading script
sql/            Phase 3 business-question queries
docs/           BRD, SQL reference guide, and the Phase 5 recommendation memo
dashboard/      Power BI data file, build guide, and DAX reference guide
```

## Phase 1 - Data cleaning (`notebooks/nyc311_data_cleaning.ipynb`)

Loads the raw sample, applies the BRD's "valid closed record" rule, flags exact-duplicate tickets for a later sensitivity check, and adds the 30-day analytical-threshold breach flag used throughout the rest of the project. Produces `data/nyc311_hpd_complaints_cleaned.csv` (405 rows, 14 columns) from `data/nyc311_hpd_complaints_v2.csv` (the raw 7-column export).

## Phase 2 - Load into PostgreSQL (`notebooks/load_to_postgres.py`)

Pushes the cleaned CSV into a local Postgres table (`hpd_complaints`) so the SQL analysis has something to query. Credentials are read from environment variables, not hardcoded - see the comment at the top of the script for the exact variables to set before running it.

## Phase 3 - SQL analysis (`sql/nyc311_analysis.sql`)

Five queries, each building on the concepts of the last:

- **Q1** - mean, median, and 90th-percentile resolution time by category
- **Q2** - percentage of tickets breaching the 30-day analytical threshold, by category
- **Q3** - categories ranked by total excess days above threshold (categories with fewer than 10 tickets excluded)
- **Q4** - a sensitivity check re-running Q1 with the 37 duplicate-flagged rows excluded, confirming the category ranking doesn't change materially
- **Q5** - the 5 longest-duration tickets, flagged for exploratory review without causal claims

`docs/NYC311_SQL_Cheat_Sheet_final.docx` and `docs/NYC311_Full_Coding_Guide_v2.docx` walk through the reasoning behind each query and code block in more depth.

## Business Requirements Document (`docs/NYC311_BRD_Restructured_v3_final.docx`)

Defines the business context, stakeholder analysis, scope, seven business requirements (BR-001 through BR-007), assumptions, constraints, and success metrics underlying every phase of this project.

## Phase 4 - Current-state process map

A swimlane diagram of the ticket lifecycle across NYC311 intake, HPD inspection, and landlord/repair lanes, distinguishing timestamped process stages from stages inferred but not directly recorded in the data (per BR-004). *Not yet added to this repo - add the exported diagram image here once finalized.*

## Phase 5 - Recommendation (`docs/NYC311_Phase5_Recommendation_Memo.docx`)

Two categories - GENERAL and PAINT/PLASTER - account for 933 of the sample's 2,226.74 total excess days, the largest combined burden of any category pairing. The memo proposes a limited one-quarter prioritization pilot for these two categories, paired with a staged rollout of stage-level timestamp tracking, with conservative/base/optimistic scenarios for excess-day reduction and explicit go/no-go success thresholds.

## Phase 6 - Power BI dashboard (`dashboard/`)

`NYC311_Dashboard_Data.xlsx` contains the fact table plus two pre-computed reference tabs for cross-checking dashboard numbers. `NYC311_PowerBI_Build_Guide_v3.docx` walks through loading the data and building every visual; `NYC311_PowerBI_DAX_Guide.docx` explains each DAX measure function by function. The dashboard covers BR-001 through BR-003 and BR-007 across two report pages, with complaint-type and resolution-time slicers (BR-006) and a sensitivity toggle to exclude duplicate-flagged rows interactively. *The finished `.pbix` file isn't yet in this repo - add it here once built, or link to a published Power BI Service report if you publish one.*

## Key findings

Resolution times range from same-day closure to roughly 150 days, with a long-tailed distribution - median and percentile measures are used throughout rather than relying on the average alone. PAINT/PLASTER and GENERAL are the two categories driving the largest cumulative delay; APPLIANCE has the highest breach rate proportionally despite lower volume. A sensitivity check confirms these rankings hold whether or not the 37 duplicate-flagged rows are included.

## Limitations

This is a bounded, narrow-window sample, not a representative view of HPD's full complaint volume. No staffing, cost, or internal process-stage data is available, so recommendations are directional and scenario-based rather than causal. All of this is documented in full in the BRD's Constraints section.
