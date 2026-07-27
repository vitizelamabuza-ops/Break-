// risk_management.mqh

string g_symbol_risk="";

void RiskInit(const string symbol)
  {
   g_symbol_risk = symbol;
  }

bool RiskAllowTrading()
  {
   // Daily loss and trades checks would require persistent storage; simplified check here
   // TODO: implement persisted daily P/L tracking
   return(true);
  }

// Calculate volume in lots given stoploss distance in price units
double RiskCalculateVolume(double stoploss_price_distance)
  {
   double riskMoney = AccountInfoDouble(ACCOUNT_BALANCE) * (Config.risk_percent/100.0);
   if(riskMoney<=0) return(0);

   double tick_size  = SymbolInfoDouble(g_symbol_risk,SYMBOL_TRADE_TICK_SIZE);
   double tick_value = SymbolInfoDouble(g_symbol_risk,SYMBOL_TRADE_TICK_VALUE);
   if(tick_size<=0 || tick_value<=0) return(0);

   double ticks = stoploss_price_distance / tick_size;
   if(ticks<=0) return(0);

   double lossPerLot = ticks * tick_value;
   if(lossPerLot<=0) return(0);

   double rawLots = riskMoney / lossPerLot;

   // Clamp to symbol limits
   double minLot = SymbolInfoDouble(g_symbol_risk,SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(g_symbol_risk,SYMBOL_VOLUME_MAX);
   double lotStep= SymbolInfoDouble(g_symbol_risk,SYMBOL_VOLUME_STEP);
   if(minLot<=0) minLot=0.01;
   if(maxLot<=0) maxLot=100.0;
   // normalize
   double lots = MathFloor(rawLots/lotStep)*lotStep;
   if(lots<minLot) lots=minLot;
   if(lots>maxLot) lots=maxLot;
   return NormalizeDouble(lots,2);
  }
