#ifndef __INCLUDES_INDICATORS_INIT_MQH__
#define __INCLUDES_INDICATORS_INIT_MQH__
// indicators/init.mqh - small helper to expose IndicatorsInit used by BreakEA.mq5
// Keeps the implementation minimal so the project compiles.
// Extend this file to pre-create indicator handles if you want persistent handles.

void IndicatorsInit(const string symbol)
  {
   // Placeholder: create per-symbol indicator handles here if desired.
   // Example:
   //   // int handle = iMA(symbol, PERIOD_CURRENT, period, 0, MODE_EMA, PRICE_CLOSE);
   //   // store handle into module-level arrays for reuse
   (void)symbol;
  }

#endif
