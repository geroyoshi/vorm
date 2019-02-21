#!/bin/sh
#---------------------------------#
# show command exec               #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

SLEEP_TIME=3

cd ${EXE_DIR}

#------#
# func #
#------#
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

function func_object {
  func_input
  if [[ $? = ${SUCCESS} ]]; then
      export TGT_DIR=${FROM_FUNC_ANS}
  fi
}

function func_dsm_config {
  cd ${EXE_DIR}
  echo
  sh root.dsm_show_conf.sh 1
  sh root.dsm_show_conf.sh 2
}

function func_dsm_license {
  cd ${EXE_DIR}
  echo
  sh root.dsm_show_lic.sh
}

function func_dsm_adminuser {
  cd ${EXE_DIR}
  echo
  sh root.dsm_show_admin.sh
}

function func_dsm_domain {
  cd ${EXE_DIR}
  echo
  sh root.dsm_show_domain.sh
}

function func_dsm_backup {
  cd ${EXE_DIR}
  echo
  sh root.dsm_show_backup.sh
}

function func_dsm_ha {
  cd ${EXE_DIR}
  echo
  sh root.dsm_show_ha.sh
}

function func_vte_agent {
  cd ${EXE_DIR}
  echo
  sh root.vte_show_host.sh
}

function func_vte_key {
  cd ${EXE_DIR}
  echo
  sh root.vte_show_key.sh
}

function func_vte_policy {
  cd ${EXE_DIR}
  echo
  sh root.vte_show_policy.sh
}

function func_vte_gp {
  cd ${EXE_DIR}
  echo
  sh root.vte_show_gp.sh
}

function func_vts_agent {
  cd ${EXE_DIR}
  echo
  sh root.vts_show_host.sh
}

function func_vts_key {
  cd ${EXE_DIR}
  echo
  sh root.vts_show_key.sh
}

#------#
# main #
#------#
while :
do
    clear
    cat <<-EOF

                   #-------------------#
                   # DSM/VTE/VTS query #
                   #-------------------#
#------------------------------------------------------------#
  ・DSM                ・VTE                ・VTS
     1) config            21) agent            31) agent
     2) license           22) key              32) key
     3) admin_user        23) policy
     4) domain            24) guard point
     5) backup
     6) ha

  ・処理終了
    99) exit
#------------------------------------------------------------#

EOF

    while :
    do
        # read No?" Select No and Press Enter > "
        echo -e "\n 対象番号を入力してください > "
        read No

        case ${No} in
          1) func_dsm_config          ;;
          2) func_dsm_license         ;;
          3) func_dsm_adminuser       ;;
          4) func_dsm_domain          ;;
          5) func_dsm_backup          ;;
          6) func_dsm_ha              ;;
         21) func_vte_agent           ;;
         22) func_vte_key             ;;
         23) func_vte_policy          ;;
         24) func_vte_gp              ;;
         31) func_vts_agent           ;;
         32) func_vts_key             ;;
         99) exit 0                   ;;
          *) continue                 ;;
        esac

        echo -e "\n press Enter"
        read

        break
    done
done

exit 0
