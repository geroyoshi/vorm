@echo off
REM エンクリプションを監視するバッチファイル
REM ============================================
REM  EnryptWatchPRG  
REM               Made by M.MAKOTO
REM ============================================


REM --30秒に1度実行--

:loop

timeout /t 30


call ..\..\EncryptWatch_with_loop\cfg\cfg.bat


:Excute

REM --%everything%の中身がない場合エラーを表示させない--

type null > %everything% 2>&1


REM --GPを１つずつListEncryptedFiles.exeにかけて、出力したエラーとサクセスの結果を１つにまとめる--

for /f "delims=" %%s in (%GpPath%) do call ListEncryptedFiles.exe -directory "%%s" -nonEncryptedResults %SUCCESS% -encryptedResults %FALSE% | type %ErrorFile% >> %everything% | type %SuccessFile% >> %everything%


REM --FindFromEveryError.batとFindFromEverySuccess.batから入力を受け取る--

for /f %%i in ('FindFromEveryError.bat') do set ErrorResult=%%i

for /f %%j in ('FindFromEverySuccess.bat') do set SuccessResult=%%j


REM --エラー時に「1」をサクセス時には「0」を表示させる為に定義--

set one=,1

set zero=,0


REM --エラー箇所とサクセスをevery.txtファイルから検索--

for /f "tokens=1 delims=" %%k in ('FindFromEveryError.bat') do set ErrorPlace=%%k
for /f "tokens=4" %%l in ('FindFromEverySuccess.bat') do set SuccessPlace=%%l


REM --IF文で場合分け。「E」がある場合とない場合。--

if "%ErrorResult%"=="" (
    echo エラーは見つかりませんでした。全て正しく暗号化されています。
    echo "%SuccessPlace:~1,-1%%zero%"
    set ERROR=
) else if "%ErrorResult%"=="E" (
     echo エラーがあります。
     echo "%ErrorPlace:~37,-3%%one%"
) else (
     echo エラーは見つかりませんでした。全て正しく暗号化されています。
     echo "%SuccessPlace:~1,-1%%zero%"
     set ERROR=
)


REM --IF文で場合分け。「N」がある場合とない場合。--

if "%SuccessResult%"=="N" (
    echo "%SuccessPlace:~1,-1%%zero%"
) else if "%SuccessResult%"=="" (
    set SAFE=
    echo エラーがあります。
    echo "%ErrorPlace:~37,-3%%one%"
) else (
    echo エラーがあります
    echo "%ErrorPlace:~37,-3%%one%"
    set SAFE=
)


REM --ErrorResultとSuccessResultの中身をゼロにする処理--

set ErrorResult=
set SuccessResult=


REM --ここで上に戻る

goto loop
