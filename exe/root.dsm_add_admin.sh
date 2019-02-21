#!/bin/sh
#---------------------------------#
# dsm add admin                   #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg

RC_C_TMP=${LOG_DIR}/C_${EXEC_NAME}.tmp ; cp /dev/null ${RC_C_TMP}
RC_G_TMP=${LOG_DIR}/G_${EXEC_NAME}.tmp ; cp /dev/null ${RC_G_TMP}

USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${ADMIN_CFG}`
AFT_FILE=${LOG_DIR}/${EXEC_NAME}.log

cd ${CURL_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- 作成 ---#
ls ${CURL_PATH}/cre_*.cfg | while read TGT_CURL
do
    curl -sS -k -X POST -u ${USER} -H 'Content-Type: application/json' -d @${TGT_CURL} https://${PRIMARY_DSM_SERVER}/dsm/v1/admins
    (( RC_C = ${RC_C} + $? ))
    echo ${RC_C} > ${RC_C_TMP}
done

RC_C=`cat ${RC_C_TMP}`

#--- 情報取得 ---#
curl -sS -o ${AFT_FILE} -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/v1/admins

#--- パス変用に、対象ID取得 ---#
ls ${CURL_PATH}/chg_*.cfg | while read TGT_CURL
do
    # 作成・変更対象ユーザ名取得
    TGT_CRE_NAME=`grep name ${TGT_CURL}| awk -F':' '{print $2}'| tr -d "\"" |tr -d ","| sed "s/^ //"`

    # ID取得
    ID=`grep -B 1 ${TGT_CRE_NAME} ${AFT_FILE}| grep "id"| awk -F':' '{print $2}'| tr -d ","| sed "s/^ //"`

    # パスワード変更用に、ログインID修正
    cp -p ${CFG_FILE} ${CFG_FILE}.org
    sed "s/base/${TGT_CRE_NAME}/" ${CFG_FILE} > ${CFG_FILE}.${TGT_CRE_NAME}
    mv ${CFG_FILE}.${TGT_CRE_NAME} ${CFG_FILE}
    chmod 777 ${CFG_FILE}

    USER=`grep -v ^# ${CFG_FILE} | awk -F'|' '{print $1}'`

    # パスワード変更
    curl -sS -k -X PUT -u ${USER} -H 'Content-Type: application/json' -d @${TGT_CURL} https://${PRIMARY_DSM_SERVER}/dsm/v1/admins/${ID}/password
    (( RC_G = ${RC_G} + $? ))
    echo ${RC_G} > ${RC_G_TMP}

    # 初期化
    mv ${CFG_FILE}.org ${CFG_FILE}
done

RC_G=`cat ${RC_G_TMP}`

(( RC = ${RC_C} + ${RC_G} ))

if [[ ${RC} = ${SUCCESS} ]]; then
    echo
    cat ${AFT_FILE}
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
