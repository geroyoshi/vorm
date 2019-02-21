#!/bin/sh
#---------------------------------#
# watch for vte + secondary       #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env # 
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

IP_P=${PRIMARY_DSM_SERVER}
IP_S=${SECONDARY_DSM_SERVER}
USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${SUPERADMIN_CFG}`
TMP_FILE=${LOG_DIR}/${EXEC_NAME}.$$.txt
URL_P=https://${IP_P}/dsm
URL_S=https://${IP_S}/dsm

#------#
# main #
#------#
    #--- 対象domainidを取得する・・・とりあえず一つ目で ---#
    DOMAINID=`curl -sS -k -X GET -u ${USER} ${URL_P}/v1/domains | grep "url" \
              |awk -F'/' '{print $4}' | cut -c1-4| head -n1`

    for TGT_HOST in ${VTE_HOST}
    do
        #--- 対象hostを取得する・・・「/v1/domains/${DOMAINID}/hosts/${HOSTID} ---#
        HOST=`curl -sS -k -X GET -u ${USER} ${URL_P}/v1/domains/${DOMAINID}/hosts \
              |grep -B 1 ${TGT_HOST} |grep url |awk -F'/' '{print $NF}'|awk -F'"' '{print $1}'`
        URL=${URL_P}/v1/domains/${DOMAINID}/hosts/${HOST}/guardpoints

        curl -sS -o ${TMP_FILE} -k -X GET -u ${USER} ${URL} ; grep -q guarded ${TMP_FILE}

        #--- success時、0リターン ---#
        if [[ $? = ${SUCCESS} ]]; then
            echo "${TGT_HOST},0"
        #--- error時、再実施 ---#
        else
            sleep 3
            curl -sS -o ${TMP_FILE} -k -X GET -u ${USER} ${URL} ; grep -q guarded ${TMP_FILE}

            #--- それでもerror時、3リターン ---#
            if [[ $? != ${SUCCESS} ]]; then
                echo "${TGT_HOST},3"
            fi
        fi
    done
    rm -f ${TMP_FILE}
