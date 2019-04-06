#!/bin/sh
#---------------------------------#
# fs watch for vts                #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

PASS=`openssl rsautl -decrypt -inkey ${KEY} -in ${VTSADMIN_PASS}`
EXEC_SH=${EXE_DIR}/df.sh
TODAY=`date "+%Y%m%d"`
LOG=${LOG_DIR}/${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

ARG=$1
case ${ARG} in
    #--- 引数が「1」の場合、Primaryが対象
    1) TGT=${PRIMARY_VTS}
       LOG=${LOG_DIR}/${EXEC_NAME}_1_`date "+%Y%m%d-%H%M%S"`.log
    ;;
    #--- 引数が「2」の場合、Secondaryが対象
    2) TGT=${SECONDARY_VTS}
       LOG=${LOG_DIR}/${EXEC_NAME}_2_`date "+%Y%m%d-%H%M%S"`.log
    ;;
    *) exit ${ERRORS}
    ;;
esac

sshpass -p ${PASS} ssh ${VTS_ADMIN_USER}@${TGT} < ${EXEC_SH} > ${LOG} 2>&1

# "%"の出力ある行のみ→不要行削除→桁ずれ対策として、行末からawk→"%"削除
grep "%" ${LOG} |sed -n '2,$p' |awk '{print $NF","$(NF-1)}'| tr -d '%'

rm -f ${LOG}
