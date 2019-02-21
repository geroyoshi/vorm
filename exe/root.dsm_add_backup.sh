#!/bin/sh
#---------------------------------#
# dsm add backup                  #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg
BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
USER_FILE=${LOG_DIR}/user_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
TGT_CURL=${CFG_DIR}/curl_${EXEC_NAME}.cfg

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- before ---#
./vmssc backup show > ${BEF_FILE}

#--- wrapperkey create ---#
USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${ADMIN_CFG}`
ASSIGN=`grep -v ^# ${CFG_FILE} | awk -F'|' '{print $7}'`

curl -sS -k -X POST -u ${USER} -H 'Content-Type: application/json' https://${PRIMARY_DSM_SERVER}/dsm/v1/wrapperkeys

#--- assign adminをsed変換 ---#
curl -sS -o ${USER_FILE} -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/v1/admins

ASSIGN_ID=`grep -B 1 ${ASSIGN} ${USER_FILE}| grep "id"| awk -F':' '{print $2}'| tr -d ","| sed "s/^ //"`
cp -p ${TGT_CURL} ${TGT_CURL}.org
sed "s/1000/${ASSIGN_ID}/" ${TGT_CURL} > ${TGT_CURL}.chg
mv ${TGT_CURL}.chg ${TGT_CURL}
chmod 777 ${TGT_CURL}

#--- wrapperkey export ---#
curl -sS -k -X POST -u ${USER} -H 'Content-Type: application/json' -d @${TGT_CURL} https://${PRIMARY_DSM_SERVER}/dsm/v1/wrapperkeys/export

#--- wrapperkey show ---#
# コマンドで実施した場合、superadmin想定
USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${SUPERADMIN_CFG}`
WRAPPERKEY=`curl -sS -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/v1/wrapperkeys/userkeyshare | grep keyShare | awk -F'"' '{print $4}'`

echo -e "\n\n#------ [ Wrapper Key Share ] ------#"
echo -e "${WRAPPERKEY}\n"

#--- curlファイル初期化 ---#
mv ${TGT_CURL}.org ${TGT_CURL}

#--- exec ---#
TIME=`grep -v ^# ${CFG_FILE} | awk -F'|' '{print $1}'`
DAY=`grep -v ^# ${CFG_FILE} | awk -F'|' '{print $2}'`
TYPE=`grep -v ^# ${CFG_FILE} | awk -F'|' '{print $3}'`
NAME=`grep -v ^# ${CFG_FILE} | awk -F'|' '{print $4}'`
DIR=`grep -v ^# ${CFG_FILE} | awk -F'|' '{print $5}'`
USER=`grep -v ^# ${CFG_FILE} | awk -F'|' '{print $6}'`
PASS=`openssl rsautl -decrypt -inkey ${KEY} -in ${ADMIN_PASS}`

./vmssc backup add -t ${TIME} -D ${DAY} -f ${TYPE} -h ${NAME} -d ${DIR} -u ${USER} -p ${PASS}
RC_C=$?

#--- after ---#
./vmssc backup show > ${AFT_FILE}

grep -q "${NAME}" ${AFT_FILE} 
RC_G=$?
if [[ ${RC_G} != ${SUCCESS} ]]; then
    echo -e "\n***** ${NAME} : [ NG ] *****"
fi

(( RC = ${RC_C} + ${RC_G} ))

if [[ ${RC} = ${SUCCESS} ]]; then
    cat ${AFT_FILE}
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
