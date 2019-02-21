#!/bin/sh
#---------------------------------#
# vte initial encrypt cp          #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env #
#-----#
. `dirname $0`/../cfg/set_env.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`
CFG_FILE=${CFG_DIR}/${EXEC_NAME}.cfg

AFT_FILE=${LOG_DIR}/aft_${EXEC_NAME}_`date "+%Y%m%d-%H%M%S"`.log

cd ${VMSSC_PATH}

#-------#
# start #
#-------#
echo -e "\n***** Info  : ${MY_NAME} Start *****"

#--- before ---#
CLASS=$1
case ${CLASS} in
    #--- mtime = 24 * n ---#
    TIME|T)
        CLASS=mtime
    ;;
    #--- mmin ---#
    MIN|M)
        CLASS=mmin
    ;;
    *)
        echo -e "\n***** Info  : argument error *****"
        echo -e "***** Info  : ${MY_NAME} Abend *****"
        exit ${ERRORS}
    ;;
esac

#--- exec ---#
grep -v ^# ${CFG_FILE} | while read TGT
do
    # 1つめ・・・source
    # 2つめ・・・destination
    SRC_DIR=`echo ${TGT} | awk -F'|' '{print $1}'`
    DEST_DIR=`echo ${TGT} | awk -F'|' '{print $2}'`

    # root.vte_initenc_file.shにて出力した、ディレクトリ毎のoutputを対象とする
    SRC_DIR_2=`echo ${SRC_DIR} | sed 's!/!_!g'`
    TGT_FILE=${LOG_DIR}/aft_vte_initenc_file_${CLASS}_${SRC_DIR_2}.log

    echo -e "\n#----- [ source : ${SRC_DIR} / dest : ${DEST_DIR}] -----#"
    echo -e "#----- [ source_file : ${TGT_FILE} ] -----#"

    # ディレクトリ毎のoutputを読み込んで、SRC_FILEとし、DEST_DIRにcp
    grep -v ^# ${TGT_FILE} | while read SRC_FILE
    do
        cp -p ${SRC_FILE} ${DEST_DIR}
    done 
    RC_C=$?
    (( RC = ${RC} + ${RC_C} ))
done

#--- after ---#
grep -v ^# ${CFG_FILE} | awk -F'|' '{print $2}' | while read TGT
do
    echo -e "\n#----- [ ${TGT} ] -----#"
    ls -ltr ${TGT}
done > ${AFT_FILE}

if [[ ${RC} = ${SUCCESS} ]]; then
    echo -e "\n***** Info  : ${MY_NAME} End *****"
    exit ${SUCCESS}
else
    echo -e "\n***** Info  : ${MY_NAME} Abend *****"
    exit ${ERRORS}
fi
