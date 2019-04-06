#!/bin/sh
#---------------------------------#
# set_env                         #
#       Authored by Y.Miyamoto    #
#---------------------------------#
SUCCESS=0
ERRORS=1
WARNING=16

RC=${SUCCESS}
RC_C=${SUCCESS}
RC_G=${SUCCESS}
RC_S=${SUCCESS}

#--- 以下、変更が必要箇所 ---#
BASE_DIR=/work01/PGM

EXE_DIR=${BASE_DIR}/exe
CFG_DIR=${BASE_DIR}/cfg
LOG_DIR=${BASE_DIR}/log

SYSLOG_DIR=/var/log
SYSLOG=messages

PRIMARY_DSM_SERVER=vdsm83.citsdomain2.local
SECONDARY_DSM_SERVER=vdsm84.citsdomain2.local
DOM_URL=v1/domains/1001
DOMAIN_NAME=dsmdomain
LICENSE_FILE=${CFG_DIR}/Version_6_-_Vormetric_POC_NO_KMIP-_Q4_2017_01-04-2017
DSM_ADMIN_USER=cliadmin
SYNCTGT_DSM=2                 # 同期対象DSMサーバ数

# 対象VTE
# for win
# VTE_HOST="winsvfs01.citsdomain2.local"
# for linux
# VTE_HOST="linux12.citsdomain2.local"
VTE_HOST="winsvfs01.citsdomain2.local linux12.citsdomain2.local"
VTE_INST=/root/vee-fs-6.1.2-22-rh7-x86_64.bin

PRIMARY_VTS="vts11.citsdomain2.local"
SECONDARY_VTS="vts12.citsdomain2.local"
VTS_HOST="vts11.citsdomain2.local"
LOG_URL=vts/rest/v2.0/log
VTS_WATCH_USER=vtswatch
VTS_WATCH_USER_KEY=${CFG_DIR}/vtswatch.key
VTS_WATCH_USER_CERT=${CFG_DIR}/vtswatch.crt
VTS_ADMIN_USER=cliadmin
VTS_SLEEP_TIME=300
VTS_UPGRADE_DIR=/var/ftp
VTS_UPGRADE_VER=vts-upgrade-2.3.0.258.zip

KEY=${CFG_DIR}/key
ADMIN_CFG=${CFG_DIR}/user_admin.cfg
ADMIN_PASS=${CFG_DIR}/user_adminpass.cfg
SUPERADMIN_CFG=${CFG_DIR}/user_superadmin.cfg
VTSWATCH_CFG=${CFG_DIR}/user_vtswatch.cfg
VTSROOT_CFG=${CFG_DIR}/user_vtsroot.cfg
VTSADMIN_PASS=${CFG_DIR}/user_vtsadminpass.cfg

#----------------------------#

CURL_PATH=${CFG_DIR}/admin_dir
VMSSC_PATH=${CFG_DIR}/vmssc_dir
POLICY_PATH=${CFG_DIR}/policy_dir
