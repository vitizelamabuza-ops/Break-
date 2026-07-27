// indicators/ema.mqh - symbol-scoped EMA value (one-shot handles)

double EMA_Value(const string symbol,int period)
  {
   int handle = iMA(symbol,PERIOD_CURRENT,period,0,MODE_EMA,PRICE_CLOSE);
   if(handle==INVALID_HANDLE) return EMPTY_VALUE;
   double buf[];
   ArrayResize(buf,1);
   if(CopyBuffer(handle,0,0,1,buf)<=0) { IndicatorRelease(handle); return EMPTY_VALUE; }
   double val = buf[0];
   IndicatorRelease(handle);
   return val;
  }
