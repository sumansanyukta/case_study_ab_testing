# Looker Studio Dashboard

**Link:** [New Customer Sorting V2 & Ranking Dashboard](https://datastudio.google.com/s/v6x_uWfkZrE)

Built in Looker Studio on BigQuery tables from `sql/02_prep`. Each page has a footnote defining its metrics.

## Pages

| Page | Audience | Question it answers | Data source | Filters |
|---|---|---|---|---|
| 1. Experiment results | Leadership, category managers | Should the new sort roll out? | `prep_ab_test_perc_diff`, `prep_ab_test_daily` | Date |
| 2. Category performance | Category managers | How do products perform in the current ranking? | `prep_ranking_category` | Virtual category, product group, brand, price cluster |
| 3. Experiment diagnostics | Sorting team lead | Why does the test result look the way it does? | `prep_ab_test_daily` | Test group, date |
| 4. Ranking trade-offs | Sorting team lead, category managers | Which ranking signals drive clicks vs profit? | `prep_ranking_category` | Virtual category, product group, brand, price cluster |

## Notes

- Pages 1 and 3 use different denominators: Page 1 is per unique visitor (month), Page 3 is per visitor-day.
- Page 4 shows associations only; the ranking data has no test assignment or rank position.
