#!/bin/sh
#---------------------------------#
# watch for dsm                   #
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
URL=${DOM_URL}
TGT_WORD=${DOMAIN_NAME}
TMP_FILE=/tmp/${EXEC_NAME}.txt; cp /dev/null ${TMP_FILE}
URL_P=https://${IP_P}/dsm/${URL}
URL_S=https://${IP_S}/dsm/${URL}

#------#
# main #
#------#
while true
do
    for TGT_DSM in ${IP_P} ${IP_S}
    do
        if [[ ${TGT_DSM} = ${IP_P} ]]; then
            URL=${URL_P}
        else
            URL=${URL_S}
        fi

        curl -sS -o ${TMP_FILE} -k -X GET -u ${USER} ${URL} ; grep -q ${TGT_WORD} ${TMP_FILE}
        #--- error時、再実施 ---#
        if [[ $? != ${SUCCESS} ]]; then
            sleep 3
            curl -sS -o ${TMP_FILE} -k -X GET -u ${USER} ${URL} ; grep -q ${TGT_WORD} ${TMP_FILE}

            #--- それでもerror時、logger ---#
            if [[ $? != ${SUCCESS} ]]; then
                logger -t ${EXEC_NAME} -p auth.crit ${TGT_DSM} is down
            fi
        fi
        sleep 1
        cp /dev/null ${TMP_FILE}
    done
    sleep ${SLEEP_TIME}
done
