@echo off
REM �o�͂��ꂽerror�e�L�X�g�t�@�C���̕�����N�������DOS���ɕ\��
REM ============================================
REM  ErrorConfirmPRG  
REM               Made by M.MAKOTO
REM ============================================

REM --���ϐ����Ăяo��--

call ..\..\EncryptWatch_with_loop\cfg\cfg.bat

REM --error.txt_0.txt�̕�������N���܂ޕ�����𒊏o--

type "%everything%" | find /V "Encrypted\NotEncrypted" | find /V "E"