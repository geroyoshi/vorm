#!/bin/sh
#---------------------------------#
# add hostname for dsm            #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

PASS=`openssl rsautl -decrypt -inkey ${KEY} -in ${ADMIN_PASS}`
TODAY=`date "+%Y%m%d"`

RC_TMP=${LOG_DIR}/${EXEC_NAME}.tmp ; cp /dev/null ${RC_TMP}

echo -e "\n***** Info  : ${MY_NAME} Start *****"

ARG=$1
case ${ARG} in
    #--- 引数が「1」の場合、Primaryが対象
    1) TGT=${PRIMARY_DSM_SERVER}
       EXEC_SH=${CFG_DIR}/dsmhostadd_1.sh
       TGT_CURL=${CFG_DIR}/curl_${EXEC_NAME}_1.cfg
       LOG=${LOG_DIR}/${EXEC_NAME}_1_`date "+%Y%m%d-%H%M%S"`.log
    ;;
    #--- 引数が「2」の場合、Secondaryが対象
    2) TGT=${SECONDARY_DSM_SERVER}
       EXEC_SH=${CFG_DIR}/dsmhostadd_2.sh
       TGT_CURL=${CFG_DIR}/curl_${EXEC_NAME}_2.cfg
       LOG=${LOG_DIR}/${EXEC_NAME}_2_`date "+%Y%m%d-%H%M%S"`.log
    ;;
    *) echo -e "\n***** Info  : Argument Error *****"
       echo -e "\n***** Info  : ${MY_NAME} Abend *****"
       exit ${ERRORS}
    ;;
esac

#--- exec ---#
sshpass -p ${PASS} ssh ${DSM_ADMIN_USER}@${TGT} < ${EXEC_SH} > ${LOG} 2>&1

#--- after ---#
# show host 結果から、ホスト名・IPが出力されていることを確認
#
grep "host add" ${EXEC_SH} |awk '{print $3,$4}' |while read TGTHOST TGTIP
do
    grep "name=${TGTHOST} ip=${TGTIP}" ${LOG}
    RC_C=$?
    (( RC = ${RC} + ${RC_C} ))

    echo ${RC} > ${RC_TMP}
done

RC=`cat ${RC_TMP}`

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
