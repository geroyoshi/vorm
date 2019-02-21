#!/bin/sh
#---------------------------------#
# vte show policy                 #
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

#--- exec ---#
grep -v ^# ${CFG_FILE} | while read TGT
do
    F_NAME=`echo ${TGT} | awk -F'|' '{print $1}'`
    NAME=`echo ${TGT} | awk -F'|' '{print $2}'`

    #--- 対象ポリシー(NAME)に対して、vmssc ---#
    echo -e "\n***** Info  : POLICY=${NAME} *****\n"
    ./vmssc policy show -f ${F_NAME} ${NAME}
    RC_C=$?

    if [[ ${RC_C} = ${SUCCESS} ]]; then
        echo
        mv ${F_NAME} ${POLICY_PATH}/.
    else
        echo -e "\n***** ${NAME} : [ NG ] *****"
    fi
    (( RC = ${RC} + ${RC_C} ))

    echo ${RC} > ${RC_C_TMP}
done

#--- after ---#
cd ${POLICY_PATH}

echo -e "\n***** Info  : ${MY_NAME} After(${POLICY_PATH}) *****"

grep -v ^# ${CFG_FILE} | while read TGT
do
    F_NAME=`echo ${TGT} | awk -F'|' '{print $1}'`

    ls -l ${F_NAME}
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
