@echo off
REM 出力されたerrorテキストファイルの文頭にNがあればDOS窓に表示
REM ============================================
REM  ErrorConfirmPRG  
REM               Made by M.MAKOTO
REM ============================================

REM --環境変数を呼び出し--

call ..\..\EncryptWatch_with_loop\cfg\cfg.bat

REM --error.txt_0.txtの文頭からNを含む文字列を抽出--

type "%everything%" | find /V "Encrypted\NotEncrypted" | find /V "E"