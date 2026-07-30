//+------------------------------------------------------------------+
//| BreakEA.mq5 - Multi-symbol capable EA with persistence           
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include "includes/config.mqh"
#include "includes/logging.mqh"
#include "includes/utils.mqh"
#include "includes/persistence.mqh"
#include "includes/indicators/ema.mqh"
#include "includes/indicators/rsi.mqh"
#include "includes/indicators/macd.mqh"
#include "includes/indicators/atr.mqh"
#include "includes/indicators/adx.mqh"
#include "includes/filters.mqh"
#include "includes/risk_management.mqh"
#include "includes/order_manager.mqh"
#include "includes/trade_management.mqh"
#include "includes/indicators/init.mqh"

// Ensure a single CTrade instance is used throughout the EA
CTrade Trade;

// Global symbol list used by the EA
string g_symbols[];
int    g_symbol_count=0;

// Signals - explicit constants so code is self-contained and clear
enum ESignal
  {
   BUY_SIGNAL  = 1,
   SELL_SIGNAL = 2
  };

//+------------------------------------------------------------------+
int OnInit()
  {
   // Initialize logging first (file creation etc)
   if(!LoggingInit()) return(INIT_FAILED);
   LogPrint("BreakEA initializing multi-symbol manager");

   if(!ConfigValidate())
     {
      LogPrint("Config invalid");
      return(INIT_FAILED);
     }

   // Prepare symbol list
   if(Config.multi_symbol)
     {
      g_symbol_count = StringSplit(Config.symbols_list,',',g_symbols);
      for(int i=0;i<g_symbol_count;i++) g_symbols[i]=StringTrim(g_symbols[i]);
      if(g_symbol_count==0) { LogPrint("Multi-symbol enabled but no symbols provided"); return(INIT_FAILED); }
     }
   else
     {
      g_symbol_count = 1;
      ArrayResize(g_symbols,1);
      g_symbols[0] = _Symbol;
     }

   // Initialize modules for each symbol
   for(int i=0;i<g_symbol_count;i++)
     {
      string s = g_symbols[i];
      IndicatorsInit(s);       // implemented in indicators/*.mqh
      FiltersInit(s);          // implemented in includes/filters.mqh
      RiskInit(s);             // implemented in includes/risk_management.mqh
      TradeManagerInit(s);     // implemented in includes/trade_management.mqh
      PersistenceLoad(s);      // implemented in includes/persistence.mqh
     }

   LogPrint(StringFormat("Initialization complete for %d symbols", g_symbol_count));
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i=0;i<g_symbol_count;i++) PersistenceSave(g_symbols[i]);
   LoggingClose();
  }
//+------------------------------------------------------------------+
void OnTick()
  {
   static datetime lastRun=0;
   // avoid multiple calls inside same second
   if(TimeCurrent()==lastRun) return; lastRun=TimeCurrent();

   for(int i=0;i<g_symbol_count;i++)
     {
      string sym = g_symbols[i];

      // Basic filters per symbol
      if(!FiltersAllowTrading(sym)) continue;

      // Persistent Risk checks per symbol
      if(!RiskAllowTrading(sym)) continue;

      // Read indicators for symbol
      double emaFast = EMA_Value(sym,Config.ema_fast_period);
      double emaSlow = EMA_Value(sym,Config.ema_slow_period);
      double rsi     = RSI_Value(sym,Config.rsi_period);
      MACDData macd  = MACD_Value(sym,Config.macd_fast,Config.macd_slow,Config.macd_signal);
      double atr     = ATR_Value(sym,Config.atr_period);
      double adx     = ADX_Value(sym,Config.adx_period);

      string reason="";

      // Trend rule preserved exactly from original logic
      if(emaFast>emaSlow)
        {
         if(SignalsCanOpen(sym,BUY_SIGNAL))
           {
            if(rsi<Config.rsi_threshold_buy && macd.isBearishCrossover)
              {
               reason = StringFormat("Uptrend %s: EMA%d>EMA%d, RSI=%.2f<%.2f, MACD bearish crossover, ATR=%.5f",
                                     sym, Config.ema_fast_period, Config.ema_slow_period, rsi, Config.rsi_threshold_buy, atr);
               TryOpenPosition(sym,ORDER_TYPE_BUY,atr,reason);
              }
           }
        }
      else if(emaFast<emaSlow)
        {
         if(SignalsCanOpen(sym,SELL_SIGNAL))
           {
            if(rsi>Config.rsi_threshold_sell && macd.isBullishCrossover)
              {
               reason = StringFormat("Downtrend %s: EMA%d<EMA%d, RSI=%.2f>%.2f, MACD bullish crossover, ATR=%.5f",
                                     sym, Config.ema_fast_period, Config.ema_slow_period, rsi, Config.rsi_threshold_sell, atr);
               TryOpenPosition(sym,ORDER_TYPE_SELL,atr,reason);
              }
           }
        }

      // Manage open trades for this symbol
      ManageOpenTrades(sym);
     }
  }
//+------------------------------------------------------------------+
void TryOpenPosition(const string symbol,int order_type,double atr_value,const string entry_reason)
  {
   // Determine stop distance in price units
   double slDistance = atr_value * Config.atr_multiplier;
   double price=0;
   if(order_type==ORDER_TYPE_BUY) price = SymbolInfoDouble(symbol,SYMBOL_ASK);
   else price = SymbolInfoDouble(symbol,SYMBOL_BID);

   if(price==0 || slDistance<=0.0)
     {
      LogPrint(StringFormat("Invalid price or slDistance for %s price=%.5f slDistance=%.5f",symbol,price,slDistance));
      return;
     }

   double stopLossPrice = (order_type==ORDER_TYPE_BUY)? price - slDistance : price + slDistance;
   double takeProfitPrice= (order_type==ORDER_TYPE_BUY)? price + slDistance * Config.risk_reward : price - slDistance * Config.risk_reward;

   double volume = RiskCalculateVolume(symbol,slDistance);
   if(volume<=0) { LogPrint(StringFormat("Volume calc <=0 for %s", symbol)); return; }

   bool trade_result=false;
   ulong ticket=0;
   // Use CTrade correctly (price parameter optional for market orders; included for explicitness)
   if(order_type==ORDER_TYPE_BUY)
     trade_result = Trade.Buy(volume, symbol, price, stopLossPrice, takeProfitPrice, entry_reason);
   else
     trade_result = Trade.Sell(volume, symbol, price, stopLossPrice, takeProfitPrice, entry_reason);

   if(trade_result)
     {
      // Retrieve result metadata
      ticket = Trade.ResultOrder();
      if(ticket==0) ticket = Trade.ResultDeal(); // fallback if needed
      LogTradeEntry(ticket, order_type, volume, stopLossPrice, takeProfitPrice, entry_reason);
      PersistenceRegisterTrade(symbol, TimeCurrent(), ticket, order_type);
     }
   else
     {
      // Log failure using result code
      LogPrint(StringFormat("Trade request failed for %s type=%d error=%d", symbol, order_type, Trade.ResultRetcode()));
     }
  }
