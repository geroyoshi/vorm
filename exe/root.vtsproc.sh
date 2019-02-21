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
EXEC_SH=${EXE_DIR}/daemon.sh
TODAY=`date "+%Y%m%d"`
LOG=${LOG_DIR}/${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

sshpass -p ${PASS} ssh ${VTS_ADMIN_USER}@${PRIMARY_VTS} < ${EXEC_SH} > ${LOG} 2>&1

# 対象プロセスは、vtsauthz、vaed、nginx、kmd、iam、cryptod
# 上記に加え、System
# Redhatは-p使えないから、-Aでとりあえず
for TGT in vtsauthz vaed nginx kmd iam cryptod System
do
    STAT=`grep -A 1 ${TGT} ${LOG}| grep status| awk '{print $2}'`
    if [[ ${STAT} = "Running" ]]; then
        NUM=0
    else
        NUM=16
    fi
    echo "${TGT},${NUM}"
done

rm -f ${LOG}
