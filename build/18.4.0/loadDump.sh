#!/bin/bash

createUser(){
sqlplus -s / as sysdba << EOF
alter session set "_ORACLE_SCRIPT"=true;  
create user $1
identified by $2
default tablespace BUPP
temporary tablespace temp 
profile default;
exit;
EOF
}

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
'idx_01.dbf' size 50m
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

IFS=', ' read -r -a array <<< "$SIIU_USERS"
for user in "${array[@]}"
do
    echo "Creating $user"
    createUser $user $ORACLE_PWD
done

IFS=', ' read -r -a array <<< "$DUMP_FILES"
for dump_file in "${array[@]}"
do
    echo "Loading dump file $dump_file"
    impdp system/$ORACLE_PWD@localhost:1521 tables=BUPP.SIIU_PROYECTO,BUPP.SIIU_CONVOCATORIA \
    directory=siiu_pump_dir dumpfile=$dump_file data_options=skip_constraint_errors version=11.2.0.4.0
    #query='BUPP.SIIU_PROYECTO:"where rownum <= (select count(*)/2 from BUPP.SIIU_PROYECTO)"' \
    #logfile=$DUMP_LOG_FILE 
done



