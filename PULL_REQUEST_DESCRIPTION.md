# Fix: remove invalid (void) casts and address logging param for MQL5

Replace invalid '(void)param' patterns with explicit unused locals and rename LogPrint parameter from `text` to `message`.

This branch includes small mechanical edits across includes/*.mqh to remove compile errors in MQL5:
- includes/logging.mqh
- includes/persistence.mqh
- includes/filters.mqh
- includes/risk_management.mqh
- includes/trade_management.mqh

No behavior changes; purely compile-time safety fixes.
