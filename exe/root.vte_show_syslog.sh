#!/bin/sh
#---------------------------------#
# vte show syslog                 #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CFG_FILE=${CFG_DIR}/vte_add_syslog.cfg
LOG_FILE=${LOG_DIR}/${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

RC_TMP=${LOG_DIR}/${EXEC_NAME}.tmp ; cp /dev/null ${RC_TMP}

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- exec ---#
grep -v ^# ${CFG_FILE}| awk -F'|' '{print $3}'| sort -u| while read NAME
do
    #--- 対象ホストに対して、vmssc ---#
    echo -e "\n***** Info  : HOST=${NAME} *****\n"
    ./vmssc syslog showhost -a FS -h ${NAME} | tee -a ${LOG_FILE}
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
