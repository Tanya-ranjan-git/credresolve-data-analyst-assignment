# CredResolve Data Analyst Assignment

## Final conclusion
The reported **11% month-on-month recovery improvement is misleading as an operating-performance claim**.

After exact payment-event deduplication:
- Feb clean recovery: ₹17.03 Cr
- Mar clean recovery: ₹18.92 Cr
- Gross change: 11.11%
- Recovery / targeted account change: 1.18%
- Account recovery-rate relative change: 1.38% (0.58 pp)
- Recovery / agent-hour change: 5.38%

## Recommendation
**Invest ₹10 Cr in better borrower targeting**, using a next-best-action engine and a randomized controlled rollout.

Base planning scenario:
- 5% relative uplift
- ₹10.88 Cr incremental recovery over 12 months
- 9% ROI after ₹10 Cr
- 11.0 months to break even

The 5% uplift is a planning assumption, not a measured causal effect.

## Key DQ findings
- ₹2.50 Cr raw successful-recovery inflation from exact payment duplicates.
- 80.3% of targeting rows outside campaign windows.
- 66.7% call/vendor timezone mismatch.
- Borrower and agent masters are heavily non-unique/contradictory.
- Strict 7-day targeting-to-payment attribution covers 4.75% of clean successful recovery.

## Deliverables
Analysis notebook; SQL; Golden account-month dataset; Data Quality Report; Executive Dashboard; Executive Memo; Architecture Diagram.
