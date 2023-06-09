#!/bin/sh

# RESET NODE SH
# Reset a given node and all its children, forcing a re-run

if [ ${#} != 2 ]
then
  echo "$0: Provide: <DB file> <NODE>"
  exit 1
fi

DB=$1
NODE=$2

sqlite3 $DB <<EOF
update runhist SET status="RESET" where (length(subplan_id) > 5 );
EOF


# UPDATE runhist SET status="RESET" WHERE (subplan_id LIKE "${NODE}%") ;
# EOF
