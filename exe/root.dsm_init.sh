#!/bin/sh
#---------------------------------#
# dsm config gw-timezone          #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
OUP_FILE=${LOG_DIR}/${EXEC_NAME}.log; cp /dev/null ${OUP_FILE}

RC_TMP=${LOG_DIR}/RC_${EXEC_NAME}.tmp ; cp /dev/null ${RC_TMP}

TGT_SH="
root.dsm_add_gw.sh
root.dsm_add_dns.sh
root.dsm_add_ntp.sh
root.dsm_add_time.sh
root.dsm_add_name.sh
root.dsm_add_ca.sh
"

ARG=$1

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

case ${ARG} in
    #--- 引数が「1」の場合、Primaryが対象
    1) :
    ;;
    #--- 引数が「2」の場合、Secondaryが対象
    2) :
    ;;
    *) echo -e "\n***** Info  : Argument Error *****"
       echo -e "\n***** Info  : ${MY_NAME} Abend *****"
       exit ${ERRORS}
    ;;
esac

for TGT in ${TGT_SH}
do
    sh ${EXE_DIR}/${TGT} ${ARG}
    (( RC = ${RC} + $? ))
    echo ${RC} > ${RC_TMP}
    cd ${EXE_DIR}
done

RC=`cat ${RC_TMP}`

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
