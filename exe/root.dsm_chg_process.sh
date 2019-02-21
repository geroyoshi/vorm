#!/bin/sh
#---------------------------------#
# chg process set                 #
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
TGT_PROC=$1
if [[ -z ${TGT_PROC} ]]; then
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
curl -o ${BEF_FILE} -sS -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/${DOM_URL}/processsets

# process_idを取得する
PROC_ID=`grep -B 2 ${TGT_PROC} ${BEF_FILE}| grep "id"| awk -F':' '{print $2}'| tr -d ","| tr -d [:blank:]`

#--- exec ---#
curl -o ${AFT_FILE} -sS -k -X PUT -u ${USER} -H 'Content-Type: application/json' -d @${CFG_FILE} https://${PRIMARY_DSM_SERVER}/dsm/${DOM_URL}/processsets/${PROC_ID}
RC_C=$?

#--- after ---#
curl -o ${AFT_FILE2} -sS -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/${DOM_URL}/processsets

grep -q ${TGT_PROC} ${AFT_FILE2} 
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
