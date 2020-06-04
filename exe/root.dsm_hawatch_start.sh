#!/bin/sh
#---------------------------------#
# dsm_hawatch start               #
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
echo "***** Start : ${TGT_PS} Start *****"

#--- runchk(before) ---#
sh ${RUNCHK_SH}
if [[ $? = ${SUCCESS} ]]; then
    echo "***** Info  : ${TGT_PS} Already Started *****"
    echo "***** End   : ${TGT_PS} Start *****"
    exit ${SUCCESS}
fi

#--- start ---#
sh ${EXEC_SH} &

#--- runchk(after) ---#
count=0
while (( ${count} < 3 ))
do
    sh ${RUNCHK_SH}
    if [[ $? = ${SUCCESS} ]]; then
        RC=${SUCCESS}
        break
    else    
        RC=${WARNING}
        sleep ${SLEEP_TIME}
        (( count = ${count} + 1 ))
    fi
done    

#-----#
# end #
#-----#
if [[ ${RC} = ${SUCCESS} ]]; then
    echo "***** End   : ${TGT_PS} Start *****"
    exit ${SUCCESS}
else
    echo "***** ${TGT_PS} : [ NG ] *****"
    echo "***** Abend : ${TGT_PS} Start *****"
    exit ${ERRORS}
fi
