// filters.mqh - symbol-scoped filters

bool FiltersAllowTrading(const string symbol)
  {
   double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
   double spread_points = (ask-bid)/SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(spread_points>Config.max_spread_points) { LogPrint(StringFormat("%s: Spread too high %.1f",symbol,spread_points)); return false; }

   // Minimum candle body
   double open0 = iOpen(symbol,PERIOD_CURRENT,1);
   double close0= iClose(symbol,PERIOD_CURRENT,1);
   double diff = MathAbs(close0-open0);
   double point = SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(point>0 && (diff/point) < Config.min_candle_points) { LogPrint(StringFormat("%s: Candle body too small",symbol)); return false; }

   // Session filter (rough)
   int hour = TimeHour(TimeCurrent());
   bool inSession = (hour>=7 && hour<=17) || (hour>=12 && hour<=21);
   if(!inSession) { LogPrint(StringFormat("%s: Outside trading session",symbol)); return false; }

   if(Config.use_adx)
     {
      double adx = ADX_Value(symbol,Config.adx_period);
      if(adx<Config.adx_threshold) { LogPrint(StringFormat("%s: ADX %.2f below threshold",symbol,adx)); return false; }
     }

   if(Config.news_filter)
     {
      LogPrint(StringFormat("%s: News filter enabled but not implemented",symbol)); return false;
     }

   return true;
  }
