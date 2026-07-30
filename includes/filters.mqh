#ifndef __INCLUDES_FILTERS_MQH__
#define __INCLUDES_FILTERS_MQH__
// filters.mqh - simple implementation of FiltersInit and FiltersAllowTrading
// Purpose: implement basic spread and ADX filters without changing original EA behavior.

void FiltersInit(const string symbol)
  {
   // No-per-symbol persistent state required now; function exists so EA initialization succeeds.
   // Keep place for future per-symbol filter caching.
   string __unused_symbol = symbol;
  }

// Returns true if trading is allowed for symbol at current market state
bool FiltersAllowTrading(const string symbol)
  {
   // Check symbol is tradeable
   if(!SymbolInfoInteger(symbol,SYMBOL_SELECT)) // ensure symbol is available
     {
      bool sel = SymbolSelect(symbol,true);
      if(!sel) { LogPrint(StringFormat("FiltersAllowTrading: symbol %s not available",symbol)); return(false); }
     }

   // Spread check: compute in points (points rather than raw price)
   double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
   double point = SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(point<=0) return(false);
   double spreadPoints = (ask - bid) / point;

   if(spreadPoints > Config.max_spread_points)
     {
      LogPrint(StringFormat("FiltersAllowTrading: %s spread %.1f > max %.1f", symbol, spreadPoints, Config.max_spread_points));
      return(false);
     }

   // Optional ADX filter
   if(Config.use_adx)
     {
      double adx = ADX_Value(symbol, Config.adx_period);
      if(adx==EMPTY_VALUE) return(false); // cannot evaluate
      if(adx < Config.adx_threshold)
        {
         LogPrint(StringFormat("FiltersAllowTrading: %s ADX %.2f < threshold %.2f", symbol, adx, Config.adx_threshold));
         return(false);
        }
     }

   // Passed basic filters
   return(true);
  }
#endif
