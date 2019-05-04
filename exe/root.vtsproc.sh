#!/bin/sh
#---------------------------------#
# process watch for vts           #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

PASS=`openssl rsautl -decrypt -inkey ${KEY} -in ${VTSADMIN_PASS}`
EXEC_SH=${EXE_DIR}/vts_daemon.sh
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

# 対象プロセスは、vtsauthz、vaed、nginx、kmd、iam、cryptod
# 上記に加え、System
# Redhatは-p使えないから、-Aでとりあえず
# 2.3で「OK」に変更
for TGT in vtsauthz vaed nginx kmd iam cryptod System
do
    STAT=`grep -A 1 ${TGT} ${LOG}| grep status| awk '{print $2}'`
    if [[ ${STAT} = "OK" ]]; then
        NUM=0
    else
        NUM=16
    fi
    echo "${TGT},${NUM}"
done

rm -f ${LOG}
