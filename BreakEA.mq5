//+------------------------------------------------------------------+
//| BreakEA.mq5                                                      |
//| Modular, production-oriented MetaTrader 5 Expert Advisor         |
//| Author: Copilot (generated)                                      |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include "includes/config.mqh"
#include "includes/utils.mqh"
#include "includes/logging.mqh"
#include "includes/indicators/ema.mqh"
#include "includes/indicators/rsi.mqh"
#include "includes/indicators/macd.mqh"
#include "includes/indicators/atr.mqh"
#include "includes/indicators/adx.mqh"
#include "includes/filters.mqh"
#include "includes/risk_management.mqh"
#include "includes/order_manager.mqh"
#include "includes/trade_management.mqh"

CTrade Trade;
string g_symbol;
int    g_digits;
double g_point;

//+------------------------------------------------------------------+
int OnInit()
  {
   g_symbol = _Symbol;
   g_digits = (int)SymbolInfoInteger(g_symbol,SYMBOL_DIGITS);
   g_point  = SymbolInfoDouble(g_symbol,SYMBOL_POINT);

   if(!LoggingInit())
     return(INIT_FAILED);

   LogPrint("Initializing BreakEA on %s",g_symbol);

   if(!ConfigValidate())
     {
      LogPrint("Configuration invalid");
      return(INIT_FAILED);
     }

   IndicatorsInit(g_symbol);
   FiltersInit(g_symbol);
   RiskInit(g_symbol);
   TradeManagerInit(g_symbol);

   LogPrint("Initialization complete");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   LogPrint("Deinitializing BreakEA: reason=%d",reason);
   LoggingClose();
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   static datetime lastTickTime=0;
   if(TimeCurrent()==lastTickTime) return;
   lastTickTime=TimeCurrent();

   // Basic filters
   if(!FiltersAllowTrading()) return;

   // Prevent over daily loss / trade caps
   if(!RiskAllowTrading()) return;

   // Read indicators
   double emaFast = EMA_Value(Config.ema_fast_period);
   double emaSlow = EMA_Value(Config.ema_slow_period);
   double rsi     = RSI_Value(Config.rsi_period);
   MACDData macd  = MACD_Value(Config.macd_fast,Config.macd_slow,Config.macd_signal);
   double atr     = ATR_Value(Config.atr_period);
   double adx     = ADX_Value(Config.adx_period);

   string reason="";

   // Trend rule
   if(emaFast>emaSlow)
     {
      // Uptrend: consider BUY only
      if(SignalsCanOpen(BUY_SIGNAL))
        {
         if(rsi<Config.rsi_threshold_buy && macd.isBearishCrossover)
           {
            reason = StringFormat("Uptrend: EMA50>EMA200, RSI=%.2f<%.2f, MACD bearish crossover=1, ATR=%.5f",rsi,Config.rsi_threshold_buy,atr);
            TryOpenPosition(ORDER_TYPE_BUY,atr,reason);
           }
        }
     }
   else if(emaFast<emaSlow)
     {
      // Downtrend: consider SELL only
      if(SignalsCanOpen(SELL_SIGNAL))
        {
         if(rsi>Config.rsi_threshold_sell && macd.isBullishCrossover)
           {
            reason = StringFormat("Downtrend: EMA50<EMA200, RSI=%.2f>%.2f, MACD bullish crossover=1, ATR=%.5f",rsi,Config.rsi_threshold_sell,atr);
            TryOpenPosition(ORDER_TYPE_SELL,atr,reason);
           }
        }
     }

   // Manage existing trades
   ManageOpenTrades();
  }

//+------------------------------------------------------------------+
void TryOpenPosition(int order_type,double atr_value,const string entry_reason)
  {
   double stopLossPrice, takeProfitPrice;
   double slDistance = atr_value * Config.atr_multiplier;

   if(order_type==ORDER_TYPE_BUY)
     {
      double price = SymbolInfoDouble(g_symbol,SYMBOL_ASK);
      stopLossPrice = price - slDistance;
      takeProfitPrice = price + slDistance * Config.risk_reward;
     }
   else
     {
      double price = SymbolInfoDouble(g_symbol,SYMBOL_BID);
      stopLossPrice = price + slDistance;
      takeProfitPrice = price - slDistance * Config.risk_reward;
     }

   // Calculate volume
   double volume = RiskCalculateVolume(slDistance);
   if(volume<=0) { LogPrint("Calculated volume <=0, aborting"); return; }

   // Send order via order manager
   ulong ticket = OrderSend(order_type,volume,stopLossPrice,takeProfitPrice,entry_reason);

   if(ticket>0)
     {
      LogTradeEntry(ticket,order_type,volume,stopLossPrice,takeProfitPrice,entry_reason);
     }
  }
