# Case Study: Sorting A/B Test & Ranking Analysis

Data Analyst (Ranking & Sorting) take-home challenge by Sanyukta Suman.

- **Full write-up:** [Notion](https://app.notion.com/p/ABOUT-YOU-CASE-STUDY-3e849339968c80a09f50ea941a9903f3)
- **Dashboard:** [Looker Studio](https://datastudio.google.com/s/v6x_uWfkZrE)

## Summary

The new sort (`new_customer_sorting_v2`) increases conversion (+3.4%) and net revenue per visitor (+3.0%), but reduces contribution profit per visitor by 5.5% (95% CI: −€0.072 to −€0.017). The effect holds across all large markets and customer segments. 

**Recommendation: do not proceed with full rollout in the current form; iterate and re-test with profit as the primary metric.**

## Data

| Dataset | Grain | Rows |
|---|---|---|
| `ab_test_hiring_case` | Visitor × day × test group | 2,670,408 |
| `ranking_hiring_case` | Product × virtual category | 167,316 |

The two datasets share no join key and are analysed separately.

## Repository structure

```
sql/
├── 01_exploratory_analysis/      Data validation (read-only)
│   ├── 01_ab_test_grain_checks.sql
│   ├── 02_ab_test_assignment_checks.sql
│   ├── 03_ab_test_categorical_profile.sql
│   ├── 04_ab_test_numerical_profile.sql
│   └── 05_ranking_exploration.sql
├── 02_prep/             Tables used by the dashboard
│   ├── 01_prep_ab_test_hiring.sql
│   ├── 02_prep_ab_test_perc_diff.sql
│   ├── 03_prep_ab_test_daily.sql
│   └── 04_prep_ranking_category.sql
└── 03_analysis/         Significance test and segmentation (read-only)
    ├── 01_ab_test_significance.sql
    └── 02_ab_test_segmentation.sql
dashboard/
└── looker_link.md
```

## Run order

1. **Exploration:** run any file in `01_exploration`. These queries only read data.
2. **Prep:** run the files in `02_prep` in numbered order. `01_prep_ab_test_hiring` must run first, as the other A/B tables are built from it.
3. **Analysis:** run the files in `03_analysis` after the prep tables exist.

## Key decisions

- 230 visitors (0.02%) assigned to both test groups were excluded.
- Missing profit is treated as zero (no purchase).
- All rates are calculated on aggregated totals, not averaged across rows.
- Significance is tested at visitor level (the unit of randomisation) using a Welch z-test.

## Tools

BigQuery (SQL) · Looker Studio (dashboard) · Notion (documentation)
