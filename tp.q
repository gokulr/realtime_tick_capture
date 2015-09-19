
// knowledge required (read up on it if these terms don't mean anything to you):
// - q data structures: lists/vectors (and nested lists), tables
// - file i/o and file handles
// - ipc: sync and async message passing, socket handles
// - usage of -11!
// - q internal callbacks (.z.pc and .z.ts in particular)
// - attributes
// - adverbs (each-left, each);
// - q timer
// - in general sub/pub architectures


// code                                                                 instructions/steps

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

// path - path to log to
// d - log date
// return - nothing
set_log_name:{[path;d]
                                                                        / set log name L, format should be /path_to_log_to/ticker_plant-YYYY.MM.DD
 };

// init log to empty log if not existent yet
// return - nothing
create_log:{[]
                                                                        / initialise log on disk to empty list
 };

// sets the sequence number (number of messages logged so far)
// return - nothing
set_seq_num:{[l]
                                                                        / find number messages logged so far and
                                                                        / set SEQ that number (use and most importantly understand -11!)
 };

// init function - sets up the process
init:{
                                                                        / set logname globally, so we can accecss it in the process
                                                                        / init the log
                                                                        / set SEQ
                                                                        / set timer to run ever 1 second
 };

// publish a table to all subscribes
// t - the table to publish; t is a sym, e.g. `trade
// return - nothing
pub:{[t]
                                                                        / publish if any subscribers
 };

// adds a subscriber to the subscribers' list
// h - subscriber handle
// return - nothing
sub:{[h]
                                                                        / add handle to SUBS
 };

// function called by subscriber to subscribe to trade/quote (all) tables
// hint: read up on .z.w, you will need it here.
// return - nothing
tp_sub:{[]
                                                                        / reply with all tables and schemas, and set them client-side
                                                                        / finally send back log and last sequence number
                                                                        / call generic subscription logic
 };

// stamps the data with current time
// d - nested list of data
// return - list of vectors (first one being the time vector)
timestamp:{[d]
                                                                        / timestamp data with TP time of arrival
 };

// log event
// e - event of type (`upd;`trade;nested_data);
// return - nothing
// explanation:
//   event e will be used on replay by real-time database;
//   real-time database will just evaluate each parse tree,
//   aka call value (`upd;`trade;nested_data)
log_to_tp:{[e]
                                                                        / append to log
 };

// upd function - this is the feehandler callback function on publish
// t - table to publish data on (you could also imagine table as a topic)
// d - data for table. d is a mixed nested list (rectangular matrix)
//     basically fh sends one vector per column, as in (a1 a2 a3;b1 b2 b3;c1 c2 c3;d1 d2 d3;...)
// return - nothing
upd:{[t;d]
 0N!d;                                                                  / increase sequence number
                                                                        / timstamp the data
                                                                        / log to tickerplant log on disk
                                                                        / publish table t
  empty t;                                                              / empty the cache (delete from table but keeps `g# on sym)
 };

// function that triggers eod on all subscribers
// "eod" function is the callback on subscribers
// eod expects a date as param (the date partition to save data to)
// return - nothing
trigger_eod:{[]
  .log.info"Trigger end-of-day event on all subscribers.";
                                                                        / publish eod event to all subscribers, if any
 };


// internal callback overrides follow here

// implement .z.ts such that it calls eod function if midnight passed
// return - nothing
.z.ts:{[]
                                                                        / if midnight passed, trigger eod on subscribers
 };

// on connection close
// h - closing handle
// return - nothing
.z.pc:{[h]
  .log.info"Close connection of handle ",  string h;
                                                                        / remove subscriber from SUBS
 };

// start the process with init call


