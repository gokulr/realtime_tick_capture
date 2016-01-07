\l utils.q                                    / load the utils file

// load the HDB from the start up param
HDB:get_param[`db];
value"\\l ",HDB;


// returns trades for a given date and sym list
get_trades:{[d;syms]
 :select from trade where date=d,sym in syms;
 }


/
  returns daily volume for all syms in the table.
  Returned columns should be: total number of traded shares and total notional trade per sym.
  Notional is size * price
\
get_daily_volume:{[d;syms]
 :select accvol:sum size, notional:sum size*price  by sym from trade where date=d, sym in syms;
 }
