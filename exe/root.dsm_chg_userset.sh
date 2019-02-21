#!/bin/sh
#---------------------------------#
# chg user set                    #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
AFT_FILE2=${LOG_DIR}/aft2_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${SUPERADMIN_CFG}`

USER_FILE=${LOG_DIR}/user_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg

#--- 引数がnullの場合、errorとする ---"
TGT_USER=$1
if [[ -z ${TGT_USER} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} Start *****"
    echo -e "***** Info  : Argument Error *****"
    echo -e "***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- before ---#
curl -o ${BEF_FILE} -sS -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/${DOM_URL}/usersets

# user_idを取得する
USER_ID=`grep -B 2 ${TGT_USER} ${BEF_FILE}| grep "id"| awk -F':' '{print $2}'| tr -d ","| tr -d [:blank:]`

#--- exec ---#
curl -o ${AFT_FILE} -sS -k -X PUT -u ${USER} -H 'Content-Type: application/json' -d @${CFG_FILE} https://${PRIMARY_DSM_SERVER}/dsm/${DOM_URL}/usersets/${USER_ID}
RC_C=$?

#--- after ---#
curl -o ${AFT_FILE2} -sS -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/${DOM_URL}/usersets

grep -q ${TGT_USER} ${AFT_FILE2} 
RC_G=$?
if [[ ${RC_G} != ${SUCCESS} ]]; then
    echo -e "\n***** ${NAME} : [ NG ] *****"
fi

(( RC = ${RC_C} + ${RC_G} ))

if [[ ${RC} = ${SUCCESS} ]]; then
    cat ${AFT_FILE2}
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
