#ifndef __INCLUDES_IND_ATR_MQH__
#define __INCLUDES_IND_ATR_MQH__
// atr.mqh - safe ATR accessor returning the latest ATR value
// - If indicator handle fails or data is missing returns EMPTY_VALUE

double ATR_Value(const string symbol,int period)
  {
   int handle = iATR(symbol, PERIOD_CURRENT, period);
   if(handle==INVALID_HANDLE) return(EMPTY_VALUE);

   double buf[];
   ArrayResize(buf,1);
   if(CopyBuffer(handle,0,0,1,buf) <= 0) { IndicatorRelease(handle); return(EMPTY_VALUE); }
   double val = buf[0];
   IndicatorRelease(handle);
   return(val);
  }
#endif
