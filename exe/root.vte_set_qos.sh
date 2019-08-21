#!/bin/sh
#---------------------------------#
# vte set qos                     #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg

RC_G_TMP=${LOG_DIR}/G_${EXEC_NAME}.tmp ; cp /dev/null ${RC_G_TMP}

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- exec ---#
grep -v ^# ${CFG_FILE} | while read TGT
do
    CAP=`echo ${TGT} | awk -F'|' '{print $1}'`
    PERCENT=`echo ${TGT} | awk -F'|' '{print $2}'`
    SCHED=`echo ${TGT} | awk -F'|' '{print $3}'`
    NAME=`echo ${TGT} | awk -F'|' '{print $4}'`

    #--- CAP=1・・・Enabled、CAP=0・・・Disabled ---#
    if [[ ${CAP} = 1 ]]; then
        CAP_WORD=Enabled
    else
        CAP_WORD=Disabled
    fi

    #--- before ---#
    BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_${NAME}_`date "+%Y%m%d-%H%M%S"`.log
    ./vmssc rekey getqos ${NAME} > ${BEF_FILE}

    #--- set ---#
    ./vmssc rekey setqos -c ${CAP} -p ${PERCENT} -s ${SCHED} ${NAME}
    RC_C=$?
    if [[ ${RC_C} != ${SUCCESS} ]]; then
        echo -e "\n***** ${NAME} : [ NG ] *****"
    fi
    (( RC = ${RC} + ${RC_C} ))

    #--- after ---#
    AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_${NAME}_`date "+%Y%m%d-%H%M%S"`.log
    ./vmssc rekey getqos ${NAME} > ${AFT_FILE}

    sed -n '1p' ${AFT_FILE} | grep -q ${PERCENT}
    RC_PERCENT=$?

    sed -n '2p' ${AFT_FILE} | grep -q ${CAP_WORD}
    RC_CAP=$?

    sed -n '3p' ${AFT_FILE} | grep -q ${SCHED}
    RC_SCHED=$?

    (( RC_G = ${RC_PERCENT} + ${RC_CAP} + ${RC_SCHED} ))
    
    if [[ ${RC_G} = ${SUCCESS} ]]; then
        echo -e "\n***** ${NAME} *****"
        cat ${AFT_FILE}
    else
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
