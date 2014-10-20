/
// get sample data to replay
h:hopen`:eqkdb2p:9013:kdbadmin:xxxxxxx
trade:h"select time,sym,price,size from trade where date=max date,sym in `VOD.L`BARC.L`BASFn.DE,price>0";
quote:h"select time,sym,bid,ask,bsize,asize from quote where date=max date,sym in `VOD.L`BARC.L`BASFn.DE,bid>0,ask>0,ask>bid";

// fids mappings
m:`sym`size`price`bid`ask`bsize`asize!1+til 7;
msgs:(raze {";" sv "=" sv/: string flip (m key x;value x)} each' (delete time from trade;delete time from quote)) i:iasc it:raze (trade;quote)[;`time];
// bucket my 1 ms
msgs:value msgs group 1 xbar it i;
\
\l utils.q

// set globals (some from params)
check_params[`fh;"q simu.q -fh localhost:4000 -data data/msgs"];
FH:frmt_handle get_param`fh;
DATA:frmt_handle get_param`data;

init:{[]
 h::hopen FH;
 msgs::get DATA;
 SEQ::0;
 };

pub:{[]
  neg[h](`upd;msgs SEQ);
  SEQ+:1;
  if[ SEQ>-1+count msgs; SEQ::0 ]; 						 // loop through messages again from start
 };

init[];
/
usage:
publish 1 message: pub[]
publish 10 messages: do[10; pub[] ];

