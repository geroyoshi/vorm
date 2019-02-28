#!/bin/sh
#---------------------------------#
# watch for vts                   #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env # 
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg

SLEEP_TIME=300
TMP_FILE=/tmp/${EXEC_NAME}.txt; cp /dev/null ${TMP_FILE}
USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${VTSWATCH_CFG}`

IP_P=${PRIMARY_VTS}
IP_S=${SECONDARY_VTS}

#------#
# main #
#------#
while true
do
    for IP in ${IP_P} ${IP_S}
    do
        URL=https://${IP}/vts/rest/v2.0/tokenize

        grep -v ^# ${CFG_FILE} | while read DAT_FILE
        do
            curl -sS -o ${TMP_FILE} -k -X POST -u ${USER} -d @${DAT_FILE} ${URL}
            # 出力待ちとして1sec
            sleep 1
            grep -i succeed ${TMP_FILE}

            #--- error時、再実施 ---#
            if [[ $? != ${SUCCESS} ]]; then
                sleep 3

                curl -sS -o ${TMP_FILE} -k -X POST -u ${USER} -d @${DAT_FILE} ${URL}
                # 出力待ちとして1sec
                sleep 1
                grep -i succeed ${TMP_FILE}
                #--- それでもerror時、logger ---#
                if [[ $? != ${SUCCESS} ]]; then
                    KEY=`grep tokengroup ${DAT_FILE} | awk -F':' '{print $2}' | tr -d \",`
                    logger -t ${EXEC_NAME} -p auth.crit "${IP} is down (KEY=${KEY})"
                fi
            fi
            cp /dev/null ${TMP_FILE}
        done
    done
    sleep ${SLEEP_TIME}
done
