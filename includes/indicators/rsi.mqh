// indicators/rsi.mqh

int g_handle_rsi=-1;

int RSI_Handle()
  {
   if(g_handle_rsi<0) g_handle_rsi = iRSI(_Symbol,PERIOD_CURRENT,Config.rsi_period,PRICE_CLOSE);
   return g_handle_rsi;
  }

double RSI_Value(int period)
  {
   double val=0;
   int handle = RSI_Handle();
   if(CopyBuffer(handle,0,0,1,&val)>0) return val;
   return EMPTY_VALUE;
  }
