#!/bin/sh
#---------------------------------#
# vte pause rekey                 #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg

RC_TMP=${LOG_DIR}/${EXEC_NAME}.tmp ; cp /dev/null ${RC_TMP}

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- exec ---#
grep -v ^# ${CFG_FILE} | while read TGT
do
    NAME=`echo ${TGT} | awk '{print $1}'`

    #--- 対象ホスト(NAME)に対して、vmssc ---#
    ./vmssc rekey pause ${NAME}
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
