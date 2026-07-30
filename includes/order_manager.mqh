#ifndef __INCLUDES_ORDER_MGR_MQH__
#define __INCLUDES_ORDER_MGR_MQH__
// order_manager.mqh - minimal wrappers for compatibility and missing identifiers
// - Provides safe wrappers for APIs that may be referenced in older code or other includes

// Compatibility constants (only define if missing)
#ifndef FILE_APPEND
  #define FILE_APPEND 8
#endif

#ifndef TRADE_RETCODE_DONE_REMAINDER
  // Define fallback constant if platform does not expose it; prefer not to override if it exists.
  #define TRADE_RETCODE_DONE_REMAINDER 1001
#endif

// No-op wrapper, present so other modules can call it if needed
bool PositionSelectByIndexWrapper(int index, ulong &ticket)
  {
   // Best-effort: iterate through positions and return ticket at index
   int total = PositionsTotal();
   if(index<0 || index>=total) return(false);

   // There is no direct PositionGetTicket(index) function that returns ticket without selecting;
   // iterate through all positions and find those matching enumerator via PositionGetTicket from PositionGetInteger
   // unfortunately the standard API doesn't give index-based selection; so we emulate:
   int found = 0;
   for(int i=0;i<total;i++)
     {
      ulong t = PositionGetTicket(i); // Note: PositionGetTicket(i) is available in modern builds
      if(t==0) continue;
      if(found==index) { ticket = t; return(true); }
      found++;
     }
   return(false);
  }
#endif
