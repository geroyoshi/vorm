#!/bin/sh
#---------------------------------#
# vte show vtekey                 #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CFG_FILE=${CFG_DIR}/vte_make_key.cfg
LOG_FILE=${LOG_DIR}/${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

RC_TMP=${LOG_DIR}/${EXEC_NAME}.tmp ; cp /dev/null ${RC_TMP}

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- exec ---#
grep -v ^# ${CFG_FILE} | while read TGT
do
    DESC=`echo ${TGT} | awk -F'|' '{print $1}'`
    TYPE=`echo ${TGT} | awk -F'|' '{print $2}'`
    NAME=`echo ${TGT} | awk -F'|' '{print $3}'`

    #--- 対象キー(NAME)に対して、vmssc ---#
    echo -e "\n***** Info  : KEY=${NAME} *****\n"
    ./vmssc show key -d ${NAME} | tee -a ${LOG_FILE}
    RC_C=$?

    (( RC = ${RC} + ${RC_C} ))

    echo ${RC} > ${RC_TMP}
done

RC=`cat ${RC_TMP}`

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
