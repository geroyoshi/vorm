#!/bin/ksh
#---------------------------------#
# set_function                    #
#       Authored by Y.Miyamoto    #
#---------------------------------#

#--- 入力 ---#
function func_input {
  sleep 1

  while :
  do
    echo -e "\n 対象を入力してください > "
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

#--- 対象入力 ---#
function func_object {
  func_input
  if [[ $? = ${SUCCESS} ]]; then
      export TGT_DIR=${FROM_FUNC_ANS}
  fi
}
