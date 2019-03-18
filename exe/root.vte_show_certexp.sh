#!/bin/sh
#---------------------------------#
# vte show cert expiration        #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
LOG_FILE=${LOG_DIR}/${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
VMUTIL_PATH=/opt/vormetric/DataSecurityExpert/agent/vmd/bin

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

if [[ ! -f ${VMUTIL_PATH}/vmutil ]]; then
    echo -e "\n***** Info  : No vmutil module *****"
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi

#--- exec ---#
${VMUTIL_PATH}/vmutil -a pkcs11 certexpiry > ${LOG_FILE}
RC=$?

DAYS=`awk '{print $8}' ${LOG_FILE}`

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : expiration date ==> ${DAYS} *****"
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
