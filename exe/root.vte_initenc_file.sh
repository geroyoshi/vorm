#!/bin/sh
#---------------------------------#
# vte initial encrypt tgtfile     #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- before ---#
CLASS=$1
case ${CLASS} in
    #--- mtime = 24 * n ---#
    TIME|T)
        CLASS=mtime
    ;;
    #--- mmin ---#
    MIN|M)
        CLASS=mmin
    ;;
    *)
        echo -e "\n***** Info  : argument error *****"
        echo -e "***** Info  : ${MY_NAME} Abend *****"
        exit ${ERRORS}
    ;;
esac

TERM=$2
if [[ ${TERM} -gt 0 ]]; then
    :
else
    echo -e "\n***** Info  : argument error *****"
    echo -e "***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi

#--- exec ---#
grep -v ^# ${CFG_FILE} | while read TGT_DIR
do
    echo -e "\n#----- [ dstdir : ${TGT_DIR} ] -----#"
    TGT_DIR_2=`echo ${TGT_DIR} | sed 's!/!_!g'`
    AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_${CLASS}_${TGT_DIR_2}.log

    find ${TGT_DIR} -${CLASS} -${TERM} -type f > ${AFT_FILE}
    RC_C=$?
    (( RC = ${RC} + ${RC_C} ))
    ls -ltr ${AFT_FILE}
done

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
