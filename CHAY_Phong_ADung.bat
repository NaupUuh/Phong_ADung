@echo off
chcp 65001 >nul
title Phong_ADung - Video Story Publisher V22.99
cd /d "%~dp0"

echo ==========================================================================
echo  PHONG_ADUNG - Phong_ADung - Video Story Publisher V22.99
echo  Thu muc : %~dp0
echo  Config  : %USERPROFILE%\.video_story_publisher_V22.99.json
echo  Cache   : %LOCALAPPDATA%\VideoStoryPublisher\V22.99\
echo ==========================================================================
echo.

rem --- Tim Python: uu tien venv cua may, roi Python 3.x da cai ---
set "PY="
for %%P in (
  "C:\ReverseEngineering\Scripts\venv\Scripts\python.exe"
  "C:\Users\Admin\AppData\Local\Programs\Python\Python313\python.exe"
  "C:\Users\Admin\AppData\Local\Programs\Python\Python312\python.exe"
  "C:\Users\Admin\AppData\Local\Programs\Python\Python314\python.exe"
) do (
  if not defined PY if exist %%P set "PY=%%~P"
)
if not defined PY (
  where py >nul 2>nul && set "PY=py -3"
)
if not defined PY (
  where python >nul 2>nul && set "PY=python"
)
if not defined PY (
  echo [LOI] Khong tim thay Python 3. Hay cai Python tu python.org roi chay lai.
  pause
  exit /b 1
)

rem --- ffmpeg: dua thu muc chua ffmpeg.exe vao PATH cho ca phien ---
set "FFDIR="
for %%D in (
  "%~dp0ffmpeg\bin"
  "%~dp0bin"
  "C:\ffmpeg-9.0.1-essentials_build\bin"
  "C:\ffmpeg\bin"
  "C:\Program Files\ffmpeg\bin"
) do (
  if not defined FFDIR if exist "%%~D\ffmpeg.exe" set "FFDIR=%%~D"
)
if defined FFDIR set "PATH=%FFDIR%;%PATH%"

%PY% "viet_drama_V22.99_stable_folder.py"
if errorlevel 1 (
    echo.
    echo [LOI] Tool thoat voi ma loi. Xem log:
    echo   %~dp0video_story_publisher_crash_V22.99.log
    pause
)
