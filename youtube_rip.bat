@echo off
setlocal EnableDelayedExpansion

echo ------------------------------------------------------------------------------
echo Script Name: youtube_rip.bat
echo Description: This script downloads audio from a specified YouTube video URL 
echo              and converts it to the desired format using yt-dlp. Supported formats 
echo              include MP3, Ogg, WAV, FLAC, and AAC.
echo Requirements: yt-dlp must be installed and available in the system's PATH.
echo Author: Nighthawk42
echo ------------------------------------------------------------------------------

REM Prompt user for YouTube URL
set /p "youtube_url=Enter YouTube URL: "

REM Prompt user for desired format
echo Choose desired format:
echo 1. MP3
echo 2. Ogg
echo 3. WAV
echo 4. FLAC
echo 5. AAC
set /p "format_choice=Enter choice (1-5): "

REM Set format according to user choice
if "%format_choice%"=="1" (
    set "format=mp3"
) else if "%format_choice%"=="2" (
    set "format=ogg"
) else if "%format_choice%"=="3" (
    set "format=wav"
) else if "%format_choice%"=="4" (
    set "format=flac"
) else if "%format_choice%"=="5" (
    set "format=aac"
) else (
    echo Invalid choice. Exiting.
    exit /b
)

REM Call yt-dlp to download audio in specified format
yt-dlp --extract-audio --audio-format !format! "%youtube_url%"

echo Download complete.
pause
