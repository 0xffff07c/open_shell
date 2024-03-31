@echo off
setlocal enabledelayedexpansion

:menu
cls
@echo off
title rclone������

color 0a
echo.
echo ��ѡ�������
echo.
echo 1. �����ļ�
echo.
echo 2. ͬ���ļ�
echo.
echo 3. ��������
echo.
echo 4. �鿴���̸�Ŀ¼
echo.
echo 5. �鿴��ʷ��¼
echo.
echo 6. �˳�
echo.
echo.


set /p choice=�����������ţ�
echo.
if "%choice%"=="1" (
    call :copy_files
) else if "%choice%"=="2" (
    call :sync_files
) else if "%choice%"=="3" (
    call :mount_drive
) else if "%choice%"=="4" (
    call :view_drive_root
) else if "%choice%"=="5" (
    call :view_history
) else if "%choice%"=="6" (
    goto :eof
) else (
    echo ��Ч��ѡ�����������롣
    pause
    goto :menu
)

goto :menu

:copy_files
set /p source=������Դ�ļ�·����
set /p destination=������Ŀ���ļ�·��:

rclone copy "%source%" "%destination%" -u -v -P --transfers=20 --ignore-errors --buffer-size=128M --check-first --checkers=10 --drive-acknowledge-abuse
set /a line_count=0
for /f %%l in (history_commands.txt) do set /a line_count+=1
echo !line_count!. rclone copy "%source%" "%destination%" -u -v -P --transfers=20 --ignore-errors --buffer-size=128M --check-first --checkers=10 --drive-acknowledge-abuse >> history_commands.txt
pause
goto :eof

:sync_files
set /p source=������Դ�ļ�·����
set /p destination=������Ŀ���ļ�·��:

rclone sync "%source%" "%destination%" -u -v -P --transfers=20 --ignore-errors --buffer-size=128M --check-first --checkers=10 --drive-acknowledge-abuse
set /a line_count=0
for /f %%l in (history_commands.txt) do set /a line_count+=1
echo !line_count!. rclone sync "%source%" "%destination%" -u -v -P --transfers=20 --ignore-errors --buffer-size=128M --check-first --checkers=10 --drive-acknowledge-abuse >> history_commands.txt
pause
goto :eof

:mount_drive
set /p source=����������·����
set /p drive_letter=����������̷���
set /p cache_dir=�����뻺��Ŀ¼��

rclone mount "%source%" %drive_letter%: --vfs-cache-mode full --vfs-cache-max-size 100G --vfs-cache-max-age 1h --dir-cache-time 1h --poll-interval 10s --buffer-size 128M --vfs-read-ahead 256M --cache-dir "%cache_dir%"
set /a line_count=0
for /f %%l in (history_commands.txt) do set /a line_count+=1
echo !line_count!. rclone mount "%source%" %drive_letter%: --vfs-cache-mode full --vfs-cache-max-size 100G --vfs-cache-max-age 1h --dir-cache-time 1h --poll-interval 10s --buffer-size 128M --vfs-read-ahead 256M --cache-dir "%cache_dir%" >> history_commands.txt
pause
goto :eof

:view_drive_root
set /p source=����������·����

rclone lsd "%source%"
pause
goto :eof

:view_history
cls
echo ��ʷ��¼��
type history_commands.txt
echo.

set /p execute=������Ҫִ�е���ʷ��¼��ţ���Enter��������
if not "%execute%"=="" (
    set "found="
    for /f "tokens=1,* delims=." %%a in (history_commands.txt) do (
        if "%%a"=="%execute%" (
            set "command=%%b"
            set "found=1"
            call :execute_command
            goto :eof
        )
    )
    if not defined found (
        echo ��Ч����ʷ��¼��ţ����������롣
        pause
    )
)
goto :menu

:execute_command
cls
echo ����ִ����ʷ��¼���
echo %command%
%command%
pause
goto :eof

:eof
