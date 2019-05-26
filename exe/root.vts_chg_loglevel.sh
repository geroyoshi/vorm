#!/bin/sh
#---------------------------------#
# vts chg loglevel                #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

RC_TMP=${LOG_DIR}/${EXEC_NAME}.tmp ; cp /dev/null ${RC_TMP}
TOTAL=${SUCCESS}
TOTAL_TMP=${LOG_DIR}/total_${EXEC_NAME}.tmp ; cp /dev/null ${TOTAL_TMP}
USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${VTSWATCH_CFG}`

ARG=$1

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

case ${ARG} in
    #--- 引数が「i/info」の場合、info
    -i|-info|-I|-INFO)
       TGT_CURL=${CFG_DIR}/curl_${EXEC_NAME}_info.cfg
       TGT_LEVEL=info
    ;;
    #--- 引数が「e/error」の場合、info
    -e|-error|-E|-ERROR)
       TGT_CURL=${CFG_DIR}/curl_${EXEC_NAME}_error.cfg
       TGT_LEVEL=error
    ;;
    #--- 引数が「d/debug」の場合、debug
    -d|-debug|-D|-DEBUG)
       TGT_CURL=${CFG_DIR}/curl_${EXEC_NAME}_debug.cfg
       TGT_LEVEL=debug
    ;;
    #--- 引数が「c/critical」の場合、critical
    -c|-critical|-C|-CRIT)
       TGT_CURL=${CFG_DIR}/curl_${EXEC_NAME}_critical.cfg
       TGT_LEVEL=critical
    ;;
    #--- 引数が「w/warning」の場合、warning
    -w|-warning|-W|-WARN)
       TGT_CURL=${CFG_DIR}/curl_${EXEC_NAME}_warning.cfg
       TGT_LEVEL=warning
    ;;
    *) echo -e "\n***** Info  : Argument Error *****"
       echo -e "\n***** Info  : ${MY_NAME} Abend *****"
       exit ${ERRORS}
    ;;
esac

#--- 対象VTSに対してループ ---#
for TGT_IP in ${VTS_HOST}
do
    echo -e "\n***** Info  : IP=${TGT_IP} LEVEL=${TGT_LEVEL} Chg Start *****"
    RC_C=`curl -sS -k -X POST -u ${USER} -d @${TGT_CURL} https://${TGT_IP}/${LOG_URL}| grep -c success`
    if [[ ${RC_C} -eq 1 ]]; then
        echo -e "\n***** Info  : IP=${TGT_IP} LEVEL=${TGT_LEVEL} Chg Success *****"
    else
        echo -e "\n***** Info  : IP=${TGT_IP} LEVEL=${TGT_LEVEL} Chg Failure *****"
    fi

    (( RC = ${RC} + ${RC_C} ))
    (( TOTAL = ${TOTAL} + 1 ))
    echo ${RC} > ${RC_TMP}
    echo ${TOTAL} > ${TOTAL_TMP}
done

RC=`cat ${RC_TMP}`
TOTAL=`cat ${TOTAL_TMP}`

if [[ ${RC} -eq ${TOTAL} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
