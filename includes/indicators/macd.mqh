// indicators/macd.mqh - symbol-scoped MACD (main & signal) and simple crossover detection

struct MACDData { double main; double signal; bool isBearishCrossover; bool isBullishCrossover; };

MACDData MACD_Value(const string symbol,int fast,int slow,int signal)
  {
   MACDData d; d.main=EMPTY_VALUE; d.signal=EMPTY_VALUE; d.isBearishCrossover=false; d.isBullishCrossover=false;
   int handle = iMACD(symbol,PERIOD_CURRENT,fast,slow,signal,PRICE_CLOSE);
   if(handle==INVALID_HANDLE) return d;
   double mainArr[]; double signalArr[];
   ArrayResize(mainArr,3); ArrayResize(signalArr,3);
   if(CopyBuffer(handle,0,0,3,mainArr)<=0) { IndicatorRelease(handle); return d; }
   if(CopyBuffer(handle,1,0,3,signalArr)<=0) { IndicatorRelease(handle); return d; }
   d.main = mainArr[0]; d.signal = signalArr[0];
   if(mainArr[1]>signalArr[1] && mainArr[0]<signalArr[0]) d.isBearishCrossover=true;
   if(mainArr[1]<signalArr[1] && mainArr[0]>signalArr[0]) d.isBullishCrossover=true;
   IndicatorRelease(handle);
   return d;
  }
