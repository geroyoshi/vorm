#!/bin/sh
#---------------------------------#
# vte_watch status_check          #  
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env # 
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

TGT_PS=root.vte_watch.sh
TMP_LOG=${TGT_PS}_runchk_$$.txt

#------#
# main #
#------#
echo "***** Start : ${TGT_PS} RunCheck *****"

ps -ef | grep ${TGT_PS} | grep -v grep
RC=$?

#-----#
# end #
#-----#
# RC=0 ==> UP
# RC=1 ==> DOWN
#
if [[ ${RC} = 0 ]]; then
    echo "***** Info  : ${TGT_PS} [ OK ] *****"
    RC=${SUCCESS}
else
    echo "***** Info  : ${TGT_PS} [ NG ] *****"
    RC=${ERRORS}
fi

exit ${RC}
