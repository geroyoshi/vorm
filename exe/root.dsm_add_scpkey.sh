#!/bin/sh
#---------------------------------#
# dsm add key(scp backup)         #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
BEF_FILE=${LOG_DIR}/bef_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log
USER_FILE=${LOG_DIR}/user_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

cd ${HOME}

#------#
# func #
#------#
function func_input {
  sleep 1

  while :
  do
    echo "情報を入力してください > "
    read FROM_INP_ANS

    if [[ -z "${FROM_INP_ANS}" ]]; then
        continue
    fi

    while :
    do
        echo -e "\n よろしいですか？(y:続行  r:再入力  q:処理中止) > "
        read ans

        case ${ans} in
          Y|y) FUNC_RC=0
               break
          ;;
          r|R) FUNC_RC=1
               break
          ;;
          q|Q) echo "quit"
               exit 1
          ;;
       esac
    done

    if [[ ${FUNC_RC} = 0 ]]; then
        export FROM_FUNC_ANS=${FROM_INP_ANS}
        break
    fi
  done

  return ${FUNC_RC}
}

function func_key {
  echo -e "\n***** authorized_key作成 *****"
  func_input
  if [[ $? = ${SUCCESS} ]]; then
      export TGT_KEY=${FROM_FUNC_ANS}
  fi
}

function func_dir {
  echo -e "\n***** backup先ディレクトリ作成 *****"
  func_input
  if [[ $? = ${SUCCESS} ]]; then
      export TGT_DIR=${FROM_FUNC_ANS}
  fi
}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- before ---#
ls -lR .ssh > ${BEF_FILE} >>/dev/null 2>&1

#--- create directory ---#
if [[ $? != ${SUCCESS} ]]; then
    mkdir -m 700 .ssh
fi

#--- create key ---#
func_key
echo ${TGT_KEY} >> .ssh/authorized_keys
chmod 600 .ssh/authorized_keys

#--- after ---#
ls -lR .ssh | tee -a ${AFT_FILE}

#--- create backupdir ---#
func_dir
if [[ ! -d ${TGT_DIR} ]]; then
    mkdir -m 700 ${TGT_DIR}
fi
ls -ld ${TGT_DIR} | tee -a ${AFT_FILE}

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
