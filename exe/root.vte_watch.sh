#!/bin/sh
#---------------------------------#
# watch for vte                   #
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
TMP_FILE=/tmp/${EXEC_NAME}.txt; cp /dev/null ${TMP_FILE}
URL_P=https://${IP_P}/dsm
URL_S=https://${IP_S}/dsm
VTE_WATCH=${LOG_DIR}/${EXEC_NAME}_NG

#------#
# main #
#------#
while true
do
    for TGT_DSM in ${IP_P} ${IP_S}
    do
        if [[ ${TGT_DSM} = ${IP_P} ]]; then
            #--- 対象domainidを取得する・・・とりあえず一つ目で ---#
            DOMAINID=`curl -sS -k -X GET -u ${USER} ${URL_P}/v1/domains | grep "url" \
                     |awk -F'/' '{print $4}' | cut -c1-4| head -n1`

            #--- DOMAINID情報取れない場合、TKO中とみなす ---#
            if [[ -z ${DOMAINID} ]]; then
                touch ${VTE_WATCH}
            else
                for TGT_HOST in ${VTE_HOST}
                do
                    #--- 対象hostを取得する・・・「/v1/domains/${DOMAINID}/hosts/${HOSTID} ---#
                    HOST=`curl -sS -k -X GET -u ${USER} ${URL_P}/v1/domains/${DOMAINID}/hosts \
                         |grep -B 1 ${TGT_HOST} |grep url |awk -F'/' '{print $NF}'|awk -F'"' '{print $1}'`
                    URL=${URL_P}/v1/domains/${DOMAINID}/hosts/${HOST}/guardpoints

                    curl -sS -o ${TMP_FILE} -k -X GET -u ${USER} ${URL} ; grep -q guarded ${TMP_FILE}

                    #--- error時、再実施 ---#
                    if [[ $? != ${SUCCESS} ]]; then
                        sleep 3
                        curl -sS -o ${TMP_FILE} -k -X GET -u ${USER} ${URL} ; grep -q guarded ${TMP_FILE}

                        #--- それでもerror時、logger ---#
                        if [[ $? != ${SUCCESS} ]]; then
                            logger -t ${EXEC_NAME} -p auth.crit ${TGT_HOST} is down
                            touch ${VTE_WATCH}
                        fi
                    fi
                done
            fi
        else
            if [[ -f ${VTE_WATCH} ]]; then
                #--- 対象domainidを取得する ---#
                DOMAINID=`curl -sS -k -X GET -u ${USER} ${URL_S}/v1/domains | grep "url" \
                         |awk -F'/' '{print $4}' | cut -c1-4`

                #--- 対象hostを取得する・・・/v1/domains/${DOMAINID}/hosts/${HOSTID} ---#
                for TGT_HOST in ${VTE_HOST}
                do
                    HOST=`curl -sS -k -X GET -u ${USER} ${URL_S}/v1/domains/${DOMAINID}/hosts \
                         |grep -B 1 ${TGT_HOST} |grep url |awk -F'/' '{print $NF}'|awk -F'"' '{print $1}'`
                    URL=${URL_S}/v1/domains/${DOMAINID}/hosts/${HOST}/guardpoints

                    curl -sS -o ${TMP_FILE} -k -X GET -u ${USER} ${URL} ; grep -q guarded ${TMP_FILE}

                    #--- error時、再実施 ---#
                    if [[ $? != ${SUCCESS} ]]; then
                        sleep 3
                        curl -sS -o ${TMP_FILE} -k -X GET -u ${USER} ${URL} ; grep -q guarded ${TMP_FILE}

                        #--- それでもerror時、logger ---#
                        if [[ $? != ${SUCCESS} ]]; then
                            logger -t ${EXEC_NAME} -p auth.crit ${TGT_HOST} is down
                            rm -f ${VTE_WATCH}
                        fi
                    fi
                done
            fi
        fi
        sleep 1
        cp /dev/null ${TMP_FILE}
    done
    # 副用フラグリセット
    rm -f ${VTE_WATCH}

    sleep ${SLEEP_TIME}
done
