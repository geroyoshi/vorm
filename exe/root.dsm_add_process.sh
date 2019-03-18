#!/bin/sh
#---------------------------------#
# add process set                 #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
AFT_FILE2=${LOG_DIR}/aft2_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${SUPERADMIN_CFG}`

USER_FILE=${LOG_DIR}/user_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg
RC_C_TMP=${LOG_DIR}/C_${EXEC_NAME}.tmp ; cp /dev/null ${RC_C_TMP}
RC_G_TMP=${LOG_DIR}/C_${EXEC_NAME}.tmp ; cp /dev/null ${RC_G_TMP}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- before ---#
curl -o ${BEF_FILE} -sS -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/${DOM_URL}/processsets

#--- exec ---#
grep -v ^# ${CFG_FILE} | while read TGT_PROC
do
    AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_${TGT_PROC}_`date "+%Y%m%d-%H%M%S"`.log
    TGT_CURL=${CFG_DIR}/policy_dir/curl_${EXEC_NAME}_${TGT_PROC}.cfg
    
    curl -o ${AFT_FILE} -sS -k -X POST -u ${USER} -H 'Content-Type: application/json' -d @${TGT_CURL} https://${PRIMARY_DSM_SERVER}/dsm/${DOM_URL}/processsets
    RC_C=$?
    (( RC = ${RC} + ${RC_C} ))

    echo ${RC} > ${RC_C_TMP}
done

#--- after ---#
curl -o ${AFT_FILE2} -sS -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/${DOM_URL}/processsets

grep -v ^# ${CFG_FILE} | while read TGT_PROC
do
    grep -q ${TGT_PROC} ${AFT_FILE2}
    RC_G=$?
    if [[ ${RC_G} != ${SUCCESS} ]]; then
        echo -e "\n***** ${TGT_PROC} : [ NG ] *****"
    fi
    (( RC = ${RC} + ${RC_G} ))

    echo ${RC} > ${RC_G_TMP}
done

RC_C=`cat ${RC_C_TMP}`
RC_G=`cat ${RC_G_TMP}`

(( RC = ${RC_C} + ${RC_G} ))

if [[ ${RC} = ${SUCCESS} ]]; then
    cat ${AFT_FILE2}
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
