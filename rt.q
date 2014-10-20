
// knowledge required (read up on it if these terms don't mean anything to you):
// - q data structures: lists/vectors (and nested lists), tables
// - file i/o and file handles
// - ipc: sync and async message passing, socket handles
// - usage of -11!
// - q internal callbacks (.z.pc and .z.ts in particular)
// - attributes
// - .Q.dpft function
// - q timer
// - date-partitioned historical databases and their structure, advantages, etc.
// - in general sub/pub architectures

\l utils.q

check_params[`tp`hdb;"q rt.q -tp localhost:5000 -hdb /tmp/taq/"];

TP:frmt_handle get_param`tp;							/ tickerplant handle
HDB:frmt_handle get_param`hdb;							/ database partition to save data to

// define the replay function
// l - log to replay
// seq - up to which sequence number to replay
// hint: check 11! and its variances at http://code.kx.com/wiki/Reference/BangSymbolInternalFunction#.E2.88.9211.21x
replay:{[l;seq] 					
 										/ replay number seq chunks of data
 };

// sub to tp handle
// tp - tp handle name, e.g. `:localhost:5000
sub_tp:{[tp]
  										/ open connection
  										/ subscribe to tickerplant; tp will trigger set schemas and trigger replay
 };

// callbacks from tp all arrive on upd 
// we could provide callback, but won't do it for simplicity reasons
// so let's set upd to insert
// t - table to insert to (table is a symbol, `trade or `quote)
// d - data to insert (list of vectors)
upd:{[t;d] 
 										/ insert data into target table
 };

// save function
// we always partition on sym
// dp - database path
// d - date partition to save to
// t - table to save (symbol, e.g. `trade)
save_t:{[dp;d;t]
  .log.info"Save table ",(string t),". Number of records in table: ", string count get t;
  										/ sort table by sym
  										/ save - check reference docs for .Q.dpft
   empty t;									/ delete from table, but keep `g#
  .log.info"Finished saving table ", string t;
 };

// eod function
// d - date to save to
eod:{[d]
  .log.info"Start saving tables.";
  										/ save any table in root to disk
  .log.info"Finnished saving tables.";
  exit 0;									/ exit safely
 };

// setup process
init:{[]
  .log.info"Subscribe to tickerplant";
  										/ subscribe to tp
 };

init[];
