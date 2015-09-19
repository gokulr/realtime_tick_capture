
// knowledge required (read up on it if these terms don't mean anything to you):
// - q data structures: dictionaries and operations on dictionaries (extract key/value, apply functions to dicts, etc.)
// - ipc: socket handles, sync and async message passing
// - adverbs (each , each-both , apply each-both (@'), could all come in handy in this part of the exercise)
// - projections

/
 message fids:
 1 - sym
 2 - size
 3 - price
 4 - bid
 5 - ask
 6 - bsize
 7 - asize
 trade msg: "1=VOD.L;3=200.014;2=631044"
 quote msg: "1=VOD.L;4=195;5=200;6=40000;7=5258"
 messages arrive nested, e.g. trade and quote into upd can look like:
 ("1=BARC.L;4=285.1;5=285.25;6=5172;7=5735";"1=VOD.L;4=196.3;5=196.4;6=14700;7=68414";"1=VOD.L;4=196.35;5=196.45;6=77938;7=85582")
 and if only one message, assume it's enlisted as in
 enlist "1=`VOD.L;2=100.10;3=500"

 NOTE: fid-value pairs order is not guaranteed, i.e. "1=BASFn.DE;3=66.58;2=8" as well as "1=BASFn.DE;2=8;3=66.58" are valid messages
\

// code                                                                         instructions/steps to follow

\l utils.q                                                                      / load util functions

TP:frmt_handle get_param`tp;                                                    / get tickerplant host:port

// setup the process
TPH:hopen TP;                                                                           / connect to tickerplant on localhost and port 5000;
                                                                                / store handle in TPH global var

// trade & quote global caches to collect data
// - one row is a nested list, so (row1;row2;...;rown)
//   where rowX is e.g. (`VOD.L;10.1;100)
TRADES:QUOTES:();                                                               / init TRADES and QUOTES caches to empty list

// trade fids!parse_types to extract
TRADE_FIDS:1 2 3!({"S"$x};{"I"$x};{"F"$x});                                     / setup sym,size,price fid and cast mappings (TRADE_FIDS global)
// quote fids!parse_types to extract
QUOTE_FIDS:1 4 5 6 7!({"S"$x};{"F"$x};{"F"$x};{"I"$x};{"I"$x});                 / setup sym,bid,ask,bsize,asize fid and cast mappings (QUOTE_FIDS global)


// helper functions for prasing/casting strings to correct types


// types - fid-type_cast pairs, e.g. TRADE_FIDS
// m - parse message, fid-string_value pair,
//     e.g 1 2 3!("VOD.L";"200.014";"1000")
// return - dict with fid-value pairs; values are now of correct type (float, int, etc.)
map_types:{[types;m]
  :{(x@y)@z@y}[types;;m] each key m                                             / cast string values to types
 };

// generic parse function
// m - message to parse
// c - cache to append to (either `TRADES or `QUOTES)
// tf - dict of fid-type mapping functions
// return - nothing
prs:{[m;c;tf]
  c upsert enlist map_types[tf;m]                                               / parse message and append to relevant cache
 };

// define parse projections for trade and quote events
tparse:prs[;`TRADES;TRADE_FIDS];                                                / cast to correct types using TRADE_FIDS and append to TRADES
qparse:prs[;`QUOTES;QUOTE_FIDS];                                                / cast to correct types using QUOTE_FIDS and append to QUOTES

// parse given message format to dicts (fid-value pairs)
// s - string to parse

p:{[s]
 (!). "I=;"0: s
 };                                                                             / could be rewritten with vs function even if inefficient

// main parse function to parse a message
// m - message in string format (see above for "protocol" explanation)
// return - nothing
mparse:{[m]
 m:p m;                                                                         / parse strings to key-value pairs (key is the fid, so fid-value pairs)
 if[any ((key m)except 1) in key TRADE_FIDS;tparse m];                          / if any fid in trade specific fids (sym doesn't count) parse trades
 if[any ((key m)except 1) in key QUOTE_FIDS;qparse m];                          / if any fid in quote specific fids (sym doesn't count) parse quotes
 };

// publish helper function
// t - table to publish on (think of table as topic)
// d - data to publish
// hint: t is a symbol, `trade or `quote
// return - nothing
pubh:{[t;d]
 (neg TPH)(`upd;`t;d);                                                                          / if there is data in d, publish (async) on table t
 };

// publishes trade and quote events
// return - nothing
pub:{[t;d]
 pubh[t;d]                                                                              / publish trade and quote using pubh helpder function

 };

// simulator callback function
// function parses strings, and publishes them
// msgs - list of messages (strings) to parse  (see above protocol)
//        see above explanation for message format
// return - nothing
upd:{[msgs]
  mparse each msgs;                                                                             / parse each message using mparse function
  pub[`trade;TRADES];
  pub[`quote;QUOTES];                                                                           / pub all messages in caches
  TRADES::QUOTES::();                                                           / reset caches to empty lists
 };





