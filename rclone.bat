@echo off
setlocal enabledelayedexpansion

:: ������ɫ
color 0A

:: ��ʾ��Ϣ
echo ==============================================
echo.
echo   rclone �ű����ɹ���
echo   https://d.99bilibili.eu.org/rclone
echo.
echo ==============================================

:: ��ȡ�û�����
echo.
set /p source=������Դ·��:
echo.
set /p destination=������Ŀ��·��:
echo.
set /p proxy=�Ƿ���Ҫ����(y/n):
if "%proxy%"=="" set proxy=n

:: ��ʾ�Ƿ����Ŀ��Ŀ¼�����е��ļ���Ĭ�Ϻ���
echo.
set /p ignore_existing=�Ƿ����Ŀ��Ŀ¼�����е��ļ���(y/n):
if "%ignore_existing%"=="" set ignore_existing=y

:: ��ʾͬʱ���е��ļ�����������Ĭ��6
echo.
set /p transfers=������ͬʱ���е��ļ���������(6-20):
if "%transfers%"=="" set transfers=6

:: ������д����bat�ű�����
(
echo @echo off
if /i "%proxy%"=="y" (
    echo set http_proxy=socks5://127.0.0.1:7890
    echo set https_proxy=socks5://127.0.0.1:7890
) else (
    echo set http_proxy=
    echo set https_proxy=
)
echo cd /d D:\rclone-v1.63.0-windows-amd64
if /i "%ignore_existing%"=="y" (
    echo rclone copy "%source%" "%destination%" --ignore-existing -u -v -P --transfers=%transfers% --ignore-errors --buffer-size=128M --check-first --checkers=10 --drive-acknowledge-abuse
) else (
    echo rclone copy "%source%" "%destination%" -u -v -P --transfers=%transfers% --ignore-errors --buffer-size=128M --check-first --checkers=10 --drive-acknowledge-abuse
)
echo pause
) > work001.bat

:: ��ʾ�û�
echo.
echo ==============================================
echo �µĽű�������: work001.bat
echo ==============================================
pause
