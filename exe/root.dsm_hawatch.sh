#!/bin/sh
#---------------------------------#
# hawatch for dsm                 #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env # 
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

SLEEP_TIME=300

IP_P=${PRIMARY_DSM_SERVER}
IP_S=${SECONDARY_DSM_SERVER}
USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${SUPERADMIN_CFG}`
TGT_WORD=NORMAL
TMP_FILE=/tmp/${EXEC_NAME}.txt; cp /dev/null ${TMP_FILE}
URL_P=https://${IP_P}/dsm/v1/ha/nodes
URL_S=https://${IP_S}/dsm/v1/ha/nodes

#------#
# main #
#------#
while true
do
    # 1系へのキックで、1系で実施不可なら1系DOWN
    for TGT_DSM in ${IP_P}
    do
        if [[ ${TGT_DSM} = ${IP_P} ]]; then
            URL=${URL_P}
        else
            URL=${URL_S}
        fi

        curl -sS -o ${TMP_FILE} -k -X GET -u ${USER} ${URL}

        # 出力ファイルの対象サーバ記載から「2行目」に「NORMAL」文言あるか無しか
        grep -A 2 ${TGT_DSM} ${TMP_FILE}| grep -q ${TGT_WORD}

        #--- error時、再実施 ---#
        if [[ $? != ${SUCCESS} ]]; then
            sleep 3
            curl -sS -o ${TMP_FILE} -k -X GET -u ${USER} ${URL}
            grep -A 2 ${TGT_DSM} ${TMP_FILE}| grep -q ${TGT_WORD}

            #--- それでもerror時、logger ---#
            if [[ $? != ${SUCCESS} ]]; then
                logger -t ${EXEC_NAME} -p auth.crit DSMServer HA is down
            fi
        fi
        sleep 1
        cp /dev/null ${TMP_FILE}
    done
    sleep ${SLEEP_TIME}
done
