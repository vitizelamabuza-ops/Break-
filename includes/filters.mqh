// filters.mqh - trading filters

string g_symbol_filter="";

void FiltersInit(const string symbol)
  {
   g_symbol_filter = symbol;
  }

bool FiltersAllowTrading()
  {
   // Spread filter
   double ask = SymbolInfoDouble(g_symbol_filter,SYMBOL_ASK);
   double bid = SymbolInfoDouble(g_symbol_filter,SYMBOL_BID);
   double spread_points = (ask-bid)/SymbolInfoDouble(g_symbol_filter,SYMBOL_POINT);
   if(spread_points>Config.max_spread_points) { Log("Spread too high: " + DoubleToString(spread_points)); return false; }

   // Minimum candle body
   if(LastCandleBodyPoints()<Config.min_candle_points) { Log("Candle body too small"); return false; }

   // Time/session filter: allow London or NewYork sessions only
   int hour = TimeHour(TimeCurrent());
   bool inSession = (hour>=7 && hour<=17) || (hour>=12 && hour<=21); // rough windows
   if(!inSession) { Log("Outside trading session"); return false; }

   // Optional ADX filter
   if(Config.use_adx)
     {
      double adx = ADX_Value(Config.adx_period);
      if(adx<Config.adx_threshold) { Log("ADX below threshold: "+DoubleToString(adx)); return false; }
     }

   // News filter placeholder
   if(Config.news_filter)
     {
      // External integration required. For now, act conservative and allow only if disabled.
      Log("News filter enabled but not implemented - skipping trade");
      return false;
     }

   return true;
  }
