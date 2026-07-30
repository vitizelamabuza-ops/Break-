#ifndef __INCLUDES_LOGGING_MQH__
#define __INCLUDES_LOGGING_MQH__

// logging.mqh - simple file logging
// Changes:
// - Ensure FileOpen uses FILE_COMMON for portable storage (still supports the provided filename style).
// - Added header guards and comments. Kept function names same so EA call sites remain unchanged.

bool g_logOpened=false;
int  g_logHandle=-1;

bool LoggingInit()
  {
   string name = StringFormat("BreakEA_log_%s.txt",_Symbol);
   // Use FILE_COMMON so files are available in the MQL5 Files folder (shared)
   g_logHandle = FileOpen(name, FILE_WRITE|FILE_APPEND|FILE_ANSI|FILE_COMMON);
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

void LogPrint(const string text)
  {
   // simple wrapper to Print and File log via Logging functions
   string msg = text;
   Print(msg);
   if(g_logOpened && g_logHandle>=0) FileWrite(g_logHandle, TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS) + " " + msg);
  }

void LogTradeEntry(ulong ticket,int type,double volume,double sl,double tp,const string reason)
  {
   string line = StringFormat("ENTRY ticket=%I64u type=%d vol=%.2f SL=%.5f TP=%.5f reason=%s",ticket,type,volume,sl,tp,reason);
   LogPrint(line);
  }
#endif
