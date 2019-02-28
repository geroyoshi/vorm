#!/bin/sh
#---------------------------------#
# dsm/vte/vts info get            #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

RC_TMP=${LOG_DIR}/RC_${EXEC_NAME}.tmp ; cp /dev/null ${RC_TMP}

ARG=$1

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

case ${ARG} in
    #--- 引数が「DSM/dsm/d/D」の場合、DSMが対象
    DSM|dsm|d|D) TGT_SH="root.dsm_show_conf.sh root.dsm_show_lic.sh root.dsm_show_admin.sh \
                         root.dsm_show_domain.sh root.dsm_show_backup.sh root.dsm_show_ha.sh \
                         root.dsm_show_syslog.sh"
                 TGT_LOG="dsm_show"
                 OUP_FILE=${LOG_DIR}/${EXEC_NAME}_DSM_`date "+%Y%m%d-%H%M%S"`.tar
    ;;
    #--- 引数が「VTE/vte/e/E」の場合、VTEが対象
    VTE|vte|e|E) TGT_SH="root.vte_show_host.sh root.vte_show_key.sh root.vte_show_policy.sh \
                         root.vte_show_gp.sh root.vte_show_syslog.sh"
                 TGT_LOG="vte_show"
                 OUP_FILE=${LOG_DIR}/${EXEC_NAME}_VTE_`date "+%Y%m%d-%H%M%S"`.tar
    ;;
    #--- 引数が「VTSlvts/s/S」の場合、VTSが対象
    VTS|vts|s|S) TGT_SH="root.vts_show_host.sh root.vts_show_key.sh"
                 TGT_LOG="vts_show"
                 OUP_FILE=${LOG_DIR}/${EXEC_NAME}_VTS_`date "+%Y%m%d-%H%M%S"`.tar
    ;;
    *) echo -e "\n***** Info  : Argument Error *****"
       echo -e "\n***** Info  : ${MY_NAME} Abend *****"
       exit ${ERRORS}
    ;;
esac

for TGT in ${TGT_SH}
do
    cd ${EXE_DIR}
    if [[ ${TGT} = "root.dsm_show_conf.sh" ]]; then
        sh ${EXE_DIR}/${TGT} 1 >/dev/null 2>&1
        (( RC = ${RC} + $? ))
        sh ${EXE_DIR}/${TGT} 2 >/dev/null 2>&1
        (( RC = ${RC} + $? ))
    else
        sh ${EXE_DIR}/${TGT} >/dev/null 2>&1
        (( RC = ${RC} + $? ))
    fi
    echo ${RC} > ${RC_TMP}
done

RC=`cat ${RC_TMP}`

echo -e "\n #--- 出力logをまとめています・・・ ---#"
cd ${LOG_DIR}
tar cf ${OUP_FILE} ${TGT_LOG}*.log

cd ${SYSLOG_DIR}
tar rf ${OUP_FILE} ${SYSLOG}*

#--- VTEの場合はpolicyも ---#
if [[ ${TGT_LOG} = "vte_show" ]]; then
    cd ${CFG_DIR}
    tar rf ${OUP_FILE} policy_dir
fi

gzip ${OUP_FILE}

echo -e "\n #--- 出力log(${OUP_FILE}.gz) ・・・ ---#"
ls -ltr ${OUP_FILE}*

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
