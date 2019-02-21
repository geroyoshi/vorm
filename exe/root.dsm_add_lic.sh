#!/bin/sh
#---------------------------------#
# dsm add license                 #
#  vmssc user ==> admin           #
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

USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${ADMIN_CFG}`
TGT=${PRIMARY_DSM_SERVER}

cd ${VMSSC_PATH}
# cp vmssc.conf.admin vmssc.conf

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- before ---#
curl -sS -o ${BEF_FILE} -k -X GET -u ${USER} https://${TGT}/dsm/v1/licenses/current

#--- exec ---#
# LICENSE_FILEはset_env.shに定義
./vmssc server license -f ${LICENSE_FILE}
RC_C=$?

#--- after ---#
curl -sS -o ${AFT_FILE} -k -X GET -u ${USER} https://${TGT}/dsm/v1/licenses/current

grep -q "issuedTo" ${AFT_FILE} 
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
