#!/bin/sh
#---------------------------------#
# dsm show conf                   #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

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
       OUP_FILE=${LOG_DIR}/${EXEC_NAME}_1.log; cp /dev/null ${OUP_FILE}
    ;;
    #--- 引数が「2」の場合、Secondaryが対象
    2) TGT=${SECONDARY_DSM_SERVER}
       OUP_FILE=${LOG_DIR}/${EXEC_NAME}_2.log; cp /dev/null ${OUP_FILE}
    ;;
    *) echo -e "\n***** Info  : Argument Error *****"
       echo -e "\n***** Info  : ${MY_NAME} Abend *****"
       exit ${ERRORS}
    ;;
esac

curl -sS -o ${OUP_FILE} -k -X GET -u ${USER} https://${TGT}/dsm/v1/system/configs
RC=$?

if [[ ${RC} = ${SUCCESS} ]]; then
    echo
    cat ${OUP_FILE}
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
