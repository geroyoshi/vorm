#!/bin/sh
#---------------------------------#
# vts - dsm status                #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
PASS=`openssl rsautl -decrypt -inkey ${KEY} -in ${VTSADMIN_PASS}`


#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

ARG=$1
case ${ARG} in
    #--- 引数が「1」の場合、Primaryが対象
    1) TGT=${PRIMARY_VTS}
       LOG=${LOG_DIR}/${EXEC_NAME}_1_`date "+%Y%m%d-%H%M%S"`.log
       BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_1.log
       AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_1.log
    ;;
    #--- 引数が「2」の場合、Secondaryが対象
    2) TGT=${SECONDARY_VTS}
       LOG=${LOG_DIR}/${EXEC_NAME}_2_`date "+%Y%m%d-%H%M%S"`.log
       BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_2.log
       AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_2.log
    ;;
    *) echo -e "\n***** Info  : Argument Error *****"
       echo -e "\n***** Info  : ${MY_NAME} Abend *****"
       exit ${ERRORS}
    ;;
esac

#--- before ---#
EXEC_SH=${EXE_DIR}/${EXEC_NAME}_show.sh
sshpass -p ${PASS} ssh ${VTS_ADMIN_USER}@${TGT} < ${EXEC_SH} > ${BEF_FILE} 2>&1

#--- exec ---#
EXEC_SH=${CFG_DIR}/${EXEC_NAME}.cfg
sshpass -p ${PASS} ssh ${VTS_ADMIN_USER}@${TGT} < ${EXEC_SH} > ${LOG} 2>&1
RC=$?

#--- after ---#
EXEC_SH=${EXE_DIR}/${EXEC_NAME}_show.sh
sshpass -p ${PASS} ssh ${VTS_ADMIN_USER}@${TGT} < ${EXEC_SH} > ${AFT_FILE} 2>&1

if [[ ${RC} = ${SUCCESS} ]]; then
    cat ${AFT_FILE}
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
