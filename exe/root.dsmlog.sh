#!/bin/sh
#---------------------------------#
# log get for dsm                 #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

PASS=`openssl rsautl -decrypt -inkey ${KEY} -in ${ADMIN_PASS}`
EXEC_SH=${EXE_DIR}/dsmlogget.sh
TODAY=`date "+%Y%m%d"`
LOG=${LOG_DIR}/${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

sshpass -p ${PASS} ssh ${DSM_ADMIN_USER}@${PRIMARY_DSM_SERVER} < ${EXEC_SH} > ${LOG} 2>&1

echo -e "\n ログ・・・${LOG}"
