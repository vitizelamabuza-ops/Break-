// indicators/atr.mqh

int g_handle_atr=-1;

int ATR_Handle()
  {
   if(g_handle_atr<0) g_handle_atr = iATR(_Symbol,PERIOD_CURRENT,Config.atr_period);
   return g_handle_atr;
  }

double ATR_Value(int period)
  {
   double arr[1];
   int handle = ATR_Handle();
   if(CopyBuffer(handle,0,0,1,arr)>0) return arr[0];
   return SymbolInfoDouble(_Symbol,SYMBOL_POINT); // fallback
  }
