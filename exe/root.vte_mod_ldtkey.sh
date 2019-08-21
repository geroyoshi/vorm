#!/bin/sh
#---------------------------------#
# vte mod ldtkey make             #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg
BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

RC_C_TMP=${LOG_DIR}/C_${EXEC_NAME}.tmp ; cp /dev/null ${RC_C_TMP}
RC_G_TMP=${LOG_DIR}/G_${EXEC_NAME}.tmp ; cp /dev/null ${RC_G_TMP}

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- before ---#
./vmssc show key -d > ${BEF_FILE}

#--- exec ---#
grep -v ^# ${CFG_FILE} | while read TGT
do
    SPAN=`echo ${TGT} | awk -F'|' '{print $1}'`
    NAME=`echo ${TGT} | awk -F'|' '{print $2}'`

    ./vmssc key mod -S "${SPAN}"  -h "${NAME}"
    RC_C=$?
    if [[ ${RC_C} != ${SUCCESS} ]]; then
        echo -e "\n***** ${NAME} : [ NG ] *****"
    fi
    (( RC = ${RC} + ${RC_C} ))

    echo ${RC} > ${RC_C_TMP}
done

#--- after ---#
./vmssc show key -d > ${AFT_FILE}

grep -v ^# ${CFG_FILE} | while read TGT
do
    SPAN=`echo ${TGT} | awk -F'|' '{print $1}'`
    NAME=`echo ${TGT} | awk -F'|' '{print $2}'`
    AFT_MOD_FILE=${LOG_DIR}/aft_${EXEC_NAME}_${NAME}_`date "+%Y%m%d-%H%M%S"`.log

    ./vmssc show key -d ${NAME} > ${AFT_MOD_FILE}

    grep "Key Version Life Span: ${SPAN}" ${AFT_MOD_FILE} 
    RC_G=$?
    if [[ ${RC_G} != ${SUCCESS} ]]; then
        echo -e "\n***** ${NAME} : [ NG ] *****"
    fi
    (( RC = ${RC} + ${RC_G} ))

    echo ${RC} > ${RC_G_TMP}
done

RC_C=`cat ${RC_C_TMP}`
RC_G=`cat ${RC_G_TMP}`

(( RC = ${RC_C} + ${RC_G} ))

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
