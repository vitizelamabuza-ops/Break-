// indicators/rsi.mqh - symbol-scoped RSI

double RSI_Value(const string symbol,int period)
  {
   int handle = iRSI(symbol,PERIOD_CURRENT,period,PRICE_CLOSE);
   if(handle==INVALID_HANDLE) return EMPTY_VALUE;
   double buf[]; ArrayResize(buf,1);
   if(CopyBuffer(handle,0,0,1,buf)<=0) { IndicatorRelease(handle); return EMPTY_VALUE; }
   double val=buf[0]; IndicatorRelease(handle); return val;
  }
