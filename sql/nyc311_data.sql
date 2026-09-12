select
*
from hpd_complaints

-- 1. What is the typical resolution time for each complaint type, and how bad does it get?

select
complaint_type,
count(*) as ticket_count,
round(avg(resolution_time_days)::numeric,2) AS mean_days,
round(percentile_cont(0.5) WITHIN GROUP(ORDER BY resolution_time_days)::numeric, 2) AS median_days,
round(percentile_cont(0.9) WITHIN GROUP(ORDER BY resolution_time_days)::numeric, 2) AS p90_days
from
hpd_complaints
where
is_valid_closed = true
group by
complaint_type
order by
median_days DESC;

-- 2. What percentage of tickets in each category take longer than 30 days?

with category_counts as (
select
complaint_type,
count(*) as ticket_count,
sum(
case
when breaches_30day_threshold then 1 else 0 
end) as breached_count
from 
hpd_complaints
where 
is_valid_closed = true
group by
complaint_type
)
 select
 complaint_type,
 ticket_count,
 breached_count,
 round(100.0 * breached_count / ticket_count, 1) as breach_pct
 from
 category_counts
 order by
 breach_pct DESC;

-- 3. Which complaint categories are driving the most total delay?

select
complaint_type,
count(*) as ticket_count,
sum(
case
when breaches_30day_threshold then 1 else 0 end
) as breached_count,
round (sum(
case
when breaches_30day_threshold then resolution_time_days - 30 else 0 end 
)::numeric, 2)
as total_excess_days,
round(sum(
case
when
breaches_30day_threshold then resolution_time_days - 30 else 0 end)::numeric / nullif(sum(case when breaches_30day_threshold then 1 else 0 end),0),2) 
as avg_excess_days_per_breach
from
hpd_complaints
where
is_valid_closed = true
group by
complaint_type
having
count(*)>=10
order by
total_excess_days DESC;

-- 4. Does it matter that some records share identical timestamps?
-- 5. Which individual tickets are the most extreme outliers?

