#ifndef __INCLUDES_UTILS_MQH__
#define __INCLUDES_UTILS_MQH__
// utils.mqh - helper utilities

void LogPrint(const string fmt); // forward (implemented in logging.mqh)

string StringTrim(const string s)
  {
   int i=0,j=StringLen(s)-1;
   while(i<=j && StringGetCharacter(s,i)==32) i++;
   while(j>=i && StringGetCharacter(s,j)==32) j--;
   if(i>j) return "";
   return StringSubstr(s,i,j-i+1);
  }
#endif
