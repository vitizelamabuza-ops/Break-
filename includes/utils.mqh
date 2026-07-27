// utils.mqh - helper utilities

void LogPrint(const string fmt,...)
  {
   string msg = StringFormat(fmt,ArrayRange(fmt,0)); // placeholder for varargs
   Print(msg);
   FileWriteString("BreakEA_log.txt",StringFormat("%s %s\n",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),msg));
  }

// Helper: get last closed candle body size in points
int LastCandleBodyPoints()
  {
   double open0 = iOpen(_Symbol,PERIOD_CURRENT,1);
   double close0= iClose(_Symbol,PERIOD_CURRENT,1);
   double diff = MathAbs(close0-open0);
   double point = SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   return (int)(diff/point);
  }
