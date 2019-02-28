#!/bin/sh
#---------------------------------#
# add domain                      #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
TGT_CURL=${CFG_DIR}/curl_${EXEC_NAME}.cfg
BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
AFT_FILE2=${LOG_DIR}/aft2_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${ADMIN_CFG}`

# domain名を抽出(一個限定)
TGT_DOMAIN=`grep name ${TGT_CURL}| awk -F':' '{print $2}'|tr -d ","| tr -d "\""| tr -d [:blank:]`

#--- 引数がnullの場合、errorとする ---"
ASSIGN_ADMIN=$1
if [[ -z ${ASSIGN_ADMIN} ]]; then
    echo -e "\n***** Info  : Argument Error *****"
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
USER_FILE=${LOG_DIR}/user_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- exec ---#
# GUIでは可能だが、CUIの場合、ドメイン名に「.」が認められない。「_」「-]は可
#
curl -sS -k -X POST -u ${USER} -H 'Content-Type: application/json' -d @${TGT_CURL} https://${PRIMARY_DSM_SERVER}/dsm/v1/domains
RC_C=$?

#--- after ---#
curl -sS -o ${AFT_FILE} -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/v1/domains

grep -q ${TGT_DOMAIN} ${AFT_FILE} 
RC_G=$?
if [[ ${RC_G} != ${SUCCESS} ]]; then
    echo -e "\n***** ${NAME} : [ NG ] *****"
fi

(( RC = ${RC_C} + ${RC_G} ))

#--- assign ---#
# IDget
curl -sS -o ${USER_FILE} -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/v1/admins
ASSIGN_ID=`grep -B 1 ${ASSIGN_ADMIN} ${USER_FILE}| grep "id"| awk -F':' '{print $2}'| tr -d ","| tr -d [:blank:]`

# assign
DOMAIN_ID=`grep -B 2 ${TGT_DOMAIN} ${AFT_FILE}| grep "id"| awk -F':' '{print $2}'| tr -d ","| tr -d [:blank:]`
curl -sS -k -X PUT -u ${USER} -H 'Content-Type: application/json' https://${PRIMARY_DSM_SERVER}/dsm/v1/admins/${ASSIGN_ID}/managing/${DOMAIN_ID}
RC_C=$?

#--- after ---#
curl -sS -o ${AFT_FILE2} -k -X GET -u ${USER} https://${PRIMARY_DSM_SERVER}/dsm/v1/domains/${DOMAIN_ID}

grep -q ${ASSIGN_ADMIN} ${AFT_FILE2} 
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
