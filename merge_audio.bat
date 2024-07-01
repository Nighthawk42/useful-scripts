@echo off
setlocal enabledelayedexpansion

echo ------------------------------------------------------------------------------
echo Script Name: merge_audio.bat
echo Description: This script merges all audio files in the current directory into a 
echo              single file using FFmpeg. The user can select the output audio format.
echo Requirements: FFmpeg must be installed and available in the system's PATH.
echo Author: Nighthawk42
echo ------------------------------------------------------------------------------

REM Supported audio file extensions
set "audio_extensions=*.wav *.mp3 *.flac *.aac *.ogg"

REM Prompt the user to enter the output filename
set /p output_filename="Enter the output filename (without extension): "

REM List available audio formats
echo Select output audio format:
echo 1. WAV
echo 2. MP3
echo 3. FLAC
echo 4. AAC
echo 5. OGG

REM Prompt the user for the format choice
set /p "formatChoice=Enter the number corresponding to the desired format: "

REM Determine the chosen format
set "audio_format="
if %formatChoice%==1 set "audio_format=wav"
if %formatChoice%==2 set "audio_format=mp3"
if %formatChoice%==3 set "audio_format=flac"
if %formatChoice%==4 set "audio_format=aac"
if %formatChoice%==5 set "audio_format=ogg"

REM Validate the chosen format
if "%audio_format%"=="" (
    echo Invalid choice. Exiting...
    exit /b 1
)

REM Prepare the filelist.txt with the list of audio files
(for %%i in (%audio_extensions%) do (
    echo file '%%i'
)) > filelist.txt

REM Merge the audio files using ffmpeg
ffmpeg -f concat -safe 0 -i filelist.txt -c copy "%output_filename%.%audio_format%"

REM Clean up temporary filelist.txt
del filelist.txt

echo All audio files merged successfully into "%output_filename%.%audio_format%"
pause
