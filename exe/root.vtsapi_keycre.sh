#!/bin/sh
#---------------------------------#
# vts api key cre                 #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CHK_SH=${EXE_DIR}/root.vtsapi_keyshow.sh

CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg
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

#--- before ---#
sh ${CHK_SH} ${ARG}

#--- exec ---#
grep -v ^# ${CFG_FILE} | while read TGT_CURL
do
    curl -o ${AFT_FILE} -sS -k -X POST -H "Authorization: Bearer ${TOKEN}" -H 'Content-Type: application/json' -d @${TGT_CURL} https://${TGT}/api/keys/
    RC=$?
done

#--- after ---#
sh ${CHK_SH} ${ARG}

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
