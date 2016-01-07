/
 data structures used:- lists/vectors (and nested lists), tables
 concepts used:- file i/o and file handles, ipc: sync and async message passing, socket handles
 internal callbacks (.z.pc and .z.ts in particular), .Q.dpft function
 date-partitioned historical databases and their structure, advantages, etc.
 and in general sub/pub architectures
\

\l utils.q                                                       / load utils file

check_params[`tp`hdb;"q rt.q -tp localhost:5000 -hdb /tmp/taq/"];

TP:frmt_handle get_param`tp;                                     / tickerplant handle
HDB:frmt_handle get_param`hdb;                                   / database partition to save data to

/
 define the replay function
 l - log to replay
 seq - up to which sequence number to replay
\
replay:{[l;seq]
 -11!(seq;l);                                                   / replay number seq chunks of data
 };

/
 sub to tp handle
 tp - tp handle name, e.g. `:localhost:5000
\ 
sub_tp:{[tp]
  TPH:hopen tp;                                                 / open connection
  TPH"tp_sub[]";                                                / subscribe to tickerplant; tp will trigger set schemas and trigger replay
 };

/
 callbacks from tp all arrive on upd
 we could provide callback, but won't do it for simplicity reasons
 so let's set upd to insert
 t - table to insert to (table is a symbol, `trade or `quote)
 d - data to insert (list of vectors)
\
upd:{[t;d]
 t insert d;                                                / insert data into target table; simple huh!
 };

/
 save function
 we always partition on sym
 dp - database path
 d - date partition to save to
 t - table to save (symbol, e.g. `trade)
\
save_t:{[dp;d;t]
  .log.info"Save table ",(string t),". Number of records in table: ", string count get t;
  .Q.dpft[dp;d;`sym;t];                                                         / sort table by sym
   empty t;                                                                     / delete from table, but keep `g#
  .log.info"Finished saving table ", string t;
 };


/
 eod function
 d - date to save to
\
eod:{[d]
  .log.info"Start saving tables.";
  if[count tables[]; save_t[HDB;d;] each tables[]];                             / save any table in root to disk
  .log.info"Finnished saving tables.";
  exit 0;                                                                       / exit safely
 };

// setup process
init:{[]
  .log.info"Subscribe to tickerplant";
   sub_tp[TP];                                                                  / subscribe to tp
 };

init[];
