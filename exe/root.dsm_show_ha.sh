#!/bin/sh
#---------------------------------#
# dsm show ha                     #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
BEF_FILE=${LOG_DIR}/${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
TMP_FILE=${LOG_DIR}/${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.tmp; cp /dev/null ${TMP_FILE}

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- before ---#
./vmssc server show -f | tee -a ${BEF_FILE}

RC=`grep "sync status" ${BEF_FILE} | grep -c Success`

if [[ ${RC} -eq 1 ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
