#!/bin/sh
#---------------------------------#
# cpu watch for dsm               #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

PASS=`openssl rsautl -decrypt -inkey ${KEY} -in ${ADMIN_PASS}`
EXEC_SH=${EXE_DIR}/vmstat.sh
TODAY=`date "+%Y%m%d"`
LOG=${LOG_DIR}/${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

for DSM_IP in ${PRIMARY_DSM_SERVER} ${SECONDARY_DSM_SERVER}
do
    sshpass -p ${PASS} ssh ${DSM_ADMIN_USER}@${DSM_IP} < ${EXEC_SH} > ${LOG} 2>&1

    # 実施コマンド名表示がない分、DSMの方がVTSより1行少ない
    # Ver変わって仕様変わった・・・
    IDLE=`sed -n '8,$p' ${LOG}| head -n1| awk '{print $(NF-2)}'`
    (( CPU = 100 - ${IDLE} ))

    echo "${DSM_IP},${CPU}"

    rm -f ${LOG}
done
