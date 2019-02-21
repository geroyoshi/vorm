#!/bin/sh
#---------------------------------#
# dsm add dns                     #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

ARG=$1

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${ADMIN_CFG}`

case ${ARG} in
    #--- 引数が「1」の場合、Primaryが対象
    1) TGT=${PRIMARY_DSM_SERVER}
       TGT_CURL=${CFG_DIR}/curl_${EXEC_NAME}_1.cfg
       AFT_FILE=${LOG_DIR}/${EXEC_NAME}_1.log
    ;;
    #--- 引数が「2」の場合、Secondaryが対象
    2) TGT=${SECONDARY_DSM_SERVER}
       TGT_CURL=${CFG_DIR}/curl_${EXEC_NAME}_2.cfg
       AFT_FILE=${LOG_DIR}/${EXEC_NAME}_2.log
    ;;
    *) echo -e "\n***** Info  : Argument Error *****"
       echo -e "\n***** Info  : ${MY_NAME} Abend *****"
       exit ${ERRORS}
    ;;
esac

curl -sS -k -X POST -u ${USER} -H 'Content-Type: application/json' -d @${TGT_CURL} https://${TGT}/dsm/v1/system/configs/dns
RC_C=$?

curl -sS -o ${AFT_FILE} -k -X GET -u ${USER} https://${TGT}/dsm/v1/system/configs/dns
RC=$?

(( RC = ${RC} + ${RC_C} ))

if [[ ${RC} = ${SUCCESS} ]]; then
    echo
    cat ${AFT_FILE}
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
