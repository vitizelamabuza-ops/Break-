// utils.mqh - helper utilities

void LogPrint(const string fmt)
  {
   // simple wrapper to Print and File log via Logging functions
   string msg = fmt;
   Print(msg);
   if(g_logOpened && g_logHandle>=0) FileWrite(g_logHandle,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)+" " + msg);
  }

string StringTrim(const string s)
  {
   int i=0,j=StringLen(s)-1;
   while(i<=j && StringGetCharacter(s,i)==32) i++;
   while(j>=i && StringGetCharacter(s,j)==32) j--;
   if(i>j) return "";
   return StringSubstr(s,i,j-i+1);
  }
