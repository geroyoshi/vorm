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
EXEC_SH=${CFG_DIR}/dsmlogget.sh
TODAY=`date "+%Y%m%d"`

ARG=$1
case ${ARG} in
    #--- 引数が「1」の場合、Primaryが対象
    1) TGT=${PRIMARY_DSM_SERVER}
       LOG=${LOG_DIR}/${EXEC_NAME}_1_`date "+%Y%m%d-%H%M%S"`.log
    ;;
    #--- 引数が「2」の場合、Secondaryが対象
    2) TGT=${SECONDARY_DSM_SERVER}
       LOG=${LOG_DIR}/${EXEC_NAME}_2_`date "+%Y%m%d-%H%M%S"`.log
    ;;
    *) echo -e "\n***** Info  : Argument Error *****"
       echo -e "\n***** Info  : ${MY_NAME} Abend *****"
       exit ${ERRORS}
    ;;
esac

sshpass -p ${PASS} ssh ${DSM_ADMIN_USER}@${TGT} < ${EXEC_SH} > ${LOG} 2>&1

echo -e "\n ログ・・・${LOG}"
