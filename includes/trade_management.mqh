// trade_management.mqh - symbol-aware trade management

void TradeManagerInit(const string symbol)
  {
   // placeholder
  }

bool SignalsCanOpen(const string symbol,int signalType)
  {
   if(Config.prevent_duplicate)
     {
      for(int i=0;i<PositionsTotal();i++)
        {
         if(PositionSelectByIndex(i))
           {
            string sym = PositionGetString(POSITION_SYMBOL);
            if(sym!=symbol) continue;
            int type = (int)PositionGetInteger(POSITION_TYPE);
            if(type==POSITION_TYPE_BUY && signalType==BUY_SIGNAL) return false;
            if(type==POSITION_TYPE_SELL && signalType==SELL_SIGNAL) return false;
           }
        }
     }
   return true;
  }

void ManageOpenTrades(const string symbol)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      if(PositionSelectByIndex(i))
        {
         string sym = PositionGetString(POSITION_SYMBOL);
         if(sym!=symbol) continue;
         ulong ticket = (ulong)PositionGetInteger(POSITION_TICKET);
         double volume = PositionGetDouble(POSITION_VOLUME);
         int type = (int)PositionGetInteger(POSITION_TYPE);
         double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
         double sl = PositionGetDouble(POSITION_SL);
         double tp = PositionGetDouble(POSITION_TP);
         double curPrice = (type==POSITION_TYPE_BUY)?SymbolInfoDouble(sym,SYMBOL_BID):SymbolInfoDouble(sym,SYMBOL_ASK);

         double atr = ATR_Value(sym,Config.atr_period);
         double trail = atr * Config.atr_multiplier;
         if(trail>0)
           {
            if(type==POSITION_TYPE_BUY)
              {
               double newSL = curPrice - trail;
               if(newSL>sl)
                 {
                  // modify
                  MqlTradeRequest req; MqlTradeResult res; ZeroMemory(req); ZeroMemory(res);
                  req.action = TRADE_ACTION_SLTP;
                  req.position = ticket;
                  req.sl = newSL;
                  if(!OrderSend(req,res))
                    {
                     LogPrint(StringFormat("%s: Modify SL failed for ticket %I64u (API false)", sym, ticket));
                    }
                  else
                    {
                     if(res.retcode!=TRADE_RETCODE_DONE)
                       LogPrint(StringFormat("%s: Modify SL returned ret=%d (%s) for ticket %I64u", sym, res.retcode, ErrorCodeToString(res.retcode), res.order));
                    }
                 }
              }
            else
              {
               double newSL = curPrice + trail;
               if(newSL<sl || sl==0.0)
                 {
                  MqlTradeRequest req; MqlTradeResult res; ZeroMemory(req); ZeroMemory(res);
                  req.action = TRADE_ACTION_SLTP;
                  req.position = ticket;
                  req.sl = newSL;
                  if(!OrderSend(req,res))
                    {
                     LogPrint(StringFormat("%s: Modify SL failed for ticket %I64u (API false)", sym, ticket));
                    }
                  else
                    {
                     if(res.retcode!=TRADE_RETCODE_DONE)
                       LogPrint(StringFormat("%s: Modify SL returned ret=%d (%s) for ticket %I64u", sym, res.retcode, ErrorCodeToString(res.retcode), res.order));
                    }
                 }
              }
           }
        }
     }
  }
