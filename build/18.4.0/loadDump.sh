#!/bin/bash

sqlplus -s / as sysdba << EOF
create tablespace datos 
default storage (
initial     40960
next        40960
minextents  1
maxextents  unlimited
pctincrease 0
)
permanent
datafile
'datos_01.dbf' size 50m
autoextend on next 50m maxsize 4000m;

create tablespace indx
default storage (
initial     40960
next        40960
minextents  1
maxextents  unlimited
pctincrease 0
)
permanent
datafile
'indices_01.dbf' size 50m
autoextend on next 50m maxsize 4000m
;
create directory EXPORTFULLNODO2 as '/tmp/dump';
exit;
EOF
IFS=', ' read -r -a array <<< "$DUMP_FILES"
for element in "${array[@]}"
do
    echo "Loading dump file $element"
    impdp system/$ORACLE_PWD@localhost:1521 directory=EXPORTFULLNODO2 dumpfile=$element version=11.2.0.4.0 
    #logfile=$DUMP_LOG_FILE 
done

