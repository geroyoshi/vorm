@echo off
REM �G���N���v�V�������Ď�����o�b�`�t�@�C��
REM ============================================
REM  EnryptWatchPRG  
REM               Made by M.MAKOTO
REM ============================================


REM --30�b��1�x���s--

:loop

timeout /t 30


call ..\..\EncryptWatch_with_loop\cfg\cfg.bat


:Excute

REM --%everything%�̒��g���Ȃ��ꍇ�G���[��\�������Ȃ�--

type null > %everything% 2>&1


REM --GP���P����ListEncryptedFiles.exe�ɂ����āA�o�͂����G���[�ƃT�N�Z�X�̌��ʂ��P�ɂ܂Ƃ߂�--

for /f "delims=" %%s in (%GpPath%) do call ListEncryptedFiles.exe -directory "%%s" -nonEncryptedResults %SUCCESS% -encryptedResults %FALSE% | type %ErrorFile% >> %everything% | type %SuccessFile% >> %everything%


REM --FindFromEveryError.bat��FindFromEverySuccess.bat������͂��󂯎��--

for /f %%i in ('FindFromEveryError.bat') do set ErrorResult=%%i

for /f %%j in ('FindFromEverySuccess.bat') do set SuccessResult=%%j


REM --�G���[���Ɂu1�v���T�N�Z�X���ɂ́u0�v��\��������ׂɒ�`--

set one=,1

set zero=,0


REM --�G���[�ӏ��ƃT�N�Z�X��every.txt�t�@�C�����猟��--

for /f "tokens=1 delims=" %%k in ('FindFromEveryError.bat') do set ErrorPlace=%%k
for /f "tokens=4" %%l in ('FindFromEverySuccess.bat') do set SuccessPlace=%%l


REM --IF���ŏꍇ�����B�uE�v������ꍇ�ƂȂ��ꍇ�B--

if "%ErrorResult%"=="" (
    echo �G���[�͌�����܂���ł����B�S�Đ������Í�������Ă��܂��B
    echo "%SuccessPlace:~1,-1%%zero%"
    set ERROR=
) else if "%ErrorResult%"=="E" (
     echo �G���[������܂��B
     echo "%ErrorPlace:~37,-3%%one%"
) else (
     echo �G���[�͌�����܂���ł����B�S�Đ������Í�������Ă��܂��B
     echo "%SuccessPlace:~1,-1%%zero%"
     set ERROR=
)


REM --IF���ŏꍇ�����B�uN�v������ꍇ�ƂȂ��ꍇ�B--

if "%SuccessResult%"=="N" (
    echo "%SuccessPlace:~1,-1%%zero%"
) else if "%SuccessResult%"=="" (
    set SAFE=
    echo �G���[������܂��B
    echo "%ErrorPlace:~37,-3%%one%"
) else (
    echo �G���[������܂�
    echo "%ErrorPlace:~37,-3%%one%"
    set SAFE=
)


REM --ErrorResult��SuccessResult�̒��g���[���ɂ��鏈��--

set ErrorResult=
set SuccessResult=


REM --�����ŏ�ɖ߂�

goto loop
