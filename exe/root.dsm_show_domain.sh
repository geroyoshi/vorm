#!/bin/sh
#---------------------------------#
# dsm show domain                 #
#  vmssc user ==> superadmin      #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
LOG_FILE=${LOG_DIR}/${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log; cp /dev/null ${LOG_FILE}

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- show ---#
./vmssc domain show > ${BEF_FILE}
RC=$?

cat ${BEF_FILE} | while read TGT
do
    echo -e "\n***** Info  : DOMAIN=${TGT} *****\n"
    ./vmssc domain show ${TGT} >> ${LOG_FILE}
done

if [[ ${RC} = ${SUCCESS} ]]; then
    echo
    cat ${LOG_FILE}
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
