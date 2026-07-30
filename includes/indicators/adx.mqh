#ifndef __INCLUDES_IND_ADX_MQH__
#define __INCLUDES_IND_ADX_MQH__
// adx.mqh - returns the latest ADX value (for usage in filters)

double ADX_Value(const string symbol,int period)
  {
   int handle = iADX(symbol, PERIOD_CURRENT, period);
   if(handle==INVALID_HANDLE) return(EMPTY_VALUE);

   double buf[];
   ArrayResize(buf,1);
   if(CopyBuffer(handle,0,0,1,buf) <= 0) { IndicatorRelease(handle); return(EMPTY_VALUE); }
   double val = buf[0];
   IndicatorRelease(handle);
   return(val);
  }
#endif
