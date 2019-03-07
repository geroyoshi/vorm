#!/bin/sh
#---------------------------------#
# vae renew cert                  #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg
VMUTIL_PATH=/opt/vormetric/DataSecurityExpert/agent/pkcs11/bin

BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
LOG_FILE=${LOG_DIR}/exec_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

if [[ ! -f ${VMUTIL_PATH}/vmutil ]]; then
    echo -e "\n***** Info  : No vmutil module *****"
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi

#--- before ---#
${VMUTIL_PATH}/vmutil -a pkcs11 certexpiry > ${BEF_FILE}
BEF_DAYS=`awk '{print $8}' ${BEF_FILE}`
echo -e "\n***** Info  : expiration date(bef) ==> ${BEF_DAYS} *****"

# 期限が364日の場合、最新として抜ける
if [[ ${BEF_DAYS} -eq 364 ]]; then
    echo -e "\n***** Info  : cert is already renewed *****"
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
fi

#--- exec ---#
${VMUTIL_PATH}/vmutil -a pkcs11 renewcerts > ${LOG_FILE}

#--- after ---#
${VMUTIL_PATH}/vmutil -a pkcs11 certexpiry > ${AFT_FILE}
AFT_DAYS=`awk '{print $8}' ${AFT_FILE}`
echo -e "\n***** Info  : expiration date(aft) ==> ${AFT_DAYS} *****"

# bef / aft で確認し、aftの方が更新されていればRC=0
if [[ ${AFT_DAYS} -gt ${BEF_DAYS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
