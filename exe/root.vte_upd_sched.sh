#!/bin/sh
#---------------------------------#
# vte upd sched                   #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg

RC_G_TMP=${LOG_DIR}/${EXEC_NAME}.tmp ; cp /dev/null ${RC_G_TMP}

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- exec ---#
grep -v ^# ${CFG_FILE} | while read TGT
do
    FILE=`echo ${TGT} | awk '{print $1}'`
    NAME=`grep Name: ${CFG_DIR}/${FILE} | awk -F':' '{print $2}' | tr -d ' '`

    #--- before ---#
    BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_${NAME}_`date "+%Y%m%d-%H%M%S"`.log
    ./vmssc rekey getsched ${NAME} > ${BEF_FILE}

    #--- update ---#
    echo -e "\n***** Info  : TGT_SCHEDULE=${NAME} *****\n"
    ./vmssc rekey updatesched -f ${CFG_DIR}/${FILE}
    RC_C=$?
    if [[ ${RC_C} != ${SUCCESS} ]]; then
        echo -e "\n***** ${NAME} : [ NG ] *****"
    fi
    (( RC = ${RC} + ${RC_C} ))

    #--- after ---#
    AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_${NAME}_`date "+%Y%m%d-%H%M%S"`.log
    ./vmssc rekey getsched ${NAME} | tee -a ${AFT_FILE}

    diff ${AFT_FILE} ${CFG_DIR}/${FILE}
    RC_G=$?
  
    if [[ ${RC_G} != ${SUCCESS} ]]; then
        echo -e "\n***** ${NAME} : [ NG ] *****"
        RC_G=${ERRORS}
    fi

    (( RC = ${RC} + ${RC_G} ))

    echo ${RC} > ${RC_G_TMP}
done

RC=`cat ${RC_G_TMP}`

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
