#ifndef __INCLUDES_IND_MACD_MQH__
#define __INCLUDES_IND_MACD_MQH__
// macd.mqh - symbol-scoped MACD helper that returns latest MACD values and simple crossover flags
// Changes:
// - Implemented MACD_Value returning MACDData structure
// - Uses CopyBuffer safely and IndicatorRelease on handle
// - Detects simple 1-bar crossover using the last two values

struct MACDData
  {
   double macd;
   double signal;
   double hist;
   bool   isBullishCrossover;
   bool   isBearishCrossover;
  };

MACDData MACD_Value(const string symbol,int fast,int slow,int signal)
  {
   MACDData res;
   res.macd = EMPTY_VALUE; res.signal = EMPTY_VALUE; res.hist = EMPTY_VALUE;
   res.isBullishCrossover = false; res.isBearishCrossover = false;

   int handle = iMACD(symbol, PERIOD_CURRENT, fast, slow, signal, PRICE_CLOSE);
   if(handle==INVALID_HANDLE) return(res);

   // We need the two most recent values to determine a crossover
   double mainBuf[2];
   double sigBuf[2];
   if(CopyBuffer(handle, 0, 0, 2, mainBuf) <= 0 || CopyBuffer(handle, 1, 0, 2, sigBuf) <= 0)
     {
      IndicatorRelease(handle);
      return(res);
     }

   // latest value index 0, previous index 1
   res.macd = mainBuf[0];
   res.signal = sigBuf[0];
   res.hist = res.macd - res.signal;

   // Detect crossovers: previous bar compared to current bar
   double prevMain = mainBuf[1];
   double prevSig  = sigBuf[1];

   if(prevMain < prevSig && res.macd > res.signal) res.isBullishCrossover = true;
   if(prevMain > prevSig && res.macd < res.signal) res.isBearishCrossover = true;

   IndicatorRelease(handle);
   return(res);
  }
#endif
