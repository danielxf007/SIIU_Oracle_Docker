#!/bin/bash

sqlplus -s / as sysdba << EOF
create tablespace BUPP
default storage (
initial     40960
next        40960
minextents  1
maxextents  unlimited
pctincrease 0
)
permanent
datafile
'bupp_01.dbf' size 50m
autoextend on next 50m maxsize 14000m;

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
create directory siiu_pump_dir as '/tmp/dump';

alter session set "_ORACLE_SCRIPT"=true;  
create user $SIIU_USER 
 identified by $ORACLE_PWD
 default tablespace BUPP
 temporary tablespace temp 
 profile default; 
grant connect to $SIIU_USER; 
grant resource to $SIIU_USER; 
grant create any view to $SIIU_USER; 
grant debug connect session to $SIIU_USER; 
grant unlimited tablespace to $SIIU_USER;
grant create session, create table, create procedure, exp_full_database, imp_full_database to $SIIU_USER;
GRANT IMP_FULL_DATABASE to $SIIU_USER;
ALTER USER $SIIU_USER DEFAULT ROLE ALL;
alter user $SIIU_USER identified by $SIIU_USER quota unlimited on indx; 
grant read, write on directory siiu_pump_dir to $SIIU_USER;

exit;
EOF
IFS=', ' read -r -a array <<< "$DUMP_FILES"
for element in "${array[@]}"
do
    echo "Loading dump file $element"
    impdp system/$ORACLE_PWD@localhost:1521 schemas=bupp directory=siiu_pump_dir dumpfile=$element version=11.2.0.4.0 
    #logfile=$DUMP_LOG_FILE 
done

