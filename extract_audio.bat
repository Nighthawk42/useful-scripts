@echo off
setlocal enabledelayedexpansion

echo ------------------------------------------------------------------------------
echo Script Name: extract_audio.bat
echo Description: This script extracts audio from all major video file formats in a 
echo              specified directory using FFmpeg. The user can select the output
echo              audio format.
echo Requirements: FFmpeg must be installed and available in the system's PATH.
echo Author: Nighthawk42
echo ------------------------------------------------------------------------------

REM Prompt the user to enter the directory path
set /p "source_dir=Enter the directory path containing video files: "

REM Check if the directory exists
if not exist "%source_dir%" (
    echo Directory not found: "%source_dir%"
    exit /b 1
)

REM List available audio formats
echo Select output audio format:
echo 1. AAC
echo 2. MP3
echo 3. WAV
echo 4. FLAC
echo 5. OGG

REM Prompt the user for the format choice
set /p "formatChoice=Enter the number corresponding to the desired format: "

REM Determine the chosen format
set "audio_format="
if %formatChoice%==1 set "audio_format=aac"
if %formatChoice%==2 set "audio_format=mp3"
if %formatChoice%==3 set "audio_format=wav"
if %formatChoice%==4 set "audio_format=flac"
if %formatChoice%==5 set "audio_format=ogg"

REM Validate the chosen format
if "%audio_format%"=="" (
    echo Invalid choice. Exiting...
    exit /b 1
)

REM Supported video file extensions
set "video_extensions=*.mkv *.mp4 *.avi *.mov *.flv *.wmv *.webm *.mpeg *.3gp"

REM Loop through all video files in the directory
for %%A in (%video_extensions%) do (
    if exist "%source_dir%\%%A" (
        REM Extract audio using ffmpeg
        ffmpeg -i "%source_dir%\%%A" -vn -c:a %audio_format% "%source_dir%\%%~nA.%audio_format%"
    )
)

echo Audio extraction complete.
pause
