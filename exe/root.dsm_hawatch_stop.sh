#!/bin/sh
#---------------------------------#
# dsm_hawatch stop                #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env # 
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

SLEEP_TIME=3

EXEC_SH=root.dsm_hawatch.sh
RUNCHK_SH=root.dsm_hawatch_status.sh

TGT_PS=dsm_hawatch

#------#
# main #
#------#
echo "***** Start : ${TGT_PS} Stop *****"

#--- runchk(before) ---#
sh ${RUNCHK_SH}
if [[ $? = ${ERRORS} ]]; then
    echo "***** Info  : ${TGT_PS} Already Stopped *****"
    echo "***** End   : ${TGT_PS} Stop *****"
    exit ${SUCCESS}
fi

#--- stop ---#
TGT_PS_ID=`ps -ef | grep ${EXEC_SH} | grep -v grep | awk '{print $2}'`
kill -9 ${TGT_PS_ID}

#--- runchk(after) ---#
count=0
while (( ${count} < 3 ))
do
    sh ${RUNCHK_SH}
    if [[ $? = ${ERRORS} ]]; then
        RC=${SUCCESS}
        break
    else    
        RC=${ERRORS}
        sleep ${SLEEP_TIME}
        (( count = ${count} + 1 ))
    fi
done    

#-----#
# end #
#-----#
if [[ ${RC} = ${SUCCESS} ]]; then
    echo "***** End   : ${TGT_PS} Stop *****"
    exit ${SUCCESS}
else
    echo "***** Abend : ${TGT_PS} Stop *****"
    exit ${ERRORS}
fi
