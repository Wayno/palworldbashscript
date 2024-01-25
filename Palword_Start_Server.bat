@echo off
title Palworld Server Watchdog
echo DO NOT CLOSE THIS WINDOW!
echo.

REM Configuration
set "SteamCMD_Dir=Z:\gameservers\SteamCMD"
set "Server_Dir=Z:\gameservers\PalServer"
set "Executable_Dir=Z:\gameservers\PalServer"
set "Server_Executable=PalServer.exe"
set "SteamGameID=2394010"
set "Extracommands=-queryport=27016 EpicApp=PalServer"

REM Configuration for Restart
set "Restart_Hour=04"
set "Restart_Minute=00"

REM Log file
set "Log_File=server_watchdog.log"

REM Main loop
:main_loop
REM Get current time
for /f "tokens=1-2 delims=:" %%a in ("%time%") do (
    set "current_hour=%%a"
    set "current_minute=%%b"
)

REM Remove leading space from hour if it exists (for times like " 3:XX AM")
if "%current_hour:~0,1%"==" " set "current_hour=0%current_hour:~1,1%"

REM Check if it's time to restart
if "%current_hour%"=="%Restart_Hour%" (
    if "%current_minute%" geq "%Restart_Minute%" if "%current_minute%" leq "05" (
        echo It is time to restart the server.
        goto shutdown_server
    )
)

REM Existing server check and update code
tasklist /nh /fi "Imagename eq %Server_Executable%" | find "%Server_Executable%" > nul
if ERRORLEVEL 1 (
    echo Server is not running, calling :update_server.
    call :update_server
) else (
    cls
    echo Server is already running.
)

timeout /t 60
goto main_loop

REM Function to update the server
:update_server
echo [%date% %time%] Checking for server update...
echo [%date% %time%] Checking for server update... >> "%Log_File%"
start "" /b /w /high "%SteamCMD_Dir%\steamcmd.exe" +force_install_dir %Server_Dir% +login anonymous  +app_update %SteamGameID% validate +quit

if ERRORLEVEL 0 (
    echo [%date% %time%] Server updated successfully. Starting server...
    echo [%date% %time%] Server updated successfully. Starting server... >> "%Log_File%"
    cd "%Executable_Dir%"
    start "" /high "%Server_Executable%" %Extracommands%
    cls
) else (
    echo [%date% %time%] Server update failed. Check logs for details.
    echo [%date% %time%] Server update failed. Check logs for details. >> "%Log_File%"
)
exit /b

REM Function to shut down the server
:shutdown_server
echo [%date% %time%] Server already running. Shutting down...
echo [%date% %time%] Server already running. Shutting down... >> "%Log_File%"
taskkill /im "%Server_Executable%" /f /t
timeout /t 3
exit /b
