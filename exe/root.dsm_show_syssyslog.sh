#!/bin/sh
#---------------------------------#
# dsm show system syslog          #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
LOG_FILE=${LOG_DIR}/${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${ADMIN_CFG}`

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

curl -sS -o ${LOG_FILE} -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/v1/syslog
RC=$?

if [[ ${RC} = ${SUCCESS} ]]; then
    cat ${LOG_FILE}
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
