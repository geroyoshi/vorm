#!/bin/sh
#---------------------------------#
# dsm add domain                  #
#  vmssc user ==> superadmin      #
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
cp vmssc.conf.super vmssc.conf

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- before ・・・作成前なので実施不要 ---#
# ./vmssc domain show > ${BEF_FILE}

#--- exec ---#
grep -v ^# ${CFG_FILE} | while read TGT
do
    DESC=`echo ${TGT} | awk -F'|' '{print $1}'`
    USER=`echo ${TGT} | awk -F'|' '{print $2}'`
    NAME=`echo ${TGT} | awk -F'|' '{print $3}'`

    ./vmssc domain add -d "${DESC}" -u ${USER} ${NAME}
    RC_C=$?

    #--- after ---#
    ./vmssc domain show > ${AFT_FILE}

    grep "${NAME}" ${AFT_FILE} 
    RC_G=$?

    if [[ ${RC_G} = ${SUCCESS} ]]; then
        TGT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_${NAME}.log
        ./vmssc domain show ${NAME} > ${TGT_FILE}
    else
        echo -e "\n***** ${NAME} : [ NG ] *****"
        echo -e "\n***** Info  : ${MY_NAME} Abend *****"
        exit ${ERRORS}
    fi
done

echo -e "\n***** Info  : ${MY_NAME} End *****"
exit ${SUCCESS}
