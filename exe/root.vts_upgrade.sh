#!/bin/sh
#---------------------------------#
# vts upgrade                     #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
PASS=`openssl rsautl -decrypt -inkey ${KEY} -in ${VTSADMIN_PASS}`

CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg

ARG=$1

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

case ${ARG} in
    #--- 引数が「1」の場合、Primaryが対象
    #    cluster join 1系 2系 (2系が主系)
    1) TGT=${PRIMARY_VTS}
       LOG=${LOG_DIR}/${EXEC_NAME}_1_`date "+%Y%m%d-%H%M%S"`.log
    ;;
    #--- 引数が「2」の場合、Secondaryが対象
    #    cluster join 2系 1系 (1系が主系)
    2) TGT=${SECONDARY_VTS}
       LOG=${LOG_DIR}/${EXEC_NAME}_2_`date "+%Y%m%d-%H%M%S"`.log
    ;;
    *) echo -e "\n***** Info  : Argument Error *****"
       echo -e "\n***** Info  : ${MY_NAME} Abend *****"
       exit ${ERRORS}
    ;;
esac

#--- ファイルが格納されていなければNG ---#
if [[ ! -f ${VTS_UPGRADE_DIR}/${VTS_UPGRADE_VER} ]]; then
    echo -e "\n***** Info  : No Upgrade File *****"
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi

#--- exec ---#
sshpass -p ${PASS} ssh ${VTS_ADMIN_USER}@${TGT} < ${CFG_FILE} | tee -a ${LOG}

#--- error文言をgrep ---#
grep -q "Upgrade failed" ${LOG}
RC=$?
if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
else
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
fi
