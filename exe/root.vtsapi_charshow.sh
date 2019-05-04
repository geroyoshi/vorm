#!/bin/sh
#---------------------------------#
# vts api character set show      #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

ARG=$1

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****\n"

case ${ARG} in
    #--- 引数が「1」の場合、Primaryが対象
    1) TGT=${PRIMARY_VTS}
       TOKEN=`cat ${VTS_TOKEN_1}`
    ;;
    #--- 引数が「2」の場合、Secondaryが対象
    2) TGT=${SECONDARY_VTS}
       TOKEN=`cat ${VTS_TOKEN_2}`
    ;;
    *) echo -e "\n***** Info  : Argument Error *****"
       echo -e "\n***** Info  : ${MY_NAME} Abend *****"
       exit ${ERRORS}
    ;;
esac

#--- exec ---#
curl -o ${AFT_FILE} -sS -k -X GET -H "Authorization: Bearer ${TOKEN}"  https://${TGT}/api/charsets/
RC=$?

if [[ ${RC} = ${SUCCESS} ]]; then
    cat ${AFT_FILE}
    echo -e "\n\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
