// indicators/ema.mqh

int    g_handle_ema_fast=-1;
int    g_handle_ema_slow=-1;
string g_sym="";

void IndicatorsInit(const string symbol)
  {
   g_sym = symbol;
   g_handle_ema_fast = iMA(symbol,PERIOD_CURRENT,Config.ema_fast_period,0,MODE_EMA,PRICE_CLOSE);
   g_handle_ema_slow = iMA(symbol,PERIOD_CURRENT,Config.ema_slow_period,0,MODE_EMA,PRICE_CLOSE);
  }

double EMA_Value(int period)
  {
   // Use built-in copy
   double val=0;
   if(period==Config.ema_fast_period)
     {
      if(CopyBuffer(g_handle_ema_fast,0,0,1,&val)>0) return val;
     }
   else if(period==Config.ema_slow_period)
     {
      if(CopyBuffer(g_handle_ema_slow,0,0,1,&val)>0) return val;
     }
   return EMPTY_VALUE;
  }
