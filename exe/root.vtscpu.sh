#!/bin/sh
#---------------------------------#
# cpu watch for vts               #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

PASS=`openssl rsautl -decrypt -inkey ${KEY} -in ${VTSADMIN_PASS}`
EXEC_SH=${EXE_DIR}/vmstat.sh
TODAY=`date "+%Y%m%d"`
LOG=${LOG_DIR}/${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

sshpass -p ${PASS} ssh ${VTS_ADMIN_USER}@${PRIMARY_VTS} < ${EXEC_SH} > ${LOG} 2>&1

# 実施コマンド名が出力されるので、DSMより1行多い
IDLE=`sed -n '7,$p' ${LOG}| head -n1| awk '{print $(NF-2)}'`
(( CPU = 100 - ${IDLE} ))

echo "CPU,${CPU}"

# rm -f ${LOG}
