#!/bin/sh
#---------------------------------#
# vte exec dataxform              #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg
VORMETRIC_PATH=/opt/vormetric/DataSecurityExpert/agent/vmd/bin
LOG_FILE=${LOG_DIR}/${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

RC_C_TMP=${LOG_DIR}/C_${EXEC_NAME}.tmp ; cp /dev/null ${RC_C_TMP}
RC_G_TMP=${LOG_DIR}/G_${EXEC_NAME}.tmp ; cp /dev/null ${RC_G_TMP}

cd ${VORMETRIC_PATH}

#----------#
# function #
#----------#
function _exec {
  grep -v ^# ${CFG_FILE} | while read TGT
  do
      #--- exec ---#
      TGT_DIR=`echo ${TGT} | awk -F'|' '{print $1}'`

      echo -e "\n***** Info  : ${TGT_DIR} *****"
      echo "\y" | dataxform --rekey --print_stat --gp ${TGT_DIR}
      RC_C=$?
      if [[ ${RC_C} != ${SUCCESS} ]]; then
          echo -e "\n***** ${NAME} : [ NG ] *****"
      fi
      (( RC = ${RC} + ${RC_C} ))

      echo ${RC} > ${RC_C_TMP}
  done | tee -a ${LOG_FILE}
}

function _del {
  grep -v ^# ${CFG_FILE} | while read TGT
  do
      #--- exec ---#
      TGT_DIR=`echo ${TGT} | awk -F'|' '{print $1}'`
      echo "\y" | dataxform --cleanup --gp ${TGT_DIR}
      RC_C=$?
      if [[ ${RC_C} != ${SUCCESS} ]]; then
          echo -e "\n***** ${NAME} : [ NG ] *****"
      fi
      (( RC = ${RC} + ${RC_C} ))

      echo ${RC} > ${RC_C_TMP}
  done | tee -a ${LOG_FILE}
}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

HIKI=$1

# 引数「-d」
if [[ ${HIKI} = "-d" ]]; then
    _del
# 上記以外 ==> 通常
else
    _exec
    _del
fi

RC=`cat ${RC_C_TMP}`

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
