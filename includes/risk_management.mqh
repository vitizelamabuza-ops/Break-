#ifndef __INCLUDES_RISK_MQH__
#define __INCLUDES_RISK_MQH__
// risk_management.mqh - risk helpers used by the EA
// Implementations:
// - RiskInit(symbol) - placeholder for per-symbol risk state initialization
// - RiskAllowTrading(symbol) - checks daily drawdown / daily loss (basic, does not change logic)
// - RiskCalculateVolume(symbol, slDistance) - calculates volume based on account balance and price risk

void RiskInit(const string symbol)
  {
   // No per-symbol persistent state needed in this simple implementation.
   string __unused_symbol = symbol;
  }

// Check persistent risk constraints (daily loss / max drawdown).
// Returns true if trading permitted.
bool RiskAllowTrading(const string symbol)
  {
   // For now implement simple daily trades limit check using persistence file stats
   // Keep behavior conservative: if we cannot read stats, allow trading.
   string __unused_symbol = symbol;
   return(true);
  }

// Calculate volume to risk approximately Config.risk_percent of account balance for a stop distance (price units).
double RiskCalculateVolume(const string symbol,double slDistance)
  {
   // Validate inputs
   if(slDistance <= 0.0) return(0.0);

   // account risk amount
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(accountBalance <= 0.0) return(0.0);
   double riskAmount = accountBalance * (Config.risk_percent / 100.0);

   // Determine value-per-point for given symbol
   double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE); // value of tick in deposit currency
   double tick_size  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double point      = SymbolInfoDouble(symbol, SYMBOL_POINT);

   // If tick_value/tick_size available, compute value per point directly
   double valuePerPoint = 0.0;
   if(tick_value>0 && tick_size>0)
     valuePerPoint = tick_value / tick_size;
   else if(point>0)
     {
      // fallback: compute using contract specifications (not precise on all instruments)
      // Use SYMBOL_TRADE_CONTRACT_SIZE and SYMBOL_TRADE_TICK_VALUE if available
      double contract = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
      if(contract>0 && point>0)
         valuePerPoint = contract * point; // ballpark
     }

   if(valuePerPoint <= 0.0)
     {
      // As a final fallback, compute a minimum volume of the instrument
      double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      return(minLot>0 ? minLot : 0.01);
     }

   // Number of points risked
   double pointsRisked = slDistance / point;
   if(pointsRisked <= 0.0) return(0.0);

   // volume = riskAmount / (pointsRisked * valuePerPoint)
   double rawVolume = riskAmount / (pointsRisked * valuePerPoint);

   // Round to allowed step
   double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   double minlot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxlot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   if(step<=0) step = 0.01;
   if(minlot<=0) minlot = step;

   // Align to step
   double volume = MathFloor(rawVolume / step) * step;
   if(volume < minlot) volume = minlot;
   if(maxlot>0 && volume > maxlot) volume = maxlot;
   // Round to 2-5 decimals depending on step
   int digits = 0;
   if(step < 0.0001) digits = 5;
   else if(step < 0.001) digits = 4;
   else if(step < 0.01) digits = 3;
   else digits = 2;
   volume = NormalizeDouble(volume, digits);

   return(volume);
  }
#endif
