// trade_management.mqh

void TradeManagerInit(const string symbol)
  {
   // placeholder for init
  }

bool SignalsCanOpen(int signalType)
  {
   // check duplicates
   if(Config.prevent_duplicate)
     {
      for(int i=0;i<PositionsTotal();i++)
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && signalType==BUY_SIGNAL) return false;
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && signalType==SELL_SIGNAL) return false;
        }
     }
   return true;
  }

void ManageOpenTrades()
  {
   // iterate positions and apply trailing stop, break even, partial close
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      if(PositionSelectByIndex(i))
        {
         string sym = PositionGetString(POSITION_SYMBOL);
         ulong ticket = PositionGetInteger(POSITION_TICKET);
         double volume = PositionGetDouble(POSITION_VOLUME);
         int type = (int)PositionGetInteger(POSITION_TYPE);
         double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
         double sl = PositionGetDouble(POSITION_SL);
         double tp = PositionGetDouble(POSITION_TP);
         double curPrice = (type==POSITION_TYPE_BUY)?SymbolInfoDouble(sym,SYMBOL_BID):SymbolInfoDouble(sym,SYMBOL_ASK);

         // ATR trailing example
         double atr = ATR_Value(Config.atr_period);
         double trail = atr * Config.atr_multiplier;
         if(trail>0)
           {
            if(type==POSITION_TYPE_BUY)
              {
               double newSL = curPrice - trail;
               if(newSL>sl) order_trade.PositionModify(sym,newSL,tp);
              }
            else
              {
               double newSL = curPrice + trail;
               if(newSL<sl || sl==0.0) order_trade.PositionModify(sym,newSL,tp);
              }
           }
        }
     }
  }
