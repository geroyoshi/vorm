#!/bin/sh
#---------------------------------#
# dsm show resource set           #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${SUPERADMIN_CFG}`

CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg
RC_C_TMP=${LOG_DIR}/C_${EXEC_NAME}.tmp ; cp /dev/null ${RC_C_TMP}

cd ${CURL_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- 情報取得 ---#
grep -v ^# ${CFG_FILE} | while read TGT_RESOURCE
do
    TGT_CURL=${CFG_DIR}/policy_dir/curl_dsm_add_resource_${TGT_RESOURCE}.cfg
    curl -o ${TGT_CURL} -sS -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/${DOM_URL}/resourcesets/${TGT_RESOURCE}

    # errorcode
    grep -vq errorCode ${TGT_CURL}
    RC_C=$?
    if [[ ${RC_C} = ${SUCCESS} ]]; then
        ls -ltr ${TGT_CURL}
    else
        echo -e "\n***** ${TGT_RESOURCE} : [ NG ] *****"
    fi
    (( RC = ${RC} + ${RC_C} ))

    echo ${RC} > ${RC_C_TMP}
done

RC=`cat ${RC_C_TMP}`

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
