@echo off
setlocal enabledelayedexpansion

:: ������ɫ
color 0A

:: ��ʾ��Ϣ
echo ==============================================
echo.
echo   rclone �ű����ɹ���
echo.
echo ==============================================

:: ��ȡ�û�����
echo.
set /p source=������Դ·���� 
echo.
set /p destination=������Ŀ��·���� 
echo.
set /p proxy=�Ƿ���Ҫ����(y/n)��Ĭ��n 

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
echo rclone copy "%source%" "%destination%" --ignore-existing -u -v -P --transfers=20 --ignore-errors --buffer-size=128M --check-first --checkers=10 --drive-acknowledge-abuse
echo pause
) > work001.bat

:: ��ʾ�û�
echo.
echo ==============================================
echo �µĽű�������: work001.bat
echo ==============================================
pause
