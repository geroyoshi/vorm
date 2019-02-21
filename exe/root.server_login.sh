#!/bin/sh
#---------------------------------#
# server login                    #
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

cd ${VMSSC_PATH}

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

function func_hiki {
  func_input
}

function func_hikiget {
  #--- サーバ名 ---#
  echo -e "\n***** DSMサーバ名を指定  *****"
  func_hiki
  if [[ $? = ${SUCCESS} ]]; then
      export DSM=${FROM_FUNC_ANS}
  fi

  #--- ユーザ名 ---#
  echo -e "\n***** ドメイン管理者名を指定  *****"
  func_hiki
  if [[ $? = ${SUCCESS} ]]; then
      export USER=${FROM_FUNC_ANS}
  fi

  #--- pass ---#
  echo -e "\n***** パスワードを指定  *****"
  func_hiki
  if [[ $? = ${SUCCESS} ]]; then
      export PASS=${FROM_FUNC_ANS}
  fi

  #--- ドメイン名 ---#
  echo -e "\n***** ドメイン名を指定  *****"
  func_hiki
  if [[ $? = ${SUCCESS} ]]; then
      export DOM=${FROM_FUNC_ANS}
  fi
}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

if [[ $# -eq 4 ]]; then
    export DSM=$1
    export USER=$2
    export PASS=$3
    export DOM=$4
else
    func_hikiget
fi

# 「-x 0」指定により、無期限
./vmssc -s ${DSM} -u ${USER} -p ${PASS} -d ${DOM} server login -x 0
RC=$?

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
