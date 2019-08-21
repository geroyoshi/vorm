#!/bin/sh
#---------------------------------#
# vte rotate ldtkey               #
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
    NAME=`echo ${TGT} | awk '{print $1}'`

    #--- before ---#
    BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_${NAME}_`date "+%Y%m%d-%H%M%S"`.log
    ./vmssc show key -d ${NAME} > ${BEF_FILE}

    BEF_VER=`grep "Key Version" ${BEF_FILE}| head -n1| awk -F':' '{print $2}'| tr -d ' '`
    (( AFT_EXPECTED_VER = ${BEF_VER} + 1 ))

    #--- reason = maintenance ---#
    ./vmssc key rotate -r M "${NAME}"
    RC_C=$?
    if [[ ${RC_C} != ${SUCCESS} ]]; then
        echo -e "\n***** ${NAME} : [ NG ] *****"
    fi
    (( RC = ${RC} + ${RC_C} ))

    #--- after ---#
    AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_${NAME}_`date "+%Y%m%d-%H%M%S"`.log
    ./vmssc show key -d ${NAME} > ${AFT_FILE}

    AFT_VER=`grep "Key Version" ${AFT_FILE}| head -n1| awk -F':' '{print $2}'| tr -d ' '`

    if [[ ${AFT_VER} = ${AFT_EXPECTED_VER} ]]; then
        RC_G=${SUCCESS}
        echo -e "${NAME} : [ ${AFT_VER} ]"
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
