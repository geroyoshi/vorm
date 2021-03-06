#!/bin/sh
#---------------------------------#
# vte del xformguardpoint         #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg

RC_C_TMP=${LOG_DIR}/C_${EXEC_NAME}.tmp ; cp /dev/null ${RC_C_TMP}
RC_G_TMP=${LOG_DIR}/G_${EXEC_NAME}.tmp ; cp /dev/null ${RC_G_TMP}

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- before ---#
grep -v ^# ${CFG_FILE} | awk -F '|' '{print $3}' | while read NAME
do
    BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_${NAME}.log

    ./vmssc host showgp ${NAME} > ${BEF_FILE}
done

grep -v ^# ${CFG_FILE} | while read TGT
do
    DIR=`echo ${TGT} | awk -F'|' '{print $1}'`
    POLICY=`echo ${TGT} | awk -F'|' '{print $2}'`
    NAME=`echo ${TGT} | awk -F'|' '{print $3}'`

    #--- exec ---#
    echo -e "\n***** Info  : ${DIR} *****"
    ./vmssc host delgp -d "${DIR}" -p ${POLICY} ${NAME}
    RC_C=$?

    if [[ ${RC_C} != ${SUCCESS} ]]; then
        echo -e "\n***** ${NAME} : [ NG ] *****"
    fi
    (( RC = ${RC} + ${RC_C} ))
done

#--- after ---#
grep -v ^# ${CFG_FILE} | awk -F '|' '{print $3}' | while read NAME
do
    AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_${NAME}.log

    ./vmssc host showgp ${NAME} > ${AFT_FILE}
done

grep -v ^# ${CFG_FILE} | while read TGT
do
    DIR=`echo ${TGT} | awk -F'|' '{print $1}'`
    POLICY=`echo ${TGT} | awk -F'|' '{print $2}'`
    NAME=`echo ${TGT} | awk -F'|' '{print $3}'`
    AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_${NAME}.log

    RC_G=`grep -c "${DIR}" ${AFT_FILE}`
    if [[ ${RC_G} != ${SUCCESS} ]]; then
        echo -e "\n***** ${NAME} : [ NG ] *****"
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
