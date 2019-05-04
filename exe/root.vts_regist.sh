#!/bin/sh
#---------------------------------#
# vts register                    #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

PASS=`openssl rsautl -decrypt -inkey ${KEY} -in ${VTSADMIN_PASS}`
RC=${SUCCESS}

ARG=$1

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

case ${ARG} in
    #--- 引数が「1」の場合、Primaryが対象
    1) TGT=${PRIMARY_VTS}
       CFG_FILE=${CFG_DIR}/${EXEC_NAME}_1.cfg
    ;;
    #--- 引数が「2」の場合、Secondaryが対象
    2) TGT=${SECONDARY_VTS}
       CFG_FILE=${CFG_DIR}/${EXEC_NAME}_2.cfg
    ;;
    *) echo -e "\n***** Info  : Argument Error *****"
       echo -e "\n***** Info  : ${MY_NAME} Abend *****"
       exit ${ERRORS}
    ;;
esac

#--- exec ---#
sshpass -p ${PASS} ssh ${VTS_ADMIN_USER}@${TGT} < ${CFG_FILE}
RC=$?

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
