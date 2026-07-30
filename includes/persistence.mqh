#ifndef __INCLUDES_PERSISTENCE_MQH__
#define __INCLUDES_PERSISTENCE_MQH__
// persistence.mqh - track daily P/L and trade counts per symbol (portable append behavior)

struct SDailyStats { string date; double dailyPL; int dailyTrades; };

SDailyStats g_daily_stats[]; // keyed by symbol index in global symbols list

string DateKey(datetime t)
  {
   MqlDateTime dt; TimeToStruct(t,dt);
   return(StringFormat("%04d%02d%02d",dt.year,dt.mon,dt.day));
  }

void PersistenceLoad(const string symbol)
  {
   string fname = StringFormat("BreakEA_stats_%s.csv",symbol);
   int handle = FileOpen(fname, FILE_READ|FILE_ANSI|FILE_COMMON);
   if(handle<0)
     {
      // create file with today's baseline
      SDailyStats s; s.date = DateKey(TimeCurrent()); s.dailyPL=0; s.dailyTrades=0;
      int h = FileOpen(fname, FILE_WRITE|FILE_ANSI|FILE_COMMON);
      if(h>=0)
        {
         FileWrite(h, StringFormat("%s,%.2f,%d", s.date, s.dailyPL, s.dailyTrades));
         FileClose(h);
        }
      return;
     }
   // read last non-empty line
   string lastLine="";
   while(!FileIsEnding(handle)) { string line = FileReadString(handle); if(StringLen(StringTrim(line))>0) lastLine=line; }
   FileClose(handle);
   if(StringLen(lastLine)==0) return;
   string parts[]; int n=StringSplit(lastLine,',',parts);
   if(n>=3)
     {
      SDailyStats s; s.date = parts[0]; s.dailyPL = StringToDouble(parts[1]); s.dailyTrades = (int)StringToInteger(parts[2]);
      // kept in memory if needed
     }
  }

void PersistenceSave(const string symbol)
  {
   (void)symbol; // no-op placeholder
  }

void PersistenceRegisterTrade(const string symbol,datetime when,ulong ticket,int type)
  {
   string fname = StringFormat("BreakEA_stats_%s.csv",symbol);
   string key = DateKey(when);
   double lastPL=0; int lastTrades=0; string lastDate="";
   int h = FileOpen(fname, FILE_READ|FILE_ANSI|FILE_COMMON);
   if(h>=0)
     {
      string lastLine="";
      while(!FileIsEnding(h)) { string line = FileReadString(h); if(StringLen(StringTrim(line))>0) lastLine=line; }
      FileClose(h);
      if(StringLen(lastLine)>0)
        {
         string parts[]; int n=StringSplit(lastLine,',',parts);
         if(n>=3) { lastDate = parts[0]; lastPL = StringToDouble(parts[1]); lastTrades = (int)StringToInteger(parts[2]); }
        }
     }
   if(lastDate==key)
     {
      lastTrades++;
      int h2 = FileOpen(fname, FILE_WRITE|FILE_ANSI|FILE_COMMON);
      if(h2>=0)
        {
         FileSeek(h2, 0, SEEK_END);
         FileWrite(h2, StringFormat("%s,%.2f,%d", key, lastPL, lastTrades));
         FileClose(h2);
        }
     }
   else
     {
      int h2 = FileOpen(fname, FILE_WRITE|FILE_ANSI|FILE_COMMON);
      if(h2>=0)
        {
         FileSeek(h2, 0, SEEK_END);
         FileWrite(h2, StringFormat("%s,%.2f,%d", key, 0.0, 1));
         FileClose(h2);
        }
     }
  }

#endif
