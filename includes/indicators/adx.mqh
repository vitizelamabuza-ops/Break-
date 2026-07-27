// indicators/adx.mqh - symbol-scoped ADX

double ADX_Value(const string symbol,int period)
  {
   int handle = iADX(symbol,PERIOD_CURRENT,period);
   if(handle==INVALID_HANDLE) return 0.0;
   double buf[]; ArrayResize(buf,1);
   if(CopyBuffer(handle,0,0,1,buf)<=0) { IndicatorRelease(handle); return 0.0; }
   double val = buf[0]; IndicatorRelease(handle); return val;
  }
