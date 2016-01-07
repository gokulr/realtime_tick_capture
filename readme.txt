TICK ARCHITECTURE OVERVIEW

In short, a tick setup constists of a tickerplant process (tp), which logs incoming data and a real-time database (rt), which is a tickerplant subscriber.
The rt keeps all data fed into the tp in-memory, then saves it down at end-of-day (usually midnight).
A historical database (hdb) then makes the database available for historical analytics.
A tp can have other subscribers, like calculation engines, java consumers, etc.
Feedhandlers (fh) publish into a tp; they can be written in java, c/c++, q, etc. You will write a feedhandler in q off simulated market data.

architecture setup (data flow): fh -> tp -> rt -> hdb

FINAL TECHNICAL SETUP

- start tp on port 5000: 				q tp.q -p 5000 -tp_path /tmp
- start fh on port 4000: 				q fh.q -p 4000 -tp localhost:5000
- start simulator: 					q simu.q -fh localhost:4000 -data data/msgs
- start rt on port 5001: 				q rt.q -p 5001 -tp localhost:5000 -hdb /tmp/taq
- start historical database on port 5002: 		q hdb.q -p 5002 -db /tmp/tick
- you could set up multiple RT's; go on play around; can set up one which keeps latest status and what not
