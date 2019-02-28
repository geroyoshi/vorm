#!/bin/sh
#---------------------------------#
# vte add syslog                  #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg

RC_C_ERR=${LOG_DIR}/C_${EXEC_NAME}.err; rm -f ${RC_C_ERR}
RC_G_ERR=${LOG_DIR}/G_${EXEC_NAME}.err; rm -f ${RC_G_ERR}

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

grep -v ^# ${CFG_FILE} | while read TGT
do
    ENTRY=`echo ${TGT} | awk -F'|' '{print $1}'`
    DOMAIN=`echo ${TGT} | awk -F'|' '{print $2}'`
    FSNAME=`echo ${TGT} | awk -F'|' '{print $3}'`
    SERVER=`echo ${TGT} | awk -F'|' '{print $4}'`
    PROTO=`echo ${TGT} | awk -F'|' '{print $5}'`
    FORMAT=`echo ${TGT} | awk -F'|' '{print $6}'`

    BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_${FSNAME}_`date "+%Y%m%d-%H%M%S"`.log
    AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_${FSNAME}_`date "+%Y%m%d-%H%M%S"`.log

    #--- before ---#
    ./vmssc syslog showhost -a FS -h ${FSNAME} > ${BEF_FILE}

    #--- exec ---#
    #--- FSなので、fs:RC ---#
    case ${ENTRY} in
        1) OPT="-o" ;;
        2) OPT="-t" ;;
        3) OPT="-r" ;;
        4) OPT="-f" ;;
        *)
          echo -e "\n***** Info  : ${MY_NAME} Abend *****"
          exit ${ERRORS}
        ;;
    esac

    ./vmssc -d ${DOMAIN} syslog addhost -a FS -h ${FSNAME} ${OPT} "${SERVER} ${PROTO} ${FORMAT}"
    RC_C=$?

    if [[ ${RC_C} != ${SUCCESS} ]]; then
        echo -e "\n***** ${NAME} : [ NG ] *****"
        touch ${RC_C_ERR}
    fi

    #--- after ---#
    ./vmssc syslog showhost -a FS -h ${FSNAME} > ${AFT_FILE}

    grep "${SERVER}" ${AFT_FILE} 
    RC_G=$?
    if [[ ${RC_G} != ${SUCCESS} ]]; then
        echo -e "\n***** ${NAME} : [ NG ] *****"
        touch ${RC_G_ERR}
    fi
done

if [[ -f ${RC_C_ERR} ]] || [[ -f ${RC_G_ERR} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
else
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
fi
