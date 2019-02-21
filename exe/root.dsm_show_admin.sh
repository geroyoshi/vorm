#!/bin/sh
#---------------------------------#
# dsm show admin                  #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${ADMIN_CFG}`
LOG_FILE=${LOG_DIR}/${EXEC_NAME}.log

cd ${CURL_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- 情報取得 ---#
curl -sS -o ${LOG_FILE} -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/v1/admins
RC=$?

if [[ ${RC} = ${SUCCESS} ]]; then
    echo
    cat ${LOG_FILE}
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
