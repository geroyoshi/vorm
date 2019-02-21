#!/bin/sh
#---------------------------------#
# update passwdfile               #
#       Authored by Y.Miyamoto    #
#---------------------------------#
#-----#
# env # 
#-----#
. `dirname $0`/../cfg/set_env.sh
. `dirname $0`/../cfg/set_function.sh

MY_NAME=`basename $0`
EXEC_NAME=`echo ${MY_NAME} | awk -F'.' '{print $2}'`

#------#
# main #
#------#
echo -e "\n***** Start : ${MY_NAME} Start *****"

#--- key ---#
echo -e "\n 暗号鍵ファイルをフルパス指定"
func_object
export TGT_KEY=${TGT_DIR}

echo -e "\n 暗号化対象ファイルの格納ディレクトリを指定"
echo -e " 暗号化対象は「user」で始まるファイルです・・・ご注意を"
func_object
if [[ $? = ${SUCCESS} ]]; then
    cd ${TGT_DIR}
    ls | grep ^user | while read TGT_FILE
    do
        echo -e "\n #--- [ ${TGT_FILE} ] ---#"
        openssl rsautl -encrypt -inkey ${TGT_KEY} -in ${TGT_FILE}  > ${TGT_FILE}.2
        mv ${TGT_FILE}.2 ${TGT_FILE}
        chmod 700 ${TGT_FILE}
    done
fi

#-----#
# end #
#-----#
ls -ltr ${TGT_DIR} | grep user
echo -e "\n***** End   : ${MY_NAME} End *****"
