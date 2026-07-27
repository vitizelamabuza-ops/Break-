// logging.mqh - simple file logging

bool g_logOpened=false;
int  g_logHandle=-1;

bool LoggingInit()
  {
   string name = StringFormat("/MQL5/Files/BreakEA_log_%s.txt",_Symbol);
   g_logHandle = FileOpen(name,FILE_WRITE|FILE_APPEND|FILE_ANSI);
   if(g_logHandle<0) return false;
   g_logOpened=true;
   FileWrite(g_logHandle,StringFormat("\n=== Log start %s ===\n",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)));
   return true;
  }

void LoggingClose()
  {
   if(g_logOpened && g_logHandle>=0) FileClose(g_logHandle);
   g_logOpened=false; g_logHandle=-1;
  }

void Log(const string text)
  {
   if(g_logOpened && g_logHandle>=0) FileWrite(g_logHandle,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)+" " + text);
  }

void LogTradeEntry(ulong ticket,int type,double volume,double sl,double tp,const string reason)
  {
   string line = StringFormat("ENTRY ticket=%I64u type=%d vol=%.2f SL=%.5f TP=%.5f reason=%s",ticket,type,volume,sl,tp,reason);
   Log(line);
  }
