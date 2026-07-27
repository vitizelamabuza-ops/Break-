// order_manager.mqh - improved error handling and symbol-aware send

#include <Trade\Trade.mqh>

string ErrorCodeToString(int code)
  {
   switch(code)
     {
      case TRADE_RETCODE_DONE: return "Done";
      case TRADE_RETCODE_REQUOTE: return "Requote";
      case TRADE_RETCODE_REJECT: return "Reject";
      case TRADE_RETCODE_CANCEL: return "Cancel";
      case TRADE_RETCODE_PLACED: return "Placed";
      case TRADE_RETCODE_DONE_REMAINDER: return "DoneRemainder";
      case TRADE_RETCODE_ERROR: return "Error";
      default: return StringFormat("Code_%d",code);
     }
  }

ulong OrderSend(const string symbol,int order_type,double volume,double sl_price,double tp_price,const string reason)
  {
   MqlTradeRequest req; MqlTradeResult res; MqlTick tick;
   ZeroMemory(req); ZeroMemory(res);
   if(!SymbolInfoTick(symbol,tick)) { LogPrint(StringFormat("%s: SymbolInfoTick failed",symbol)); return 0; }

   req.action = TRADE_ACTION_DEAL;
   req.symbol = symbol;
   req.volume = volume;
   req.type = (order_type==ORDER_TYPE_BUY)?ORDER_TYPE_BUY:ORDER_TYPE_SELL;
   req.price = (req.type==ORDER_TYPE_BUY)?tick.ask:tick.bid;
   req.sl = sl_price;
   req.tp = tp_price;
   req.deviation = Config.slippage_points;
   req.type_filling = ORDER_FILLING_FOK;
   req.type_time = ORDER_TIME_GTC;

   int attempts=0;
   while(attempts<4)
     {
      attempts++;
      if(!OrderSend(req,res))
        {
         LogPrint(StringFormat("%s: OrderSend API returned false attempt %d",symbol,attempts));
         Sleep(200);
         continue;
        }
      // Check result
      if(res.retcode==TRADE_RETCODE_DONE || res.retcode==TRADE_RETCODE_PLACED || res.retcode==TRADE_RETCODE_DONE_REMAINDER)
        {
         LogPrint(StringFormat("%s: Order placed ret=%d (%s) ticket=%I64u",symbol,res.retcode,ErrorCodeToString(res.retcode),res.order));
         return res.order;
        }
      else if(res.retcode==TRADE_RETCODE_REQUOTE || res.retcode==TRADE_RETCODE_REJECT || res.retcode==TRADE_RETCODE_CANCEL)
        {
         LogPrint(StringFormat("%s: Transient failure ret=%d (%s), attempt %d",symbol,res.retcode,ErrorCodeToString(res.retcode),attempts));
         Sleep(300);
         continue;
        }
      else
        {
         LogPrint(StringFormat("%s: Fatal trade failure ret=%d (%s)",symbol,res.retcode,ErrorCodeToString(res.retcode)));
         break;
        }
     }
   return 0;
  }

bool ClosePositionByTicket(ulong ticket)
  {
   if(!PositionSelectByTicket(ticket)) return false;
   string symbol = PositionGetString(POSITION_SYMBOL);
   double volume = PositionGetDouble(POSITION_VOLUME);
   int type = (int)PositionGetInteger(POSITION_TYPE);

   MqlTradeRequest req; MqlTradeResult res; MqlTick tick;
   ZeroMemory(req); ZeroMemory(res);
   if(!SymbolInfoTick(symbol,tick)) return false;
   req.action = TRADE_ACTION_DEAL;
   req.symbol = symbol;
   req.volume = volume;
   req.deviation = Config.slippage_points;
   req.type = (type==POSITION_TYPE_BUY)?ORDER_TYPE_SELL:ORDER_TYPE_BUY;
   req.price = (req.type==ORDER_TYPE_BUY)?tick.ask:tick.bid;
   req.position = ticket;
   req.type_filling = ORDER_FILLING_FOK;
   req.type_time = ORDER_TIME_GTC;

   if(!OrderSend(req,res)) { LogPrint(StringFormat("Close: OrderSend API false for ticket %I64u",ticket)); return false; }
   if(res.retcode==TRADE_RETCODE_DONE) return true;
   LogPrint(StringFormat("Close failed ticket %I64u ret=%d",ticket,res.retcode));
   return false;
  }
