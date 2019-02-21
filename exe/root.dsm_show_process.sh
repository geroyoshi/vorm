#!/bin/sh
#---------------------------------#
# dsm show process set            #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${SUPERADMIN_CFG}`

LOG_FILE=${LOG_DIR}/${EXEC_NAME}.log

cd ${CURL_PATH}

#--- 引数がnullの場合、errorとする ---"
TGT_PROC=$1
if [[ ${TGT_PROC} = "" ]]; then
    echo -e "\n***** Info  : ${MY_NAME} Start *****"
    echo -e "***** Info  : argument error *****"
    echo -e "***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi


#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- 情報取得 ---#
curl -o ${LOG_FILE} -sS -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/${DOM_URL}/processsets/${TGT_PROC}
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
