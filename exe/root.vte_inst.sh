#!/bin/sh
#---------------------------------#
# vte inst/regist                 #
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

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- before ---#
./vmssc host show > ${BEF_FILE}

#--- exec ---#
# Fingerprintでの認証
# VTE_INSTはset_env.shに定義

${VTE_INST} -s ${CFG_FILE}
RC_C=$?

#--- after ---#
./vmssc host show > ${AFT_FILE}

# 対象ホストを抽出し、事後ファイルに存在することを確認
TGT_HOST=`grep -v ^# ${CFG_FILE} | grep AGENT_HOST_NAME | awk -F'=' '{print $2}'`
grep -q ${TGT_HOST} ${AFT_FILE}
RC_G=$?

(( RC = ${RC_C} + ${RC_G} ))

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
