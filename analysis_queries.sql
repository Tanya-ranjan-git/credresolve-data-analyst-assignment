-- CredResolve Collections Assignment | PostgreSQL-compatible SQL
CREATE OR REPLACE VIEW clean_successful_payments AS
SELECT DISTINCT account_id,event_at,payment_reference,amount,payment_status,payment_method,provider_id
FROM payments WHERE payment_status='SUCCESS';

CREATE OR REPLACE VIEW clean_calls AS
SELECT * FROM (
  SELECT c.*, ROW_NUMBER() OVER(PARTITION BY call_id ORDER BY event_at,account_id) rn
  FROM calls c
) x WHERE rn=1;

-- Independent monthly recovery performance
WITH p AS (
 SELECT DATE_TRUNC('month',event_at)::date month,SUM(amount) recovery,
        COUNT(DISTINCT account_id) paid_accounts
 FROM clean_successful_payments GROUP BY 1
), t AS (
 SELECT DATE_TRUNC('month',target_date)::date month,
        COUNT(DISTINCT account_id) targeted_accounts
 FROM daily_targeting GROUP BY 1
)
SELECT p.month,p.recovery,p.paid_accounts,t.targeted_accounts,
       p.recovery/NULLIF(t.targeted_accounts,0) recovery_per_targeted_account,
       p.paid_accounts::numeric/NULLIF(t.targeted_accounts,0) account_recovery_rate
FROM p JOIN t USING(month) ORDER BY p.month;

-- Campaign-window DQ
SELECT COUNT(*) total_targets,
       SUM(CASE WHEN t.target_date<c.start_at::date OR t.target_date>c.end_at::date THEN 1 ELSE 0 END) outside_window
FROM daily_targeting t JOIN campaigns c USING(campaign_id);

-- Vendor timezone DQ
SELECT COUNT(*) timezone_mismatch
FROM clean_calls c JOIN vendor_telephony v USING(vendor_id)
WHERE c.timezone<>v.timezone;

-- Payment duplicate reconciliation
SELECT SUM(amount) raw_success_amount FROM payments WHERE payment_status='SUCCESS';
SELECT SUM(amount) clean_success_amount FROM clean_successful_payments;

-- Risk x channel outcome (directional; not causal)
WITH x AS (
 SELECT t.target_id,t.account_id,t.target_date,t.channel,a.risk_segment,
        p.event_at,p.amount,
        ROW_NUMBER() OVER(PARTITION BY t.target_id ORDER BY p.event_at) rn
 FROM daily_targeting t JOIN accounts a USING(account_id)
 LEFT JOIN clean_successful_payments p
   ON p.account_id=t.account_id
  AND p.event_at>=t.target_date
  AND p.event_at<t.target_date+INTERVAL '7 days'
)
SELECT risk_segment,channel,COUNT(*) targets,
       AVG(CASE WHEN event_at IS NOT NULL THEN 1.0 ELSE 0 END) paid_7d_rate,
       AVG(COALESCE(amount,0)) expected_recovery_per_target
FROM x WHERE rn=1 OR rn IS NULL
GROUP BY 1,2 ORDER BY 1,2;

-- Production DQ tests should include:
-- primary-key uniqueness, orphan-account rate, enum validity,
-- timestamp window checks, campaign-window validity, payment reconciliation,
-- late-arrival monitoring, and anomaly alerts.
