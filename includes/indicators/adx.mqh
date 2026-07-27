// indicators/adx.mqh

int g_handle_adx=-1;

int ADX_Handle()
  {
   if(g_handle_adx<0) g_handle_adx = iADX(_Symbol,PERIOD_CURRENT,Config.adx_period);
   return g_handle_adx;
  }

double ADX_Value(int period)
  {
   double arr[1];
   int handle = ADX_Handle();
   if(CopyBuffer(handle,0,0,1,arr)>0) return arr[0];
   return 0.0;
  }
