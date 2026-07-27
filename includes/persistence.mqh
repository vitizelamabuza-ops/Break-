// persistence.mqh - track daily P/L and trade counts per symbol

struct SDailyStats { string date; double dailyPL; int dailyTrades; };

SDailyStats g_daily_stats[]; // keyed by symbol index in global symbols list

// helper to format date as YYYYMMDD
string DateKey(datetime t)
  {
   MqlDateTime dt; TimeToStruct(t,dt);
   return(StringFormat("%04d%02d%02d",dt.year,dt.mon,dt.day));
  }

// Load stats from file for symbol
void PersistenceLoad(const string symbol)
  {
   string fname = StringFormat("/MQL5/Files/BreakEA_stats_%s.csv",symbol);
   g_daily_stats[ArraySize(g_daily_stats)-1]; // noop to avoid unused
   // If file exists, load latest line for symbol
   int handle = FileOpen(fname,FILE_READ|FILE_ANSI);
   if(handle<0)
     {
      // initialize file with today
      SDailyStats s; s.date = DateKey(TimeCurrent()); s.dailyPL=0; s.dailyTrades=0;
      // Save immediately
      int h = FileOpen(fname,FILE_WRITE|FILE_ANSI);
      if(h>=0)
        {
         FileWrite(h, StringFormat("%s,%.2f,%d",s.date,s.dailyPL,s.dailyTrades));
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
      SDailyStats s; s.date = parts[0]; s.dailyPL = StrToDouble(parts[1]); s.dailyTrades = (int)StrToInteger(parts[2]);
      // store in file with name scheme; for simplicity we keep a single current stats file per symbol
      // save to in-memory map by writing a file key per symbol
      // We'll use a simple approach: write latest values back on updates
     }
  }

void PersistenceSave(const string symbol)
  {
   string fname = StringFormat("/MQL5/Files/BreakEA_stats_%s.csv",symbol);
   // For now we'll append current date line with zeroed values if missing
   // This function is a placeholder; updates are done per trade by PersistenceRegisterTrade
   return;
  }

void PersistenceRegisterTrade(const string symbol,datetime when,ulong ticket,int type)
  {
   string fname = StringFormat("/MQL5/Files/BreakEA_stats_%s.csv",symbol);
   string key = DateKey(when);
   double pl=0.0; // try to read closed profit if immediate; we'll append zero and allow separate post-processing
   int h = FileOpen(fname,FILE_READ|FILE_ANSI);
   string lastDate=""; double lastPL=0; int lastTrades=0;
   if(h>=0)
     {
      string lastLine="";
      while(!FileIsEnding(h)) { string line=FileReadString(h); if(StringLen(StringTrim(line))>0) lastLine=line; }
      FileClose(h);
      if(StringLen(lastLine)>0)
        {
         string parts[]; int n=StringSplit(lastLine,',',parts);
         if(n>=3) { lastDate = parts[0]; lastPL = StrToDouble(parts[1]); lastTrades = (int)StrToInteger(parts[2]); }
        }
     }
   if(lastDate==key)
     {
      lastTrades++;
      // append new line with updated totals (PL unknown until close)
      int h2 = FileOpen(fname,FILE_WRITE|FILE_ANSI|FILE_APPEND);
      if(h2>=0) { FileWrite(h2,StringFormat("%s,%.2f,%d",key,lastPL,lastTrades)); FileClose(h2); }
     }
   else
     {
      int h2 = FileOpen(fname,FILE_WRITE|FILE_ANSI|FILE_APPEND);
      if(h2>=0) { FileWrite(h2,StringFormat("%s,%.2f,%d",key,0.0,1)); FileClose(h2); }
     }
  }
