// indicators/macd.mqh

struct MACDData { double main; double signal; bool isBearishCrossover; bool isBullishCrossover; };
int g_handle_macd=-1;

def MACDData MACD_Value(int fast,int slow,int signal)
  {
   MACDData d; d.main=EMPTY_VALUE; d.signal=EMPTY_VALUE; d.isBearishCrossover=false; d.isBullishCrossover=false;
   if(g_handle_macd<0) g_handle_macd = iMACD(_Symbol,PERIOD_CURRENT,fast,slow,signal,PRICE_CLOSE);
   double mainArr[3]; double signalArr[3];
   if(CopyBuffer(g_handle_macd,0,0,3,mainArr)<=0) return d;
   if(CopyBuffer(g_handle_macd,1,0,3,signalArr)<=0) return d;
   d.main = mainArr[0]; d.signal = signalArr[0];
   // Crossover detection: previous bar
   if(mainArr[1]>signalArr[1] && mainArr[0]<signalArr[0]) d.isBearishCrossover=true;
   if(mainArr[1]<signalArr[1] && mainArr[0]>signalArr[0]) d.isBullishCrossover=true;
   return d;
  }
