// config.mqh - inputs for multi-symbol and persistence

#property copyright "vitizelamabuza-ops"
#property version   "1.1"

// Symbol management
input bool   InpMultiSymbol       = false;            // Enable multi-symbol management
input string InpSymbolsList       = "";             // Comma-separated symbols when multi-symbol enabled (e.g., EURUSD,GBPUSD)

// Indicator settings
input int    InpEMAFast         = 50;      // EMA fast period
input int    InpEMASlow         = 200;     // EMA slow period
input int    InpRSIPeriod       = 14;      // RSI period
input double InpRSIThresholdBuy = 50.0;   // RSI threshold for buy
input double InpRSIThresholdSell= 50.0;   // RSI threshold for sell
input int    InpMACDFast        = 12;      // MACD fast
input int    InpMACDSlow        = 26;      // MACD slow
input int    InpMACDSignal      = 9;       // MACD signal
input int    InpATRPeriod       = 14;      // ATR period
input double InpATRRMultiplier  = 3.0;     // ATR multiplier for SL

// Risk & trade limits
input double InpRiskPercent     = 0.5;     // Risk per trade (%)
input double InpRiskReward      = 2.0;     // Risk:Reward default 1:2
input int    InpMaxDailyTrades  = 5;       // Max daily trades per symbol
input double InpMaxDailyLoss    = 5.0;     // Max daily loss per symbol (%)
input double InpMaxDrawdown     = 20.0;    // Max drawdown (%)

// Filters
input double InpMaxSpreadPoints = 20.0;    // Max spread in points
input int    InpSlippage        = 3;       // Max slippage in points
input int    InpMinCandlePoints = 10;      // Minimum candle body size in points
input bool   InpUseADX          = false;   // Enable ADX
input int    InpADXPeriod       = 14;      // ADX period
input double InpADXThreshold    = 20.0;    // ADX threshold
input bool   InpNewsFilter      = false;   // News filter (not implemented)
input bool   InpCloseOpposite   = true;    // Close opposite trades on new trade
input bool   InpPreventDuplicate= true;    // Prevent duplicate trades per symbol

struct SConfig
  {
   bool multi_symbol;
   string symbols_list;
   int ema_fast_period;
   int ema_slow_period;
   int rsi_period;
   double rsi_threshold_buy;
   double rsi_threshold_sell;
   int macd_fast,macd_slow,macd_signal;
   int atr_period;
   double atr_multiplier;
   double risk_percent;
   double risk_reward;
   int max_daily_trades;
   double max_daily_loss;
   double max_drawdown;
   double max_spread_points;
   int slippage_points;
   int min_candle_points;
   bool use_adx;
   int adx_period;
   double adx_threshold;
   bool news_filter;
   bool close_opposite;
   bool prevent_duplicate;
  };

SConfig Config;

bool ConfigValidate()
  {
   Config.multi_symbol = InpMultiSymbol;
   Config.symbols_list = InpSymbolsList;
   Config.ema_fast_period = InpEMAFast;
   Config.ema_slow_period = InpEMASlow;
   Config.rsi_period      = InpRSIPeriod;
   Config.rsi_threshold_buy  = InpRSIThresholdBuy;
   Config.rsi_threshold_sell = InpRSIThresholdSell;
   Config.macd_fast = InpMACDFast;
   Config.macd_slow = InpMACDSlow;
   Config.macd_signal = InpMACDSignal;
   Config.atr_period = InpATRPeriod;
   Config.atr_multiplier = InpATRRMultiplier;
   Config.risk_percent = InpRiskPercent;
   Config.risk_reward = InpRiskReward;
   Config.max_daily_trades = InpMaxDailyTrades;
   Config.max_daily_loss = InpMaxDailyLoss;
   Config.max_drawdown = InpMaxDrawdown;
   Config.max_spread_points = InpMaxSpreadPoints;
   Config.slippage_points = InpSlippage;
   Config.min_candle_points = InpMinCandlePoints;
   Config.use_adx = InpUseADX;
   Config.adx_period = InpADXPeriod;
   Config.adx_threshold = InpADXThreshold;
   Config.news_filter = InpNewsFilter;
   Config.close_opposite = InpCloseOpposite;
   Config.prevent_duplicate = InpPreventDuplicate;

   if(Config.ema_fast_period<=0 || Config.ema_slow_period<=0) return false;
   if(Config.rsi_period<=0) return false;
   if(Config.atr_period<=0) return false;
   if(Config.risk_percent<=0 || Config.risk_percent>10) return false;
   if(Config.risk_reward<=0) return false;

   return true;
  }
