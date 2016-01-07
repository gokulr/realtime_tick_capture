/ init schema for trade table
trade:([] 
  time:`time$();
  sym:`g#`$();
  price:`float$();
  size:`int$()
  );

/ init schema for quote table
quote:([] 
  time:`time$();
  sym:`g#`$();
  bid:`float$();
  ask:`float$(); 
  bsize:`int$();
  asize:`int$()
 );
