#!/bin/sh
#---------------------------------#
# vte add host for dr             #
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
./vmssc host show > ${BEF_FILE}

#--- exec ---#
grep -v ^# ${CFG_FILE} | while read TGT
do
    DESC=`echo ${TGT} | awk -F'|' '{print $1}'`
    TYPE=`echo ${TGT} | awk -F'|' '{print $2}'`
    NAME=`echo ${TGT} | awk -F'|' '{print $3}'`

    #--- FSなので、fs:RC ---#
    ./vmssc host add -G -e "fs:RC db2:rc ids:rc key:rc kmip:rc" -d "${DESC}" ${NAME}
    RC_C=$?

    #--- ライセンス情報やLDTenableはmodify時しかできない ---#
    if [[ ${RC_C} = ${SUCCESS} ]]; then
        ./vmssc host modify -L ${TYPE} ${NAME}
    else
        echo -e "\n***** ${NAME} : [ NG ] *****"
    fi
    (( RC = ${RC} + ${RC_C} ))

    echo ${RC} > ${RC_C_TMP}
done

#--- after ---#
./vmssc host show > ${AFT_FILE}

grep -v ^# ${CFG_FILE} | while read TGT
do
    NAME=`echo ${TGT} | awk -F'|' '{print $3}'`

    grep "${NAME}" ${AFT_FILE} 
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
