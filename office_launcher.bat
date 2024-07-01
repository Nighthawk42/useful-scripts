@echo off
title Microsoft Office Launcher

echo ------------------------------------------------------------------------------
echo Script Name: office_launcher.bat
echo Description: This script provides a menu to launch various Microsoft Office 
echo              applications.
echo Requirements: Microsoft Office must be installed at the specified paths.
echo Author: Nighthawk42
echo ------------------------------------------------------------------------------

:menu
echo.
echo Select an application to launch:
echo 1. Microsoft Word
echo 2. Microsoft PowerPoint
echo 3. Microsoft Outlook
echo 4. Microsoft Excel
echo 5. Microsoft OneNote
echo 6. Microsoft Access
echo 7. Microsoft Teams
echo 0. Exit
echo.

set /p choice="Enter your choice (1-7 or 0 to exit): "

if "%choice%"=="1" goto launch_word
if "%choice%"=="2" goto launch_powerpoint
if "%choice%"=="3" goto launch_outlook
if "%choice%"=="4" goto launch_excel
if "%choice%"=="5" goto launch_onenote
if "%choice%"=="6" goto launch_access
if "%choice%"=="7" goto launch_teams
if "%choice%"=="0" goto end

echo Invalid choice. Please select a number between 1 and 7 or 0 to exit.
goto menu

:launch_word
start "" "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"
goto end

:launch_powerpoint
start "" "C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE"
goto end

:launch_outlook
start "" "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
goto end

:launch_excel
start "" "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"
goto end

:launch_onenote
start "" "C:\Program Files\Microsoft Office\root\Office16\ONENOTE.EXE"
goto end

:launch_access
start "" "C:\Program Files\Microsoft Office\root\Office16\MSACCESS.EXE"
goto end

:launch_teams
start "" "C:\Users\%USERNAME%\AppData\Local\Microsoft\Teams\current\Teams.exe"
goto end

:end
exit
