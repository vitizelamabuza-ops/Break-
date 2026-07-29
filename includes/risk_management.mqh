// risk_management.mqh - symbol-scoped risk calculations and persistent checks

void RiskInit(const string symbol)
  {
   // placeholder
  }

bool RiskAllowTrading(const string symbol)
  {
   // check persistent daily stats for symbol
   // we will read last line from stats file
   string fname = StringFormat("/MQL5/Files/BreakEA_stats_%s.csv",symbol);
   int h = FileOpen(fname,FILE_READ|FILE_ANSI);
   string lastLine="";
   if(h>=0)
     {
      while(!FileIsEnding(h)) { string line = FileReadString(h); if(StringLen(StringTrim(line))>0) lastLine=line; }
      FileClose(h);
     }

   if(StringLen(lastLine)>0)
     {
      string parts[]; int n=StringSplit(lastLine,',',parts);
      if(n>=3)
        {
         string date = parts[0]; double pl = StringToDouble(parts[1]); int trades = (int)StringToInteger(parts[2]);
         if(trades>=Config.max_daily_trades) { LogPrint(StringFormat("%s: Reached max daily trades %d",symbol,trades)); return false; }
         double balance = AccountInfoDouble(ACCOUNT_BALANCE);
         double lossPercent = (pl<0) ? (MathAbs(pl)/balance)*100.0 : 0.0;
         if(lossPercent>=Config.max_daily_loss) { LogPrint(StringFormat("%s: Daily loss %.2f%% >= limit %.2f%%",symbol,lossPercent,Config.max_daily_loss)); return false; }
        }
     }

   // free margin check
   double freeMargin = AccountInfoDouble(ACCOUNT_FREEMARGIN);
   if(freeMargin<100) { LogPrint(StringFormat("%s: Free margin low %.2f",symbol,freeMargin)); return false; }

   return true;
  }

// Calculate volume in lots given stoploss distance in price units
double RiskCalculateVolume(const string symbol,double stoploss_price_distance)
  {
   double riskMoney = AccountInfoDouble(ACCOUNT_BALANCE) * (Config.risk_percent/100.0);
   if(riskMoney<=0) return(0);

   double tick_size  = SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   double tick_value = SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
   if(tick_size<=0 || tick_value<=0) return(0);

   double ticks = stoploss_price_distance / tick_size;
   if(ticks<=0) return(0);

   double lossPerLot = ticks * tick_value;
   if(lossPerLot<=0) return(0);

   double rawLots = riskMoney / lossPerLot;

   double minLot = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double lotStep= SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   if(minLot<=0) minLot=0.01;
   if(maxLot<=0) maxLot=100.0;
   double lots = MathFloor(rawLots/lotStep)*lotStep;
   if(lots<minLot) lots=minLot;
   if(lots>maxLot) lots=maxLot;
   return NormalizeDouble(lots,2);
  }
