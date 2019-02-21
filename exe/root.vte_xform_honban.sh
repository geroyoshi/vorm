#!/bin/sh
#---------------------------------#
# vte_xform_honbanpol             #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env # 
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_SHELL=`basename $0`
EXEC_NAME=`echo ${MY_SHELL} | awk -F'.' '{print $2}'`

EXEC_SH="
root.vte_add_xformgp.sh
root.vte_exe_dataxform.sh
root.vte_del_xformgp.sh
root.vte_add_honbangp.sh
"

cd ${EXE_DIR}

#------#
# main #
#------#
echo -e "\n***** Info  : ${MY_SHELL} Start *****"

#--- start ---#
for TGT_SH in ${EXEC_SH}
do
    sh ${TGT_SH}

    if [[ $? = ${SUCCESS} ]]; then
        RC=${SUCCESS}
    else    
        RC=${WARNING}
        break
    fi
done    

#-----#
# end #
#-----#
if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_SHELL} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_SHELL} Abend *****"
    exit ${ERRORS}
fi
