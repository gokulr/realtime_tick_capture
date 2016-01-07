/
  logging utils
  lvl - level to log (DEBUG|ERROR|WARN|INFO)
  return - nothing
\
.log.log:{[lvl;str]
   -1 (string .z.Z)," : ", (string lvl), " ", str;                              /  log a string to stdout for level lvl
  };

// log level projections
.log.error:.log.log[`ERROR;];
.log.info:.log.log[`INFO;];
.log.warn:.log.log[`WARN;];
.log.debug:.log.log[`DEBUG;];

/ 
  get/check params utils
  p - param key to return value for
  return - value for given key
\
get_param:{[p]
 :first(.Q.opt .z.x)p                                                           / using .Q.opt, return value of given param key
 };

/
  function to check if all parameters have been passed on command line
  ps - parameter keys
  str - usage string, e.g. "q tp -p 5000 -tp_path /tmp"
  return - nothing
\
check_params:{[ps;str]
  ps:(),ps;                                                                     / make sure it's a list of parameter keys - takes care of 1 param only
  if[ 0b ;                                                                      / if not all params provided (replay 0b condition)
    .log.error"Need to provide all params.";                                    / print error message
    .log.info"Usage:\n\t",str;                                                  / print info usage message
    exit 1;                                                                     / and exit 1
  ];
 };

/
  p - handle as string in format host:port
  return - q handle as sym, e.g. `:host:port
\
frmt_handle:{[h]
  hsym `$h                                                                      / convert string into q handle
 };

/
  efficient in-place delete
  t - table to delete from
  return - nothing
\
empty:{[t]
  @[`.;t;0#];                                                                   / delete and keep sym
 };

