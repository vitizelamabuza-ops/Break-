// indicators/atr.mqh - symbol-scoped ATR

double ATR_Value(const string symbol,int period)
  {
   int handle = iATR(symbol,PERIOD_CURRENT,period);
   if(handle==INVALID_HANDLE) return SymbolInfoDouble(symbol,SYMBOL_POINT);
   double buf[]; ArrayResize(buf,1);
   if(CopyBuffer(handle,0,0,1,buf)<=0) { IndicatorRelease(handle); return SymbolInfoDouble(symbol,SYMBOL_POINT); }
   double val = buf[0]; IndicatorRelease(handle); return val;
  }
