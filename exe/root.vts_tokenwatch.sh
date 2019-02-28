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

TMP_FILE=${LOG_DIR}/${EXEC_NAME}.$$.txt; cp /dev/null ${TMP_FILE}
USER=`openssl rsautl -decrypt -inkey ${KEY} -in ${VTSWATCH_CFG}`

IP_P=${PRIMARY_VTS}
IP_S=${SECONDARY_VTS}

#------#
# main #
#------#
for IP in ${IP_P} ${IP_S}
do
    # IP=${IP_P}
    URL=https://${IP}/vts/rest/v2.0/tokenize

    grep -v ^# ${CFG_FILE} | while read DAT_FILE
    do
        curl -sS -o ${TMP_FILE} -k -X POST -u ${USER} -d @${DAT_FILE} ${URL} >/dev/null 2>&1
        # 出力待ちとして1sec
        sleep 1
        grep -i succeed ${TMP_FILE} >/dev/null 2>&1

        #--- success時、0出力 ---#
        if [[ $? = ${SUCCESS} ]]; then
            echo "${IP},0"
        #--- error時、再実施 ---#
        else
            sleep 1

            curl -sS -o ${TMP_FILE} -k -X POST -u ${USER} -d @${DAT_FILE} ${URL} >/dev/null 2>&1
            # 出力待ちとして1sec
            sleep 1
            grep -i succeed ${TMP_FILE} >/dev/null 2>&1
            #--- それでもerror時、3出力 ---#
            if [[ $? != ${SUCCESS} ]]; then
                echo "${IP},3"
            fi
        fi
        rm -f ${TMP_FILE}
    done
done
