#!/bin/sh
#---------------------------------#
# vts api auth                    #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${VTSROOT_CFG}`

TGT_CURL=${CFG_DIR}/curl_${EXEC_NAME}.cfg
AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

ARG=$1

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

case ${ARG} in
    #--- 引数が「1」の場合、Primaryが対象
    1) TGT=${PRIMARY_VTS}
    ;;
    #--- 引数が「2」の場合、Secondaryが対象
    2) TGT=${SECONDARY_VTS}
    ;;
    *) echo -e "\n***** Info  : Argument Error *****"
       echo -e "\n***** Info  : ${MY_NAME} Abend *****"
       exit ${ERRORS}
    ;;
esac

TOKEN_FILE=${LOG_DIR}/token_${ARG}.txt

#--- exec ---#
curl -o ${AFT_FILE} -sS -k -X POST -H 'Content-Type: application/json' -d @${TGT_CURL} https://${TGT}/api/api-token-auth/
RC=$?

if [[ ${RC} = ${SUCCESS} ]]; then
    TOKEN=`awk -F':' '{print $2}' ${AFT_FILE}| awk -F',' '{print $1}'| tr -d '\"'`
    echo ${TOKEN} > ${TOKEN_FILE}
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
