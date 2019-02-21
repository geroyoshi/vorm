#!/bin/sh
#---------------------------------#
# vts key make                    #
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

ATTR_0="Attribute Index=0"
ATTR_1="Cryptographic Usage Mask=127"
ATTR_2="Object Type=SymmetricKey"
ATTR_3="pdktaALGORITHM=KT_AES128"
ATTR_4="pdktaAPP_SPEC_INFO=(null)"
ATTR_5="pdktaCONTACT_INFO=(null)"
ATTR_6="pdktaEXPIRY_DATE=(null)"
ATTR_7="pdktaKEY_USAGE=ONLINE"
ATTR_8="pdktaUNIQUE=FALSE"
ATTR_9="x-VormCanBePlainText=true"
ATTR_10="x-VormCanNeverBeExported=true"
ATTR_11="x-VormCanNeverBePlaintext=false"
ATTR_12="x-VormCanObjectPersist=true"
ATTR_13="x-VormID=(null)"

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
    DESC=`echo ${TGT} | awk -F'|' '{print $1}'`
    TYPE=`echo ${TGT} | awk -F'|' '{print $2}'`
    NAME=`echo ${TGT} | awk -F'|' '{print $3}'`

    ./vmssc key add -d "${DESC}" -t "${TYPE}" -h "${NAME}"
    RC_C=$?
    if [[ ${RC_C} != ${SUCCESS} ]]; then
        echo -e "\n***** ${NAME} : [ NG ] *****"
    fi

    # -A ファイルオプションが腐っているので、個別(-a)指定とする
    ./vmssc key setattr -a "${ATTR_0}" -a "${ATTR_1}" -a "${ATTR_2}" -a "${ATTR_3}" -a "${ATTR_4}" \
      -a "${ATTR_5}" -a "${ATTR_6}" -a "${ATTR_7}" -a "${ATTR_8}" -a "${ATTR_9}" -a "${ATTR_10}" \
      -a "${ATTR_11}" -a "${ATTR_12}" -a "${ATTR_13}" ${NAME}
    RC_S=$?
    (( RC = ${RC} + ${RC_C} + ${RC_S} ))

    echo ${RC} > ${RC_C_TMP}
done

#--- after ---#
grep -v ^# ${CFG_FILE} | while read TGT
do
    NAME=`echo ${TGT} | awk -F'|' '{print $3}'`
    ./vmssc show key -d ${NAME} >> ${AFT_FILE}

    grep -q "${NAME}" ${AFT_FILE} 
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
    echo -e "\n***** Key detail *****"
    cat ${AFT_FILE}
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
