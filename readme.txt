
AIM OF TUTORIAL

The aim of this tutorial is to give you exposure to one of the most basic setups of a kdb+ architecture, a tick setup.
You will write a very basic and minimal tick setup from scratch, and you will get to see how much functionality you can build with little code (compared to other common oop languages or other procedural languages like c++, java, c, vba).
The aim is NOT to have a prod-ready tick setup with full resiliancy etc., but to get you coding on a "real" world project/problem.


TICK ARCHITECTURE OVERVIEW

In short, a tick setup constists of a tickerplant process (tp), which logs incoming data and a real-time database (rt), which is a tickerplant subscriber.
The rt keeps all data fed into the tp in-memory, then saves it down at end-of-day (usually midnight).
A historical database (hdb) then makes the database available for historical analytics.
A tp can have other subscribers, like calculation engines, java consumers, etc.
Feedhandlers (fh) publish into a tp; they can be written in java, c/c++, q, etc. You will write a feedhandler in q off simulated market data.

architecture setup (data flow): fh -> tp -> rt -> hdb

FINAL TECHNICAL SETUP (AIM)

- start tp on port 5001: 				q tp.q -p 5000 -tp_path /tmp
- start fh on port 4000: 				q fh.q -p 4000 -tp localhost:5000
- start simulator: 					q simu.q -fh localhost:4000 -data data/msgs
- start rt on port 5002: 				q rt.q -p 5001 -tp localhost:5000 -hdb /tmp/taq
- start historical database on port 5003: 		q hdb.q -p 5002 -db /tmp/tick

SOME NOTES ON Q PHILOSOPHY
- it's terse and expressive
- it aims for for simplicity (terseness is not seen as complexity - arguably that's right)
- let the compiler (aka c language) do the tricks; it's a high level language,
  think of ipc


SOME NOTES ON CODING STANDARDS
- Unlike mainstream languages, there are no widely followed coding standards, which can make q a horror to read, especially because of its tersness.
- If you fancy, you can read up on some coding standards here: http://www.nsl.com/papers/style.pdf; however, don't see this as the ultimate reference. 
  You will see that at the beginning you prefer verbose code, and the more you get an expert in q, you try to shorten as much as possible. 
  My favourite standard is to write readable and concise code, while being sensible at the same time. Someone will have to maintain your code eventually.
  And as with any language, choose a guideline and stick to it.

For this project we will try to stick to a few simple rules that will hopefully make q code readable and maintainable:
 - globals are all CAPITAL_CASE names; underscore can be used to make them more readable
 - function names follow c-style coding, e.g. get_param over getParam (in your own projects you are welcome to use camelCase style of course)
 - local vars should be of short names
 - avoid vars ending with _ ( _ is a q function)
 - no one-line function; instead a function always start with a signature and end with the closing curly bracket "}" on its own line followed by ";",  as in

	f:{[p]
	  p+1
	};

   is preferred over 

	f:{[p] p+1 };

 - define functions to have explicit parameters, don't rely on x,y,z implicit parameters supported by q.
 - don't use tab for identation, instead use 2-3 spaces (or set your vi/editor to small tabs)

