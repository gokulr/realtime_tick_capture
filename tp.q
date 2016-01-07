/
  q data structures used:- lists/vectors (and nested lists), tables
  concepts used:- file i/o and file handles, ipc: sync and async message passing, socket handles, 
  internal callbacks (.z.pc and .z.ts in particular), sub/pub architectures
\

\l utils.q                                                              / load utils funcs
\l tick_schema.q                                                        / load schemas

check_params[`tp_path;"q tp.q -p 5000 -tp_path /tmp"];                  / check all params got passed

// setup globals (some from params)
LPATH:get_param`tp_path;                                                / tickerplant log path
CDATE:.z.D;                                                             / current date
SEQ:0;                                                                  / sequence number - needed for real-time database replay
L:();                                                                   / log name
SUBS:();                                                                / set subscribers list - a simple list of socket handlers

// tp log util funcs

/
  path - path to log to
  d - log date
  return - nothing
\
set_log_name:{[path;d]
 `L set hsym `$path,"/ticker_plant-",string d;                          / set log name L, format should be /path_to_log_to/ticker_plant-YYYY.MM.DD
 };

/
  init log to empty log if not existent yet
  return - nothing
\
create_log:{[]
 if[not count key L; L set ()];                                         / initialise log on disk to empty list
 };

/
  sets the sequence number (number of messages logged so far)
  return - nothing
\
set_seq_num:{[l]
 `SEQ set -11!(-2;l);                                                   / find number messages logged so far and set SEQ that number using -11!
 };

/
  init function - sets up the process
\
init:{
 set_log_name[LPATH;CDATE];                                     / set logname globally, so we can accecss it in the process
 create_log[];                                                  / init the log
 set_seq_num[L];                                                / set SEQ
 value "\\t 1000";                                              / set timer to run ever 1 second
 };

/
  publish a table to all subscribes
  t - the table to publish; t is a sym, e.g. `trade
  return - nothing
  try to use each left instead of loop IDIOT
\
pub:{[t]
 if[count SUBS;  {[t;x] (neg x)(`upd;t;value t)}[t;]each SUBS];                                 / publish if any subscribers
 };

/
  adds a subscriber to the subscribers' list
  h - subscriber handle
  return - nothing
\
sub:{[h]
 SUBS,::h;                                                                      / add handle to SUBS
 };

/
  function called by subscriber to subscribe to trade/quote (all) tables
  .z.w is DA BOMB
  return - nothing
\
tp_sub:{[]
 (neg .z.w)(set';tables`;get each tables`);                     / reply with all tables and schemas, and set them client-side
 (neg .z.w)(`replay;L;SEQ);                                     / finally send back log and last sequence number
 sub(.z.w);                                                     / call generic subscription logic
 };

/
  stamps the data with current time
  d - nested list of data
  twisted and interesting piece!!!!
  return - list of vectors (first one being the time vector)
\
timestamp:{[d]
 :(enlist(max count each d)#.z.T),d;                            / timestamp data with TP time of arrival
 };

/
  log event to TP log file
  e - event of type (`upd;`trade;nested_data);
  return - nothing
  explanation:
    event e will be used on replay by real-time database;
    real-time database will just evaluate each parse tree,
    aka call value (`upd;`trade;nested_data)
    cool stuff huh!!
\
log_to_tp:{[e]
 .[L;();,;e];                                                   / append to log
 };

/
  upd function - this is the feehandler callback function on publish
  t - table to publish data on (you could also imagine table as a topic)
  d - data for table. d is a mixed nested list (rectangular matrix)
  basically fh sends one vector per column, as in (a1 a2 a3;b1 b2 b3;c1 c2 c3;d1 d2 d3;...)
  return - nothing
\
upd:{[t;d]
 SEQ+:1;                                                                / increase sequence number
 d:timestamp[d];                                                        / timstamp the data
 log_to_tp[enlist(`upd;t;d)];                                           / log to tickerplant log on disk
 t insert d;
 pub[t];                                                                / publish table t
 empty t;                                                               / empty the cache (delete from table but keeps `g# on sym)
 };


/
  function that triggers eod on all subscribers
  "eod" function is the callback on subscribers
  eod expects a date as param (the date partition to save data to)
  return - nothing
  AGAIN USE @\: IDIOT
\
trigger_eod:{[]
  .log.info"Trigger end-of-day event on all subscribers.";
  if[count SUBS;{(neg x)(`eod;CDATE)}each SUBS];                      / publish eod event to all subscribers, if any
 };


/
  implement .z.ts (the timer) such that it calls eod function if midnight passed
  return - nothing
\
.z.ts:{[]
 if[CDATE<.z.D;                 / check if midnight has passed
    trigger_eod[];              / trigger eod funcs for the RDB to save down
    CDATE::.z.D;                / change current date to the next day
    SEQ::0;                     / reset sequence number
    L::();                      / reset log file and prepare to create a new log file
    SUBS::();                   / reset subscribers; although is it needed?
    init[]];                    / reinitialize TP
 };

/
  on connection close
  h - closing handle
  return - nothing
\
.z.pc:{[h]
  .log.info"Close connection of handle ",  string h;
  SUBS::SUBS _SUBS?h;                                         / remove subscriber from SUBS
 };

// start the process with init call
init[];
