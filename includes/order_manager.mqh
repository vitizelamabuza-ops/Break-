// order_manager.mqh

#include <Trade\Trade.mqh>
CTrade order_trade;
string g_symbol_order="";

ulong OrderSend(int order_type,double volume,double sl_price,double tp_price,const string reason)
  {
   g_symbol_order = _Symbol;
   bool res=false; ulong ticket=0;
   int attempts=0;
   while(attempts<3 && !res)
     {
      attempts++;
      if(order_type==ORDER_TYPE_BUY)
        res = order_trade.Buy(volume,g_symbol_order,SymbolInfoDouble(g_symbol_order,SYMBOL_ASK),sl_price,tp_price,NULL);
      else
        res = order_trade.Sell(volume,g_symbol_order,SymbolInfoDouble(g_symbol_order,SYMBOL_BID),sl_price,tp_price,NULL);

      if(res)
        {
         ticket = order_trade.ResultOrder();
         break;
        }
      else
        {
         int code = order_trade.ResultRetcode();
         Log(StringFormat("OrderSend attempt %d failed, code=%d",attempts,code));
         Sleep(500);
        }
     }
   return ticket;
  }

bool ClosePositionByTicket(ulong ticket)
  {
   // Use trade to close
   if(!PositionSelectByTicket(ticket)) return false;
   string sym = PositionGetString(POSITION_SYMBOL);
   double volume = PositionGetDouble(POSITION_VOLUME);
   int type = (int)PositionGetInteger(POSITION_TYPE);
   bool res=false; int attempts=0;
   while(attempts<3 && !res)
     {
      attempts++;
      if(type==POSITION_TYPE_BUY) res = order_trade.PositionClose(sym);
      else res = order_trade.PositionClose(sym);
      if(!res) { Sleep(300); }
     }
   return res;
  }
