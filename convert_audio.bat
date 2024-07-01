@echo off
setlocal enabledelayedexpansion

REM Display script information
echo ------------------------------------------------------------------------------
echo Script Name: convert_audio.bat
echo Description: This script converts all audio files in a specified source directory 
echo              to a chosen format using FFmpeg. The supported formats are MP3, OGG, 
echo              WAV, FLAC, and AAC.
echo Requirements: FFmpeg must be installed and available in the system's PATH.
echo Author: Nighthawk42
echo ------------------------------------------------------------------------------

REM Prompt the user for the source directory
set /p srcDir=Enter Source Directory: 

REM List available formats
echo Select Format.
echo 1. MP3
echo 2. OGG
echo 3. WAV
echo 4. FLAC
echo 5. AAC

REM Prompt the user for the format choice
set /p formatChoice=Enter the number corresponding to the desired format: 

REM Determine the chosen format
set format=
if %formatChoice%==1 set format=mp3
if %formatChoice%==2 set format=ogg
if %formatChoice%==3 set format=wav
if %formatChoice%==4 set format=flac
if %formatChoice%==5 set format=aac

REM Validate the chosen format
if "%format%"=="" (
    echo Invalid choice. Exiting...
    exit /b 1
)

REM Create the output directory
set outDir=%srcDir%\converted
mkdir "%outDir%"

REM Convert files while preserving audio quality
for %%f in ("%srcDir%\*.*") do (
    echo Converting "%%f" to "%outDir%\%%~nf.%format%"
    if %format%==mp3 (
        ffmpeg -i "%%f" -q:a 0 "%outDir%\%%~nf.%format%"
    ) else if %format%==ogg (
        ffmpeg -i "%%f" -q:a 10 "%outDir%\%%~nf.%format%"
    ) else if %format%==wav (
        ffmpeg -i "%%f" "%outDir%\%%~nf.%format%"
    ) else if %format%==flac (
        ffmpeg -i "%%f" -compression_level 12 "%outDir%\%%~nf.%format%"
    ) else if %format%==aac (
        ffmpeg -i "%%f" -b:a 320k "%outDir%\%%~nf.%format%"
    )
)

echo Conversion completed.
pause
